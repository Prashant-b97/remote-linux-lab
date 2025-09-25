#!/usr/bin/env bash
# Collect local CPU, memory, and disk metrics on a schedule and export them as JSON or CSV.
# Designed for beginners rehearsing monitoring fundamentals while still sounding professional in reports.
set -euo pipefail

FORMAT="json"
INTERVAL=5
COUNT=1
OUTPUT=""
MOUNT_PATH="/"
CPU_SAMPLING_GAP=1

METRIC_TIMESTAMP=""
CPU_USAGE=""
MEM_TOTAL_MB=""
MEM_USED_MB=""
MEM_AVAILABLE_MB=""
MEM_USAGE_PERCENT=""
DISK_TOTAL_GB=""
DISK_USED_GB=""
DISK_FREE_GB=""
DISK_USAGE_PERCENT=""
DISK_MOUNT_POINT=""

# Detect platform so we can fall back to macOS-friendly commands when /proc is missing.
OS_NAME="$(uname -s)"
case "$OS_NAME" in
  Linux) PLATFORM_ID="linux" ;;
  Darwin) PLATFORM_ID="darwin" ;;
  *) PLATFORM_ID="unknown" ;;
esac

# macOS sampling does not need the extra 1-second pause used with /proc deltas.
if [[ "$PLATFORM_ID" == "darwin" ]]; then
  CPU_SAMPLING_GAP=0
fi

usage() {
  cat <<'EOF'
Usage: monitor.sh [options]

Options:
  --format {json|csv}   Output format. Default: json (newline-delimited JSON objects).
  --interval SECONDS    Seconds between samples. Must be >= 1. Default: 5.
  --count N             Number of samples to capture. Use 0 to run until interrupted. Default: 1.
  --once                Alias for --count 1.
  --output PATH         Write results to PATH. Use '-' for stdout. Default: logs/system-metrics-<timestamp>.<ext>.
  --mount PATH          Filesystem path to inspect with df. Default: '/'.
  --help                Display this help and exit.

Examples:
  ./monitor.sh --format json --once
  ./monitor.sh --format csv --interval 10 --count 6
  ./monitor.sh --output - --count 0
EOF
}

die() {
  echo "monitor.sh: $1" >&2
  exit 1
}

is_integer() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format)
        [[ $# -lt 2 ]] && die "--format requires a value"
        FORMAT="$2"
        shift 2
        ;;
      --interval)
        [[ $# -lt 2 ]] && die "--interval requires a value"
        is_integer "$2" || die "--interval must be a positive integer"
        INTERVAL="$2"
        shift 2
        ;;
      --count)
        [[ $# -lt 2 ]] && die "--count requires a value"
        is_integer "$2" || die "--count must be a non-negative integer"
        COUNT="$2"
        shift 2
        ;;
      --once)
        COUNT=1
        shift
        ;;
      --output)
        [[ $# -lt 2 ]] && die "--output requires a value"
        OUTPUT="$2"
        shift 2
        ;;
      --mount)
        [[ $# -lt 2 ]] && die "--mount requires a value"
        MOUNT_PATH="$2"
        shift 2
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        die "unknown option: $1"
        ;;
    esac
  done

  case "$FORMAT" in
    json|csv) ;;
    *) die "--format must be 'json' or 'csv'" ;;
  esac

  if (( INTERVAL < 1 )); then
    die "--interval must be >= 1"
  fi
}

read_cpu_snapshot() {
  [[ -r /proc/stat ]] || die "/proc/stat not available; CPU metrics require a Linux-style /proc filesystem"
  local user nice system idle iowait irq softirq steal guest guest_nice
  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  local idle_all=$((idle + iowait))
  local non_idle=$((user + nice + system + irq + softirq + steal))
  local total=$((idle_all + non_idle))
  printf '%s %s\n' "$idle_all" "$total"
}

get_cpu_usage() {
  case "$PLATFORM_ID" in
    linux)
      local idle1 total1 idle2 total2 idle_diff total_diff
      read -r idle1 total1 <<<"$(read_cpu_snapshot)"
      sleep "$CPU_SAMPLING_GAP"
      read -r idle2 total2 <<<"$(read_cpu_snapshot)"
      idle_diff=$((idle2 - idle1))
      total_diff=$((total2 - total1))

      awk -v idle_diff="$idle_diff" -v total_diff="$total_diff" 'BEGIN {
        if (total_diff <= 0) {
          printf "0.00";
        } else {
          printf "%.2f", (1 - idle_diff / total_diff) * 100;
        }
      }'
      ;;
    darwin)
      local cores usage
      # ps on macOS reports per-core utilisation; normalise it so the number stays within 0-100%.
      cores=$(sysctl -n hw.ncpu 2>/dev/null || echo 1)
      usage=$(ps -A -o %cpu= 2>/dev/null | awk -v cores="$cores" 'BEGIN {sum=0} {sum+=$1} END {
        if (cores <= 0) {
          cores = 1;
        }
        if (NR == 0) {
          sum = 0;
        }
        val = sum / cores;
        if (val < 0) {
          val = 0;
        }
        if (val > 100) {
          val = 100;
        }
        printf "%.2f", val;
      }')
      if [[ -z "$usage" ]]; then
        usage="0.00"
      fi
      printf '%s' "$usage"
      ;;
    *)
      die "Unsupported platform for CPU metrics: $OS_NAME"
      ;;
  esac
}

