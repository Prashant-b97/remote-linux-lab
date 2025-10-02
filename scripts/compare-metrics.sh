#!/usr/bin/env bash
# Compare two monitor.sh JSON snapshot files and highlight CPU/memory/disk deltas.
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "compare-metrics.sh: jq is required" >&2
  exit 1
fi

if [[ $# -ne 2 ]]; then
  echo "Usage: compare-metrics.sh BASELINE.json CURRENT.json" >&2
  exit 1
fi

BASELINE="$1"
CURRENT="$2"

for file in "$BASELINE" "$CURRENT"; do
  if [[ ! -f "$file" ]]; then
    echo "compare-metrics.sh: file not found: $file" >&2
    exit 1
  fi
done

summarise() {
  jq -s '
    def safe_map(path): map(path) | map(select(. != null));
    def avg(v): (if (v | length) == 0 then null else (v | add / length) end);
    def max_or_null(v): (if (v | length) == 0 then null else (v | max) end);

    {
      samples: length,
      cpu_avg: avg(safe_map(.cpu.usage_percent)),
      cpu_max: max_or_null(safe_map(.cpu.usage_percent)),
      mem_avg: avg(safe_map(.memory.usage_percent)),
      mem_max: max_or_null(safe_map(.memory.usage_percent)),
      disk_avg: avg(safe_map(.disk.usage_percent)),
      disk_max: max_or_null(safe_map(.disk.usage_percent))
    }
  ' "$1"
}

BASE_SUMMARY="$(summarise "$BASELINE")"
CURR_SUMMARY="$(summarise "$CURRENT")"

jq -n --argjson base "$BASE_SUMMARY" \
       --argjson curr "$CURR_SUMMARY" '
  def delta(curr; base):
    if (curr == null or base == null) then null
    else (curr - base)
    end;

  {
    baseline: $base,
    current: $curr,
    deltas: {
      cpu_avg: delta($curr.cpu_avg; $base.cpu_avg),
      cpu_max: delta($curr.cpu_max; $base.cpu_max),
      mem_avg: delta($curr.mem_avg; $base.mem_avg),
      mem_max: delta($curr.mem_max; $base.mem_max),
      disk_avg: delta($curr.disk_avg; $base.disk_avg),
      disk_max: delta($curr.disk_max; $base.disk_max)
    }
  }
'
