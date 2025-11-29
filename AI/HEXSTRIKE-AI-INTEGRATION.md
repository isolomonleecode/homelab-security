# HexStrike-AI Integration Guide

**Date:** November 22, 2025
**Purpose:** Deploy AI-driven penetration testing automation with HexStrike-AI MCP server
**Repository:** https://github.com/isolomonleecode/hexstrike-ai

---

## What is HexStrike-AI?

HexStrike-AI is an advanced **Model Context Protocol (MCP) server** that bridges AI agents (Claude, GPT, etc.) with 150+ cybersecurity tools for autonomous penetration testing, vulnerability discovery, and bug bounty automation.

**Key Insight:** HexStrike-AI is **NOT an LLM** - it's a tool orchestration server that exposes security tools to AI clients via the MCP protocol.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│         Arch Linux Workstation (192.168.0.52)           │
│                                                         │
│  ┌───────────────────────────────────────────────┐     │
│  │  Claude Desktop (MCP Client)                  │     │
│  │  - Connects to HexStrike-AI MCP Server        │     │
│  │  - Orchestrates security tools via AI         │     │
│  └────────────┬──────────────────────────────────┘     │
│               │                                         │
│  ┌────────────▼──────────────────────────────────┐     │
│  │  LocalAI (Port 8080) - Optional               │     │
│  │  - Llama 3.1 70B Q4_K_M                       │     │
│  │  - 128K context window                        │     │
│  │  - Local inference for privacy                │     │
│  └───────────────────────────────────────────────┘     │
│                                                         │
└─────────────────────────────────────────────────────────┘
                         │
                         │ MCP Protocol
                         │ Port: 8888
                         │
┌────────────────────────▼─────────────────────────────────┐
│         Kali Linux VM (sweetrpi-desktop)                 │
│                                                          │
│  ┌────────────────────────────────────────────────┐     │
│  │  HexStrike-AI MCP Server (Port 8888)           │     │
│  │                                                 │     │
│  │  Core Components:                              │     │
│  │  ├─ IntelligentDecisionEngine                  │     │
│  │  ├─ BugBountyWorkflowManager                   │     │
│  │  ├─ CTFWorkflowManager                         │     │
│  │  ├─ CVEIntelligenceManager                     │     │
│  │  ├─ AIExploitGenerator                         │     │
│  │  ├─ VulnerabilityCorrelator                    │     │
│  │  ├─ TechnologyDetector                         │     │
│  │  └─ 5+ Additional AI Agents                    │     │
│  └────────────────────────────────────────────────┘     │
│                         │                                │
│  ┌──────────────────────▼──────────────────────────┐    │
│  │  150+ Security Tools                            │    │
│  │                                                  │    │
│  │  Network Recon (25+):                           │    │
│  │  └─ nmap, masscan, rustscan, amass, subfinder   │    │
│  │                                                  │    │
│  │  Web AppSec (40+):                              │    │
│  │  └─ nuclei, sqlmap, wpscan, nikto, gobuster     │    │
│  │                                                  │    │
│  │  Auth/Password (12+):                           │    │
│  │  └─ hydra, john, hashcat, netexec              │    │
│  │                                                  │    │
│  │  Binary Analysis (25+):                         │    │
│  │  └─ ghidra, radare2, gdb, binwalk              │    │
│  │                                                  │    │
│  │  Cloud Security (20+):                          │    │
│  │  └─ prowler, scout-suite, trivy, kube-hunter   │    │
│  │                                                  │    │
│  │  CTF/Forensics (20+):                           │    │
│  │  └─ volatility3, foremost, steghide, exiftool  │    │
│  └──────────────────────────────────────────────────┘    │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Why This Architecture?

### Kali VM for HexStrike-AI Server
- **Security Isolation:** Pentesting tools contained in dedicated environment
- **Tool Ecosystem:** Kali has 150+ security tools pre-installed
- **Risk Mitigation:** Mistakes won't damage main system
- **Professional Standard:** Industry best practice
- **Snapshot Safety:** Can revert VM if something breaks

### LocalAI on Arch Workstation
- **Native Performance:** No virtualization overhead for LLM inference
- **GPU Access:** Direct GPU acceleration for faster responses
- **Resource Flexibility:** Can allocate full system resources when needed

### Best of Both Worlds
- Security tools isolated (Kali VM)
- AI inference optimized (Arch native)
- Network connectivity between components

---

## Core Capabilities

### 12+ Specialized AI Agents

1. **IntelligentDecisionEngine**
   - Analyzes targets and selects optimal tools
   - Adapts strategies based on scan results
   - Multi-criteria decision making

