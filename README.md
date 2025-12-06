# Homelab Security Hardening

[![Security](https://img.shields.io/badge/Security-Hardened-green.svg)](https://github.com/isolomonleecode/homelab-security-hardening)
[![CompTIA](https://img.shields.io/badge/CompTIA-Security%2B-red.svg)](https://www.comptia.org/certifications/security)
[![Docker](https://img.shields.io/badge/Docker-25%2B%20Containers-blue.svg)](https://www.docker.com/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Grafana%20%2B%20Wazuh-orange.svg)](https://grafana.com/)

**Author:** isolomonlee | **Certifications:** CompTIA Security+

---

## Overview

Systematic security audit, hardening, and monitoring implementation for a production homelab environment running 25+ containerized services and VMs.

**Objectives:**
- Comprehensive security audit of infrastructure
- Defense-in-depth security controls
- Continuous monitoring and vulnerability management
- Security+ and Network+ concepts in practice

---

## Infrastructure

### Environment
- **Platform:** Unraid 6.x server
- **Containers:** Docker (25+ services)
- **Virtualization:** KVM/QEMU VMs
- **Networking:** Tailscale VPN, Pi-hole DNS, Nginx proxy
- **Monitoring:** Grafana, Prometheus, Wazuh, Alloy

### Key Services
- Nextcloud AIO (file sync/share)
- Jellyfin (media streaming)
- Sonarr/Radarr/Lidarr (media automation)
- Pi-hole (DNS & ad blocking)
- PostgreSQL & MariaDB (databases)
- Nginx Proxy Manager (reverse proxy)
- Wazuh (SIEM & security monitoring)

---

## Security Implementation

### 1. Asset Management
- Complete infrastructure inventory
- Service mapping and dependencies
- Attack surface identification

### 2. Vulnerability Assessment
- Container image scanning (Trivy, Grype)
- Configuration reviews
- CVE tracking and remediation

### 3. Hardening
- Container security best practices
- Least privilege implementation
- Secure configuration baselines
- Secret management

### 4. Monitoring & Detection
- Grafana dashboards for security metrics
- Wazuh SIEM integration
- Log aggregation (Alloy)
- Anomaly detection
- Incident response preparation

### 5. Network Security
- Tailscale mesh VPN
- Pi-hole DNS filtering
- Network segmentation
- Certificate management

---

## Repository Structure

```
homelab-security-hardening/
├── SCRIPTS-README.md           # Info about relocated files
└── README.md                   # This file
```

**Privacy Notice:** All environment-specific files have been moved to the centralized vault:
- **configs/** - All configuration files (Tailscale domains, IPs, hostnames)
- **scripts/** - Deployment and automation scripts
- **sessions/** - Troubleshooting and session notes
- **findings/** - Security assessment results
- **AI/** - AI configurations

See [SCRIPTS-README.md](SCRIPTS-README.md) for vault location and details.

---

## Documentation

Full documentation is in the centralized vault:
```
/run/media/ssjlox/gamer/Documentation/Projects/homelab-security-hardening/
```

**Key Documentation:**
- Infrastructure inventory & baseline
- Security assessment findings
- Hardening implementation guides
- Monitoring & logging setup
- Platform-specific guides (macOS, Windows, Linux)
- Network & DNS configuration
- Wazuh SIEM deployment

See [INDEX.md](file:///run/media/ssjlox/gamer/Documentation/Projects/homelab-security-hardening/INDEX.md) for complete documentation index.

---

## Skills Demonstrated

**Technical:**
- Linux system hardening
- Docker container security
- Network security architecture
- Vulnerability assessment & management
- Security automation & scripting
- SIEM deployment & management
- Log analysis & monitoring

**Frameworks & Standards:**
- NIST Cybersecurity Framework
- CIS Benchmarks (Docker, Linux)
- Defense in Depth
- Zero Trust principles

**Tools:**
- Wazuh SIEM
- Grafana & Prometheus
- Docker security tools (Trivy, Grype)
- Pi-hole DNS
- Tailscale VPN
- Alloy log collector

---

## Monitoring Dashboards

### Security Monitoring
- Wazuh SIEM integration
- Real-time security alerts
- Vulnerability tracking
- Compliance monitoring

### Container Health
- Container update monitoring
- Resource utilization
- Health check tracking
- Automated alerts

### Infrastructure Metrics
- System performance
- Network traffic analysis
- Service availability
- Log aggregation

---

## Methodology

Industry-standard security assessment:

1. **Reconnaissance** - Document current state
2. **Vulnerability ID** - Automated & manual scanning
3. **Risk Analysis** - Prioritize by severity
4. **Remediation** - Implement controls
5. **Validation** - Verify fixes
6. **Monitoring** - Continuous posture tracking

---

## Learning Objectives

**Security+ Domains:**
- Attacks, Threats & Vulnerabilities
- Architecture & Design
- Implementation
- Operations & Incident Response
- Governance, Risk & Compliance

**Network+ Concepts:**
- Network segmentation
- DNS architecture & security
- VPN technologies
- Network monitoring

---

## Contact

GitHub: [@isolomonleecode](https://github.com/isolomonleecode)

---

**Disclaimer:** This is a personal homelab environment. All security testing is conducted on systems I own and operate.

**Last Updated:** December 6, 2025
