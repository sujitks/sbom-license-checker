#!/bin/bash
# Quick fix for SBOM tool permission issues in DevContainer

echo "🔧 SBOM Tool Permission Fix"
echo "============================"

# Check current user
CURRENT_USER=$(whoami)
echo "Current user: $CURRENT_USER"

# Check if dotnet is available
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET CLI not found!"
    exit 1
fi

echo "✅ .NET CLI found: $(which dotnet)"

# Check current .NET tools
echo ""
echo "📋 Current .NET tools:"
dotnet tool list --global || echo "No tools installed globally"

# Install SBOM tool for current user if not present
echo ""
echo "📦 Installing/updating SBOM tool..."
dotnet tool install --global Microsoft.Sbom.DotNetTool --verbosity quiet || \
dotnet tool update --global Microsoft.Sbom.DotNetTool --verbosity quiet

# Verify installation
echo ""
echo "🔍 Verifying SBOM tool installation..."
if dotnet tool list --global | grep -q "microsoft.sbom.dottool"; then
    echo "✅ SBOM tool is installed"
    
    # Find the tool path
    if [ "$CURRENT_USER" = "root" ]; then
        DOTNET_TOOLS_PATH="/root/.dotnet/tools"
    else
        DOTNET_TOOLS_PATH="/home/$CURRENT_USER/.dotnet/tools"
    fi
    
    echo "📂 Tools directory: $DOTNET_TOOLS_PATH"
    
    # Check if the tool is executable
    if [ -f "$DOTNET_TOOLS_PATH/dotnet-sbom-tool" ]; then
        echo "✅ SBOM tool binary found and accessible"
        ls -la "$DOTNET_TOOLS_PATH/dotnet-sbom-tool"
        
        # Test the tool
        echo ""
        echo "🧪 Testing SBOM tool..."
        export PATH="$DOTNET_TOOLS_PATH:$PATH"
        dotnet sbom-tool --version && echo "✅ SBOM tool working!" || echo "⚠️ SBOM tool test failed"
    else
        echo "⚠️ SBOM tool binary not found in expected location"
        ls -la "$DOTNET_TOOLS_PATH/" || echo "Tools directory not accessible"
    fi
else
    echo "❌ SBOM tool installation failed"
    exit 1
fi

# Set up environment
echo ""
echo "🌍 Setting up environment..."
echo "export PATH=\"$DOTNET_TOOLS_PATH:\$PATH\"" >> ~/.bashrc
echo "alias sbom-tool='dotnet sbom-tool'" >> ~/.bashrc

# Create convenience aliases
echo ""
echo "🔗 Creating convenience aliases..."
ln -sf /app/entrypoint.sh /usr/local/bin/sbom-scanner 2>/dev/null && echo "✅ sbom-scanner link created" || echo "⚠️ Could not create sbom-scanner link"
ln -sf /app/entrypoint.sh /usr/local/bin/sbom 2>/dev/null && echo "✅ sbom link created" || echo "⚠️ Could not create sbom link"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Available commands:"
echo "  dotnet sbom-tool     - Direct .NET SBOM tool"
echo "  sbom-scanner         - Full SBOM scanner (recommended)"
echo "  sbom                 - Short alias for sbom-scanner"
echo "  /app/entrypoint.sh   - Direct entrypoint (always works)"
echo ""
echo "🧪 Test with:"
echo "  sbom-scanner --version"
echo "  sbom --type auto --path /workspace/test-projects"