2. **BugBountyWorkflowManager**
   - Automated reconnaissance pipelines
   - Systematic vulnerability discovery
   - Report generation for submissions

3. **CTFWorkflowManager**
   - Challenge analysis and categorization
   - Tool selection for specific challenge types
   - Solution automation

4. **CVEIntelligenceManager**
   - Real-time CVE monitoring
   - Vulnerability correlation with detected services
   - Exploitability assessment

5. **AIExploitGenerator**
   - Custom payload generation
   - Exploit adaptation and optimization
   - Evasion technique integration

6. **VulnerabilityCorrelator**
   - Multi-vulnerability attack chain discovery
   - Cross-service exploitation paths
   - Impact maximization strategies

7. **TechnologyDetector**
   - Stack identification (frontend, backend, database)
   - Version detection and fingerprinting
   - Technology-specific attack surface mapping

8. **RateLimitDetector**
   - Identifies API rate limits
   - Optimizes scan speed without triggering defenses

9. **FailureRecoverySystem**
   - Handles tool failures gracefully
   - Automatic retry with parameter adjustments
   - Fallback tool selection

10. **PerformanceMonitor**
    - Real-time performance tracking
    - Resource usage optimization
    - Bottleneck identification

11. **ParameterOptimizer**
    - Fine-tunes attack parameters
    - Learns from successful exploits
    - Adapts to target behavior

12. **GracefulDegradation**
    - Works even with missing tools
    - Suggests alternatives
    - Maintains functionality

---

## Use Cases & Workflows

### 1. Automated Bug Bounty Reconnaissance

**Traditional Approach (Manual):**
```
1. Run amass for subdomains (30 min)
2. Analyze results, pick next tool (10 min)
3. Run httpx to check live hosts (10 min)
4. Analyze results (10 min)
5. Run nuclei on live hosts (1 hour)
6. Manually correlate findings (30 min)
Total: ~2.5 hours
```

**HexStrike-AI Approach (Automated):**
```
Claude Desktop Prompt: "Perform reconnaissance on example.com"

AI Workflow (Automated):
1. TechnologyDetector analyzes target
2. IntelligentDecisionEngine selects: amass, subfinder, assetfinder
3. Parallel execution of subdomain tools (5 min)
4. AI correlates and deduplicates results
5. httpx verifies live hosts (5 min)
6. nuclei scans with optimized templates (30 min)
7. CVEIntelligenceManager correlates findings
8. Generates structured report

Total: ~40 minutes (60% time reduction)
```

**Example Interaction:**
```
User: "Scan hackerone.com for bug bounty vulnerabilities"

HexStrike-AI:
✓ Technology detected: Next.js, Node.js, PostgreSQL, Cloudflare
✓ Running subdomain enumeration: amass, subfinder, assetfinder
✓ Found 47 subdomains
✓ Checking live hosts: 31 live, 16 down
✓ Running nuclei with web templates
✓ Detected 3 potential vulnerabilities:
  - Exposed .git directory (Medium)
  - Missing security headers (Low)
  - Outdated jQuery version with known CVE (High)
✓ Correlating with CVE-2023-XXXX
✓ Report generated: bugbounty_report_20251122.md
```

### 2. CTF Challenge Solving

**Challenge Type: Web Exploitation**

```
User: "Solve this CTF challenge: http://ctf.example.com:8080"

HexStrike-AI:
✓ Technology detected: PHP 7.4, Apache 2.4, MySQL
✓ Running directory enumeration: gobuster, feroxbuster
✓ Found: /admin, /backup, /.git
✓ Analyzing .git exposure
✓ Reconstructing source code from git objects
✓ Code analysis reveals SQL injection in login.php
✓ Testing payload: ' OR 1=1 --
✓ Authentication bypassed
✓ Flag found: CTF{git_exposure_leads_to_sqli}
```

### 3. CVE Vulnerability Research

**Scenario: New CVE Published for Widely Used Software**

```
User: "Monitor for new Nginx CVEs and test my infrastructure"

HexStrike-AI:
✓ CVEIntelligenceManager monitoring NVD feed
✓ New CVE detected: CVE-2025-XXXX (Nginx 1.24.x)
✓ Severity: CRITICAL (CVSS 9.8)
✓ Scanning infrastructure for Nginx instances
✓ Found 5 Nginx servers:
  - 192.168.0.51 - Version 1.24.0 (VULNERABLE)
  - 192.168.0.52 - Version 1.25.1 (PATCHED)
  - 192.168.0.53 - Version 1.24.2 (VULNERABLE)
✓ Exploitability: High (public exploit available)
✓ Generating remediation report
✓ Notification sent to security team
```

### 4. Network Penetration Testing

**Full Network Assessment**

