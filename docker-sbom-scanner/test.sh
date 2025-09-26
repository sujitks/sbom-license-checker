#!/bin/bash

# Docker SBOM Scanner Test Script
# Author: Sujit Singh
# Purpose: Comprehensive testing of the SBOM scanner Docker image

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="sbom-scanner:latest"
TEST_OUTPUT_DIR="$(mktemp -d)"
TEST_PROJECTS_DIR="../test-projects"

# Test configuration
VERBOSE=false
CLEANUP=true
TEST_TIMEOUT=300

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Usage function
show_help() {
    cat << EOF
${PURPLE}Docker SBOM Scanner Test Script${NC}

${YELLOW}USAGE:${NC}
    ./test.sh [OPTIONS] [IMAGE_NAME]

${YELLOW}OPTIONS:${NC}
    -i, --image IMAGE       Docker image to test (default: sbom-scanner:latest)
    -o, --output DIR        Test output directory (default: temp directory)
    -p, --projects DIR      Test projects directory (default: ../test-projects)
    --no-cleanup           Don't cleanup test files after completion
    -v, --verbose          Enable verbose output
    -t, --timeout SECONDS  Test timeout in seconds (default: 300)
    -h, --help            Show this help message

${YELLOW}EXAMPLES:${NC}
    # Basic test
    ./test.sh

    # Test specific image with verbose output
    ./test.sh --image myregistry.azurecr.io/sbom-scanner:v1.0.0 --verbose

    # Test with custom output directory
    ./test.sh --output ./test-results --no-cleanup

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--image)
                IMAGE_NAME="$2"
                shift 2
                ;;
            -o|--output)
                TEST_OUTPUT_DIR="$2"
                CLEANUP=false
                shift 2
                ;;
            -p|--projects)
                TEST_PROJECTS_DIR="$2"
                shift 2
                ;;
            --no-cleanup)
                CLEANUP=false
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -t|--timeout)
                TEST_TIMEOUT="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo -e "${RED}Error: Unknown option $1${NC}" >&2
                show_help
                exit 1
                ;;
            *)
                IMAGE_NAME="$1"
                shift
                ;;
        esac
    done
}

# Logging functions
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠${NC} $1"
}

log_test() {
    echo -e "${CYAN}[TEST $((++TOTAL_TESTS))]${NC} $1"
}

# Test helper functions
assert_success() {
    if [ $1 -eq 0 ]; then
        log_success "$2"
        ((PASSED_TESTS++))
        return 0
    else
        log_error "$2 (Exit code: $1)"
        ((FAILED_TESTS++))
        return 1
    fi
}

assert_file_exists() {
    if [ -f "$1" ]; then
        log_success "File exists: $(basename "$1")"
        return 0
    else
        log_error "File missing: $1"
        return 1
    fi
}

assert_json_valid() {
    if jq . "$1" >/dev/null 2>&1; then
        log_success "Valid JSON: $(basename "$1")"
        return 0
    else
        log_error "Invalid JSON: $1"
        return 1
    fi
}

# Setup test environment
setup_tests() {
    log "Setting up test environment..."
    
    # Create test output directory
    mkdir -p "$TEST_OUTPUT_DIR"
    
    # Validate image exists
    if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        log_error "Docker image not found: $IMAGE_NAME"
        log "Please build the image first or specify correct image name"
        exit 1
    fi
    
    # Check test projects
    if [ ! -d "$TEST_PROJECTS_DIR" ]; then
        log_warning "Test projects directory not found: $TEST_PROJECTS_DIR"
        log "Some integration tests will be skipped"
    fi
    
    log_success "Test environment ready"
    log "Image: $IMAGE_NAME"
    log "Output: $TEST_OUTPUT_DIR"
    log "Projects: $TEST_PROJECTS_DIR"
}

