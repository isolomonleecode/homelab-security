#!/bin/bash

#
# HexStrike-AI Automated Setup Script
# Deploys HexStrike-AI MCP server to Kali VM
#
# Usage: ./setup-hexstrike-ai.sh [kali_vm_ip]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KALI_VM_IP="${1:-192.168.0.XX}"  # Replace XX with your Kali VM IP
KALI_USER="kali"
HEXSTRIKE_DIR="/home/kali/hexstrike-ai"
HEXSTRIKE_REPO="https://github.com/isolomonleecode/hexstrike-ai.git"

echo "========================================="
echo "HexStrike-AI Deployment Script"
echo "========================================="
echo ""
echo "Target: $KALI_USER@$KALI_VM_IP"
echo "Installation directory: $HEXSTRIKE_DIR"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if IP is still placeholder
if [[ "$KALI_VM_IP" == "192.168.0.XX" ]]; then
    log_error "Please provide the Kali VM IP address"
    echo "Usage: $0 <kali_vm_ip>"
    echo "Example: $0 192.168.0.100"
    exit 1
fi

# Check SSH connectivity
log_info "Checking SSH connectivity to Kali VM..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$KALI_USER@$KALI_VM_IP" "echo 'SSH OK'" &>/dev/null; then
    log_error "Cannot connect to $KALI_USER@$KALI_VM_IP via SSH"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Verify Kali VM is running"
    echo "2. Check IP address: ip addr"
    echo "3. Ensure SSH is enabled: sudo systemctl start ssh"
    echo "4. Copy SSH key: ssh-copy-id $KALI_USER@$KALI_VM_IP"
    exit 1
fi

log_info "SSH connectivity verified ✓"

# Create deployment script for remote execution
log_info "Creating remote deployment script..."

DEPLOY_SCRIPT=$(cat <<'DEPLOY_EOF'
#!/bin/bash

set -e

echo "[*] Starting HexStrike-AI setup on Kali VM"

# Update package list
echo "[*] Updating package list..."
sudo apt update -qq

# Install system dependencies
echo "[*] Installing system dependencies..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    build-essential \
    chromium \
    chromium-driver

# Install core security tools (if not already installed)
echo "[*] Verifying security tools installation..."
TOOLS=(nmap masscan rustscan nuclei subfinder amass sqlmap wpscan nikto gobuster ffuf hydra john binwalk radare2 ghidra)

for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "  - Installing $tool..."
        sudo apt install -y "$tool" || echo "  ! $tool not available in apt, skipping"
    else
        echo "  ✓ $tool already installed"
    fi
done

# Install Go tools
echo "[*] Installing Go-based security tools..."
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Create Go directories
mkdir -p $GOPATH/bin

# Install ProjectDiscovery tools
if ! command -v subfinder &> /dev/null; then
    echo "  - Installing subfinder..."
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
fi

if ! command -v nuclei &> /dev/null; then
    echo "  - Installing nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
fi

if ! command -v httpx &> /dev/null; then
    echo "  - Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
fi

# Clone HexStrike-AI repository
echo "[*] Cloning HexStrike-AI repository..."
if [ -d "$HOME/hexstrike-ai" ]; then
    echo "  ! Directory already exists, pulling latest changes..."
    cd $HOME/hexstrike-ai
    git pull
else
    cd $HOME
    git clone https://github.com/isolomonleecode/hexstrike-ai.git
    cd hexstrike-ai
fi

# Create Python virtual environment
echo "[*] Creating Python virtual environment..."
python3 -m venv hexstrike-env
source hexstrike-env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install Python dependencies
echo "[*] Installing Python dependencies..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "  ! requirements.txt not found, installing core dependencies..."
    pip install fastapi uvicorn requests beautifulsoup4 lxml
fi

# Create configuration file
echo "[*] Creating configuration file..."
if [ ! -f "config.yml" ]; then
    cat > config.yml <<'CONFIG_EOF'
server:
  host: 0.0.0.0
  port: 8888
  debug: false

security:
  rate_limit: 100
  max_concurrent_scans: 5
  timeout: 3600

logging:
  level: INFO
  file: /var/log/hexstrike-ai/server.log
  audit: true

agents:
  intelligent_decision_engine: true
  bugbounty_workflow_manager: true
  ctf_workflow_manager: true
  cve_intelligence_manager: true
  ai_exploit_generator: true
  vulnerability_correlator: true
  technology_detector: true
  rate_limit_detector: true
  failure_recovery_system: true
  performance_monitor: true
  parameter_optimizer: true

tools:
  nmap:
    path: /usr/bin/nmap
    max_threads: 10
  nuclei:
    path: $(command -v nuclei || echo /usr/bin/nuclei)
    templates_dir: $HOME/nuclei-templates
  sqlmap:
    path: /usr/bin/sqlmap
    threads: 5
  subfinder:
    path: $(command -v subfinder || echo $HOME/go/bin/subfinder)
  amass:
    path: /usr/bin/amass
CONFIG_EOF
    echo "  ✓ Configuration file created"
else
    echo "  ! config.yml already exists, skipping"
fi

# Create log directory
echo "[*] Creating log directory..."
sudo mkdir -p /var/log/hexstrike-ai
sudo chown $USER:$USER /var/log/hexstrike-ai

# Download nuclei templates
echo "[*] Downloading nuclei templates..."
if [ ! -d "$HOME/nuclei-templates" ]; then
    nuclei -update-templates || echo "  ! Could not update nuclei templates"
fi

# Create systemd service file
echo "[*] Creating systemd service..."
sudo tee /etc/systemd/system/hexstrike-ai.service > /dev/null <<SERVICE_EOF
[Unit]
Description=HexStrike-AI MCP Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/hexstrike-ai
Environment="PATH=$HOME/hexstrike-ai/hexstrike-env/bin:$HOME/go/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=$HOME/hexstrike-ai/hexstrike-env/bin/python3 hexstrike_server.py --config config.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Reload systemd
sudo systemctl daemon-reload

echo ""
echo "========================================="
echo "HexStrike-AI Installation Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review configuration: nano $HOME/hexstrike-ai/config.yml"
echo "2. Start server: sudo systemctl start hexstrike-ai"
echo "3. Enable auto-start: sudo systemctl enable hexstrike-ai"
echo "4. Check status: sudo systemctl status hexstrike-ai"
echo "5. Test endpoint: curl http://localhost:8888/health"
echo ""
echo "Server will be accessible at: http://$(hostname -I | awk '{print $1}'):8888"
echo ""

DEPLOY_EOF
)