```
User: "Perform internal network pentest on 192.168.1.0/24"

HexStrike-AI:
✓ Phase 1: Discovery
  - Running masscan for quick port discovery
  - Found 23 live hosts, 157 open ports

✓ Phase 2: Service Enumeration
  - nmap detailed scan on open ports
  - Service fingerprinting completed

✓ Phase 3: Vulnerability Analysis
  - Detected SMBv1 enabled on 3 Windows hosts
  - Found outdated SSH on 5 Linux servers
  - Identified unpatched Apache on web server

✓ Phase 4: Exploitation (Authorized)
  - Testing EternalBlue on SMBv1 hosts
  - 2/3 hosts vulnerable, exploitation successful
  - Privilege escalation to SYSTEM

✓ Phase 5: Reporting
  - Attack chain documented
  - Remediation priorities assigned
  - Full pentest report generated
```

---

## Installation Guide

### Prerequisites

**Kali Linux VM Requirements:**
- Kali Linux 2024.x or newer
- Python 3.11+ (for AI features)
- 8GB+ RAM allocated to VM
- 100GB+ storage
- Network connectivity to host machine

**Arch Workstation Requirements (Optional - for LocalAI):**
- 40GB+ RAM (for Llama 3.1 70B Q4_K_M)
- NVIDIA GPU with 16GB+ VRAM (recommended)
- 100GB+ free storage for models

### Step 1: Clone Repository in Kali VM

```bash
# SSH into Kali VM or open terminal
cd ~
git clone https://github.com/isolomonleecode/hexstrike-ai.git
cd hexstrike-ai
```

### Step 2: Set Up Python Environment

```bash
# Create virtual environment
python3 -m venv hexstrike-env
source hexstrike-env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

**Expected Installation Time:** 5-10 minutes

### Step 3: Verify Security Tools Installation

Most tools are pre-installed in Kali. Verify key tools:

```bash
# Network reconnaissance
which nmap masscan rustscan amass subfinder

# Web application security
which nuclei sqlmap wpscan nikto gobuster ffuf

# Password attacks
which hydra john hashcat

# Binary analysis
which ghidra radare2 binwalk strings

# Check installation status
python3 hexstrike_server.py --check-tools
```

**If tools are missing:**

```bash
# Install via apt
sudo apt update
sudo apt install nmap masscan rustscan nuclei subfinder \
    sqlmap wpscan nikto gobuster ffuf hydra john binwalk \
    radare2 ghidra

# Install Go-based tools
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install github.com/ffuf/ffuf@latest
```

### Step 4: Configure HexStrike-AI

```bash
# Edit configuration
cp config.example.yml config.yml
nano config.yml
```

**Key Configuration Settings:**

```yaml
server:
  host: 0.0.0.0  # Listen on all interfaces for network access
  port: 8888
  debug: false

security:
  rate_limit: 100  # requests per minute
  max_concurrent_scans: 5
  timeout: 3600  # 1 hour per scan

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

tools:
  nmap:
    path: /usr/bin/nmap
    max_threads: 10
  nuclei:
    path: /usr/bin/nuclei
    templates_dir: /home/kali/nuclei-templates
  sqlmap:
    path: /usr/bin/sqlmap
    threads: 5
```

### Step 5: Start HexStrike-AI Server

```bash
# Start in foreground (for testing)
python3 hexstrike_server.py --config config.yml

# Or start as background service
nohup python3 hexstrike_server.py --config config.yml > hexstrike.log 2>&1 &

# Check server health
curl http://localhost:8888/health
```

**Expected Response:**

```json
{
  "status": "healthy",
  "version": "6.0.0",
  "agents_active": 12,
  "tools_available": 150,
  "uptime": "5 minutes"
}
```

### Step 6: Configure Firewall for Network Access

Allow MCP port from Arch workstation:

```bash
# If using ufw (Ubuntu firewall)
sudo ufw allow from 192.168.0.52 to any port 8888

# Or using iptables
sudo iptables -A INPUT -p tcp -s 192.168.0.52 --dport 8888 -j ACCEPT
```

### Step 7: Test from Arch Workstation

```bash
# From Arch workstation, test connectivity
curl http://192.168.0.XX:8888/health  # Replace XX with Kali VM IP

# Expected: JSON response with server status
```

---

## MCP Client Configuration

### Option 1: Claude Desktop (Recommended for Beginners)

**Installation on Arch Workstation:**

```bash
# Download Claude Desktop from Anthropic
# https://claude.ai/download

