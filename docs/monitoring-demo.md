# Monitoring Dashboard Demo

Spin up Prometheus, Node Exporter, and Grafana locally to mirror the observability stories you tell during interviews. Everything runs via Docker Compose so the stack tears down cleanly after practice sessions.

## Prerequisites

- Docker Desktop or Docker Engine + Compose Plugin
- Optional: `./scripts/monitor.sh` to generate additional sample metrics

## Launch the stack

```bash
cd monitoring
docker compose up -d
```

Services exposed:

- Prometheus — http://localhost:9090
- Node Exporter — http://localhost:9100/metrics
- Grafana — http://localhost:3000 (login: `lab` / `lab`)

First login to Grafana using the provided credentials and change the password if you plan to keep the stack running longer than a demo.

## Wire Prometheus into Grafana

1. Open **Configuration → Data sources** in Grafana.
2. Add **Prometheus** with URL `http://prometheus:9090`.
3. Save & test. Grafana confirms the connection.

Now import a starter dashboard:

1. Navigate to **Dashboards → New → Import**.
2. Use Grafana.com dashboard ID `1860` (Node Exporter Full) or upload your favourite JSON.
3. Select the Prometheus data source you created.
4. Explore CPU, memory, filesystem, and network panels.

## Quick htop-style snapshots

If you prefer a lightweight demo, capture a terminal recording of `htop` inside the Docker lab or Vagrant VM:

```bash
docker build -t remote-linux-lab .
docker run --rm -it remote-linux-lab:latest htop
```

Use macOS `Cmd+Shift+4` or Linux `gnome-screenshot` to grab still images and drop them under `docs/media/` (ignored by git). Reference them in portfolios or slide decks.

## Tear down

```bash
cd monitoring
docker compose down -v
```

This removes containers and the Grafana volume so you start fresh next time.
