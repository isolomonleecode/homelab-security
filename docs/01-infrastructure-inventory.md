# Infrastructure Inventory & Asset Management

**Security Assessment Phase 1: Asset Discovery**

---

## Overview

Complete inventory of homelab infrastructure for security assessment and hardening. This baseline establishes the attack surface and identifies all assets requiring protection.

---

## Infrastructure Components

### Hypervisor Platform

**Platform:** Unraid 6.x Server
**Role:** Primary hypervisor and storage server
**Management:** Web UI on port 80/443
**Services:** Docker containers, KVM VMs, SMB shares

**Security Considerations:**
- Web interface exposure
- Container escape risks
- VM isolation
- Share permissions

---

## Containerized Services Inventory

### Total Containers: 25+

#### Media & Entertainment
| Service | Purpose | Ports | Attack Surface |
|---------|---------|-------|----------------|
| Jellyfin | Media streaming | 8096 | Web interface, API |
| Sonarr | TV automation | 8989 | Web UI, API |
| Radarr | Movie automation | 7878 | Web UI, API |
| Lidarr | Music automation | 8686 | Web UI, API |
| Prowlarr | Indexer manager | 9696 | Web UI, API |

**Risk Assessment:** Medium - Internet-facing services, credential management

#### Infrastructure Services
| Service | Purpose | Ports | Attack Surface |
|---------|---------|-------|----------------|
| Pi-hole | DNS & ad blocking | 53, 80 | DNS queries, web admin |
| Nginx Proxy Manager | Reverse proxy | 80, 443 | All proxied traffic |
| Nextcloud AIO | File sync/share | 443 | Web interface, WebDAV |

**Risk Assessment:** High - Core infrastructure, authentication required

#### Databases
| Service | Purpose | Ports | Attack Surface |
|---------|---------|-------|----------------|
| PostgreSQL | Nextcloud DB | 5432 | Database connections |
| MariaDB | Application DB | 3306 | Database connections |

**Risk Assessment:** Critical - Data storage, must be protected

#### Security & Monitoring
| Service | Purpose | Ports | Attack Surface |
|---------|---------|-------|----------------|
| Wazuh Manager | SIEM | 1514, 1515, 55000 | Agent connections, API |
| Wazuh Indexer | Log storage | 9200 | OpenSearch API |
| Wazuh Dashboard | Visualization | 443 | Web interface |
| Grafana | Monitoring dashboards | 3000 | Web interface, API |
| Prometheus | Metrics collection | 9090 | Scrape targets, API |
| Loki | Log aggregation | 3100 | Log ingestion API |

**Risk Assessment:** Critical - Security infrastructure must remain secure

---

## Virtual Machines

### Production VMs

**VM: YOUR_VM_NAME**
- OS: Ubuntu 22.04 LTS / Windows 11 / etc.
- vCPUs: X
- RAM: XGB
- Purpose: Development / Testing / Services
- Network: Bridged / NAT
- Exposed Services: SSH (22), HTTP (80), etc.

**Security Posture:**
- Firewall: Enabled/Disabled
- Updates: Automatic/Manual
- Monitoring: Yes/No

*Template - duplicate for each VM in your environment*

---

## Network Architecture

### Network Segments

**Primary Network:** `YOUR_NETWORK.0/24`
**VLAN Segmentation:** Implemented / Not Implemented
**Tailscale VPN:** Enabled (mesh network)

### Network Services

| Service | IP | Port | Purpose |
|---------|-----|------|---------|
| Router/Gateway | YOUR_NETWORK.1 | - | Network gateway |
| Unraid Server | YOUR_NETWORK.X | Various | Hypervisor |
| Pi-hole | YOUR_NETWORK.X | 53 | DNS server |
| Raspberry Pi | YOUR_NETWORK.X | Various | Monitoring agent |

**Firewall Rules:**
- Default: Deny all inbound
- Allowed: SSH from LAN
- Allowed: HTTP/HTTPS from LAN
- Allowed: Tailscale mesh traffic

---

## Attack Surface Analysis

### External Exposure

**Publicly Accessible:**
- [ ] None (recommended for homelab)
- [ ] Reverse proxy (Nginx) with specific services
- [ ] VPN only (Tailscale)

**VPN Access:**
- Tailscale mesh network
- Devices: Laptops, mobile devices, remote workstations
- Authentication: Multi-factor via Tailscale

### Internal Threats

**Risks:**
- Container escape → host compromise
- Lateral movement between containers
- Credential theft from web interfaces
- Database exposure

**Mitigations:**
- Network segmentation
- Least privilege container permissions
- Strong authentication
- Regular updates

---

## Asset Classification

### Critical Assets
- Wazuh SIEM (security visibility)
- PostgreSQL/MariaDB (data storage)
- Nextcloud (file storage)
- Backup systems

**Protection Required:**
- Real-time monitoring
- Automated backups
- Access controls
- Encryption at rest

### High-Value Assets
- Media servers (Jellyfin, *arr stack)
- Reverse proxy (Nginx)
- Pi-hole DNS

**Protection Required:**
- Regular updates
- Access logging
- Basic authentication

### Low-Risk Assets
- Test/development containers
- Non-production services

**Protection Required:**
- Standard hardening
- Periodic review

---

## Baseline Established

**Date:** [Your audit date]
**Total Assets:** 25+ containers, X VMs, Y network devices
**Next Steps:**
1. Vulnerability assessment (see [02-vulnerability-assessment.md](02-vulnerability-assessment.md))
2. Risk prioritization
3. Hardening implementation
4. Continuous monitoring

---

## Maintenance

**Review Frequency:** Quarterly
**Update Triggers:**
- New service deployment
- Infrastructure changes
- Security incidents
- Compliance requirements

**Inventory Tools:**
- `docker ps` - List running containers
- `virsh list --all` - List VMs
- `nmap -sn YOUR_NETWORK.0/24` - Network scan
- Asset management spreadsheet

---

**Next Document:** [Vulnerability Assessment →](02-vulnerability-assessment.md)