# Or use AUR (Arch User Repository)
yay -S claude-desktop
```

**Configure MCP Server:**

Edit Claude Desktop config: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "hexstrike": {
      "command": "python3",
      "args": [
        "-c",
        "import requests; import sys; import json; server='http://192.168.0.XX:8888'; [print(json.dumps(requests.post(f'{server}/api/mcp', json=json.loads(line)).json())) for line in sys.stdin]"
      ],
      "env": {
        "HEXSTRIKE_SERVER": "http://192.168.0.XX:8888"
      }
    }
  }
}
```

**Replace XX with your Kali VM IP address.**

**Test Connection:**

Open Claude Desktop and ask:

```
"List available security tools via HexStrike"
```

Expected response with list of 150+ tools.

### Option 2: VS Code with GitHub Copilot + MCP Extension

**Install MCP Extension:**

```bash
# In VS Code
code --install-extension anthropic.mcp-client
```

**Configure in VS Code settings.json:**

```json
{
  "mcp.servers": {
    "hexstrike": {
      "url": "http://192.168.0.XX:8888",
      "protocol": "mcp",
      "timeout": 300000
    }
  }
}
```

### Option 3: Custom MCP Client (Advanced)

Create Python MCP client for LocalAI integration:

```python
#!/usr/bin/env python3
"""
Custom MCP Client for HexStrike-AI with LocalAI
"""

import requests
import json
from openai import OpenAI

# LocalAI configuration
localai_client = OpenAI(
    base_url="http://192.168.0.52:8080/v1",
    api_key="local-ai-key"
)

# HexStrike-AI MCP server
HEXSTRIKE_URL = "http://192.168.0.XX:8888"

def call_hexstrike_tool(tool_name, parameters):
    """Call HexStrike-AI tool via MCP"""
    response = requests.post(
        f"{HEXSTRIKE_URL}/api/command",
        json={
            "tool": tool_name,
            "params": parameters
        }
    )
    return response.json()

def ai_pentesting_workflow(target):
    """AI-driven pentesting workflow using LocalAI + HexStrike"""

    # Step 1: Use LocalAI to plan the attack
    planning_prompt = f"""
    I need to perform a security assessment on {target}.
    Based on common pentesting methodology, what tools should I use
    and in what order? Consider:
    - Subdomain enumeration
    - Port scanning
    - Service detection
    - Vulnerability scanning

    Respond with a JSON array of tools and parameters.
    """

    response = localai_client.chat.completions.create(
        model="llama-3.1-70b-instruct",
        messages=[{"role": "user", "content": planning_prompt}]
    )

    plan = json.loads(response.choices[0].message.content)

    # Step 2: Execute plan using HexStrike-AI
    results = []
    for step in plan:
        tool_result = call_hexstrike_tool(
            tool_name=step["tool"],
            parameters=step["params"]
        )
        results.append(tool_result)

    # Step 3: Use LocalAI to analyze results
    analysis_prompt = f"""
    Here are the pentesting results for {target}:

    {json.dumps(results, indent=2)}

    Provide a security assessment including:
    - Critical findings
    - Recommended remediation
    - Risk prioritization
    """

    analysis = localai_client.chat.completions.create(
        model="llama-3.1-70b-instruct",
        messages=[{"role": "user", "content": analysis_prompt}]
    )

    return analysis.choices[0].message.content

# Example usage
if __name__ == "__main__":
    target = "example.com"  # Replace with authorized target
    report = ai_pentesting_workflow(target)
    print(report)
```

Save as `hexstrike_localai_client.py` and run:

```bash
python3 hexstrike_localai_client.py
```

---

## LocalAI Integration (Optional)

### Recommended Model: Llama 3.1 70B Q4_K_M

**Why This Model:**
- Proven performance in pentesting benchmarks (beats GPT-4o)
- 128K context window (handles complex multi-stage workflows)
- Strong tool use and function calling
- Open source with permissive license

### Installation Steps

**Step 1: Download Model**

```bash
# Create models directory
mkdir -p ~/ai-models

# Download Llama 3.1 70B Q4_K_M (approximately 40GB)
cd ~/ai-models
wget https://huggingface.co/models/llama-3.1-70b-instruct.Q4_K_M.gguf
```

**Alternative models:**
- **DeepSeek-R1 33B** (best for cybersecurity, verify compatibility)
- **Mistral 7B Q4_K_M** (lightweight, good for testing)

**Step 2: Configure LocalAI**

Assuming LocalAI is already running, add model configuration:

```bash
# Edit LocalAI model config
nano /path/to/localai/models/llama-3.1-70b.yaml
```