# Copy deployment script to Kali VM
log_info "Copying deployment script to Kali VM..."
echo "$DEPLOY_SCRIPT" | ssh "$KALI_USER@$KALI_VM_IP" "cat > /tmp/deploy-hexstrike.sh && chmod +x /tmp/deploy-hexstrike.sh"

# Execute deployment script on Kali VM
log_info "Executing deployment on Kali VM..."
echo ""
ssh -t "$KALI_USER@$KALI_VM_IP" "bash /tmp/deploy-hexstrike.sh"

echo ""
log_info "Deployment script execution completed"

# Test server accessibility
log_info "Testing server accessibility from host..."
sleep 3

if curl -s "http://$KALI_VM_IP:8888/health" > /dev/null 2>&1; then
    log_info "Server is accessible at http://$KALI_VM_IP:8888 ✓"
else
    log_warn "Server not yet accessible (may need to be started manually)"
    echo ""
    echo "To start the server, SSH into Kali VM and run:"
    echo "  cd $HEXSTRIKE_DIR"
    echo "  source hexstrike-env/bin/activate"
    echo "  python3 hexstrike_server.py --config config.yml"
    echo ""
    echo "Or start as service:"
    echo "  sudo systemctl start hexstrike-ai"
fi

echo ""
echo "========================================="
echo "HexStrike-AI Deployment Summary"
echo "========================================="
echo ""
echo "Installation location: $HEXSTRIKE_DIR"
echo "Configuration file: $HEXSTRIKE_DIR/config.yml"
echo "Server endpoint: http://$KALI_VM_IP:8888"
echo "Systemd service: hexstrike-ai.service"
echo ""
echo "Useful commands (run on Kali VM):"
echo ""
echo "  Start server:    sudo systemctl start hexstrike-ai"
echo "  Stop server:     sudo systemctl stop hexstrike-ai"
echo "  Server status:   sudo systemctl status hexstrike-ai"
echo "  View logs:       sudo journalctl -u hexstrike-ai -f"
echo "  Test endpoint:   curl http://localhost:8888/health"
echo ""
echo "Manual start (for testing):"
echo "  cd $HEXSTRIKE_DIR"
echo "  source hexstrike-env/bin/activate"
echo "  python3 hexstrike_server.py --config config.yml"
echo ""
echo "Next: Configure MCP client on your Arch workstation"
echo "See: HEXSTRIKE-AI-INTEGRATION.md"
echo ""

log_info "Deployment complete! 🚀"