# Read /proc/meminfo and convert to megabytes for Linux hosts.
set_memory_metrics_linux() {
  local mem_total_kb mem_available_kb mem_used_kb
  read -r mem_total_kb mem_available_kb <<<"$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {printf "%s %s", t, a}' /proc/meminfo)"
  mem_used_kb=$((mem_total_kb - mem_available_kb))

  MEM_TOTAL_MB="$(awk -v k="$mem_total_kb" 'BEGIN { printf "%.2f", k / 1024 }')"
  MEM_AVAILABLE_MB="$(awk -v k="$mem_available_kb" 'BEGIN { printf "%.2f", k / 1024 }')"
  MEM_USED_MB="$(awk -v k="$mem_used_kb" 'BEGIN { printf "%.2f", k / 1024 }')"
  MEM_USAGE_PERCENT="$(awk -v used="$mem_used_kb" -v total="$mem_total_kb" 'BEGIN {
    if (total <= 0) {
      printf "0.00";
    } else {
      printf "%.2f", (used / total) * 100;
    }
  }')"
}

# Use vm_stat output so we avoid restricted sysctl calls inside locked-down macOS sandboxes.
set_memory_metrics_darwin() {
  local page_size free_pages inactive_pages speculative_pages active_pages wired_pages total_pages total_bytes available_pages available_bytes used_bytes

  local vm_output
  vm_output=$(vm_stat 2>/dev/null) || die "vm_stat is required to calculate memory metrics on macOS"

  page_size=$(echo "$vm_output" | awk '/page size of/ {print $(NF-1)}')
  if [[ -z "$page_size" ]]; then
    page_size=$(sysctl -n hw.pagesize 2>/dev/null || echo 4096)
  fi

  read -r free_pages active_pages inactive_pages speculative_pages wired_pages <<<"$(echo "$vm_output" | awk -F':' '
    /Pages free/ {gsub(/[^0-9]/, "", $2); free=$2}
    /Pages active/ {gsub(/[^0-9]/, "", $2); active=$2}
    /Pages inactive/ {gsub(/[^0-9]/, "", $2); inactive=$2}
    /Pages speculative/ {gsub(/[^0-9]/, "", $2); spec=$2}
    /Pages wired down/ {gsub(/[^0-9]/, "", $2); wired=$2}
    END {printf "%s %s %s %s %s", free, active, inactive, spec, wired}
  ')"

  free_pages=${free_pages:-0}
  active_pages=${active_pages:-0}
  inactive_pages=${inactive_pages:-0}
  speculative_pages=${speculative_pages:-0}
  wired_pages=${wired_pages:-0}

  total_pages=$((free_pages + active_pages + inactive_pages + speculative_pages + wired_pages))
  total_bytes=$((total_pages * page_size))

  available_pages=$((free_pages + inactive_pages + speculative_pages))
  available_bytes=$((available_pages * page_size))
  if (( available_bytes > total_bytes )); then
    available_bytes=$total_bytes
  fi

  used_bytes=$((total_bytes - available_bytes))

  MEM_TOTAL_MB="$(awk -v b="$total_bytes" 'BEGIN { printf "%.2f", b / 1048576 }')"
  MEM_AVAILABLE_MB="$(awk -v b="$available_bytes" 'BEGIN { printf "%.2f", b / 1048576 }')"
  MEM_USED_MB="$(awk -v b="$used_bytes" 'BEGIN { printf "%.2f", b / 1048576 }')"
  MEM_USAGE_PERCENT="$(awk -v used="$used_bytes" -v total="$total_bytes" 'BEGIN {
    if (total <= 0) {
      printf "0.00";
    } else {
      printf "%.2f", (used / total) * 100;
    }
  }')"
}

set_memory_metrics() {
  case "$PLATFORM_ID" in
    linux)
      set_memory_metrics_linux
      ;;
    darwin)
      set_memory_metrics_darwin
      ;;
    *)
      die "Unsupported platform for memory metrics: $OS_NAME"
      ;;
  esac
}