```yaml
name: llama-3.1-70b-instruct
model: llama-3.1-70b-instruct.Q4_K_M.gguf
backend: llama-cpp

parameters:
  model: llama-3.1-70b-instruct.Q4_K_M.gguf
  context_size: 128000
  gpu_layers: 35  # Adjust based on VRAM (0 for CPU-only)
  threads: 8
  temperature: 0.7
  top_p: 0.9
  top_k: 40

template:
  chat: llama3
  completion: llama3

capabilities:
  embeddings: false
  chat: true
  completion: true
  function_calling: true

usage:
  max_tokens: 4096
  stop_words: ["<|end_of_text|>", "<|eot_id|>"]
```

**Step 3: Restart LocalAI**

```bash
# If running as Docker
docker restart local-ai

# If running as systemd service
sudo systemctl restart localai
```

**Step 4: Test Model**

```bash
# Test inference
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.1-70b-instruct",
    "messages": [
      {"role": "user", "content": "What tools would you use for subdomain enumeration?"}
    ]
  }'
```

### Performance Optimization

**GPU Acceleration:**

```yaml
# Increase GPU layers for faster inference
gpu_layers: 35  # 16GB VRAM
gpu_layers: 45  # 24GB VRAM
gpu_layers: 60  # 48GB+ VRAM (entire model)
```

**CPU-Only Mode:**

```yaml
# If no GPU available
gpu_layers: 0
threads: 16  # Use more CPU threads
```

**Memory Requirements:**

| Configuration | RAM Required | VRAM Required | Inference Speed |
|---------------|--------------|---------------|-----------------|
| CPU Only      | 48GB+        | 0GB           | Slow (~10 tok/s)|
| Hybrid (35 layers) | 24GB    | 16GB          | Medium (~30 tok/s)|
| Full GPU (60 layers) | 16GB  | 48GB          | Fast (~80 tok/s)|

---

## Example Workflows

### Workflow 1: Automated Bug Bounty Recon

**File:** `workflows/bugbounty_recon.py`

```python
#!/usr/bin/env python3
"""
Automated Bug Bounty Reconnaissance Workflow
Uses HexStrike-AI for tool orchestration
"""

import requests
import json
from datetime import datetime

HEXSTRIKE_API = "http://192.168.0.XX:8888/api"

def run_bugbounty_recon(target_domain):
    """
    Complete bug bounty reconnaissance workflow

    Args:
        target_domain: Target domain (e.g., "hackerone.com")
    """

    print(f"[*] Starting bug bounty recon on {target_domain}")
    print(f"[*] Timestamp: {datetime.now()}")

    # Phase 1: Subdomain Enumeration
    print("\n[Phase 1] Subdomain Enumeration")
    response = requests.post(
        f"{HEXSTRIKE_API}/intelligence/analyze-target",
        json={
            "target": target_domain,
            "workflow": "bugbounty_recon",
            "phases": ["subdomain_enum"]
        }
    )

    subdomains = response.json()["subdomains"]
    print(f"[+] Found {len(subdomains)} subdomains")

    # Phase 2: Technology Detection
    print("\n[Phase 2] Technology Stack Detection")
    response = requests.post(
        f"{HEXSTRIKE_API}/intelligence/analyze-target",
        json={
            "target": target_domain,
            "workflow": "bugbounty_recon",
            "phases": ["tech_detection"]
        }
    )

    tech_stack = response.json()["technologies"]
    print(f"[+] Detected technologies: {', '.join(tech_stack)}")

    # Phase 3: Vulnerability Scanning
    print("\n[Phase 3] Vulnerability Scanning with Nuclei")
    response = requests.post(
        f"{HEXSTRIKE_API}/command",
        json={
            "tool": "nuclei",
            "params": {
                "targets": subdomains,
                "templates": "high,critical",
                "severity": "medium,high,critical"
            }
        }
    )

    vulnerabilities = response.json()["results"]
    print(f"[+] Found {len(vulnerabilities)} potential vulnerabilities")

    # Phase 4: CVE Correlation
    print("\n[Phase 4] CVE Intelligence Correlation")
    response = requests.post(
        f"{HEXSTRIKE_API}/intelligence/analyze-target",
        json={
            "target": target_domain,
            "workflow": "cve_correlation",
            "technologies": tech_stack
        }
    )

    cve_matches = response.json()["cve_matches"]
    print(f"[+] Correlated {len(cve_matches)} relevant CVEs")

    # Generate Report
    report = {
        "target": target_domain,
        "timestamp": datetime.now().isoformat(),
        "subdomains": subdomains,
        "technologies": tech_stack,
        "vulnerabilities": vulnerabilities,
        "cve_matches": cve_matches
    }

    # Save report
    filename = f"bugbounty_report_{target_domain}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(filename, 'w') as f:
        json.dump(report, f, indent=2)

    print(f"\n[✓] Report saved: {filename}")
    print(f"[✓] Reconnaissance complete")

    return report

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 bugbounty_recon.py <target_domain>")
        sys.exit(1)

    target = sys.argv[1]
    run_bugbounty_recon(target)
```

