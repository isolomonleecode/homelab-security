# LocalAI LLM Setup Guide for HexStrike-AI

**Date:** November 22, 2025
**Purpose:** Configure optimal local LLM models for AI-driven penetration testing
**Recommended Model:** Llama 3.1 70B Instruct (Q4_K_M quantization)

---

## Overview

This guide walks through deploying local Large Language Models (LLMs) in LocalAI for use with HexStrike-AI and other cybersecurity workflows.

**Key Insight:** HexStrike-AI doesn't require a local LLM to function (it's an MCP server), but using local models provides:
- **Privacy:** All inference happens locally
- **Cost Savings:** No API fees
- **Offline Capability:** Works without internet
- **Customization:** Fine-tune models for specific tasks

---

## Recommended Models for Cybersecurity

### Model Comparison

| Model | Size | Context | Cybersec Performance | Resource Req | Best For |
|-------|------|---------|---------------------|--------------|----------|
| **Llama 3.1 70B** | 70B | 128K | ⭐⭐⭐⭐⭐ | 40GB RAM | Production pentesting |
| **DeepSeek-R1 33B** | 33B* | 164K | ⭐⭐⭐⭐⭐ | 24GB RAM | Advanced exploitation |
| **Mistral 7B** | 7B | 32K | ⭐⭐⭐ | 8GB RAM | Testing, light workloads |

*MoE architecture - 671B total, ~33B activated

---

## Option 1: Llama 3.1 70B (Recommended)

### Why Llama 3.1 70B?

**Proven Performance:**
- Outperforms GPT-4o in penetration testing benchmarks
- Excellent at tool selection and parameter optimization
- Strong function calling capabilities

**Technical Specs:**
- **Parameters:** 70 billion
- **Context Window:** 128K tokens (ideal for multi-tool workflows)
- **Quantization:** Q4_K_M (26GB) or Q5_K_M (32GB)
- **License:** Llama 3.1 Community License (permissive)

### System Requirements

**Minimum Configuration:**
```
CPU: 8+ cores
RAM: 40GB+ (system RAM)
VRAM: 0GB (CPU-only mode)
Storage: 50GB free
```

**Recommended Configuration:**
```
CPU: 16+ cores
RAM: 64GB+
VRAM: 16GB+ NVIDIA GPU
Storage: 100GB+ SSD
```

**Performance Expectations:**

| Hardware | Inference Speed | Use Case |
|----------|----------------|----------|
| CPU Only (16 cores, 64GB RAM) | ~10 tokens/sec | Budget option |
| Hybrid (16GB VRAM + 32GB RAM) | ~30 tokens/sec | Recommended |
| Full GPU (48GB VRAM) | ~80 tokens/sec | Professional |

### Installation Steps

#### Step 1: Download Model

```bash
# Create models directory
mkdir -p ~/ai-models
cd ~/ai-models

# Option A: Download Q4_K_M (26GB - faster download, good quality)
wget https://huggingface.co/models/TheBloke/Llama-3.1-70B-Instruct-GGUF/resolve/main/llama-3.1-70b-instruct.Q4_K_M.gguf

# Option B: Download Q5_K_M (32GB - better quality, slower download)
wget https://huggingface.co/models/TheBloke/Llama-3.1-70B-Instruct-GGUF/resolve/main/llama-3.1-70b-instruct.Q5_K_M.gguf
```

**Alternative: Use HuggingFace CLI (Faster)**

```bash
# Install HuggingFace CLI
pip install huggingface-hub

# Download with progress bar
huggingface-cli download TheBloke/Llama-3.1-70B-Instruct-GGUF \
    llama-3.1-70b-instruct.Q4_K_M.gguf \
    --local-dir ~/ai-models
```

**Download Time Estimates:**
- Gigabit connection: ~30-45 minutes (Q4_K_M)
- 100Mbps connection: ~3-4 hours (Q4_K_M)

#### Step 2: Configure LocalAI Model

