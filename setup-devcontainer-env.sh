#!/bin/bash
# DevContainer Environment Setup
# Source this file to set up SBOM scanner aliases and environment

echo "🔧 Setting up SBOM Scanner environment in DevContainer..."

# Ensure .NET SBOM tool is available for current user
echo "🔧 Checking .NET SBOM tool installation..."
if ! dotnet tool list --global | grep -q "microsoft.sbom.dottool"; then
    echo "📦 Installing .NET SBOM tool for current user..."
    dotnet tool install --global Microsoft.Sbom.DotNetTool --verbosity quiet || echo "⚠️  SBOM tool installation failed, will use alternative methods"
fi

# Create symlink for sbom-scanner command
if [ ! -f "/usr/local/bin/sbom-scanner" ]; then
    if [ -w "/usr/local/bin" ] || sudo -n true 2>/dev/null; then
        sudo ln -sf /app/entrypoint.sh /usr/local/bin/sbom-scanner 2>/dev/null || {
            echo "⚠️  Could not create symlink in /usr/local/bin, using alias instead"
            alias sbom-scanner='/app/entrypoint.sh'
        }
    else
        alias sbom-scanner='/app/entrypoint.sh'
    fi
fi

# Create convenient aliases
alias sbom='sbom-scanner'
alias sbom-help='sbom-scanner --help'
alias sbom-version='sbom-scanner --version'
alias sbom-auto='sbom-scanner --type auto --verbose'

# Set up environment variables
export SBOM_OUTPUT_DIR="/workspace/sbom-reports"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Add to PATH if not already there
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    export PATH="/usr/local/bin:$PATH"
fi

if [[ ":$PATH:" != *":/app:"* ]]; then
    export PATH="/app:$PATH"
fi

# Add .NET tools to PATH for current user
CURRENT_USER=$(whoami)
if [ "$CURRENT_USER" = "root" ]; then
    DOTNET_TOOLS_PATH="/root/.dotnet/tools"
else
    DOTNET_TOOLS_PATH="/home/$CURRENT_USER/.dotnet/tools"
fi

if [[ ":$PATH:" != *":$DOTNET_TOOLS_PATH:"* ]] && [ -d "$DOTNET_TOOLS_PATH" ]; then
    export PATH="$DOTNET_TOOLS_PATH:$PATH"
fi

# Verify setup
echo "✅ SBOM Scanner environment ready!"
echo ""
echo "📋 Available commands:"
echo "  sbom-scanner    - Main SBOM scanner command"
echo "  sbom            - Short alias for sbom-scanner"  
echo "  sbom-help       - Show help"
echo "  sbom-version    - Show version"
echo "  sbom-auto       - Auto-detect and scan with verbose output"
echo ""
echo "🧪 Quick test:"
echo "  sbom-scanner --version"
echo "  sbom --type auto --path /workspace/test-projects"
echo ""

# Test if the command works
if command -v sbom-scanner >/dev/null 2>&1; then
    echo "🎉 Setup successful! SBOM Scanner is ready to use."
else
    echo "⚠️  Setup incomplete. You can still use: /app/entrypoint.sh"
    echo "   Try running: source /workspace/setup-devcontainer-env.sh"
fi