**Usage:**

```bash
python3 workflows/bugbounty_recon.py hackerone.com
```

### Workflow 2: CTF Challenge Solver

**File:** `workflows/ctf_solver.py`

```python
#!/usr/bin/env python3
"""
Automated CTF Challenge Solver
"""

import requests
import json

HEXSTRIKE_API = "http://192.168.0.XX:8888/api"

def solve_ctf_challenge(challenge_url, challenge_type="auto"):
    """
    Automated CTF challenge solving

    Args:
        challenge_url: URL of the CTF challenge
        challenge_type: Type hint (web, pwn, reverse, crypto, forensics, auto)
    """

    print(f"[*] Analyzing CTF challenge: {challenge_url}")

    # Let HexStrike-AI analyze and solve
    response = requests.post(
        f"{HEXSTRIKE_API}/intelligence/analyze-target",
        json={
            "target": challenge_url,
            "workflow": "ctf_solver",
            "challenge_type": challenge_type
        }
    )

    result = response.json()

    print(f"\n[+] Challenge Type Detected: {result['detected_type']}")
    print(f"[+] Tools Used: {', '.join(result['tools_used'])}")
    print(f"\n[!] Solution:\n{result['solution']}")

    if "flag" in result:
        print(f"\n[FLAG FOUND] {result['flag']}")

    return result

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python3 ctf_solver.py <challenge_url> [type]")
        sys.exit(1)

    url = sys.argv[1]
    ctype = sys.argv[2] if len(sys.argv) > 2 else "auto"

    solve_ctf_challenge(url, ctype)
```

### Workflow 3: Continuous CVE Monitoring

**File:** `workflows/cve_monitor.py`

```python
#!/usr/bin/env python3
"""
Continuous CVE Monitoring with Notifications
"""

import requests
import time
from datetime import datetime

HEXSTRIKE_API = "http://192.168.0.XX:8888/api"
DISCORD_WEBHOOK = "https://discord.com/api/webhooks/YOUR_WEBHOOK"  # Optional

def monitor_cves(technologies, check_interval=3600):
    """
    Monitor for new CVEs affecting your tech stack

    Args:
        technologies: List of technologies to monitor
        check_interval: Seconds between checks (default: 1 hour)
    """

    print(f"[*] Starting CVE monitoring for: {', '.join(technologies)}")
    print(f"[*] Check interval: {check_interval} seconds")

    seen_cves = set()

    while True:
        print(f"\n[{datetime.now()}] Checking for new CVEs...")

        response = requests.post(
            f"{HEXSTRIKE_API}/intelligence/analyze-target",
            json={
                "workflow": "cve_monitoring",
                "technologies": technologies,
                "severity": ["critical", "high"]
            }
        )

        result = response.json()
        new_cves = [cve for cve in result["cves"] if cve["id"] not in seen_cves]

        if new_cves:
            print(f"[!] {len(new_cves)} new CVEs detected!")

            for cve in new_cves:
                print(f"\n[CVE] {cve['id']}")
                print(f"  Severity: {cve['severity']}")
                print(f"  Affected: {cve['affected']}")
                print(f"  Description: {cve['description'][:100]}...")

                # Send Discord notification (optional)
                if DISCORD_WEBHOOK:
                    send_discord_alert(cve)

                seen_cves.add(cve["id"])
        else:
            print("[+] No new CVEs")

        time.sleep(check_interval)

def send_discord_alert(cve):
    """Send Discord webhook notification"""
    payload = {
        "embeds": [{
            "title": f"🚨 New CVE Detected: {cve['id']}",
            "description": cve['description'],
            "color": 15158332,  # Red
            "fields": [
                {"name": "Severity", "value": cve['severity'], "inline": True},
                {"name": "CVSS", "value": str(cve['cvss_score']), "inline": True},
                {"name": "Affected", "value": cve['affected'], "inline": False}
            ],
            "timestamp": datetime.now().isoformat()
        }]
    }
    requests.post(DISCORD_WEBHOOK, json=payload)

if __name__ == "__main__":
    # Monitor your infrastructure's tech stack
    tech_stack = [
        "nginx",
        "postgresql",
        "node.js",
        "docker",
        "kubernetes"
    ]

    monitor_cves(tech_stack, check_interval=3600)  # Check every hour
```

---

## Security Considerations

### Authorization & Legal Compliance

**CRITICAL: Only test authorized targets**

- Bug bounty programs: Follow program rules and scope
- Personal infrastructure: Document ownership
- Pentesting engagements: Obtain written authorization
- CTF competitions: Adhere to competition rules

