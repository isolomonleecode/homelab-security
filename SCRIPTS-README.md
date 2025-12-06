# Environment-Specific Files Relocated

**All environment-specific files have been moved to the centralized documentation vault.**

---

## Why Were They Moved?

These directories contained personal/environment-specific information:
- **Tailscale domains** (tailc12764.ts.net)
- **IP addresses** (192.168.0.x, 100.x.x.x)
- **Hostnames** (capcorp9000, unraid, etc.)
- **Usernames** (ssjlox) and **file paths**
- **Personal notes** and **troubleshooting sessions**

To protect privacy and make this repository portable, they've been relocated to a private vault.

---

## Where Are They Now?

**Location:**
```
/run/media/ssjlox/gamer/Documentation/Projects/homelab-security-hardening/
```

**Directories moved:**
- `configs/` - **ALL configuration files** (Grafana, Wazuh, Promtail, Pi-hole DNS, Caddy, etc.)
- `scripts/` - Deployment and automation scripts (29 files)
- `sessions/` - Session notes and troubleshooting docs (20+ files)
- `findings/` - Security assessment findings
- `AI/` - AI-related configurations

---

## What's Still in GitHub?

This repository now contains only **portable, shareable** content:
- `configs/` - Configuration **templates** and examples
  - Docker Compose files
  - Grafana dashboards (no personal data)
  - Wazuh configurations (sanitized)
  - Prometheus/Promtail templates
- `README.md` - Project overview
- `.gitignore` - Privacy protection

---

## Using This Repository

### For Others

1. Clone the repository
2. Use `configs/` as templates for your own setup
3. Customize with your environment details
4. No personal data to clean up!

### For Original Author (ssjlox)

All scripts and detailed documentation are in the vault:
```bash
cd /run/media/ssjlox/gamer/Documentation/Projects/homelab-security-hardening/

# Access scripts
ls scripts/

# View session notes
ls sessions/

# Check findings
ls findings/
```

---

## Config Files That Remain

Configuration files in `configs/` have been sanitized or are templates:
- **Docker Compose files** - Port mappings and service definitions (no secrets)
- **Grafana dashboards** - JSON exports (no API keys)
- **Prometheus configs** - Scrape targets as templates
- **Promtail configs** - Log collection templates

**Note:** Some configs still reference example hostnames like `capcorp9000` - these serve as placeholders showing the expected format.

---

## Creating Your Own Scripts

If you need scripts for your environment:

1. **Copy templates from configs/**
2. **Customize for your setup:**
   - Replace hostnames
   - Update IP addresses
   - Set your paths
   - Configure your credentials

3. **Keep them private** (don't commit to public repos)

---

## Documentation

Full deployment guides and tutorials are available in the centralized vault:
```
/run/media/ssjlox/gamer/Documentation/Projects/homelab-security-hardening/
```

See [INDEX.md](file:///run/media/ssjlox/gamer/Documentation/Projects/homelab-security-hardening/INDEX.md) for the complete documentation index.

---

**Privacy:** This keeps your personal homelab details private while sharing reusable configurations.

**Last Updated:** December 6, 2025
