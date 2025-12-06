#!/bin/bash

# Container Vulnerability Scanner
# Scans Docker containers for vulnerabilities using Trivy

set -e

REPORT_DIR="./scan-reports"
mkdir -p "$REPORT_DIR"

echo "======================================"
echo " Container Vulnerability Scanner"
echo "======================================"
echo ""

# Check if Trivy is installed
if ! command -v trivy &> /dev/null; then
    echo "❌ Trivy is not installed"
    echo "Install with: curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin"
    exit 1
fi

# Get list of running containers
echo "[INFO] Scanning running containers..."
CONTAINERS=$(docker ps --format "{{.Names}}")

if [ -z "$CONTAINERS" ]; then
    echo "❌ No running containers found"
    exit 0
fi

# Scan each container
for container in $CONTAINERS; do
    echo ""
    echo "Scanning: $container"
    echo "----------------------------------------"
    
    # Get image name
    IMAGE=$(docker inspect --format='{{.Config.Image}}' "$container")
    
    # Scan image
    REPORT_FILE="$REPORT_DIR/${container}_$(date +%Y%m%d).txt"
    trivy image --severity HIGH,CRITICAL "$IMAGE" | tee "$REPORT_FILE"
    
    echo "Report saved: $REPORT_FILE"
done

echo ""
echo "✅ Scan complete!"
echo "Reports in: $REPORT_DIR"
