# Security Monitoring & Logging Implementation

**Security Assessment Phase 4: Continuous Visibility**

---

## Overview

Comprehensive monitoring and logging infrastructure for security event detection, incident response, and compliance. Implements centralized logging, real-time dashboards, and automated alerting.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Monitoring & Logging Stack                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Agents (Promtail, Wazuh)                               │
│         │                                                │
│         ▼                                                │
│  Aggregation (Loki, Wazuh Indexer)                      │
│         │                                                │
│         ▼                                                │
│  Visualization (Grafana, Wazuh Dashboard)               │
│         │                                                │
│         ▼                                                │
│  Alerting (n8n SOAR, Email, Discord)                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Log Aggregation with Loki & Promtail

### Loki Deployment

**Docker Compose:**
```yaml
version: '3.8'

services:
  loki:
    image: grafana/loki:latest
    container_name: loki
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yml:/etc/loki/local-config.yaml
      - loki-data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - monitoring
    restart: unless-stopped

volumes:
  loki-data:

networks:
  monitoring:
    driver: bridge
```

**Loki Configuration (`loki-config.yml`):**
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2024-01-01
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb:
    directory: /loki/index
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  retention_period: 720h  # 30 days

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: true
  retention_period: 720h
```

### Promtail Deployment

**See:** [configs/promtail/linux-workstation.yml](../configs/promtail/linux-workstation.yml)

**Key Features:**
- Docker container log collection
- Systemd journal monitoring
- SSH failed login extraction
- Sudo command logging
- Fail2ban ban events

**Deploy on Each Host:**
```bash
# Use the setup script
sudo ../scripts/setup-monitoring.sh

# Or manual Docker deployment
docker run -d \
  --name=promtail \
  --user root \
  -v /var/log:/var/log:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /run/log/journal:/run/log/journal:ro \
  -v $(pwd)/promtail-config.yml:/etc/promtail/config.yml \
  grafana/promtail:latest \
  -config.file=/etc/promtail/config.yml
```

---

## SIEM with Wazuh

### Wazuh Architecture

**Components:**
- Wazuh Manager: Agent management, rule engine
- Wazuh Indexer: OpenSearch for log storage
- Wazuh Dashboard: Web UI for analysis

**Deployment:**
See [configs/n8n/WAZUH-INTEGRATION-GUIDE.md](../configs/n8n/WAZUH-INTEGRATION-GUIDE.md) for complete setup.

### Agent Deployment

**Linux/macOS:**
```bash
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.0-1_amd64.deb && \
sudo WAZUH_MANAGER='WAZUH_IP' dpkg -i ./wazuh-agent.deb

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

**Windows:**
```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi -OutFile wazuh-agent.msi

msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="WAZUH_IP" WAZUH_AGENT_NAME="HOSTNAME"
NET START WazuhSvc
```

**Docker Container Monitoring:**
```yaml
# Add to docker-compose.yml
services:
  wazuh-agent:
    image: wazuh/wazuh-agent:latest
    hostname: docker-host-wazuh-agent
    environment:
      - WAZUH_MANAGER=WAZUH_IP
      - WAZUH_AGENT_NAME=docker-host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /var/lib/docker:/var/lib/docker:ro
      - /var/log:/host/var/log:ro
```

### Custom Rules

**File Integrity Monitoring:**
```xml
<!-- /var/ossec/etc/ossec.conf -->
<syscheck>
  <directories check_all="yes">/etc,/usr/bin,/usr/sbin</directories>
  <directories check_all="yes">/home</directories>
  <frequency>300</frequency>
  <alert_new_files>yes</alert_new_files>
</syscheck>
```

**Container Security Monitoring:**
```xml
<!-- Custom rule for container events -->
<group name="docker,">
  <rule id="100001" level="5">
    <decoded_as>json</decoded_as>
    <field name="status">start</field>
    <description>Docker container started</description>
  </rule>

  <rule id="100002" level="7">
    <decoded_as>json</decoded_as>
    <field name="status">die</field>
    <description>Docker container died</description>
  </rule>

  <rule id="100003" level="10">
    <if_sid>100002</if_sid>
    <field name="exitCode">!^0$</field>
    <description>Docker container crashed (non-zero exit)</description>
  </rule>
</group>
```

---

## Metrics Collection with Prometheus

