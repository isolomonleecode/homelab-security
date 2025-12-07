# Security Hardening Implementation

**Security Assessment Phase 3: Risk Mitigation**

---

## Overview

Systematic hardening of homelab infrastructure based on vulnerability assessment findings. Implementation follows defense-in-depth principles and industry best practices.

---

## Container Security Hardening

### Docker Host Security

**1. Enable User Namespaces**
```bash
# /etc/docker/daemon.json
{
  "userns-remap": "default",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}

sudo systemctl restart docker
```

**Benefits:**
- Container root != host root
- Reduced privilege escalation risk
- Process isolation

**2. AppArmor/SELinux Profiles**
```bash
# Enable Docker default AppArmor profile
docker run --security-opt apparmor=docker-default nginx

# Custom profile for high-security containers
docker run --security-opt apparmor=custom-profile sensitive-app
```

### Container Best Practices

**Docker Compose Security Template:**
```yaml
version: '3.8'

services:
  secure-app:
    image: app:latest
    container_name: secure-app

    # Security hardening
    read_only: true  # Immutable filesystem
    security_opt:
      - no-new-privileges:true  # Prevent privilege escalation
      - apparmor:docker-default
    cap_drop:
      - ALL  # Drop all capabilities
    cap_add:
      - NET_BIND_SERVICE  # Only add required caps

    # Resource limits
    mem_limit: 512m
    cpus: 0.5
    pids_limit: 100

    # Network isolation
    networks:
      - app_network

    # Non-root user
    user: "1000:1000"

    # Secrets management
    secrets:
      - db_password

    # Health monitoring
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  app_network:
    driver: bridge
    internal: true  # No external access

secrets:
  db_password:
    external: true
```

**Checklist:**
- [ ] Non-root user in container
- [ ] Read-only filesystem where possible
- [ ] Minimal capabilities
- [ ] Resource limits configured
- [ ] Health checks implemented
- [ ] Secrets via Docker secrets or env files (not in compose)
- [ ] Custom bridge network (not default)

---

## Network Security Hardening

### Firewall Configuration

**UFW (Uncomplicated Firewall) Setup:**
```bash
# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (change default port)
sudo ufw allow 2222/tcp comment 'SSH custom port'

# Allow specific services from LAN only
sudo ufw allow from YOUR_NETWORK.0/24 to any port 80 proto tcp comment 'HTTP from LAN'
sudo ufw allow from YOUR_NETWORK.0/24 to any port 443 proto tcp comment 'HTTPS from LAN'

# Allow Tailscale
sudo ufw allow 41641/udp comment 'Tailscale'

# Enable firewall
sudo ufw enable
sudo ufw status verbose
```

**iptables Rules for Docker:**
```bash
# Prevent Docker from bypassing UFW
# /etc/ufw/after.rules

# BEGIN DOCKER CONTAINER RULES
*filter
:DOCKER-USER - [0:0]

# Allow established connections
-A DOCKER-USER -i eth0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow from LAN
-A DOCKER-USER -i eth0 -s YOUR_NETWORK.0/24 -j ACCEPT

# Drop all other traffic
-A DOCKER-USER -i eth0 -j DROP

COMMIT
# END DOCKER CONTAINER RULES
```

### Network Segmentation

**VLAN Implementation (if supported):**
```
VLAN 10: Management (Unraid, network gear)
VLAN 20: Services (containers, VMs)
VLAN 30: IoT Devices (isolated)
VLAN 40: Guest Network (no LAN access)
```

**Docker Network Isolation:**
```yaml
# Separate networks for different security zones
networks:
  frontend:  # Public-facing services
    driver: bridge
  backend:   # Database, internal services
    driver: bridge
    internal: true  # No internet access
  monitoring:  # Security monitoring
    driver: bridge
```

---

## Authentication & Access Control

### SSH Hardening

**/etc/ssh/sshd_config:**
```bash
# Network
Port 2222  # Non-standard port
ListenAddress YOUR_SERVER_IP
AddressFamily inet

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Security
Protocol 2
MaxAuthTries 3
MaxSessions 2
LoginGraceTime 30

# Algorithms
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Additional
X11Forwarding no
AllowAgentForwarding no
AllowTcpForwarding no
PermitTunnel no
```

**Restart SSH:**
```bash
sudo systemctl restart sshd
```

