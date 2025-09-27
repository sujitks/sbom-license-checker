#!/bin/bash

# Universal SBOM Scanner Script
# Author: Sujit Singh
# Purpose: Generate SBOM and license reports for .NET, Node.js, and Python projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="${SBOM_OUTPUT_DIR:-$(pwd)/sbom-reports}"
TEMP_DIR="${SBOM_TEMP_DIR:-$(pwd)/temp}"
SCAN_PATH="${1:-$(pwd)}"
PROJECT_TYPE="${2:-auto}"

# API Configuration for license resolution
CLEARLYDEFINED_API="https://api.clearlydefined.io/definitions"
GITHUB_API="https://api.github.com/repos"
NUGET_API="https://api.nuget.org/v3-flatcontainer"

# Create output directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✓${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠${NC} $1"
}

# Auto-detect project type
detect_project_type() {
    local scan_path="$1"
    local detected_types=()
    
    log "Auto-detecting project type in: $scan_path"
    
    # Check for .NET projects
    if find "$scan_path" -name "*.csproj" -o -name "*.sln" -o -name "*.fsproj" -o -name "*.vbproj" 2>/dev/null | head -1 | grep -q .; then
        detected_types+=("dotnet")
    fi
    
    # Check for Node.js projects
    if find "$scan_path" -name "package.json" 2>/dev/null | head -1 | grep -q .; then
        detected_types+=("nodejs")
    fi
    
    # Check for Python projects
    if find "$scan_path" -name "requirements.txt" -o -name "setup.py" -o -name "pyproject.toml" -o -name "Pipfile" 2>/dev/null | head -1 | grep -q .; then
        detected_types+=("python")
    fi
    
    if [ ${#detected_types[@]} -eq 0 ]; then
        log_error "No supported project types detected in $scan_path"
        log "Supported files: *.csproj, *.sln, package.json, requirements.txt, setup.py, pyproject.toml, Pipfile"
        return 1
    elif [ ${#detected_types[@]} -eq 1 ]; then
        echo "${detected_types[0]}" >&1
        return 0
    else
        log_warning "Multiple project types detected: ${detected_types[*]}"
        log "Will process all detected project types"
        echo "multi" >&1
        return 0
    fi
}

# Resolve license using multiple APIs
resolve_license() {
    local package_name="$1"
    local package_version="$2"
    local ecosystem="$3"
    
    # Try ClearlyDefined API first
    local namespace=""
    case "$ecosystem" in
        "nuget") namespace="nuget/nuget/-" ;;
        "npm") namespace="npm/npmjs/-" ;;
        "pypi") namespace="pypi/pypi/-" ;;
    esac
    
    if [ -n "$namespace" ]; then
        local clearly_defined_url="$CLEARLYDEFINED_API/$namespace/$package_name/$package_version"
        local license=$(curl -s "$clearly_defined_url" 2>/dev/null | jq -r '.licensed.declared // empty' 2>/dev/null)
        
        if [ -n "$license" ] && [ "$license" != "null" ]; then
            echo "$license"
            return 0
        fi
    fi
    
    # Comprehensive fallback license database
    case "$package_name" in
        # Microsoft packages
        Microsoft.*|Azure.*|System.*|AspNet*) echo "MIT" ;;
        
        # Popular .NET packages
        "Npgsql") echo "PostgreSQL" ;;
        Serilog*) echo "Apache-2.0" ;;
        "Newtonsoft.Json") echo "MIT" ;;
        "RestSharp") echo "Apache-2.0" ;;
        "Bogus") echo "MIT" ;;
        SkiaSharp*) echo "MIT" ;;
        "Aspose.Cells") echo "Proprietary" ;;
        AutoMapper*) echo "MIT" ;;
        FluentValidation*) echo "Apache-2.0" ;;
        Dapper*) echo "Apache-2.0" ;;
        NUnit*) echo "MIT" ;;
        xunit*) echo "Apache-2.0" ;;
        Moq*) echo "BSD-3-Clause" ;;
        Castle.*) echo "Apache-2.0" ;;
        log4net*) echo "Apache-2.0" ;;
        NLog*) echo "BSD-3-Clause" ;;
        Polly*) echo "BSD-3-Clause" ;;
        Swashbuckle*) echo "MIT" ;;
        MediatR*) echo "Apache-2.0" ;;
        StackExchange.Redis*) echo "MIT" ;;
        RabbitMQ*) echo "MPL-2.0" ;;
        MongoDB*) echo "Apache-2.0" ;;
        Elastic*) echo "Apache-2.0" ;;
        Hangfire*) echo "LGPL-3.0" ;;
        Quartz*) echo "Apache-2.0" ;;
        EPPlus*) echo "Polyform-Noncommercial-1.0.0" ;;
        ClosedXML*) echo "MIT" ;;
        CsvHelper*) echo "MS-PL" ;;
        
        # Generic patterns
        *apache*) echo "Apache-2.0" ;;
        *bsd*) echo "BSD-3-Clause" ;;
        *) echo "NOASSERTION" ;;
    esac
}

# Enhanced .NET SBOM generation with license resolution
scan_dotnet_project() {
    local project_path="$1"
    local output_file="$OUTPUT_DIR/dotnet-sbom.spdx.json"
    local report_dir="$OUTPUT_DIR/dotnet-reports"
    
    log "Scanning .NET project: $project_path"
    mkdir -p "$report_dir"
    
    # Find .NET project files
    local project_files=$(find "$project_path" -name "*.csproj" -o -name "*.sln" -o -name "*.fsproj" -o -name "*.vbproj")
    
    if [ -z "$project_files" ]; then
        log_error "No .NET project files found in $project_path"
        return 1
    fi
    
    local project_file=$(echo "$project_files" | head -1)
    local project_dir=$(dirname "$project_file")
    
    log "Found project file: $project_file"
    log "Project directory: $project_dir"
    log "Current working directory: $(pwd)"
    
    # Convert to absolute path first
    local abs_project_dir
    if [[ "$project_dir" = /* ]]; then
        abs_project_dir="$project_dir"
    else
        abs_project_dir="$(pwd)/$project_dir"
    fi
    
    log "Absolute project directory: $abs_project_dir"
    log "Restoring NuGet packages..."
    
    cd "$abs_project_dir"
    
    # Restore packages
    if ! dotnet restore --verbosity quiet; then
        log_error "Failed to restore NuGet packages"
        return 1
    fi
    
    # Generate SBOM using Microsoft SBOM Tool
    log "Generating SBOM with Microsoft SBOM Tool..."
    local temp_sbom="$TEMP_DIR/temp-sbom"
    mkdir -p "$temp_sbom"
    
    # Use absolute paths for SBOM tool (already set above)
    local abs_temp_sbom=$(mkdir -p "$temp_sbom" && cd "$temp_sbom" && pwd)
    
    if sbom-tool generate \
        -b "$abs_project_dir" \
        -bc "$abs_project_dir" \
        -pn "$(basename "$project_dir")" \
        -pv "1.0.0" \
        -ps "github.com" \
        -nsb "https://sbom.example.org" \
        -m "$abs_temp_sbom" \
        -V Information > "$report_dir/sbom-generation.log" 2>&1; then
        
        log_success "Basic SBOM generated successfully"
        
        # Find the generated SBOM file
        local generated_sbom=$(find "$temp_sbom" -name "*spdx.json" | head -1)
        
        if [ -n "$generated_sbom" ]; then
            # Enhance with license resolution
            log "Enhancing SBOM with license resolution..."
            
            local enhanced_sbom="$TEMP_DIR/enhanced-sbom.json"
            local license_mapping="$report_dir/license-mapping.json"
            
            # Create enhanced SBOM with comprehensive license resolution
            jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
                .creationInfo.created = $timestamp |
                .packages[] |= (
                    if .name then
                        .licenseConcluded = (
                            if .licenseConcluded == "NOASSERTION" or .licenseConcluded == null then
                                # Comprehensive license database for popular .NET packages
                                if (.name | test("^Microsoft\\.|^Azure\\.|^AspNet"; "i")) then "MIT"
                                elif (.name | test("^System\\.")) then "MIT"
                                elif (.name == "Npgsql") then "PostgreSQL"
                                elif (.name | test("^Serilog")) then "Apache-2.0"
                                elif (.name == "Newtonsoft.Json") then "MIT"
                                elif (.name == "RestSharp") then "Apache-2.0"
                                elif (.name == "Bogus") then "MIT"
                                elif (.name | test("^SkiaSharp")) then "MIT"
                                elif (.name == "Aspose.Cells") then "Proprietary"
                                elif (.name | test("^AutoMapper")) then "MIT"
                                elif (.name | test("^FluentValidation")) then "Apache-2.0"
                                elif (.name | test("^Dapper")) then "Apache-2.0"
                                elif (.name | test("^NUnit")) then "MIT"
                                elif (.name | test("^xunit")) then "Apache-2.0"
                                elif (.name | test("^Moq")) then "BSD-3-Clause"
                                elif (.name | test("^Castle\\.")) then "Apache-2.0"
                                elif (.name | test("^log4net")) then "Apache-2.0"
                                elif (.name | test("^NLog")) then "BSD-3-Clause"
                                elif (.name | test("^Polly")) then "BSD-3-Clause"
                                elif (.name | test("^Swashbuckle")) then "MIT"
                                elif (.name | test("^MediatR")) then "Apache-2.0"
                                elif (.name | test("^StackExchange\\.Redis")) then "MIT"
                                elif (.name | test("^RabbitMQ")) then "MPL-2.0"
                                elif (.name | test("^MongoDB")) then "Apache-2.0"
                                elif (.name | test("^Elastic")) then "Apache-2.0"
                                elif (.name | test("^Hangfire")) then "LGPL-3.0"
                                elif (.name | test("^Quartz")) then "Apache-2.0"
                                elif (.name | test("^EPPlus")) then "Polyform-Noncommercial-1.0.0"
                                elif (.name | test("^ClosedXML")) then "MIT"
                                elif (.name | test("^CsvHelper")) then "MS-PL"
                                elif (.name | test("^Apache"; "i")) then "Apache-2.0"  
                                elif (.name | test("^BSD"; "i")) then "BSD-3-Clause"
                                else "NOASSERTION"
                                end
                            else .licenseConcluded
                            end
                        ) |
                        .licenseDeclared = .licenseConcluded
                    else .
                    end
                )
            ' "$generated_sbom" > "$enhanced_sbom"
            
            # Copy enhanced SBOM to output
            cp "$enhanced_sbom" "$output_file"
            
            # Generate license summary
            jq -r '.packages[] | select(.name) | "\(.name): \(.licenseConcluded)"' "$enhanced_sbom" > "$report_dir/license-summary.txt"
            
            # Generate license statistics
            local total_packages=$(jq '.packages | length' "$enhanced_sbom")
            local resolved_licenses=$(jq -r '.packages[].licenseConcluded' "$enhanced_sbom" | grep -v "NOASSERTION" | wc -l)
            local success_rate=$(( resolved_licenses * 100 / total_packages ))
            
            cat > "$report_dir/scan-summary.txt" << EOF
.NET SBOM Scan Summary
=====================
Scan Date: $(date)
Project: $(basename "$project_dir")
Total Packages: $total_packages
Licenses Resolved: $resolved_licenses
Success Rate: $success_rate%

Generated Files:
- SBOM: dotnet-sbom.spdx.json
- License Summary: license-summary.txt
- Scan Log: sbom-generation.log
EOF
            
            log_success "Enhanced .NET SBOM completed (Success Rate: $success_rate%)"
            return 0
        else
            log_error "Generated SBOM file not found"
            return 1
        fi
    else
        log_error "SBOM generation failed"
        return 1
    fi
}

# Node.js SBOM generation
scan_nodejs_project() {
    local project_path="$1"
    local output_file="$OUTPUT_DIR/nodejs-sbom.spdx.json"
    local report_dir="$OUTPUT_DIR/nodejs-reports"
    
    log "Scanning Node.js project: $project_path"
    mkdir -p "$report_dir"
    
    # Find package.json files
    local package_files=$(find "$project_path" -name "package.json" -not -path "*/node_modules/*")
    
    if [ -z "$package_files" ]; then
        log_error "No package.json files found in $project_path"
        return 1
    fi
    
    local package_file=$(echo "$package_files" | head -1)
    local project_dir=$(dirname "$package_file")
    
    log "Found package.json: $package_file"
    
    cd "$project_dir"
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        log "Installing npm dependencies..."
        if ! npm install --silent; then
            log_error "Failed to install npm dependencies"
            return 1
        fi
    fi
    
    # Install license-checker locally if needed
    if [ ! -f "node_modules/.bin/license-checker" ]; then
        log "Installing license-checker..."
        npm install license-checker --no-save --silent
    fi
    
    # Generate license report
    log "Analyzing licenses with license-checker..."
    local license_file="$report_dir/npm-licenses.json"
    
    if ./node_modules/.bin/license-checker --json --out "$license_file" 2>/dev/null; then
        log_success "License analysis completed"
        
        # Generate SPDX SBOM
        local project_name=$(jq -r '.name // "unknown"' package.json)
        local project_version=$(jq -r '.version // "1.0.0"' package.json)
        
        cat > "$output_file" << EOF
{
  "spdxVersion": "SPDX-2.3",
  "creationInfo": {
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "creators": ["Tool: docker-sbom-scanner"]
  },
  "name": "$project_name",
  "SPDXID": "SPDXRef-DOCUMENT",
  "documentNamespace": "https://sbom.example.org/$project_name-$project_version",
  "packages": [
EOF
        
        # Add packages from license report
        local first=true
        jq -r 'to_entries[] | @json' "$license_file" | while read -r entry; do
            if [ "$first" = "true" ]; then
                first=false
            else
                echo "," >> "$output_file"
            fi
            
            local pkg_name=$(echo "$entry" | jq -r '.key' | cut -d'@' -f1)
            local pkg_version=$(echo "$entry" | jq -r '.key' | cut -d'@' -f2-)
            local pkg_license=$(echo "$entry" | jq -r '.value.licenses // "NOASSERTION"')
            
            cat >> "$output_file" << EOF_PKG
    {
      "name": "$pkg_name",
      "SPDXID": "SPDXRef-Package-$(echo "$pkg_name" | tr '[:lower:]' '[:upper:]' | tr -cd '[:alnum:]')",
      "versionInfo": "$pkg_version", 
      "downloadLocation": "NOASSERTION",
      "filesAnalyzed": false,
      "licenseConcluded": "$pkg_license",
      "licenseDeclared": "$pkg_license",
      "copyrightText": "NOASSERTION"
    }
EOF_PKG
        done
        
        echo "  ]" >> "$output_file"
        echo "}" >> "$output_file"
        
        # Generate summary
        local total_packages=$(jq 'length' "$license_file")
        local resolved_licenses=$(jq -r 'to_entries[].value.licenses' "$license_file" | grep -v "NOASSERTION\|null\|^$" | wc -l)
        local success_rate=$(( resolved_licenses * 100 / total_packages ))
        
        cat > "$report_dir/scan-summary.txt" << EOF
Node.js SBOM Scan Summary
========================
Scan Date: $(date)
Project: $project_name v$project_version
Total Packages: $total_packages
Licenses Resolved: $resolved_licenses
Success Rate: $success_rate%

Generated Files:
- SBOM: nodejs-sbom.spdx.json
- License Data: npm-licenses.json
EOF
        
        log_success "Node.js SBOM completed (Success Rate: $success_rate%)"
        return 0
    else
        log_error "License analysis failed"
        return 1
    fi
}

# Python SBOM generation
scan_python_project() {
    local project_path="$1"
    local output_file="$OUTPUT_DIR/python-sbom.spdx.json"
    local report_dir="$OUTPUT_DIR/python-reports"
    
    log "Scanning Python project: $project_path"
    mkdir -p "$report_dir"
    
    # Find Python requirement files
    local req_files=$(find "$project_path" -name "requirements.txt" -o -name "setup.py" -o -name "pyproject.toml" -o -name "Pipfile")
    
    if [ -z "$req_files" ]; then
        log_error "No Python requirement files found in $project_path"
        return 1
    fi
    
    local req_file=$(echo "$req_files" | grep requirements.txt | head -1)
    if [ -z "$req_file" ]; then
        req_file=$(echo "$req_files" | head -1)
    fi
    
    log "Found requirement file: $req_file"
    
    local project_dir=$(dirname "$req_file")
    cd "$project_dir"
    
    # Create and activate virtual environment for package installation
    local venv_dir="$TEMP_DIR/python-venv"
    log "Creating Python virtual environment..."
    
    if python3 -m venv "$venv_dir" 2>/dev/null; then
        log_success "Virtual environment created"
        
        # Activate virtual environment and install packages
        if [ -f "requirements.txt" ]; then
            log "Installing Python packages from requirements.txt..."
            if source "$venv_dir/bin/activate" && pip install -r requirements.txt --quiet && pip install pip-licenses --quiet; then
                log_success "Packages installed in virtual environment"
            else
                log_warning "Some packages may have failed to install, continuing with analysis..."
            fi
        fi
    else
        log_warning "Failed to create virtual environment, trying system-wide analysis..."
    fi
    
    # Generate license report using pip-licenses
    log "Analyzing licenses with pip-licenses..."
    local license_file="$report_dir/python-licenses.json"
    
    # Try to use virtual environment pip-licenses first, then fall back to system
    local pip_licenses_cmd="pip-licenses"
    if [ -f "$venv_dir/bin/pip-licenses" ]; then
        source "$venv_dir/bin/activate"
        pip_licenses_cmd="$venv_dir/bin/pip-licenses"
    elif [ -f "$venv_dir/bin/activate" ]; then
        source "$venv_dir/bin/activate"
    fi
    
    if $pip_licenses_cmd --format=json --output-file="$license_file" 2>/dev/null; then
        log_success "License analysis completed"
        
        # Generate SPDX SBOM
        local project_name=$(basename "$project_dir")
        
        cat > "$output_file" << EOF
{
  "spdxVersion": "SPDX-2.3",
  "creationInfo": {
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "creators": ["Tool: docker-sbom-scanner"]
  },
  "name": "$project_name",
  "SPDXID": "SPDXRef-DOCUMENT", 
  "documentNamespace": "https://sbom.example.org/$project_name-1.0.0",
  "packages": [
EOF
        
        # Add packages from license report
        local package_count=0
        cat "$license_file" | jq -r '.[] | @json' | while read -r entry; do
            if [ $package_count -gt 0 ]; then
                echo "," >> "$output_file"
            fi
            
            local pkg_name=$(echo "$entry" | jq -r '.Name')
            local pkg_version=$(echo "$entry" | jq -r '.Version')
            local pkg_license=$(echo "$entry" | jq -r '.License // "NOASSERTION"')
            
            cat >> "$output_file" << EOF_PKG
    {
      "name": "$pkg_name",
      "SPDXID": "SPDXRef-Package-$(echo "$pkg_name" | tr '[:lower:]' '[:upper:]' | tr -cd '[:alnum:]')",
      "versionInfo": "$pkg_version",
      "downloadLocation": "NOASSERTION",
      "filesAnalyzed": false,
      "licenseConcluded": "$pkg_license",
      "licenseDeclared": "$pkg_license", 
      "copyrightText": "NOASSERTION"
    }
EOF_PKG
            ((package_count++))
        done
        
        echo "  ]" >> "$output_file"
        echo "}" >> "$output_file"
        
        # Generate summary
        local total_packages=$(cat "$license_file" | jq '. | length')
        local resolved_licenses=$(cat "$license_file" | jq -r '.[].License' | grep -v "NOASSERTION\|Unknown\|^$" | wc -l)
        local success_rate=$(( resolved_licenses * 100 / total_packages ))
        
        cat > "$report_dir/scan-summary.txt" << EOF
Python SBOM Scan Summary
=======================
Scan Date: $(date)
Project: $project_name
Total Packages: $total_packages
Licenses Resolved: $resolved_licenses
Success Rate: $success_rate%

Generated Files:
- SBOM: python-sbom.spdx.json
- License Data: python-licenses.json
EOF
        
        log_success "Python SBOM completed (Success Rate: $success_rate%)"
        return 0
    else
        log_error "License analysis failed"
        return 1
    fi
}

# Main scanner function
main_scan() {
    local scan_path="$1"
    local project_type="$2"
    
    echo -e "${PURPLE}================================================================${NC}"
    echo -e "${PURPLE}              DOCKER SBOM SCANNER v1.0                         ${NC}"
    echo -e "${PURPLE}================================================================${NC}"
    log "Starting SBOM scan..."
    log "Scan path: $scan_path"
    log "Project type: $project_type"
    
    # Validate scan path
    if [ ! -d "$scan_path" ]; then
        log_error "Scan path does not exist: $scan_path"
        exit 1
    fi
    
    # Auto-detect project type if needed
    if [ "$project_type" = "auto" ]; then
        detected=$(detect_project_type "$scan_path" 2>&1)
        project_type=$(echo "$detected" | tail -1)
        log "Detected project type: $project_type"
    fi
    
    # Scan based on project type
    local scan_success=false
    
    case "$project_type" in
        "dotnet")
            if scan_dotnet_project "$scan_path"; then
                scan_success=true
            fi
            ;;
        "nodejs")
            if scan_nodejs_project "$scan_path"; then
                scan_success=true
            fi
            ;;
        "python")
            if scan_python_project "$scan_path"; then
                scan_success=true
            fi
            ;;
        "multi")
            # Scan all detected project types
            local multi_success=false
            
            if find "$scan_path" -name "*.csproj" -o -name "*.sln" | head -1 | grep -q .; then
                log "Scanning .NET components..."
                if scan_dotnet_project "$scan_path"; then
                    multi_success=true
                fi
            fi
            
            if find "$scan_path" -name "package.json" | head -1 | grep -q .; then
                log "Scanning Node.js components..."
                if scan_nodejs_project "$scan_path"; then
                    multi_success=true
                fi
            fi
            
            if find "$scan_path" -name "requirements.txt" -o -name "setup.py" | head -1 | grep -q .; then
                log "Scanning Python components..."
                if scan_python_project "$scan_path"; then
                    multi_success=true
                fi
            fi
            
            scan_success=$multi_success
            ;;
        *)
            log_error "Unsupported project type: $project_type"
            log "Supported types: dotnet, nodejs, python, auto"
            exit 1
            ;;
    esac
    
    # Generate final report
    if [ "$scan_success" = true ]; then
        cat > "$OUTPUT_DIR/scan-report.md" << EOF
# SBOM Scan Report

**Generated:** $(date)  
**Scanner:** Docker SBOM Scanner v1.0  
**Scan Path:** $scan_path  
**Project Type:** $project_type  

## Generated Files

EOF
        
        find "$OUTPUT_DIR" -name "*.spdx.json" | while read -r file; do
            echo "- [$(basename "$file")]($file)" >> "$OUTPUT_DIR/scan-report.md"
        done
        
        echo "" >> "$OUTPUT_DIR/scan-report.md"
        echo "## Detailed Reports" >> "$OUTPUT_DIR/scan-report.md"
        echo "" >> "$OUTPUT_DIR/scan-report.md"
        
        find "$OUTPUT_DIR" -name "*-reports" -type d | while read -r dir; do
            echo "### $(basename "$dir")" >> "$OUTPUT_DIR/scan-report.md"
            find "$dir" -name "*.txt" | while read -r file; do
                echo "- [$(basename "$file")]($file)" >> "$OUTPUT_DIR/scan-report.md"
            done
        done
        
        log_success "SBOM scan completed successfully!"
        log "Output directory: $OUTPUT_DIR"
        log "Report: $OUTPUT_DIR/scan-report.md"
        
        echo -e "${GREEN}================================================================${NC}"
        echo -e "${GREEN}                    SCAN COMPLETED                             ${NC}"
        echo -e "${GREEN}================================================================${NC}"
        
        exit 0
    else
        log_error "SBOM scan failed!"
        exit 1
    fi
}

# Run main scan
main_scan "$SCAN_PATH" "$PROJECT_TYPE"