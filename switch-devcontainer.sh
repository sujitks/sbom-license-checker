#!/bin/bash
# DevContainer Configuration Switcher
# Usage: ./switch-devcontainer.sh [config-name]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVCONTAINER_DIR="$SCRIPT_DIR/.devcontainer"

show_help() {
    echo "🐳 DevContainer Configuration Switcher"
    echo ""
    echo "Available configurations:"
    echo "  minimal     - Minimal config with sbom user (default)"
    echo "  root        - Same as minimal but uses root user (if having user issues)"
    echo "  production  - Production config with Git/GitHub CLI features"
    echo "  dev         - Development config that builds locally"
    echo "  simple      - Simple config with base Microsoft image"
    echo ""
    echo "Usage: $0 [config-name]"
    echo "Example: $0 minimal"
    echo ""
    echo "Current configuration:"
    if [ -f "$DEVCONTAINER_DIR/devcontainer.json" ]; then
        grep '"name"' "$DEVCONTAINER_DIR/devcontainer.json" | sed 's/.*"name": *"\([^"]*\)".*/  \1/'
    else
        echo "  No configuration active"
    fi
}

switch_config() {
    local config_name="$1"
    local source_file=""
    
    case "$config_name" in
        "minimal")
            source_file="devcontainer.minimal.json"
            ;;
        "root")
            source_file="devcontainer.root.json"
            ;;
        "production")
            source_file="devcontainer.production.json"
            ;;
        "dev")
            source_file="devcontainer.dev.json"
            ;;
        "simple")
            source_file="devcontainer.simple.json"
            ;;
        *)
            echo "❌ Unknown configuration: $config_name"
            show_help
            exit 1
            ;;
    esac
    
    if [ ! -f "$DEVCONTAINER_DIR/$source_file" ]; then
        echo "❌ Configuration file not found: $source_file"
        exit 1
    fi
    
    # Backup current config
    if [ -f "$DEVCONTAINER_DIR/devcontainer.json" ]; then
        cp "$DEVCONTAINER_DIR/devcontainer.json" "$DEVCONTAINER_DIR/devcontainer.backup.json"
        echo "📦 Backed up current configuration to devcontainer.backup.json"
    fi
    
    # Switch to new config
    cp "$DEVCONTAINER_DIR/$source_file" "$DEVCONTAINER_DIR/devcontainer.json"
    
    echo "✅ Switched to '$config_name' configuration"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Open VS Code: code ."
    echo "  2. Command Palette: 'Dev Containers: Rebuild Container'"
    echo "  3. Or restart VS Code and select 'Reopen in Container'"
    echo ""
    echo "🔧 If you have issues:"
    echo "  - Try: $0 minimal (most compatible)"
    echo "  - Or: $0 simple (builds from scratch)"
}

# Main logic
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

switch_config "$1"