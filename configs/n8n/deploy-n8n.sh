#!/bin/bash

# n8n SOAR Deployment Script
# Deploys n8n workflow automation for Wazuh SIEM integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNRAID_IP="YOUR_UNRAID_IP"  # e.g., 192.168.1.100
UNRAID_HOSTNAME="YOUR_UNRAID_HOSTNAME"  # e.g., unraid

echo "========================================="
echo "n8n SOAR Deployment for Wazuh Integration"
echo "========================================="
echo ""

# Check if running on Unraid or need to deploy remotely
if [ "$(hostname)" != "$UNRAID_HOSTNAME" ]; then
    echo "[INFO] Deploying to Unraid server at $UNRAID_IP..."
    
    # Copy files to Unraid
    echo "[INFO] Copying deployment files to Unraid..."
    ssh root@$UNRAID_IP "mkdir -p /mnt/user/appdata/n8n-soar"
    scp "$SCRIPT_DIR/docker-compose.yml" root@$UNRAID_IP:/mnt/user/appdata/n8n-soar/
    
    # Deploy on Unraid
    echo "[INFO] Starting n8n container on Unraid..."
    ssh root@$UNRAID_IP "cd /mnt/user/appdata/n8n-soar && docker compose up -d"
    
    echo ""
    echo "✅ n8n deployed successfully on Unraid!"
else
    # Running directly on Unraid
    echo "[INFO] Deploying locally on Unraid..."
    cd "$SCRIPT_DIR"
    docker compose up -d
fi

echo ""
echo "========================================="
echo "n8n SOAR Access Information"
echo "========================================="
echo "URL: http://$UNRAID_IP:5678"
echo "Username: admin"
echo "Password: CHANGE_ME_SECURE_PASSWORD"
echo ""
echo "Webhook endpoint for Wazuh:"
echo "http://$UNRAID_IP:5678/webhook/wazuh-alerts"
echo ""
echo "========================================="
echo "Next Steps:"
echo "========================================="
echo "1. Access n8n at http://$UNRAID_IP:5678"
echo "2. Create your first workflow"
echo "3. Configure Wazuh integration webhook"
echo "4. Set up automated alert notifications"
echo ""
