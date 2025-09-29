#!/bin/bash

# Docker SBOM Scanner Entry Point
# Author: Sujit Singh
# Purpose: Handle command-line arguments and route to appropriate scanner

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Default values
PROJECT_TYPE="auto"
SCAN_PATH="/workspace"
OUTPUT_PATH="/app/output"
VERBOSE=false
SHOW_HELP=false

# Version information
VERSION="1.0.0"
BUILD_DATE="$(date +%Y-%m-%d)"

# Usage function
show_help() {
    cat << EOF
${PURPLE}Docker SBOM Scanner v$VERSION${NC}
${CYAN}Multi-language SBOM generation and license scanning tool${NC}

${YELLOW}USAGE:${NC}
    docker run [docker-options] sbom-scanner [OPTIONS] [PATH]

${YELLOW}OPTIONS:${NC}
    -t, --type TYPE         Project type: dotnet, nodejs, python, auto (default: auto)
    -p, --path PATH         Path to scan (default: /workspace)
    -o, --output PATH       Output directory (default: /app/output)  
    -v, --verbose           Enable verbose output
    -h, --help             Show this help message
    --version              Show version information

${YELLOW}PROJECT TYPES:${NC}
    ${GREEN}dotnet${NC}             Scan .NET projects (.csproj, .sln files)
    ${GREEN}nodejs${NC}             Scan Node.js projects (package.json files)
    ${GREEN}python${NC}             Scan Python projects (requirements.txt, setup.py, pyproject.toml)
    ${GREEN}auto${NC}               Auto-detect project type(s) and scan all found

${YELLOW}EXAMPLES:${NC}
    # Auto-detect and scan current directory
    docker run -v \$(pwd):/workspace sbom-scanner

    # Scan specific .NET project
    docker run -v \$(pwd):/workspace sbom-scanner --type dotnet

    # Scan with custom output directory
    docker run -v \$(pwd):/workspace -v \$(pwd)/reports:/output sbom-scanner --output /output

    # Verbose scanning with specific path
    docker run -v \$(pwd):/workspace sbom-scanner --verbose --path /workspace/src

${YELLOW}AZURE DEVOPS USAGE:${NC}
    # Use in pipeline task
    - task: Docker@2
      displayName: 'SBOM License Scan'
      inputs:
        command: 'run'
        arguments: '-v \$(Build.SourcesDirectory):/workspace -v \$(Build.ArtifactStagingDirectory):/output sbom-scanner --type \$(ProjectType) --output /output'

${YELLOW}OUTPUT FILES:${NC}
    - ${CYAN}*-sbom.spdx.json${NC}        SPDX 2.3 compliant SBOM files
    - ${CYAN}scan-report.md${NC}          Comprehensive scan report
    - ${CYAN}*-reports/${NC}              Detailed analysis reports per project type

${YELLOW}SUPPORTED FILE TYPES:${NC}
    ${GREEN}.NET:${NC}      *.csproj, *.sln, *.fsproj, *.vbproj
    ${GREEN}Node.js:${NC}   package.json  
    ${GREEN}Python:${NC}    requirements.txt, setup.py, pyproject.toml, Pipfile

${YELLOW}ENVIRONMENT VARIABLES:${NC}
    SBOM_OUTPUT_DIR         Override default output directory
    SBOM_TEMP_DIR           Override temporary directory
    GITHUB_TOKEN            GitHub API token for enhanced license resolution
    SCAN_TIMEOUT            Scanner timeout in seconds (default: 1800)

EOF
}

show_version() {
    cat << EOF
${PURPLE}Docker SBOM Scanner${NC}
Version: $VERSION
Build Date: $BUILD_DATE
License: MIT
Author: Sujit Singh

${CYAN}Supported Technologies:${NC}
- .NET SDK 9.0
- Node.js v20+
- Python 3.13+
- Microsoft SBOM Tool
- SPDX 2.3 Standard

${CYAN}Container Base:${NC}
- Base Image: mcr.microsoft.com/dotnet/sdk:9.0-alpine
- Architecture: linux/amd64, linux/arm64
- Security: Non-root user execution
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                PROJECT_TYPE="$2"
                shift 2
                ;;
            -p|--path)
                SCAN_PATH="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_PATH="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                SHOW_HELP=true
                shift
                ;;
            --version)
                show_version
                exit 0
                ;;
            -*)
                echo -e "${RED}Error: Unknown option $1${NC}" >&2
                echo -e "${YELLOW}Use --help for usage information${NC}" >&2
                exit 1
                ;;
            *)
                # Positional argument - treat as path
                SCAN_PATH="$1"
                shift
                ;;
        esac
    done
}

# Validate arguments
validate_args() {
    # Validate project type
    case "$PROJECT_TYPE" in
        dotnet|nodejs|python|auto)
            ;;
        *)
            echo -e "${RED}Error: Invalid project type '$PROJECT_TYPE'${NC}" >&2
            echo -e "${YELLOW}Supported types: dotnet, nodejs, python, auto${NC}" >&2
            exit 1
            ;;
    esac
    
    # Validate scan path exists
    if [ ! -d "$SCAN_PATH" ]; then
        echo -e "${RED}Error: Scan path does not exist: $SCAN_PATH${NC}" >&2
        exit 1
    fi
    
    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_PATH"
    
    # Export for scanner script
    export SBOM_OUTPUT_DIR="$OUTPUT_PATH"
    export SBOM_TEMP_DIR="/app/temp"
    export SBOM_SCAN_PATH="$SCAN_PATH"
    export SBOM_PROJECT_TYPE="$PROJECT_TYPE"
    export SBOM_VERBOSE="$VERBOSE"
}