### Fail2Ban Configuration

**Install and Configure:**
```bash
sudo apt install fail2ban

# /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
destemail = YOUR_EMAIL@example.com
sendername = Fail2Ban

[sshd]
enabled = true
port = 2222
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3

sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Web Service Authentication

**Nginx Basic Auth:**
```bash
# Create password file
sudo htpasswd -c /etc/nginx/.htpasswd admin

# Nginx config
location / {
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://backend:8080;
}
```

**OAuth2 Proxy (Advanced):**
```yaml
# Use OAuth2 proxy for enterprise SSO
services:
  oauth2-proxy:
    image: quay.io/oauth2-proxy/oauth2-proxy
    command:
      - --http-address=0.0.0.0:4180
      - --upstream=http://grafana:3000
      - --email-domain=YOUR_DOMAIN.com
      - --provider=google
    environment:
      OAUTH2_PROXY_CLIENT_ID: YOUR_CLIENT_ID
      OAUTH2_PROXY_CLIENT_SECRET: YOUR_CLIENT_SECRET
      OAUTH2_PROXY_COOKIE_SECRET: RANDOM_SECRET
```

---

## Secrets Management

### Docker Secrets

```bash
# Create secret
echo "super_secret_password" | docker secret create db_password -

# Use in compose
services:
  database:
    image: postgres:15
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    external: true
```

### Environment Files

**Never commit .env to git!**
```bash
# .env file for docker-compose
DB_PASSWORD=ChangeMe
API_KEY=SecureRandomKey
JWT_SECRET=AnotherSecretKey

# .gitignore
*.env
*.env.local
secrets/
```

**Use .env.example as template:**
```bash
# .env.example (commit this)
DB_PASSWORD=CHANGE_ME
API_KEY=YOUR_API_KEY_HERE
JWT_SECRET=GENERATE_RANDOM_SECRET
```

---

## SSL/TLS Configuration

### Let's Encrypt with Nginx Proxy Manager

**Automatic Certificate Management:**
1. Add proxy host in NPM web UI
2. Enable "Force SSL"
3. Request Let's Encrypt certificate
4. Enable HTTP/2
5. Add HSTS header

**Manual Configuration:**
```nginx
# Strong SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_stapling on;
ssl_stapling_verify on;

# Security headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

### Self-Signed CA for Internal Services

```bash
# Create CA
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -days 3650 -key ca-key.pem -out ca.pem

# Create service certificate
openssl genrsa -out service-key.pem 4096
openssl req -new -key service-key.pem -out service.csr
openssl x509 -req -in service.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out service-cert.pem -days 365

# Trust CA on client machines
sudo cp ca.pem /usr/local/share/ca-certificates/homelab-ca.crt
sudo update-ca-certificates
```

---

## Application-Specific Hardening

### Nextcloud

```php
// config/config.php hardening
'overwrite.cli.url' => 'https://cloud.YOUR_DOMAIN.com',
'overwriteprotocol' => 'https',
'default_phone_region' => 'US',
'auth.bruteforce.protection.enabled' => true,
'ratelimit.protection.enabled' => true,
'check_data_directory_permissions' => true,
'enable_previews' => false,  // Reduce attack surface
'filesystem_check_changes' => 1,
```

**Enable 2FA:**
- Install TOTP app
- Enforce for admin users
- Document recovery codes

### Grafana

```ini
# /etc/grafana/grafana.ini
[server]
protocol = https
cert_file = /path/to/cert.pem
cert_key = /path/to/key.pem

[security]
admin_password = STRONG_PASSWORD_HERE
disable_gravatar = true
cookie_secure = true
cookie_samesite = strict
strict_transport_security = true

[users]
allow_sign_up = false
auto_assign_org_role = Viewer

[auth.anonymous]
enabled = false
```

### Wazuh

**Change Default Credentials:**
```bash
# Wazuh dashboard
curl -XPOST https://localhost:9200/_plugins/_security/api/account \
  -u admin:admin \
  -H 'Content-Type: application/json' \
  -d '{"current_password":"admin","password":"NEW_SECURE_PASSWORD"}'

# Wazuh API
docker exec -it wazuh-manager wazuh-control apiconfig
```

