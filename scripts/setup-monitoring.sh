#!/bin/bash

# Universal Monitoring Setup Script
# Deploys Promtail for log shipping to Loki

set -e

LOKI_URL="http://YOUR_LOKI_IP:3100"  # Update with your Loki server IP
HOSTNAME=$(hostname)

echo "======================================"
echo " Homelab Monitoring Setup"
echo "======================================"
echo ""
echo "Hostname: $HOSTNAME"
echo "Loki URL: $LOKI_URL"
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect OS"
    exit 1
fi

# Install Promtail based on OS
case "$OS" in
    ubuntu|debian)
        echo "[INFO] Installing Promtail for Debian/Ubuntu..."
        wget https://github.com/grafana/loki/releases/download/v2.9.0/promtail-linux-amd64.zip
        unzip promtail-linux-amd64.zip
        sudo mv promtail-linux-amd64 /usr/local/bin/promtail
        sudo chmod +x /usr/local/bin/promtail
        ;;
    arch)
        echo "[INFO] Installing Promtail for Arch Linux..."
        yay -S promtail-bin || paru -S promtail-bin
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        echo "Manually install Promtail from: https://grafana.com/docs/loki/latest/clients/promtail/"
        exit 1
        ;;
esac

# Create config file
echo "[INFO] Creating Promtail config..."
sudo mkdir -p /etc/promtail

sudo tee /etc/promtail/config.yml > /dev/null << YAML
server:
  http_listen_port: 9080
  grpc_listen_port: 0

clients:
  - url: ${LOKI_URL}/loki/api/v1/push

positions:
  filename: /tmp/positions.yaml

scrape_configs:
  - job_name: systemd-journal
    journal:
      max_age: 12h
      labels:
        job: systemd-journal
        hostname: ${HOSTNAME}
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'
YAML

# Create systemd service
echo "[INFO] Creating systemd service..."
sudo tee /etc/systemd/system/promtail.service > /dev/null << SERVICE
[Unit]
Description=Promtail Log Shipper
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/config.yml
Restart=always

[Install]
WantedBy=multi-user.target
SERVICE

# Enable and start
echo "[INFO] Starting Promtail..."
sudo systemctl daemon-reload
sudo systemctl enable promtail
sudo systemctl start promtail

echo ""
echo "✅ Monitoring setup complete!"
echo ""
echo "Check status: sudo systemctl status promtail"
echo "View logs: sudo journalctl -u promtail -f"
