# Homelab Security Scripts

Security automation and deployment scripts for homelab infrastructure.

## Container Security

### scan-containers.sh
**Purpose:** Scan all running Docker containers for vulnerabilities

**Requirements:**
- [Trivy](https://github.com/aquasecurity/trivy) vulnerability scanner
- Docker installed and running

**Usage:**
```bash
./scan-containers.sh
```

**Output:** Creates `scan-reports/` directory with vulnerability reports for each container

## Monitoring & Logging

### setup-monitoring.sh
**Purpose:** Deploy Promtail log shipper to send logs to Loki

**Requirements:**
- Loki server running (for centralized logging)
- Systemd-based Linux OS

**Configuration:**
Edit the script to set your Loki server IP:
```bash
LOKI_URL="http://YOUR_LOKI_IP:3100"
```

**Usage:**
```bash
sudo ./setup-monitoring.sh
```

**What it does:**
1. Detects OS (Ubuntu/Debian/Arch)
2. Installs Promtail
3. Creates config file at `/etc/promtail/config.yml`
4. Creates systemd service
5. Starts Promtail log shipping

**Verify:**
```bash
sudo systemctl status promtail
sudo journalctl -u promtail -f
```

## Customization

All scripts use placeholders for environment-specific values:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `YOUR_LOKI_IP` | Loki server IP | `192.168.1.100` |
| `YOUR_HOSTNAME` | Device hostname | `workstation` |

## Security Best Practices

- Review all scripts before running
- Never commit credentials to git
- Use environment variables for sensitive data
- Run with least privilege (only sudo when required)
- Keep Trivy database updated: `trivy image --download-db-only`

## License

MIT License - Use freely in your homelab!