### Prometheus Deployment

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=30d'
    networks:
      - monitoring
    restart: unless-stopped

volumes:
  prometheus-data:

networks:
  monitoring:
    external: true
```

**Prometheus Configuration:**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  # Node Exporter (host metrics)
  - job_name: 'node-exporter'
    static_configs:
      - targets:
        - 'YOUR_NETWORK.100:9100'  # Unraid
        - 'YOUR_NETWORK.101:9100'  # Raspberry Pi

  # cAdvisor (container metrics)
  - job_name: 'cadvisor'
    static_configs:
      - targets:
        - 'YOUR_NETWORK.100:8080'

  # Docker daemon metrics
  - job_name: 'docker'
    static_configs:
      - targets:
        - 'YOUR_NETWORK.100:9323'

  # Wazuh metrics
  - job_name: 'wazuh'
    static_configs:
      - targets:
        - 'WAZUH_IP:55000'
```

### Exporters

**Node Exporter (System Metrics):**
```bash
docker run -d \
  --name=node-exporter \
  --net=host \
  --pid=host \
  -v /:/host:ro,rslave \
  prom/node-exporter:latest \
  --path.rootfs=/host
```

**cAdvisor (Container Metrics):**
```bash
docker run -d \
  --name=cadvisor \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  gcr.io/cadvisor/cadvisor:latest
```

---

## Visualization with Grafana

### Grafana Deployment

```yaml
version: '3.8'

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=CHANGE_ME_SECURE_PASSWORD
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_ROOT_URL=https://grafana.YOUR_DOMAIN.com
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    networks:
      - monitoring
    restart: unless-stopped

volumes:
  grafana-data:

networks:
  monitoring:
    external: true
```

### Data Sources

**Add Loki:**
```yaml
# provisioning/datasources/loki.yml
apiVersion: 1

datasources:
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    isDefault: false
```

**Add Prometheus:**
```yaml
# provisioning/datasources/prometheus.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

### Dashboards

**Import Pre-built Dashboard:**
See [configs/grafana/security-monitoring-dashboard.json](../configs/grafana/security-monitoring-dashboard.json)

**Key Panels:**
- Failed SSH attempts (last 24h)
- Sudo authentication events
- Container health status
- System resource usage
- Security alerts timeline

---

## Alerting & SOAR

### Grafana Alerts

**Alert Rule Example:**
```yaml
# Failed SSH Attempts
name: High SSH Failures
query: sum(rate({unit="ssh.service"} |= "Failed password" [5m]))
condition: > 5
for: 5m
annotations:
  summary: "High number of SSH failures detected"
  description: "More than 5 failed SSH attempts in 5 minutes"
notifications:
  - discord-webhook
  - email-oncall
```

### n8n SOAR Integration

**See:** [configs/n8n/WAZUH-INTEGRATION-GUIDE.md](../configs/n8n/WAZUH-INTEGRATION-GUIDE.md)

**Automated Response Workflows:**

1. **SSH Brute Force Detection**
   - Trigger: 10+ failed attempts in 5 minutes
   - Action: Add source IP to fail2ban, send alert

2. **Container Crash**
   - Trigger: Container exit code != 0
   - Action: Collect logs, restart container, notify team

3. **Critical CVE Detected**
   - Trigger: Trivy scan finds CRITICAL CVE
   - Action: Create ticket, send email, Slack alert

4. **File Integrity Violation**
   - Trigger: Wazuh FIM alert
   - Action: Create backup, alert security team, create incident

---

## Log Retention & Compliance

### Retention Policies

**Loki:**
- Raw logs: 30 days
- Aggregated metrics: 90 days

**Wazuh Indexer:**
- Security events: 90 days
- Audit logs: 1 year
- Compliance logs: 7 years (if required)

**Prometheus:**
- Metrics: 30 days
- Long-term storage: Thanos (optional)

### Backup Strategy

```bash
#!/bin/bash
# backup-logs.sh

# Backup Loki data
docker exec loki tar czf /tmp/loki-backup.tar.gz /loki
docker cp loki:/tmp/loki-backup.tar.gz /backup/loki/

# Backup Wazuh indexes
curl -X POST "WAZUH_IP:9200/_snapshot/my_backup/snapshot_1" \
  -H 'Content-Type: application/json' \
  -d'{"indices": "wazuh-*"}'