**Restrict Agent Enrollment:**
```xml
<!-- /var/ossec/etc/ossec.conf -->
<auth>
  <disabled>no</disabled>
  <port>1515</port>
  <use_source_ip>yes</use_source_ip>
  <force_insert>yes</force_insert>
  <force_time>0</force_time>
  <purge>yes</purge>
  <use_password>yes</use_password>
  <ssl_agent_ca>/var/ossec/etc/sslmanager.cert</ssl_agent_ca>
</auth>
```

---

## Patch Management

### Automated Updates

**Ubuntu/Debian:**
```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Configure /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Mail "YOUR_EMAIL@example.com";

# Enable
sudo dpkg-reconfigure -plow unattended-upgrades
```

**Docker Containers:**
```bash
# Watchtower for automated updates (use with caution)
docker run -d \
  --name watchtower \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --schedule "0 0 4 * * *" \
  --cleanup \
  --include-stopped
```

**Manual Update Script:**
```bash
#!/bin/bash
# update-containers.sh

echo "Pulling latest images..."
docker compose pull

echo "Recreating containers..."
docker compose up -d

echo "Cleaning up..."
docker image prune -af

echo "Update complete!"
docker compose ps
```

---

## Backup & Recovery

### Critical Data Backup

**3-2-1 Backup Strategy:**
- 3 copies of data
- 2 different media types
- 1 offsite copy

**Automated Backups:**
```bash
#!/bin/bash
# backup-critical-data.sh

BACKUP_DIR="/mnt/backup"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup Docker volumes
docker run --rm \
  -v nextcloud_data:/data \
  -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/nextcloud_$DATE.tar.gz /data

# Backup databases
docker exec postgres pg_dumpall -U postgres | gzip > $BACKUP_DIR/postgres_$DATE.sql.gz

# Backup configurations
tar czf $BACKUP_DIR/configs_$DATE.tar.gz /etc/docker /etc/nginx /etc/grafana

# Sync to offsite (Tailscale peer or cloud)
rsync -avz $BACKUP_DIR/ backup-server:/backups/homelab/

# Retention (keep 30 days)
find $BACKUP_DIR -type f -mtime +30 -delete
```

**Cron Schedule:**
```
0 2 * * * /usr/local/bin/backup-critical-data.sh >> /var/log/backup.log 2>&1
```

---

## Compliance Checklist

### CIS Docker Benchmark

- [x] 1.1.1 Ensure Docker daemon is not exposed over network
- [x] 1.1.2 Ensure the version of Docker is up to date
- [x] 2.1 Ensure network traffic is restricted between containers
- [x] 2.5 Ensure containers use only trusted images
- [x] 5.1 Ensure AppArmor profile is enabled
- [x] 5.7 Ensure privileged containers are not used
- [x] 5.10 Ensure memory usage for containers is limited
- [x] 5.15 Ensure the host's process namespace is not shared

### NIST CSF Implementation

**Protect (PR):**
- [x] Access control (PR.AC)
- [x] Data security (PR.DS)
- [x] Protective technology (PR.PT)

---

## Validation

### Security Testing

**1. Port Scan from External:**
```bash
nmap -sV -p- -T4 YOUR_PUBLIC_IP
# Expected: No open ports or only VPN
```

**2. SSL Test:**
```bash
sslscan YOUR_DOMAIN.com
# Expected: A+ rating, TLS 1.2+
```

**3. Docker Bench:**
```bash
docker run --rm --net host --pid host --cap-add audit_control \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  docker/docker-bench-security
# Expected: PASS on critical checks
```

**4. Access Control Test:**
```bash
# Attempt unauthorized access
curl -I https://YOUR_SERVICE.com
# Expected: 401 Unauthorized
```

---

## Hardening Summary

**Implemented Controls:**
- ✅ Container security (user namespaces, capabilities, resources)
- ✅ Network segmentation (VLANs, Docker networks)
- ✅ Authentication hardening (SSH, 2FA, strong passwords)
- ✅ Encryption (SSL/TLS, HTTPS everywhere)
- ✅ Access control (firewalls, fail2ban)
- ✅ Patch management (automated updates)
- ✅ Backup & recovery (3-2-1 strategy)

**Security Posture:**
- Before: Medium risk (default configs, exposed services)
- After: Low risk (defense-in-depth, continuous monitoring)

---

**Previous:** [← Vulnerability Assessment](02-vulnerability-assessment.md)
**Next:** [Monitoring & Logging →](04-monitoring-logging.md)