# Accept both GNU (Linux) and BSD (macOS) df formats for disk usage.
set_disk_metrics() {
  local disk_line disk_size_k disk_used_k disk_avail_k disk_used_pct_raw disk_mount
  case "$PLATFORM_ID" in
    linux)
      if ! disk_line=$(df -k --output=size,used,avail,pcent,target "$MOUNT_PATH" 2>/dev/null | tail -n 1); then
        die "Unable to read disk usage for $MOUNT_PATH"
      fi
      ;;
    darwin)
      disk_line=$(df -k "$MOUNT_PATH" 2>/dev/null | awk 'NR==2 {print $2, $3, $4, $5, $9}')
      if [[ -z "$disk_line" ]]; then
        die "Unable to read disk usage for $MOUNT_PATH"
      fi
      ;;
    *)
      die "Unsupported platform for disk metrics: $OS_NAME"
      ;;
  esac

  read -r disk_size_k disk_used_k disk_avail_k disk_used_pct_raw disk_mount <<<"$disk_line"

  DISK_MOUNT_POINT="$disk_mount"
  DISK_TOTAL_GB="$(awk -v k="$disk_size_k" 'BEGIN { printf "%.2f", k / 1048576 }')"
  DISK_USED_GB="$(awk -v k="$disk_used_k" 'BEGIN { printf "%.2f", k / 1048576 }')"
  DISK_FREE_GB="$(awk -v k="$disk_avail_k" 'BEGIN { printf "%.2f", k / 1048576 }')"
  local disk_pct_clean=${disk_used_pct_raw%\%}
  DISK_USAGE_PERCENT="$(awk -v p="$disk_pct_clean" 'BEGIN { printf "%.2f", p }')"
}

collect_metrics() {
  METRIC_TIMESTAMP="$(date -u +%FT%TZ)"
  CPU_USAGE="$(get_cpu_usage)"
  set_memory_metrics
  set_disk_metrics
}

json_escape() {
  local s="${1//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  printf '%s' "$s"
}

emit_json() {
  cat <<EOF
{"timestamp":"$METRIC_TIMESTAMP","cpu":{"usage_percent":$CPU_USAGE},"memory":{"total_mb":$MEM_TOTAL_MB,"used_mb":$MEM_USED_MB,"available_mb":$MEM_AVAILABLE_MB,"usage_percent":$MEM_USAGE_PERCENT},"disk":{"mount_point":"$(json_escape "$DISK_MOUNT_POINT")","total_gb":$DISK_TOTAL_GB,"used_gb":$DISK_USED_GB,"free_gb":$DISK_FREE_GB,"usage_percent":$DISK_USAGE_PERCENT}}
EOF
}

csv_escape() {
  local s
  s=$(printf '%s' "$1" | sed 's/"/""/g')
  printf '"%s"' "$s"
}

emit_csv_line() {
  printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
    "$METRIC_TIMESTAMP" \
    "$CPU_USAGE" \
    "$MEM_TOTAL_MB" \
    "$MEM_USED_MB" \
    "$MEM_AVAILABLE_MB" \
    "$MEM_USAGE_PERCENT" \
    "$DISK_TOTAL_GB" \
    "$DISK_USED_GB" \
    "$DISK_FREE_GB" \
    "$DISK_USAGE_PERCENT" \
    "$(csv_escape "$DISK_MOUNT_POINT")"
}

output_line() {
  local line="$1"
  if [[ "$OUT_TARGET" == "/dev/stdout" ]]; then
    printf '%s\n' "$line"
  else
    printf '%s\n' "$line" >>"$OUT_TARGET"
  fi
}

write_header_if_needed() {
  if [[ "$FORMAT" != "csv" ]]; then
    return
  fi

  local header='timestamp,cpu_usage_percent,mem_total_mb,mem_used_mb,mem_available_mb,mem_usage_percent,disk_total_gb,disk_used_gb,disk_free_gb,disk_usage_percent,mount_point'

  if [[ "$OUT_TARGET" == "/dev/stdout" ]]; then
    output_line "$header"
    return
  fi

  if [[ ! -s "$OUT_TARGET" ]]; then
    output_line "$header"
  fi
}

main() {
  parse_args "$@"

  local timestamp token
  timestamp="$(date -u +%Y%m%d-%H%M%S)"
  if [[ -z "$OUTPUT" ]]; then
    mkdir -p logs
    OUTPUT="logs/system-metrics-${timestamp}.${FORMAT}"
  fi

  if [[ "$OUTPUT" == "-" ]]; then
    OUT_TARGET="/dev/stdout"
  else
    mkdir -p "$(dirname "$OUTPUT")"
    OUT_TARGET="$OUTPUT"
    : >"$OUT_TARGET"
  fi

  write_header_if_needed

  local samples_taken=0
  local sleep_after
  if (( INTERVAL > CPU_SAMPLING_GAP )); then
    sleep_after=$((INTERVAL - CPU_SAMPLING_GAP))
  else
    sleep_after=0
  fi

  while :; do
    collect_metrics

    if [[ "$FORMAT" == "json" ]]; then
      output_line "$(emit_json)"
    else
      output_line "$(emit_csv_line)"
    fi

    ((samples_taken++))
    if (( COUNT != 0 && samples_taken >= COUNT )); then
      break
    fi

    if (( sleep_after > 0 )); then
      sleep "$sleep_after"
    fi
  done

  if [[ "$OUT_TARGET" != "/dev/stdout" ]]; then
    echo "Saved metrics to $OUT_TARGET"
  fi
}

main "$@"