Assuming LocalAI is installed and running. If not, see [LocalAI Installation](#localai-installation) below.

**Create model configuration file:**

```bash
# Navigate to LocalAI models directory
cd /path/to/localai/models  # Adjust based on your installation

# Create YAML configuration for Llama 3.1 70B
nano llama-3.1-70b-pentesting.yaml
```

**Configuration file content:**

```yaml
name: llama-3.1-70b-pentesting
model: llama-3.1-70b-instruct.Q4_K_M.gguf
backend: llama-cpp

# Context and performance settings
parameters:
  model: llama-3.1-70b-instruct.Q4_K_M.gguf
  context_size: 128000  # Full 128K context
  batch_size: 512       # Batch processing size
  threads: 8            # CPU threads (adjust based on your CPU)
  gpu_layers: 35        # Offload layers to GPU (0 for CPU-only)

  # Inference parameters
  temperature: 0.7      # Randomness (0.7 = balanced)
  top_p: 0.9           # Nucleus sampling
  top_k: 40            # Top-K sampling
  repeat_penalty: 1.1  # Prevent repetition

  # Memory optimization
  f16: true            # Use FP16 precision
  mmap: true           # Memory-map model file
  mlock: false         # Don't lock memory (set true if enough RAM)

# Template configuration
template:
  chat: llama3
  completion: llama3
  chat_message: |
    <|start_header_id|>{{.RoleName}}<|end_header_id|>
    {{.Content}}<|eot_id|>

# Model capabilities
capabilities:
  embeddings: false    # This model doesn't do embeddings
  chat: true
  completion: true
  function_calling: true

# Usage limits
usage:
  max_tokens: 8192     # Maximum output tokens per request
  stop_words:
    - "<|end_of_text|>"
    - "<|eot_id|>"
    - "<|start_header_id|>"

# Cybersecurity optimizations
cybersec_prompt_prefix: |
  You are a cybersecurity expert assistant with deep knowledge of:
  - Penetration testing methodologies (OWASP, PTES, MITRE ATT&CK)
  - Security tool usage (nmap, nuclei, sqlmap, metasploit)
  - Vulnerability analysis and exploitation
  - Secure coding and defensive techniques

  Always prioritize:
  1. Authorization and legal compliance
  2. Accurate technical information
  3. Clear explanations of security concepts
```

**Save and exit** (Ctrl+X, Y, Enter)

#### Step 3: Move Model File to LocalAI Directory

```bash
# Copy model to LocalAI models directory
cp ~/ai-models/llama-3.1-70b-instruct.Q4_K_M.gguf /path/to/localai/models/

# Verify file size (should be ~26GB for Q4_K_M)
ls -lh /path/to/localai/models/llama-3.1-70b-instruct.Q4_K_M.gguf
```

#### Step 4: Restart LocalAI

```bash
# If running as Docker container
docker restart local-ai

# If running as systemd service
sudo systemctl restart localai

# If running manually
# Kill existing process and restart
pkill localai
# Start LocalAI with your usual command
```

#### Step 5: Test Model

**Health Check:**

```bash
# List available models
curl http://localhost:8080/v1/models
```

**Expected output:**
```json
{
  "object": "list",
  "data": [
    {
      "id": "llama-3.1-70b-pentesting",
      "object": "model",
      "created": 1700000000,
      "owned_by": "localai"
    }
  ]
}
```

**Test Chat Completion:**

```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.1-70b-pentesting",
    "messages": [
      {
        "role": "system",
        "content": "You are a cybersecurity expert specializing in penetration testing."
      },
      {
        "role": "user",
        "content": "What tools would you recommend for subdomain enumeration during a bug bounty engagement?"
      }
    ],
    "temperature": 0.7,
    "max_tokens": 500
  }'
```

**Expected response:**
```json
{
  "id": "chatcmpl-xxx",
  "object": "chat.completion",
  "created": 1700000000,
  "model": "llama-3.1-70b-pentesting",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "For subdomain enumeration in bug bounty programs, I recommend:\n\n1. **amass** - Comprehensive OSINT-based subdomain discovery\n2. **subfinder** - Fast passive subdomain enumeration\n3. **assetfinder** - Simple but effective subdomain finder\n4. **crt.sh** - Certificate transparency logs\n5. **dnsenum** - DNS enumeration tool\n\nBest practice: Use multiple tools and correlate results for comprehensive coverage. Always ensure you're within the program's scope before scanning."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 45,
    "completion_tokens": 120,
    "total_tokens": 165
  }
}
```

**Performance Check:**

```bash
# Test inference speed
time curl -s http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.1-70b-pentesting",
    "messages": [{"role": "user", "content": "Say hello"}],
    "max_tokens": 50
  }' | jq '.choices[0].message.content'
```

**Expected timing:**
- CPU-only: 5-10 seconds
- Hybrid GPU: 2-4 seconds
- Full GPU: 1-2 seconds

### GPU Optimization

If you have an NVIDIA GPU, optimize layer offloading:

**Check GPU Memory:**

```bash
nvidia-smi
```

**Adjust gpu_layers based on VRAM:**

| VRAM | Recommended gpu_layers | RAM Needed |
|------|----------------------|------------|
| 8GB  | 0 (CPU-only)         | 40GB       |
| 12GB | 15-20                | 35GB       |
| 16GB | 30-35                | 30GB       |
| 24GB | 45-50                | 24GB       |
| 48GB+ | 60 (full GPU)       | 16GB       |

**Edit configuration:**

```bash
nano /path/to/localai/models/llama-3.1-70b-pentesting.yaml
```

Change:
```yaml
parameters:
  gpu_layers: 35  # Adjust based on table above
```

Restart LocalAI and test performance improvement.

---

## Option 2: DeepSeek-R1 33B (Advanced)

### Why DeepSeek-R1?

**Cybersecurity Specialization:**
- Top-ranked for threat analysis and exploit development
- Advanced reasoning via reinforcement learning (comparable to OpenAI o1)
- Excellent at code analysis and vulnerability discovery

**Technical Specs:**
- **Architecture:** Mixture of Experts (MoE)
- **Total Parameters:** 671B (33B activated per token)
- **Context Window:** 164K tokens
- **Quantization:** Q4_K_M or Q5_K_M

### Installation

```bash
# Download DeepSeek-R1 GGUF
cd ~/ai-models
wget https://huggingface.co/models/TheBloke/DeepSeek-R1-GGUF/resolve/main/deepseek-r1.Q4_K_M.gguf

# Copy to LocalAI
cp deepseek-r1.Q4_K_M.gguf /path/to/localai/models/
```

**Configuration:**

```yaml
name: deepseek-r1-cybersec
model: deepseek-r1.Q4_K_M.gguf
backend: llama-cpp

parameters:
  model: deepseek-r1.Q4_K_M.gguf
  context_size: 164000  # Full 164K context
  gpu_layers: 40
  threads: 8
  temperature: 0.7

template:
  chat: deepseek
  completion: deepseek

capabilities:
  chat: true
  completion: true
  function_calling: true
```

**Note:** DeepSeek-R1 may require latest llama.cpp backend. Verify LocalAI compatibility first:

```bash
# Check LocalAI version
docker exec local-ai localai --version

# Update LocalAI if needed
docker pull quay.io/go-skynet/local-ai:latest
```

---

## Option 3: Mistral 7B (Lightweight)

### Why Mistral 7B?

**Resource Efficiency:**
- Runs on consumer hardware (8GB RAM)
- Fast inference even on CPU
- Good performance for its size

**Best For:**
- Testing workflows before deploying larger models
- Resource-constrained environments
- Quick tool orchestration tasks

### Installation

```bash
# Download Mistral 7B Instruct
cd ~/ai-models
wget https://huggingface.co/models/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf

# Copy to LocalAI
cp mistral-7b-instruct-v0.2.Q4_K_M.gguf /path/to/localai/models/
```

**Configuration:**

```yaml
name: mistral-7b-pentesting
model: mistral-7b-instruct-v0.2.Q4_K_M.gguf
backend: llama-cpp

parameters:
  model: mistral-7b-instruct-v0.2.Q4_K_M.gguf
  context_size: 32000
  gpu_layers: 50  # Can fit entire model on 8GB VRAM
  threads: 8
  temperature: 0.7

template:
  chat: mistral
  completion: mistral

capabilities:
  chat: true
  completion: true
  function_calling: true
```

---

## LocalAI Installation

If you don't have LocalAI installed yet:

### Docker Installation (Recommended)

```bash
# Pull LocalAI image
docker pull quay.io/go-skynet/local-ai:latest

# Create directory structure
mkdir -p ~/localai/models

# Run LocalAI
docker run -d \
  --name local-ai \
  --restart unless-stopped \
  -p 8080:8080 \
  -v ~/localai/models:/models \
  --gpus all \
  quay.io/go-skynet/local-ai:latest
```

**Without GPU:**
```bash
# Remove --gpus all flag
docker run -d \
  --name local-ai \
  --restart unless-stopped \
  -p 8080:8080 \
  -v ~/localai/models:/models \
  quay.io/go-skynet/local-ai:latest
```

### Verify Installation

```bash
# Check container is running
docker ps | grep local-ai

# Test API
curl http://localhost:8080/v1/models
```

---

## Integration with HexStrike-AI

### Workflow: LocalAI + HexStrike-AI

Once both are running:

```
1. User interacts with AI client (Claude Desktop, custom client, etc.)
2. AI client calls LocalAI for reasoning and planning
3. AI client calls HexStrike-AI MCP server to execute tools
4. Results flow back to AI client for analysis
5. AI client uses LocalAI to generate reports/recommendations
```

### Example Python Integration

```python
#!/usr/bin/env python3
"""
HexStrike-AI + LocalAI Integration Example
"""

from openai import OpenAI
import requests

# LocalAI client
localai = OpenAI(
    base_url="http://192.168.0.52:8080/v1",
    api_key="not-needed"
)

# HexStrike-AI MCP server
HEXSTRIKE_URL = "http://192.168.0.XX:8888/api"

def ai_pentesting_workflow(target):
    """
    AI-driven pentesting using LocalAI for reasoning
    and HexStrike-AI for tool execution
    """

    # Step 1: Use LocalAI to plan the attack
    plan_response = localai.chat.completions.create(
        model="llama-3.1-70b-pentesting",
        messages=[
            {
                "role": "system",
                "content": "You are a penetration testing expert. Plan systematic security assessments."
            },
            {
                "role": "user",
                "content": f"Create a pentesting plan for {target}. List tools and steps."
            }
        ]
    )

    plan = plan_response.choices[0].message.content
    print(f"[Plan]\n{plan}\n")

    # Step 2: Execute tools via HexStrike-AI
    # (Implementation depends on HexStrike-AI API)
    result = requests.post(
        f"{HEXSTRIKE_URL}/intelligence/analyze-target",
        json={"target": target, "workflow": "comprehensive_pentest"}
    )

    findings = result.json()

    # Step 3: Use LocalAI to analyze results
    analysis_response = localai.chat.completions.create(
        model="llama-3.1-70b-pentesting",
        messages=[
            {
                "role": "system",
                "content": "Analyze pentesting results and prioritize vulnerabilities."
            },
            {
                "role": "user",
                "content": f"Analyze these findings:\n{findings}\n\nProvide:\n1. Critical vulnerabilities\n2. Risk assessment\n3. Remediation steps"
            }
        ]
    )

    analysis = analysis_response.choices[0].message.content
    print(f"[Analysis]\n{analysis}\n")

    return {
        "plan": plan,
        "findings": findings,
        "analysis": analysis
    }

# Example usage
if __name__ == "__main__":
    results = ai_pentesting_workflow("example.com")
```

---

## Performance Tuning

### Optimizing Inference Speed

**1. Batch Processing**

```yaml
parameters:
  batch_size: 512  # Increase for faster throughput
```

**2. Reduce Context Window (if not needed)**

```yaml
parameters:
  context_size: 32000  # Instead of 128000 for shorter conversations
```

**3. Adjust Temperature for Faster Generation**

```yaml
parameters:
  temperature: 0.5  # Lower = more deterministic, slightly faster
```

**4. Enable Memory Mapping**

```yaml
parameters:
  mmap: true  # Map model file to memory
  mlock: true # Lock memory pages (requires enough RAM)
```

### Monitoring Performance

**CPU Usage:**
```bash
htop
# Look for localai process CPU usage
```

**GPU Usage:**
```bash
watch -n 1 nvidia-smi
# Monitor GPU memory and utilization
```

**Inference Metrics:**
```bash
# Test tokens per second
curl -s -w "\nTime: %{time_total}s\n" \
  http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.1-70b-pentesting",
    "messages": [{"role": "user", "content": "Generate a 100-word paragraph about cybersecurity."}],
    "max_tokens": 150
  }' | jq -r '.choices[0].message.content'
```

---

## Troubleshooting

### Issue 1: Model Loads But Inference is Extremely Slow

**Symptoms:**
- 30+ seconds per response
- High RAM usage, low GPU usage

**Solution:**

```bash
# Check gpu_layers setting
grep "gpu_layers" /path/to/localai/models/*.yaml

# Increase GPU offloading
nano /path/to/localai/models/llama-3.1-70b-pentesting.yaml
# Change: gpu_layers: 35 (or higher based on VRAM)

# Restart LocalAI
docker restart local-ai
```

### Issue 2: Out of Memory Errors

**Symptoms:**
```
Error: Failed to allocate memory for model
```

**Solution:**

```bash
# Option 1: Use smaller quantization
# Q4_K_M instead of Q5_K_M
cp llama-3.1-70b-instruct.Q4_K_M.gguf /path/to/localai/models/

# Option 2: Reduce context size
parameters:
  context_size: 32000  # Instead of 128000

# Option 3: Enable memory optimization
parameters:
  mmap: true
  mlock: false  # Don't lock memory if RAM is limited
```

### Issue 3: GPU Not Being Used

**Symptoms:**
- `nvidia-smi` shows 0% GPU usage
- Inference using only CPU

**Solution:**

```bash
# Verify GPU is accessible to Docker
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

# If error, install nvidia-container-toolkit
sudo apt install nvidia-container-toolkit
sudo systemctl restart docker

# Restart LocalAI with GPU
docker stop local-ai
docker rm local-ai
docker run -d \
  --name local-ai \
  --restart unless-stopped \
  -p 8080:8080 \
  -v ~/localai/models:/models \
  --gpus all \
  quay.io/go-skynet/local-ai:latest
```

### Issue 4: Model Not Appearing in /v1/models

**Symptoms:**
- Curl shows empty model list
- 404 errors when trying to use model

**Solution:**

```bash
# Check model file exists
ls -lh /path/to/localai/models/

# Verify YAML filename matches model name
# File should be: llama-3.1-70b-pentesting.yaml
# Model GGUF referenced in YAML should exist

# Check LocalAI logs
docker logs local-ai | tail -50

# Restart LocalAI
docker restart local-ai

# Wait 30 seconds for model to load
sleep 30
curl http://localhost:8080/v1/models
```

---

## Security Considerations

### Model Security

**1. Sensitive Data Handling**

Local LLMs process data entirely locally, but:
- Don't feed sensitive credentials to the model
- Clear conversation history containing sensitive info
- Monitor model outputs for data leakage

**2. Model Provenance**

Download models only from trusted sources:
- ✅ HuggingFace verified accounts (TheBloke, Meta, etc.)
- ✅ Official model repositories
- ❌ Unknown mirrors or third-party sites

**3. Network Isolation**

LocalAI should only be accessible from trusted devices:

```bash
# Bind to localhost only (most secure)
docker run -p 127.0.0.1:8080:8080 ...

# Bind to specific network interface
docker run -p 192.168.0.52:8080:8080 ...

# Use firewall rules
sudo ufw allow from 192.168.0.0/24 to any port 8080
```

---

## Next Steps

### Phase 1: Install Llama 3.1 70B (Today)

- [ ] Download Q4_K_M model (~26GB)
- [ ] Create LocalAI configuration
- [ ] Test inference speed
- [ ] Optimize GPU settings

### Phase 2: Integration Testing (This Week)

- [ ] Test with HexStrike-AI workflows
- [ ] Benchmark performance vs cloud APIs
- [ ] Fine-tune parameters for cybersecurity tasks
- [ ] Document optimal settings

### Phase 3: Advanced Optimization (Next Week)

- [ ] Experiment with DeepSeek-R1
- [ ] Compare model performance on pentesting tasks
- [ ] Create custom prompts for security workflows
- [ ] Build automated model switching logic

---

## Resources

- [LocalAI Documentation](https://localai.io/docs/)
- [Llama 3.1 Model Card](https://huggingface.co/meta-llama/Meta-Llama-3.1-70B-Instruct)
- [GGUF Quantization Guide](https://github.com/ggerganov/llama.cpp/blob/master/docs/quantization.md)
- [TheBloke HuggingFace](https://huggingface.co/TheBloke) - Trusted GGUF models
- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp) - Backend used by LocalAI

---

**Created by:** isolomonleecode
**Last Updated:** November 22, 2025
**Status:** Production Ready
**Next Action:** Download Llama 3.1 70B and configure LocalAI