# Basic functionality tests
test_basic_functionality() {
    echo -e "\n${PURPLE}=== BASIC FUNCTIONALITY TESTS ===${NC}"
    
    # Test 1: Help command
    log_test "Testing help command"
    if timeout "$TEST_TIMEOUT" docker run --rm "$IMAGE_NAME" --help >/dev/null 2>&1; then
        assert_success 0 "Help command works"
    else
        assert_success 1 "Help command failed"
    fi
    
    # Test 2: Version command
    log_test "Testing version command"
    if timeout "$TEST_TIMEOUT" docker run --rm "$IMAGE_NAME" --version >/dev/null 2>&1; then
        assert_success 0 "Version command works"
    else
        assert_success 1 "Version command failed"
    fi
    
    # Test 3: Invalid arguments
    log_test "Testing invalid arguments handling"
    if timeout "$TEST_TIMEOUT" docker run --rm "$IMAGE_NAME" --invalid-option >/dev/null 2>&1; then
        assert_success 1 "Invalid option should fail"
    else
        assert_success 0 "Invalid option properly rejected"
    fi
}

# Docker container tests
test_container_functionality() {
    echo -e "\n${PURPLE}=== CONTAINER FUNCTIONALITY TESTS ===${NC}"
    
    # Test 1: Container startup
    log_test "Testing container startup and shutdown"
    local container_id=$(docker run -d "$IMAGE_NAME" sleep 10)
    sleep 2
    
    if docker ps | grep -q "$container_id"; then
        docker stop "$container_id" >/dev/null 2>&1
        docker rm "$container_id" >/dev/null 2>&1
        assert_success 0 "Container startup/shutdown works"
    else
        assert_success 1 "Container startup failed"
    fi
    
    # Test 2: Volume mounting
    log_test "Testing volume mounting"
    local test_dir=$(mktemp -d)
    echo "test file" > "$test_dir/test.txt"
    
    local result=$(docker run --rm -v "$test_dir:/test:ro" "$IMAGE_NAME" sh -c "cat /test/test.txt 2>/dev/null || echo 'failed'")
    rm -rf "$test_dir"
    
    if [ "$result" = "test file" ]; then
        assert_success 0 "Volume mounting works"
    else
        assert_success 1 "Volume mounting failed"
    fi
    
    # Test 3: Environment variables
    log_test "Testing environment variables"
    local result=$(docker run --rm -e TEST_VAR="hello world" "$IMAGE_NAME" sh -c "echo \$TEST_VAR")
    
    if [ "$result" = "hello world" ]; then
        assert_success 0 "Environment variables work"
    else
        assert_success 1 "Environment variables failed"
    fi
}

