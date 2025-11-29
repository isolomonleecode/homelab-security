#!/bin/bash

# Wazuh Admin Password Change Script
# Changes the admin password for Wazuh Dashboard

set -e

# Check if new password provided
if [ -z "$1" ]; then
    echo "Usage: $0 <new_password>"
    echo "Example: $0 MyNewSecurePassword123"
    exit 1
fi

NEW_PASSWORD="$1"
WAZUH_DIR="$(dirname "$0")/wazuh-docker/single-node"

echo "[INFO] Generating bcrypt hash for new password..."
# Generate bcrypt hash using httpd container
HASH=$(docker run --rm httpd:2.4-alpine htpasswd -bnBC 12 "" "$NEW_PASSWORD" | tr -d ':\n' | sed 's/\$/\\$/g')

echo "[INFO] Hash generated: ${HASH:0:20}..."

echo "[INFO] Backing up current internal_users.yml..."
cp "$WAZUH_DIR/config/wazuh_indexer/internal_users.yml" \
   "$WAZUH_DIR/config/wazuh_indexer/internal_users.yml.backup.$(date +%Y%m%d_%H%M%S)"

echo "[INFO] Updating admin password hash..."
# Update the admin hash in internal_users.yml
sed -i "/^admin:/,/^  hash:/ s|hash:.*|hash: \"$HASH\"|" \
    "$WAZUH_DIR/config/wazuh_indexer/internal_users.yml"

echo "[INFO] Restarting Wazuh indexer to apply changes..."
cd "$WAZUH_DIR"
docker compose restart wazuh.indexer

echo "[INFO] Waiting for indexer to be ready..."
sleep 10

echo "✅ Admin password changed successfully!"
echo ""
echo "New credentials:"
echo "  Username: admin"
echo "  Password: $NEW_PASSWORD"
echo "  Dashboard: https://192.168.0.52"
echo ""
echo "⚠️  Backup saved to: config/wazuh_indexer/internal_users.yml.backup.*"
