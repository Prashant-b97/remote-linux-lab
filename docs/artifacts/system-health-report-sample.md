# Local System Health Report

- Generated at (UTC): 2025-10-02 01:43:54Z
- Hostname: sample-lab
- Kernel: Linux 6.8.0-xx-generic
- Uptime: 01:43:54 up 1 day,  1:43, 1 user, load average: 0.42, 0.58, 0.44
- Disk usage (/): 11Gi/40Gi (28%)
- Memory usage: 2.9Gi/4.0Gi
- Load average: 0.42, 0.58, 0.44
- Metrics sample: `system-metrics-2025-10-02T01-43-45Z.json`

## Recent Metrics (JSON)

The file `system-metrics-2025-10-02T01-43-45Z.json` contains five samples captured via `monitor.sh`.

```json
{
  "timestamp": "2025-10-02T01:43:45Z",
  "cpu": {"usage_percent": 27.39},
  "memory": {"total_mb": 4096, "used_mb": 2957, "available_mb": 1139, "usage_percent": 72.23},
  "disk": {"mount_point": "/", "total_gb": 40.00, "used_gb": 11.21, "free_gb": 28.79, "usage_percent": 28.03}
}
```

*(Truncated to keep the sample brief. CI artifacts include the full series.)*

## Recommended Next Steps

1. Attach this markdown and its JSON pair to pull requests as automation evidence.
2. Collect multiple snapshots and compare load/memory to spot regressions.
3. Customize the script with service-specific health checks before sharing.