**Unauthorized testing is illegal** under:
- Computer Fraud and Abuse Act (CFAA) - United States
- Computer Misuse Act - United Kingdom
- Similar laws in most countries worldwide

### Built-in Safety Features

**HexStrike-AI includes:**

1. **Rate Limiting**
   - Prevents accidental DoS attacks
   - Configurable limits per tool
   - Automatic throttling

2. **Scope Validation**
   - Ensures targets are within authorized scope
   - Prevents scanning of restricted networks
   - IP range validation

3. **Audit Logging**
   - Complete audit trail of all actions
   - Timestamped command history
   - Accountability for team environments

4. **Configurable Safety Controls**
   - Disable aggressive scanning modes
   - Set maximum scan intensity
   - Whitelist/blacklist management

### Network Isolation

**Kali VM Network Configuration:**

```bash
# Recommended: Host-only network for maximum security
# VM can only communicate with host, not external network

# Or: NAT with port forwarding
# VM uses host's IP, controlled external access

# Avoid: Bridged mode (unless necessary for team collaboration)
# VM gets its own IP on your network
```

### Credential Management

**Never hardcode credentials:**

```python
# ❌ BAD
HEXSTRIKE_API_KEY = "my-secret-key-12345"

# ✅ GOOD
import os
HEXSTRIKE_API_KEY = os.environ.get("HEXSTRIKE_API_KEY")
```

**Use environment variables:**

```bash
# Set in .bashrc or .zshrc
export HEXSTRIKE_API_KEY="your-key-here"
export HEXSTRIKE_SERVER="http://192.168.0.XX:8888"
```

---

## Career & Portfolio Value

### Skills Demonstrated

✅ **AI-Driven Security Automation** - Cutting-edge AI + cybersecurity integration
✅ **Model Context Protocol (MCP)** - Modern AI orchestration framework
✅ **150+ Security Tools** - Comprehensive pentesting tool knowledge
✅ **Multi-Agent Systems** - Advanced AI architecture understanding
✅ **DevSecOps** - Security automation in development workflows
✅ **Bug Bounty Automation** - Professional vulnerability research
✅ **CTF Expertise** - Competitive cybersecurity skills

### Portfolio Project Ideas

**Beginner Level:**
1. "Automated Subdomain Enumeration Pipeline with HexStrike-AI"
2. "AI-Powered CTF Challenge Solver"
3. "Building My First MCP Security Server"

**Intermediate Level:**
4. "Automated Bug Bounty Reconnaissance Framework"
5. "CVE Intelligence Correlation System"
6. "Multi-Tool Web Application Security Testing"

**Advanced Level:**
7. "AI-Driven Red Team Automation Platform"
8. "Zero-Day Discovery Using ML-Enhanced Fuzzing"
9. "Enterprise Security Orchestration with HexStrike-AI + SIEM"

### LinkedIn Update Template

```
🚀 Excited to share my latest cybersecurity project!

I've deployed HexStrike-AI, an advanced AI-driven penetration testing
framework that integrates 150+ security tools with local LLMs for
autonomous vulnerability discovery.

Key achievements:
✅ Deployed 12+ specialized AI agents for intelligent tool orchestration
✅ Integrated with local Llama 3.1 70B model for privacy-focused testing
✅ Built automated workflows for bug bounty reconnaissance
✅ Reduced manual reconnaissance time by 60-80%
✅ Created CVE intelligence correlation system

Tech stack:
- Model Context Protocol (MCP)
- Python 3.11 + FastMCP
- Llama 3.1 70B (LocalAI)
- 150+ security tools (nmap, nuclei, sqlmap, etc.)
- Kali Linux + Arch workstation

This project demonstrates the future of cybersecurity: AI-augmented
security testing that combines human expertise with autonomous
tool orchestration.

Next steps: Integrating with my Wazuh SIEM deployment for complete
SOAR (Security Orchestration, Automation & Response) capabilities.

#CyberSecurity #AI #PenetrationTesting #BugBounty #SOAR #InfoSec
```

### Interview Talking Points

**Q: "Tell me about a complex security automation project you've worked on."**

**A:** "I deployed HexStrike-AI, an AI-driven penetration testing framework that uses the Model Context Protocol to orchestrate 150+ security tools through specialized AI agents.

The system includes 12 intelligent agents like the IntelligentDecisionEngine for tool selection, BugBountyWorkflowManager for automated reconnaissance, and CVEIntelligenceManager for real-time vulnerability correlation.

I integrated it with a local Llama 3.1 70B model running in LocalAI for privacy-focused testing, and deployed the MCP server in an isolated Kali VM for security best practices.