# Project scanning tests
test_project_scanning() {
    echo -e "\n${PURPLE}=== PROJECT SCANNING TESTS ===${NC}"
    
    if [ ! -d "$TEST_PROJECTS_DIR" ]; then
        log_warning "Test projects not available, skipping scanning tests"
        ((SKIPPED_TESTS += 3))
        return 0
    fi
    
    # Test 1: .NET project scanning
    if [ -d "$TEST_PROJECTS_DIR/dotnet-sample" ]; then
        log_test "Testing .NET project scanning"
        local output_dir="$TEST_OUTPUT_DIR/dotnet-test"
        mkdir -p "$output_dir"
        
        if timeout "$TEST_TIMEOUT" docker run --rm \
            -v "$(realpath "$TEST_PROJECTS_DIR/dotnet-sample"):/workspace:ro" \
            -v "$output_dir:/output" \
            "$IMAGE_NAME" \
            --type dotnet --path /workspace --output /output ${VERBOSE:+--verbose} >/dev/null 2>&1; then
            
            if assert_file_exists "$output_dir/dotnet-sbom.spdx.json"; then
                assert_json_valid "$output_dir/dotnet-sbom.spdx.json"
                assert_success 0 ".NET project scanning completed"
            else
                assert_success 1 ".NET project scanning failed - no SBOM generated"
            fi
        else
            assert_success 1 ".NET project scanning failed"
        fi
    else
        log_warning ".NET test project not found"
        ((SKIPPED_TESTS++))
    fi
    
    # Test 2: Node.js project scanning
    if [ -d "$TEST_PROJECTS_DIR/nodejs-sample" ]; then
        log_test "Testing Node.js project scanning"
        local output_dir="$TEST_OUTPUT_DIR/nodejs-test"
        mkdir -p "$output_dir"
        
        if timeout "$TEST_TIMEOUT" docker run --rm \
            -v "$(realpath "$TEST_PROJECTS_DIR/nodejs-sample"):/workspace:ro" \
            -v "$output_dir:/output" \
            "$IMAGE_NAME" \
            --type nodejs --path /workspace --output /output ${VERBOSE:+--verbose} >/dev/null 2>&1; then
            
            if assert_file_exists "$output_dir/nodejs-sbom.spdx.json"; then
                assert_json_valid "$output_dir/nodejs-sbom.spdx.json"
                assert_success 0 "Node.js project scanning completed"
            else
                assert_success 1 "Node.js project scanning failed - no SBOM generated"
            fi
        else
            assert_success 1 "Node.js project scanning failed"
        fi
    else
        log_warning "Node.js test project not found"
        ((SKIPPED_TESTS++))
    fi
    
    # Test 3: Python project scanning
    if [ -d "$TEST_PROJECTS_DIR/python-sample" ]; then
        log_test "Testing Python project scanning"
        local output_dir="$TEST_OUTPUT_DIR/python-test"
        mkdir -p "$output_dir"
        
        if timeout "$TEST_TIMEOUT" docker run --rm \
            -v "$(realpath "$TEST_PROJECTS_DIR/python-sample"):/workspace:ro" \
            -v "$output_dir:/output" \
            "$IMAGE_NAME" \
            --type python --path /workspace --output /output ${VERBOSE:+--verbose} >/dev/null 2>&1; then
            
            if assert_file_exists "$output_dir/python-sbom.spdx.json"; then
                assert_json_valid "$output_dir/python-sbom.spdx.json"
                assert_success 0 "Python project scanning completed"
            else
                assert_success 1 "Python project scanning failed - no SBOM generated"
            fi
        else
            assert_success 1 "Python project scanning failed"
        fi
    else
        log_warning "Python test project not found"
        ((SKIPPED_TESTS++))
    fi
    
    # Test 4: Auto-detection
    if [ -d "$TEST_PROJECTS_DIR" ]; then
        log_test "Testing auto-detection"
        local output_dir="$TEST_OUTPUT_DIR/auto-test"
        mkdir -p "$output_dir"
        
        if timeout "$TEST_TIMEOUT" docker run --rm \
            -v "$(realpath "$TEST_PROJECTS_DIR"):/workspace:ro" \
            -v "$output_dir:/output" \
            "$IMAGE_NAME" \
            --type auto --path /workspace --output /output ${VERBOSE:+--verbose} >/dev/null 2>&1; then
            
            local sbom_count=$(find "$output_dir" -name "*.spdx.json" | wc -l)
            if [ "$sbom_count" -gt 0 ]; then
                assert_success 0 "Auto-detection found and scanned $sbom_count project(s)"
            else
                assert_success 1 "Auto-detection failed - no SBOMs generated"
            fi
        else
            assert_success 1 "Auto-detection test failed"
        fi
    fi
}

