# DevContainer Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: "container is not running" or User Permission Errors

**Symptoms:**
- `Error response from daemon: container [ID] is not running`
- `An error occurred setting up the container`
- User `sbom` not found errors

**Solutions (try in order):**

1. **Clean up Docker containers**:
   ```bash
   # Remove any stuck DevContainer containers
   docker ps -a | grep vsc-
   docker rm $(docker ps -a -q --filter "name=vsc-")
   
   # Clean up Docker system
   docker system prune -f
   ```

2. **Switch to root user configuration**:
   ```bash
   ./switch-devcontainer.sh root
   # Then rebuild container in VS Code
   ```

3. **Pull latest image**:
   ```bash
   docker pull ghcr.io/sujitks/sbom-scanner:latest
   ```

4. **Complete VS Code reset**:
   - Close VS Code completely
   - Remove DevContainer cache:
     ```bash
     rm -rf ~/Library/Application\ Support/Code/User/globalStorage/ms-vscode-remote.remote-containers
     ```
   - Restart VS Code and try again

### Issue 2: SBOM Commands Not Available or Permission Denied

**Symptoms:**
- `permission denied` for sbom-tool
- `dotnet sbom-tool: command not found`
- SBOM scanner fails to execute

**Solutions:**
1. **Run the permission fix script**:
   ```bash
   ./fix-sbom-permissions.sh
   ```

2. **Run environment setup**:
   ```bash
   source /workspace/setup-devcontainer-env.sh
   ```

3. **Manual .NET tool installation**:
   ```bash
   dotnet tool install --global Microsoft.Sbom.DotNetTool
   export PATH="/root/.dotnet/tools:$PATH"  # or /home/username/.dotnet/tools
   ```

4. **Use full path**:
   ```bash
   /app/entrypoint.sh --version
   ```

5. **Manual alias setup**:
   ```bash
   alias sbom='/app/entrypoint.sh'
   echo 'alias sbom="/app/entrypoint.sh"' >> ~/.bashrc
   ```

### Issue 3: Build or Feature Installation Failures

**Solutions:**
1. **Use minimal configuration**:
   ```bash
   ./switch-devcontainer.sh minimal
   ```

2. **Use simple configuration (builds from scratch)**:
   ```bash
   ./switch-devcontainer.sh simple
   ```

3. **Disable features temporarily**:
   Edit `.devcontainer/devcontainer.json` and set `"features": {}`

### Issue 4: Docker Desktop Problems

**Solutions:**
1. **Restart Docker Desktop**
2. **Update to latest version**
3. **Check Docker is running**:
   ```bash
   docker version
   docker ps
   ```

4. **Reset Docker Desktop** (if needed):
   - Docker Desktop → Troubleshoot → Reset to factory defaults

## Configuration Priority (Most → Least Compatible)

1. **Root** - Uses root user, most compatible
2. **Minimal** - Uses sbom user, minimal features  
3. **Simple** - Builds from base Microsoft image
4. **Production** - Includes Git/GitHub CLI features
5. **Dev** - Builds locally, most complex

## Quick Recovery Commands

```bash
# 1. Clean everything
docker system prune -af && ./switch-devcontainer.sh root

# 2. Force rebuild in VS Code
# Command Palette: "Dev Containers: Rebuild Container Without Cache"

# 3. If VS Code issues persist
# Restart VS Code completely and try: "Dev Containers: Reopen in Container"

# 4. Last resort - use Docker directly
docker run -it --rm -v $(pwd):/workspace ghcr.io/sujitks/sbom-scanner:latest /bin/bash
```

## Testing Your DevContainer

Once successfully started:

```bash
# Test basic functionality
whoami
pwd
ls -la /workspace

# Test SBOM scanner
sbom-scanner --version || /app/entrypoint.sh --version
sbom --help || /app/entrypoint.sh --help

# Test with sample projects
sbom-scanner --type auto --path /workspace/test-projects --verbose
```

## When All Else Fails

If DevContainer continues to fail, you can still use the Docker image directly:

```bash
# Option 1: Interactive session
docker run -it --rm -v $(pwd):/workspace ghcr.io/sujitks/sbom-scanner:latest /bin/bash

# Option 2: Direct scanning
docker run --rm -v $(pwd):/workspace ghcr.io/sujitks/sbom-scanner:latest --type auto --path /workspace

# Option 3: Use local quick-test script
cd docker-sbom-scanner
./quick-test.sh
```