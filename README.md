# Homelab Security Hardening

[![Security](https://img.shields.io/badge/Security-Hardened-green.svg)](https://github.com/isolomonleecode/homelab-security-hardening)
[![CompTIA](https://img.shields.io/badge/CompTIA-Security%2B-red.svg)](https://www.comptia.org/certifications/security)
[![Docker](https://img.shields.io/badge/Docker-Security-blue.svg)](https://www.docker.com/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Grafana%20%2B%20Wazuh-orange.svg)](https://grafana.com/)

**Security configurations, monitoring, and automation for production homelab environments**

---

## 🎯 Overview

Complete security implementation for homelabs running containerized services and VMs. Includes vulnerability scanning, SIEM integration, automated monitoring, and security orchestration.

**Key Features:**
- 🔒 Container vulnerability scanning (Trivy)
- 📊 Security monitoring dashboards (Grafana + Wazuh)
- 🤖 Automated incident response (n8n SOAR)
- 📝 Centralized logging (Promtail + Loki)
- 🛡️ Network security (Pi-hole DNS filtering)

---

## 📦 What's Included

### Configurations (`configs/`)

#### Grafana Dashboards
- **security-monitoring-dashboard.json** - Real-time security metrics, failed logins, container health
- **README.md** - Dashboard import guide

#### Promtail (Log Shipping)
- **linux-workstation.yml** - Log collection for Linux systems
- Ships logs to Loki for centralized analysis
- Captures: SSH, sudo, Docker containers, systemd

#### Pi-hole (DNS Security)
- **local-dns-template.conf** - Local DNS configuration
- Internal network DNS resolution
- Tailscale MagicDNS integration

#### n8n SOAR (Security Automation)
- **deploy-n8n.sh** - Automated deployment script
- **WAZUH-INTEGRATION-GUIDE.md** - Complete integration guide
- Webhook-based alert handling
- Automated incident response workflows

### Scripts (`scripts/`)

#### Container Security
- **scan-containers.sh** - Vulnerability scanning with Trivy
- Generates reports for all running containers
- Identifies HIGH/CRITICAL CVEs

#### Monitoring Setup
- **setup-monitoring.sh** - Universal Promtail deployment
- Auto-detects OS (Ubuntu/Debian/Arch)
- Configures systemd service
- Ships logs to Loki

---

## 🚀 Quick Start

### 1. Container Vulnerability Scanning

```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan all containers
cd scripts/
./scan-containers.sh

# View reports
ls scan-reports/
```

### 2. Deploy Log Monitoring

```bash
# Edit Loki URL in script
nano scripts/setup-monitoring.sh
# Change: LOKI_URL="http://YOUR_LOKI_IP:3100"

# Run setup
sudo ./scripts/setup-monitoring.sh

# Verify
sudo systemctl status promtail
```

### 3. Import Grafana Dashboard

```bash
# Navigate to Grafana UI
# Settings → Data Sources → Add Loki
# Dashboards → Import → Upload configs/grafana/security-monitoring-dashboard.json
```

### 4. Deploy n8n SOAR

```bash
# Edit deployment script
nano configs/n8n/deploy-n8n.sh
# Set: UNRAID_IP="YOUR_SERVER_IP"

# Deploy
./configs/n8n/deploy-n8n.sh

# Access n8n at http://YOUR_IP:5678
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Homelab Security Stack                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐           │
│  │ Pi-hole  │──▶│ Promtail │──▶│   Loki   │           │
│  │   DNS    │   │   Logs   │   │ Storage  │           │
│  └──────────┘   └──────────┘   └────┬─────┘           │
│                                       │                  │
│  ┌──────────┐   ┌──────────┐        ▼                  │
│  │  Wazuh   │──▶│  n8n     │   ┌──────────┐           │
│  │   SIEM   │   │  SOAR    │──▶│ Grafana  │           │
│  └──────────┘   └──────────┘   │Dashboard │           │
│                                  └──────────┘           │
└─────────────────────────────────────────────────────────┘
```

**Data Flow:**
1. **Promtail** collects logs from all devices
2. **Loki** stores logs centrally
3. **Grafana** visualizes metrics and security events
4. **Wazuh** triggers alerts based on rules
5. **n8n** automates incident response

---

## 📖 Documentation

### Configuration Guides

- [**Wazuh + n8n SOAR Integration**](configs/n8n/WAZUH-INTEGRATION-GUIDE.md) - Complete webhook setup, alert routing, automated playbooks
- [**Grafana Dashboard Guide**](configs/grafana/README.md) - Dashboard import and customization
- [**Scripts README**](scripts/README.md) - Usage guide for all automation scripts

### Monitoring Dashboards

**Security Monitoring Dashboard:**
- Failed SSH attempts
- Sudo authentication events
- Container update status
- System resource usage
- Real-time security alerts

---

## 🛡️ Security Features

### Vulnerability Management
- **Trivy scanning** for container images
- **CVE tracking** with severity ratings
- **Automated reports** for compliance

### Logging & Detection
- **Centralized logging** with Loki
- **Failed authentication tracking**
- **Privilege escalation monitoring**
- **Container anomaly detection**

### Incident Response
- **Automated alert handling** via n8n
- **Severity-based routing** (Critical/High/Medium)
- **Multi-channel notifications** (Discord/Slack/Email)
- **Threat intelligence enrichment** (VirusTotal, AbuseIPDB)

### Network Security
- **Pi-hole DNS filtering**
- **Tailscale VPN** integration
- **Local DNS resolution**

---

## 🔧 Customization

All configs use placeholders for easy customization:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `YOUR_LOKI_IP` | Loki server IP | `192.168.1.100` |
| `YOUR_HOSTNAME` | Device hostname | `workstation` |
| `WAZUH_IP` | Wazuh manager IP | `192.168.1.50` |
| `N8N_IP` | n8n server IP | `192.168.1.51` |
| `YOUR_NETWORK` | Network prefix | `192.168.1` |

**To customize:**
1. Clone this repository
2. Find/replace placeholders with your values
3. Deploy configurations
4. Never commit your actual IPs/hostnames to git!

---

## 💻 Supported Platforms

### Operating Systems
- ✅ Ubuntu/Debian (tested)
- ✅ Arch Linux (tested)
- ✅ Unraid (Docker containers)
- ⚠️ macOS (limited support)
- ⚠️ Windows (via WSL or containers)

### Infrastructure
- Docker containers (primary focus)
- KVM/QEMU VMs
- Bare metal Linux servers

---

## 📊 Skills Demonstrated

**Technical:**
- Linux system hardening
- Docker container security
- Vulnerability assessment & management
- SIEM deployment (Wazuh)
- SOAR automation (n8n)
- Log aggregation & analysis
- Network security (DNS filtering)
- Security automation & scripting

**Frameworks:**
- NIST Cybersecurity Framework
- CIS Benchmarks (Docker, Linux)
- Defense in Depth
- Zero Trust principles

**Tools:**
- Wazuh SIEM
- Grafana & Prometheus & Loki
- Trivy vulnerability scanner
- n8n workflow automation
- Pi-hole DNS
- Promtail log shipper

---

## 🤝 Contributing

This is a personal homelab security project, but feel free to:

1. **Fork** this repository
2. **Customize** for your environment
3. **Share** improvements via pull requests
4. **Report** issues or suggestions

**Please:**
- Remove personal data before committing
- Use placeholders for environment-specific values
- Test configs before submitting PRs

---

## 📜 License

MIT License - Use freely in your homelab!

---

## 📞 Contact

**GitHub:** [@isolomonleecode](https://github.com/isolomonleecode)

**Author:** isolomonlee | **Certifications:** CompTIA Security+

---

**Disclaimer:** This is a personal homelab environment. All security testing is conducted on systems I own and operate. Always obtain proper authorization before security testing.

**Last Updated:** December 6, 2025