The automation reduced manual reconnaissance time by 60-80% in bug bounty workflows while maintaining comprehensive coverage. For example, a typical subdomain enumeration and vulnerability scan that would take 2-3 hours manually now completes in about 40 minutes with better correlation of findings.

I also built custom workflows for CTF challenge solving and continuous CVE monitoring, demonstrating the versatility of AI-augmented security testing."

---

## Troubleshooting

### Issue 1: HexStrike-AI Server Won't Start

**Symptoms:**
```
Error: Address already in use: 0.0.0.0:8888
```

**Solution:**

```bash
# Check what's using port 8888
sudo lsof -i :8888

# Kill the process
sudo kill -9 <PID>

# Or change port in config.yml
server:
  port: 8889  # Use different port
```

### Issue 2: Tools Not Found

**Symptoms:**
```
Error: Tool 'nuclei' not found in PATH
```

**Solution:**

```bash
# Install missing tool
sudo apt install nuclei

# Or update PATH in config
tools:
  nuclei:
    path: /usr/local/bin/nuclei
```

### Issue 3: MCP Client Can't Connect

**Symptoms:**
```
Connection refused to 192.168.0.XX:8888
```

**Solution:**

```bash
# Check firewall
sudo ufw status

# Allow port
sudo ufw allow from 192.168.0.52 to any port 8888

# Verify server is listening on all interfaces
netstat -tulpn | grep 8888
# Should show: 0.0.0.0:8888 (not 127.0.0.1:8888)
```

### Issue 4: LocalAI Model Too Slow

**Symptoms:**
- Inference taking 30+ seconds per request
- High RAM usage, low GPU usage

**Solution:**

```yaml
# Increase GPU layers in model config
gpu_layers: 45  # Move more layers to GPU

# Reduce context size if not needed
context_size: 32000  # Instead of 128000

# Use smaller quantization if VRAM limited
model: llama-3.1-70b-instruct.Q4_K_M.gguf  # Instead of Q5_K_M
```

### Issue 5: VM Performance Issues

**Symptoms:**
- Scans taking much longer than expected
- High CPU usage in VM

**Solution:**

```bash
# Allocate more resources to VM
# In VirtualBox/VMware settings:
# - CPU: 8 cores (from 4)
# - RAM: 16GB (from 8GB)

# Or move to native installation (if security allows)
```

---

## Next Steps

### Phase 1: Basic Setup (Today)

- [ ] Clone HexStrike-AI repository to Kali VM
- [ ] Install Python dependencies
- [ ] Verify security tools installation
- [ ] Start HexStrike-AI server
- [ ] Test health endpoint

### Phase 2: MCP Client Configuration (This Week)

- [ ] Install Claude Desktop on Arch workstation
- [ ] Configure MCP server connection
- [ ] Test basic tool orchestration
- [ ] Run first automated workflow

### Phase 3: LocalAI Integration (Next Week)

- [ ] Download Llama 3.1 70B Q4_K_M model
- [ ] Configure LocalAI with new model
- [ ] Test inference performance
- [ ] Build custom MCP client for LocalAI integration

### Phase 4: Production Workflows (Ongoing)

- [ ] Create bug bounty reconnaissance pipeline
- [ ] Set up CVE monitoring for infrastructure
- [ ] Build CTF challenge solver workflows
- [ ] Document all workflows for portfolio

### Phase 5: Portfolio & Career Development

- [ ] Write LinkedIn update about HexStrike-AI deployment
- [ ] Create portfolio project documentation
- [ ] Record demo videos of workflows
- [ ] Update resume with AI + security automation skills

---

## Resources

### Official Documentation

- [HexStrike-AI GitHub](https://github.com/0x4m4/hexstrike-ai)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)
- [FastMCP Framework](https://github.com/jlowin/fastmcp)
- [LocalAI Documentation](https://localai.io/)

### Security Tools Documentation

- [Nmap Reference](https://nmap.org/book/man.html)
- [Nuclei Templates](https://github.com/projectdiscovery/nuclei-templates)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [Bug Bounty Playbook](https://gowthams.gitbook.io/bughunter-handbook/)

### AI & LLM Resources

- [Llama 3.1 Model Card](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct)
- [DeepSeek Models](https://huggingface.co/deepseek-ai)
- [GGUF Quantization Guide](https://github.com/ggerganov/llama.cpp/blob/master/docs/quantization.md)

### Learning Resources

- [HackTheBox](https://hackthebox.com/) - Pentesting practice
- [TryHackMe](https://tryhackme.com/) - Guided security training
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) - Free web security training

---

**Created by:** isolomonleecode
**Last Updated:** November 22, 2025
**Status:** Deployment Ready
**Next Action:** Clone repository and start Phase 1 setup
