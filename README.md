# Opencode Headless on Render Free Tier

Deploy a persistent `opencode serve` instance on Render's free tier with free models and websearch capabilities.

## Quick Deploy

### Option 1: One-click (Recommended)
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/YOUR_USERNAME/opencode-render-deploy)

### Option 2: Manual
1. Fork this repo
2. Connect to Render → New Web Service → Docker
3. Set env vars:
   - `OPENCODE_SERVER_PASSWORD` (auto-generated)
   - `NVIDIA_API_KEY` (optional, for NVIDIA models)

## What's Included

- **Free Models**: deepseek-v4-flash-free, hy3-free, nemotron-3-ultra-free, nemotron-3.5-lightning-free, nvidia/nemotron-3-ultra-550b-a55b, nvidia/nemotron-3-super-120b-a12b
- **Web Search**: `websearch` permission enabled
- **Browser Automation**: Playwright MCP for dynamic sites
- **Docs Lookup**: Context7 MCP for library docs
- **Code Search**: grep.app MCP

## Usage After Deploy

```bash
# Get your URL from Render dashboard (e.g., https://opencode-headless.onrender.com)
export OPENCODE_REMOTE=https://opencode-headless.onrender.com

# Test a free model
opencode run --attach $OPENCODE_REMOTE --auto -m opencode/deepseek-v4-flash-free "Hello"

# Use web-researcher agent (has websearch + browser)
opencode run --attach $OPENCODE_REMOTE --auto --agent web-researcher "Latest React 19 features"

# Attach TUI
opencode attach $OPENCODE_REMOTE
```

## Test Locally First

```bash
# Requires Docker
docker-compose up --build

# Test
python test_models.py http://localhost:4096
```

## Auto-Deploy

Push to `main` → GitHub Actions deploys to Render automatically.

Add these secrets to GitHub repo:
- `RENDER_API_KEY` (your Render API key)
- `RENDER_SERVICE_ID` (from Render dashboard after first deploy)

## Config

Edit `opencode.jsonc` to add/remove models. The whitelist controls what `-m provider/model` can use.

## Free Tier Limits

- 750 hours/month (enough for 24/7)
- Spins down after 15 min inactivity (cold start ~30s)
- 512 MB RAM, 0.5 CPU
- Custom domain supported