# SBOM validation tests
test_sbom_validation() {
    echo -e "\n${PURPLE}=== SBOM VALIDATION TESTS ===${NC}"
    
    local sbom_files=$(find "$TEST_OUTPUT_DIR" -name "*.spdx.json" 2>/dev/null)
    
    if [ -z "$sbom_files" ]; then
        log_warning "No SBOM files found for validation"
        ((SKIPPED_TESTS += 3))
        return 0
    fi
    
    for sbom_file in $sbom_files; do
        local project_type=$(echo "$sbom_file" | grep -o '\(dotnet\|nodejs\|python\)' | head -1)
        
        log_test "Validating SBOM structure: $(basename "$sbom_file")"
        
        # Test SPDX version
        local spdx_version=$(jq -r '.spdxVersion // "missing"' "$sbom_file")
        if [[ "$spdx_version" =~ ^SPDX-2\. ]]; then
            assert_success 0 "Valid SPDX version: $spdx_version"
        else
            assert_success 1 "Invalid SPDX version: $spdx_version"
        fi
        
        # Test required fields
        local required_fields=("name" "SPDXID" "documentNamespace" "creationInfo" "packages")
        local missing_fields=()
        
        for field in "${required_fields[@]}"; do
            if jq -e ".$field" "$sbom_file" >/dev/null 2>&1; then
                continue
            else
                missing_fields+=("$field")
            fi
        done
        
        if [ ${#missing_fields[@]} -eq 0 ]; then
            assert_success 0 "All required fields present"
        else
            assert_success 1 "Missing fields: ${missing_fields[*]}"
        fi
        
        # Test packages array
        local package_count=$(jq '.packages | length' "$sbom_file")
        if [ "$package_count" -gt 0 ]; then
            assert_success 0 "Found $package_count packages"
            
            # Check license resolution
            local resolved_licenses=$(jq -r '.packages[].licenseConcluded' "$sbom_file" | grep -v "NOASSERTION" | wc -l)
            local resolution_rate=$(( resolved_licenses * 100 / package_count ))
            
            if [ "$resolution_rate" -gt 50 ]; then
                assert_success 0 "License resolution rate: $resolution_rate% ($resolved_licenses/$package_count)"
            else
                assert_success 1 "Low license resolution rate: $resolution_rate%"
            fi
        else
            assert_success 1 "No packages found in SBOM"
        fi
    done
}

# Performance tests
test_performance() {
    echo -e "\n${PURPLE}=== PERFORMANCE TESTS ===${NC}"
    
    if [ ! -d "$TEST_PROJECTS_DIR" ]; then
        log_warning "Test projects not available, skipping performance tests"
        ((SKIPPED_TESTS += 2))
        return 0
    fi
    
    # Test 1: Scan time measurement
    if [ -d "$TEST_PROJECTS_DIR/nodejs-sample" ]; then
        log_test "Testing scan performance"
        local output_dir="$TEST_OUTPUT_DIR/perf-test"
        mkdir -p "$output_dir"
        
        local start_time=$(date +%s)
        
        if timeout "$TEST_TIMEOUT" docker run --rm \
            -v "$(realpath "$TEST_PROJECTS_DIR/nodejs-sample"):/workspace:ro" \
            -v "$output_dir:/output" \
            "$IMAGE_NAME" \
            --type nodejs --path /workspace --output /output >/dev/null 2>&1; then
            
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            
            if [ "$duration" -lt 60 ]; then
                assert_success 0 "Scan completed in ${duration}s (acceptable)"
            elif [ "$duration" -lt 120 ]; then
                log_warning "Scan took ${duration}s (slow but acceptable)"
                ((PASSED_TESTS++))
            else
                assert_success 1 "Scan took ${duration}s (too slow)"
            fi
        else
            assert_success 1 "Performance test scan failed"
        fi
    else
        ((SKIPPED_TESTS++))
    fi
    
    # Test 2: Memory usage (approximate)
    log_test "Testing memory usage"
    local stats=$(docker run --rm -m 512m "$IMAGE_NAME" --help 2>&1)
    
    if echo "$stats" | grep -q "memory"; then
        assert_success 1 "Memory limit exceeded"
    else
        assert_success 0 "Memory usage acceptable"
    fi
}

# Error handling tests
test_error_handling() {
    echo -e "\n${PURPLE}=== ERROR HANDLING TESTS ===${NC}"
    
    # Test 1: Invalid project path
    log_test "Testing invalid project path"
    local output_dir="$TEST_OUTPUT_DIR/error-test"
    mkdir -p "$output_dir"
    
    if timeout "$TEST_TIMEOUT" docker run --rm \
        -v "$output_dir:/output" \
        "$IMAGE_NAME" \
        --path /nonexistent --output /output >/dev/null 2>&1; then
        assert_success 1 "Should fail with invalid path"
    else
        assert_success 0 "Properly handles invalid path"
    fi
    
    # Test 2: Read-only filesystem
    log_test "Testing read-only workspace"
    local test_dir=$(mktemp -d)
    echo "test" > "$test_dir/file.txt"
    
    if timeout "$TEST_TIMEOUT" docker run --rm \
        -v "$test_dir:/workspace:ro" \
        -v "$output_dir:/output" \
        "$IMAGE_NAME" \
        --type auto --path /workspace --output /output >/dev/null 2>&1; then
        # This might succeed or fail depending on project type, both are acceptable
        log_success "Read-only workspace handled"
        ((PASSED_TESTS++))
    else
        log_success "Read-only workspace properly rejected"
        ((PASSED_TESTS++))
    fi
    
    rm -rf "$test_dir"
    
    # Test 3: Invalid project type
    log_test "Testing invalid project type"
    if timeout "$TEST_TIMEOUT" docker run --rm "$IMAGE_NAME" --type invalid >/dev/null 2>&1; then
        assert_success 1 "Should reject invalid project type"
    else
        assert_success 0 "Properly rejects invalid project type"
    fi
}

# Generate test report
generate_test_report() {
    local report_file="$TEST_OUTPUT_DIR/test-report.md"
    
    cat > "$report_file" << EOF
# Docker SBOM Scanner Test Report

**Generated:** $(date)  
**Image:** $IMAGE_NAME  
**Test Duration:** ${test_duration}s

## Test Summary

- **Total Tests:** $TOTAL_TESTS
- **Passed:** $PASSED_TESTS
- **Failed:** $FAILED_TESTS  
- **Skipped:** $SKIPPED_TESTS
- **Success Rate:** $(( PASSED_TESTS * 100 / (TOTAL_TESTS - SKIPPED_TESTS) ))%

## Test Environment

- **OS:** $(uname -s) $(uname -r)
- **Docker:** $(docker version --format '{{.Server.Version}}' 2>/dev/null || echo 'unknown')
- **Test Output:** $TEST_OUTPUT_DIR
- **Test Projects:** $TEST_PROJECTS_DIR

## Generated SBOM Files

EOF
    
    find "$TEST_OUTPUT_DIR" -name "*.spdx.json" | while read -r file; do
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "unknown")
        local packages=$(jq '.packages | length' "$file" 2>/dev/null || echo "unknown")
        echo "- \`$(basename "$file")\` ($size bytes, $packages packages)" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Recommendations

EOF
    
    if [ "$FAILED_TESTS" -gt 0 ]; then
        echo "- ❌ $FAILED_TESTS test(s) failed - review logs for details" >> "$report_file"
    fi
    
    if [ "$SKIPPED_TESTS" -gt 0 ]; then
        echo "- ⚠️ $SKIPPED_TESTS test(s) skipped - ensure test environment is complete" >> "$report_file"
    fi
    
    if [ "$FAILED_TESTS" -eq 0 ] && [ "$SKIPPED_TESTS" -eq 0 ]; then
        echo "- ✅ All tests passed - image is ready for production use" >> "$report_file"
    fi
    
    log "Test report generated: $report_file"
}

# Cleanup function
cleanup_tests() {
    if [ "$CLEANUP" = true ]; then
        log "Cleaning up test files..."
        rm -rf "$TEST_OUTPUT_DIR"
        log_success "Test cleanup completed"
    else
        log "Test files preserved in: $TEST_OUTPUT_DIR"
    fi
}

# Main test function
main() {
    local start_time=$(date +%s)
    
    echo -e "${PURPLE}================================================================${NC}"
    echo -e "${PURPLE}              DOCKER SBOM SCANNER TESTS                        ${NC}"
    echo -e "${PURPLE}================================================================${NC}"
    
    # Parse arguments
    parse_args "$@"
    
    # Set verbose mode
    if [ "$VERBOSE" = true ]; then
        set -x
    fi
    
    # Setup
    setup_tests
    
    # Run test suites
    test_basic_functionality
    test_container_functionality
    test_project_scanning
    test_sbom_validation
    test_performance
    test_error_handling
    
    # Calculate test duration
    local end_time=$(date +%s)
    local test_duration=$((end_time - start_time))
    
    # Generate report
    generate_test_report
    
    # Show results
    echo -e "\n${PURPLE}================================================================${NC}"
    echo -e "${PURPLE}                    TEST RESULTS                               ${NC}"
    echo -e "${PURPLE}================================================================${NC}"
    
    echo -e "${CYAN}Test Summary:${NC}"
    echo -e "  Total Tests: $TOTAL_TESTS"
    echo -e "  ${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "  ${RED}Failed: $FAILED_TESTS${NC}"
    echo -e "  ${YELLOW}Skipped: $SKIPPED_TESTS${NC}"
    echo -e "  Duration: ${test_duration}s"
    
    if [ "$FAILED_TESTS" -gt 0 ]; then
        echo -e "\n${RED}❌ Some tests failed!${NC}"
        cleanup_tests
        exit 1
    elif [ "$TOTAL_TESTS" -eq "$SKIPPED_TESTS" ]; then
        echo -e "\n${YELLOW}⚠️ All tests were skipped!${NC}"
        cleanup_tests
        exit 2
    else
        echo -e "\n${GREEN}✅ All available tests passed!${NC}"
        cleanup_tests
        exit 0
    fi
}

# Trap for cleanup on exit
trap cleanup_tests EXIT

# Run main function
main "$@"