# Setup logging
setup_logging() {
    if [ "$VERBOSE" = "true" ]; then
        set -x
        export SBOM_DEBUG=1
    fi
    
    # Log startup information
    echo -e "${PURPLE}================================================================${NC}"
    echo -e "${PURPLE}              DOCKER SBOM SCANNER v$VERSION${NC}"
    echo -e "${PURPLE}================================================================${NC}"
    echo -e "${CYAN}Scan Configuration:${NC}"
    echo -e "  ${YELLOW}Project Type:${NC} $PROJECT_TYPE"
    echo -e "  ${YELLOW}Scan Path:${NC} $SCAN_PATH"
    echo -e "  ${YELLOW}Output Path:${NC} $OUTPUT_PATH"
    echo -e "  ${YELLOW}Verbose Mode:${NC} $VERBOSE"
    echo -e "${PURPLE}================================================================${NC}"
}

# Health check function
health_check() {
    echo -e "${BLUE}Performing health check...${NC}"
    
    local health_status=0
    
    # Check .NET SDK
    if dotnet --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ .NET SDK available${NC}"
    else
        echo -e "${RED}✗ .NET SDK not available${NC}"
        health_status=1
    fi
    
    # Check SBOM Tool (try multiple approaches)
    if command -v sbom-tool >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SBOM Tool available via command${NC}"
    elif /home/sbom/.dotnet/tools/sbom-tool --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SBOM Tool available in sbom user path${NC}"
    elif /root/.dotnet/tools/sbom-tool --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SBOM Tool available in root path${NC}"
    else
        echo -e "${RED}✗ SBOM Tool not available${NC}"
        echo -e "${YELLOW}Attempting to locate dotnet tools...${NC}"
        find /home /root -name "sbom-tool" 2>/dev/null | head -5
        health_status=1
    fi
    
    # Check Node.js
    if node --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Node.js available${NC}"
    else
        echo -e "${RED}✗ Node.js not available${NC}"
        health_status=1
    fi
    
    # Check Python
    if python3 --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Python available${NC}"
    else
        echo -e "${RED}✗ Python not available${NC}"
        health_status=1
    fi
    
    # Check jq
    if jq --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ jq available${NC}"
    else
        echo -e "${RED}✗ jq not available${NC}"
        health_status=1
    fi
    
    if [ $health_status -eq 0 ]; then
        echo -e "${GREEN}✅ All dependencies available${NC}"
    else
        echo -e "${RED}❌ Some dependencies missing${NC}"
        exit 1
    fi
}

# Signal handlers
cleanup() {
    echo -e "${YELLOW}Cleaning up temporary files...${NC}"
    # Only cleanup if scanner completed or failed, don't cleanup during processing
    if [ "${SCANNER_RUNNING}" != "true" ]; then
        rm -rf /app/temp/* 2>/dev/null || true
    fi
}

# Set up signal traps  
trap 'export SCANNER_RUNNING="false"; cleanup' EXIT
trap 'echo -e "${RED}Interrupted by user${NC}"; export SCANNER_RUNNING="false"; cleanup; exit 130' INT TERM

# Main entry point
main() {
    # If first argument is /bin/bash or sh, execute it directly
    if [ "$1" = "/bin/bash" ] || [ "$1" = "/bin/sh" ] || [ "$1" = "bash" ] || [ "$1" = "sh" ]; then
        exec "$@"
        return
    fi
    
    # Parse arguments
    parse_args "$@"
    
    # Show help if requested
    if [ "$SHOW_HELP" = "true" ]; then
        show_help
        exit 0
    fi
    
    # Validate arguments
    validate_args
    
    # Setup environment
    setup_logging
    
    # Ensure dotnet tools are in PATH
    export PATH="$PATH:/home/sbom/.dotnet/tools:/root/.dotnet/tools:/app/venv/bin"
    
    # Perform health check
    health_check
    
    # Set timeout for scanner
    export SCAN_TIMEOUT="${SCAN_TIMEOUT:-1800}"
    
    # Run the scanner
    echo -e "${BLUE}Starting SBOM scanner...${NC}"
    
    # Mark scanner as running
    export SCANNER_RUNNING="true"
    
    # Execute scanner with timeout
    if timeout "$SCAN_TIMEOUT" /app/scanner.sh "$SCAN_PATH" "$PROJECT_TYPE"; then
        export SCANNER_RUNNING="false"
        echo -e "${GREEN}✅ SBOM scan completed successfully!${NC}"
        
        # Display output summary
        echo -e "${CYAN}Generated files:${NC}"
        find "$OUTPUT_PATH" -type f -name "*.spdx.json" -o -name "*.md" -o -name "*.txt" | while read -r file; do
            local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "unknown")
            echo -e "  ${YELLOW}$(basename "$file")${NC} ($size bytes)"
        done
        
        # Now cleanup temp files
        cleanup
        exit 0
    else
        local exit_code=$?
        export SCANNER_RUNNING="false"
        if [ $exit_code -eq 124 ]; then
            echo -e "${RED}❌ Scanner timed out after $SCAN_TIMEOUT seconds${NC}"
        else
            echo -e "${RED}❌ Scanner failed with exit code $exit_code${NC}"
        fi
        cleanup
        exit $exit_code
    fi
}

# Check if script is being sourced or executed
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi