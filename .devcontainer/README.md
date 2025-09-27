# SBOM Scanner Development Container

This directory contains development container configurations for the SBOM Scanner project.

## 🐳 Available Configurations

### Production Image (`devcontainer.json`)
Uses the published Docker image from GitHub Container Registry.

**Features:**
- Pre-built image with all SBOM tools
- Fast startup time
- Consistent environment
- Automatic updates with image releases

**Usage:**
```bash
# Open in VS Code
code .
# Select "Reopen in Container" when prompted
# Or use Command Palette: "Dev Containers: Reopen in Container"
```

### Development Build (`devcontainer.dev.json`)
Builds the Docker image locally from source.

**Features:**
- Local development and testing
- Immediate reflection of Dockerfile changes
- Full development tools included
- Docker-in-Docker for testing

**Usage:**
```bash
# Open specific devcontainer config
code .
# Command Palette: "Dev Containers: Reopen in Container"
# Select "SBOM Scanner Development" configuration
```

## 🚀 Quick Start

### 1. Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### 2. Open in Development Container

**Option A: Use Published Image (Recommended)**
```bash
git clone <your-repo>
cd sbom-check
code .
# Select "Reopen in Container" when prompted
```

**Option B: Use Development Build**
```bash
git clone <your-repo>
cd sbom-check
# Copy the dev config as default
cp .devcontainer/devcontainer.dev.json .devcontainer/devcontainer.json
code .
# Select "Reopen in Container" when prompted
```

### 3. Verify Installation
Once the container starts:
```bash
# Check SBOM scanner version
sbom-scanner --version

# Test with sample projects
sbom-scanner --type auto --path /workspace/test-projects --verbose

# Run development tests
cd /workspace/docker-sbom-scanner
./quick-test.sh
```

## 📁 Container Features

### Pre-installed Tools
- ✅ .NET SDK 9.0
- ✅ Node.js 20+ with npm
- ✅ Python 3.13+ with pip
- ✅ Microsoft SBOM Tool
- ✅ jq for JSON processing
- ✅ Git and GitHub CLI
- ✅ Docker (in development config)

### VS Code Extensions
- **Language Support**: C#, TypeScript, Python
- **DevOps**: Docker, YAML, JSON
- **AI Assistant**: GitHub Copilot
- **Utilities**: PowerShell, Ansible

### Environment Variables
```bash
SBOM_OUTPUT_DIR=/workspace/sbom-reports
DOTNET_CLI_TELEMETRY_OPTOUT=1
DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
NODE_ENV=development
```

## 🔧 Customization

### Adding Extensions
Edit `.devcontainer/devcontainer.json`:
```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "your.extension.id"
      ]
    }
  }
}
```

### Environment Variables
```json
{
  "containerEnv": {
    "YOUR_VAR": "your_value"
  }
}
```

### Port Forwarding
```json
{
  "forwardPorts": [3000, 5000],
  "portsAttributes": {
    "3000": {
      "label": "Your App"
    }
  }
}
```

## 📊 Usage Examples

### Scan Current Workspace
```bash
# Auto-detect project types
sbom-scanner --type auto --path /workspace --output /workspace/sbom-reports --verbose

# Scan specific project type
sbom-scanner --type dotnet --path /workspace/MyApp --verbose
```

### Development Workflow
```bash
# Test changes to the scanner
cd /workspace/docker-sbom-scanner
./build.sh --verbose
./test.sh --verbose

# Test with sample projects
sbom-scanner --type auto --path /workspace/test-projects
```

### Azure DevOps Testing
```bash
# Test pipeline templates locally
cd /workspace/docker-sbom-scanner/azure-devops
# Review pipeline configurations
code sbom-scan-template.yml
```

## 🐛 Troubleshooting

### Container Won't Start
```bash
# Check Docker is running
docker version

# Rebuild container
# Command Palette: "Dev Containers: Rebuild Container"
```

### Docker Build Errors (RUN --mount issues)
If you see errors like `ERROR [dev_containers_target_stage 6/6] RUN --mount=type=bind`, try these solutions:

**Option 1: Use Simple Development Config**
```bash
# Copy the simple config
cp .devcontainer/devcontainer.simple.json .devcontainer/devcontainer.json
# Command Palette: "Dev Containers: Rebuild Container"
```

**Option 2: Use Production Image Instead**
```bash
# Revert to production config
git checkout .devcontainer/devcontainer.json
# Command Palette: "Dev Containers: Reopen in Container"
```

**Option 3: Update Docker Desktop**
```bash
# Make sure you have Docker Desktop 4.0+ with BuildKit support
docker version
# Update Docker Desktop if needed
```

### Permission Issues
```bash
# Fix ownership in container
sudo chown -R sbom:sbom /workspace

# Or start as root user temporarily
# Edit devcontainer.json: "remoteUser": "root"
```

### SBOM Command Not Found
If you get "sbom: command not found" or similar errors:

```bash
# Option 1: Use full path directly
/app/entrypoint.sh --version
/app/entrypoint.sh --type auto --path /workspace/test-projects

# Option 2: Run the environment setup
source /workspace/setup-devcontainer-env.sh

# Option 3: Create alias manually
alias sbom-scanner='/app/entrypoint.sh'
alias sbom='/app/entrypoint.sh'

# Option 4: Rebuild container
# Command Palette: "Dev Containers: Rebuild Container"
```

### SBOM Generation Fails
```bash
# Check logs
sbom-scanner --verbose --type auto --path /workspace

# Verify project files
ls -la /workspace/test-projects/*/
```

### Docker-in-Docker Issues
```bash
# Check Docker socket
docker ps

# Restart Docker service
sudo service docker restart
```

## 🔗 Related Documentation

- [Docker SBOM Scanner README](../docker-sbom-scanner/README.md)
- [Azure DevOps Integration](../docker-sbom-scanner/azure-devops/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)

## 🚀 Publishing Updates

When you make changes to the Docker image:

1. **Update version in GitHub Actions**
2. **Push changes to trigger build**
3. **Update devcontainer.json image tag** (if using specific version)
4. **Test in fresh container**

```bash
# Update to specific version
"image": "ghcr.io/sujitks/sbom-scanner:v1.1.0"

# Or use latest (auto-updates)
"image": "ghcr.io/sujitks/sbom-scanner:latest"
```