# Backup Grafana dashboards
docker exec grafana tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana
docker cp grafana:/tmp/grafana-backup.tar.gz /backup/grafana/

# Sync to offsite
rsync -avz /backup/ backup-server:/archives/logs/
```

---

## Security Event Monitoring

### Key Events to Monitor

**Authentication:**
- SSH login attempts (success/failure)
- Sudo command execution
- Web service authentication (401/403 errors)
- API key usage

**System Changes:**
- File modifications in /etc, /bin, /usr
- New user/group creation
- Cron job modifications
- Service start/stop

**Network:**
- Port scans (multiple connection attempts)
- Unusual outbound connections
- DNS query anomalies
- Bandwidth spikes

**Application:**
- Container starts/stops/crashes
- Error rate increases
- Resource exhaustion (CPU, memory, disk)
- Database connection failures

### Alert Thresholds

**Critical (Immediate Response):**
- Rootkit detection
- Unauthorized system modification
- Data exfiltration attempt
- Multiple authentication failures from same IP

**High (Response within 1 hour):**
- Container crash
- Service downtime
- Disk space >90%
- Critical CVE detected

**Medium (Response within 24 hours):**
- Failed backup
- Certificate expiring <30 days
- High error rate

**Low (Review weekly):**
- Unusual access patterns
- Performance degradation
- Configuration drift

---

## Incident Response Integration

### Playbook Automation

**Example: Suspected Compromise Response**
```yaml
# n8n workflow
trigger:
  - wazuh_alert: "rootkit_detected"

actions:
  1. isolate_host:
      - disable_network_interface
      - stop_all_containers
      - create_memory_dump

  2. collect_evidence:
      - export_logs (last 7 days)
      - snapshot_disk
      - copy_to_forensics_server

  3. notify:
      - send_email: security_team
      - create_ticket: incident_id
      - alert_slack: #security-incidents

  4. document:
      - timeline_start: trigger_timestamp
      - affected_systems: [host_list]
      - initial_findings: alert_details
```

---

## Monitoring Dashboard Access

**Grafana:** http://YOUR_GRAFANA_IP:3000
**Wazuh:** https://WAZUH_IP
**Prometheus:** http://YOUR_PROMETHEUS_IP:9090

**Default Credentials (CHANGE IMMEDIATELY):**
- Grafana: admin / CHANGE_ME
- Wazuh: admin / CHANGE_ME

---

## Performance Tuning

### Loki Query Optimization

```yaml
# Indexed fields for faster queries
schema_config:
  configs:
    - from: 2024-01-01
      index:
        prefix: loki_
        period: 24h
      chunks:
        prefix: chunks_
        period: 24h
```

### Prometheus Retention

```yaml
# Reduce retention for high-cardinality metrics
global:
  scrape_interval: 30s  # Increase interval for non-critical metrics

# Sample metric relabeling
metric_relabel_configs:
  - source_labels: [__name__]
    regex: 'high_cardinality_metric_.*'
    action: drop
```

---

## Validation & Testing

### Test Log Ingestion

```bash
# Generate test SSH failure
ssh invalid_user@localhost

# Check Loki for logs
curl -G -s "http://localhost:3100/loki/api/v1/query" \
  --data-urlencode 'query={unit="ssh.service"} |= "Failed password"' \
  | jq .
```

### Test Alerting

```bash
# Trigger alert (generate 10 failed SSH attempts)
for i in {1..10}; do ssh invalid@localhost; done

# Check alert status in Grafana
# Check notification received (email/Discord)
```

### Performance Baseline

**Metrics to track:**
- Log ingestion rate: X logs/second
- Query response time: <2 seconds
- Dashboard load time: <5 seconds
- Alert latency: <30 seconds

---

## Summary

**Implemented Monitoring:**
- ✅ Centralized logging (Loki)
- ✅ SIEM (Wazuh)
- ✅ Metrics collection (Prometheus)
- ✅ Visualization (Grafana)
- ✅ Automated alerting (n8n SOAR)
- ✅ Log retention & backup
- ✅ Incident response integration

**Coverage:**
- 25+ containers monitored
- Multiple VMs with agents
- Network security events
- Authentication tracking
- File integrity monitoring
- Performance metrics

**Security Visibility:** 360° view of homelab infrastructure

---

**Previous:** [← Hardening Implementation](03-hardening-implementation.md)
**Next:** Complete - Start continuous improvement cycle
