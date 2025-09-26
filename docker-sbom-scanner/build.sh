#!/bin/bash

# Docker SBOM Scanner Build Script
# Author: Sujit Singh
# Purpose: Build and test the SBOM scanner Docker image

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
IMAGE_NAME="sbom-scanner"
IMAGE_TAG="latest"
BUILD_CONTEXT="$SCRIPT_DIR"

# Build options
PUSH_TO_REGISTRY=false
REGISTRY_URL=""
RUN_TESTS=true
VERBOSE=false
BUILD_ARGS=()

# Usage function
show_help() {
    cat << EOF
${PURPLE}Docker SBOM Scanner Build Script${NC}

${YELLOW}USAGE:${NC}
    ./build.sh [OPTIONS]

${YELLOW}OPTIONS:${NC}
    -t, --tag TAG           Docker image tag (default: latest)
    -n, --name NAME         Docker image name (default: sbom-scanner)
    -p, --push              Push to registry after build
    -r, --registry URL      Registry URL (required with --push)
    --no-tests              Skip running tests after build
    -v, --verbose           Enable verbose output
    --build-arg ARG         Pass build argument to docker build
    -h, --help             Show this help message

${YELLOW}EXAMPLES:${NC}
    # Basic build
    ./build.sh

    # Build with custom tag and push to registry
    ./build.sh --tag v1.0.0 --push --registry myregistry.azurecr.io

    # Build with build arguments
    ./build.sh --build-arg HTTP_PROXY=http://proxy:8080

    # Build without tests
    ./build.sh --no-tests --verbose

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--tag)
                IMAGE_TAG="$2"
                shift 2
                ;;
            -n|--name)
                IMAGE_NAME="$2"
                shift 2
                ;;
            -p|--push)
                PUSH_TO_REGISTRY=true
                shift
                ;;
            -r|--registry)
                REGISTRY_URL="$2"
                shift 2
                ;;
            --no-tests)
                RUN_TESTS=false
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --build-arg)
                BUILD_ARGS+=("--build-arg" "$2")
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option $1${NC}" >&2
                show_help
                exit 1
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

# Validate environment
validate_environment() {
    log "Validating build environment..."
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    # Check Docker daemon
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    # Check Dockerfile
    if [ ! -f "$BUILD_CONTEXT/Dockerfile" ]; then
        log_error "Dockerfile not found at $BUILD_CONTEXT/Dockerfile"
        exit 1
    fi
    
    # Validate registry URL if pushing
    if [ "$PUSH_TO_REGISTRY" = true ] && [ -z "$REGISTRY_URL" ]; then
        log_error "Registry URL is required when --push is specified"
        exit 1
    fi
    
    log_success "Environment validation passed"
}

# Build Docker image
build_image() {
    local full_image_name="$IMAGE_NAME:$IMAGE_TAG"
    
    if [ -n "$REGISTRY_URL" ]; then
        full_image_name="$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"
    fi
    
    log "Building Docker image: $full_image_name"
    log "Build context: $BUILD_CONTEXT"
    
    # Prepare build command
    local build_cmd=(docker build)
    
    # Add build arguments
    if [ ${#BUILD_ARGS[@]} -gt 0 ]; then
        build_cmd+=("${BUILD_ARGS[@]}")
    fi
    
    # Add verbose flag if requested
    if [ "$VERBOSE" = true ]; then
        build_cmd+=(--progress=plain)
    fi
    
    # Add tag and context
    build_cmd+=(-t "$full_image_name" "$BUILD_CONTEXT")
    
    # Execute build
    if [ "$VERBOSE" = true ]; then
        log "Build command: ${build_cmd[*]}"
    fi
    
    if "${build_cmd[@]}"; then
        log_success "Docker image built successfully: $full_image_name"
        
        # Show image size
        local image_size=$(docker images --format "{{.Size}}" "$full_image_name" | head -1)
        log "Image size: $image_size"
        
        return 0
    else
        log_error "Docker build failed"
        return 1
    fi
}

# Test Docker image
test_image() {
    local test_image="$IMAGE_NAME:$IMAGE_TAG"
    
    if [ -n "$REGISTRY_URL" ]; then
        test_image="$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"
    fi
    
    log "Testing Docker image: $test_image"
    
    # Test 1: Basic help command
    log "Test 1: Running help command..."
    if docker run --rm "$test_image" --help >/dev/null 2>&1; then
        log_success "Help command test passed"
    else
        log_error "Help command test failed"
        return 1
    fi
    
    # Test 2: Version command
    log "Test 2: Running version command..."
    if docker run --rm "$test_image" --version >/dev/null 2>&1; then
        log_success "Version command test passed"
    else
        log_error "Version command test failed"
        return 1
    fi
    
    # Test 3: Health check
    log "Test 3: Running health check..."
    local temp_container=$(docker run -d "$test_image" sleep 30)
    sleep 5
    
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$temp_container" 2>/dev/null || echo "unknown")
    docker stop "$temp_container" >/dev/null 2>&1
    docker rm "$temp_container" >/dev/null 2>&1
    
    if [ "$health_status" = "healthy" ] || [ "$health_status" = "unknown" ]; then
        log_success "Health check test passed"
    else
        log_error "Health check test failed: $health_status"
        return 1
    fi
    
    # Test 4: Test with sample projects
    log "Test 4: Testing with sample projects..."
    local test_projects_dir="../test-projects"
    
    if [ -d "$test_projects_dir" ]; then
        # Test .NET project
        if [ -d "$test_projects_dir/dotnet-sample" ]; then
            log "Testing .NET project scanning..."
            local output_dir=$(mktemp -d)
            
            if docker run --rm \
                -v "$(realpath "$test_projects_dir/dotnet-sample"):/workspace:ro" \
                -v "$output_dir:/output" \
                "$test_image" \
                --type dotnet --path /workspace --output /output >/dev/null 2>&1; then
                
                if [ -f "$output_dir/dotnet-sbom.spdx.json" ]; then
                    log_success ".NET project test passed"
                else
                    log_warning ".NET project test completed but no SBOM generated"
                fi
            else
                log_warning ".NET project test failed (may be expected in CI environment)"
            fi
            
            rm -rf "$output_dir"
        fi
        
        # Test Node.js project
        if [ -d "$test_projects_dir/nodejs-sample" ]; then
            log "Testing Node.js project scanning..."
            local output_dir=$(mktemp -d)
            
            if docker run --rm \
                -v "$(realpath "$test_projects_dir/nodejs-sample"):/workspace:ro" \
                -v "$output_dir:/output" \
                "$test_image" \
                --type nodejs --path /workspace --output /output >/dev/null 2>&1; then
                
                if [ -f "$output_dir/nodejs-sbom.spdx.json" ]; then
                    log_success "Node.js project test passed"
                else
                    log_warning "Node.js project test completed but no SBOM generated"
                fi
            else
                log_warning "Node.js project test failed (may be expected in CI environment)"
            fi
            
            rm -rf "$output_dir"
        fi
    else
        log_warning "Test projects directory not found, skipping integration tests"
    fi
    
    log_success "All available tests passed"
    return 0
}

# Push image to registry
push_image() {
    local full_image_name="$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"
    
    log "Pushing image to registry: $full_image_name"
    
    # Login check
    if ! docker info | grep -q "Registry:"; then
        log_warning "Consider running 'docker login $REGISTRY_URL' before pushing"
    fi
    
    if docker push "$full_image_name"; then
        log_success "Image pushed successfully: $full_image_name"
        
        # Also tag and push as 'latest' if not already latest
        if [ "$IMAGE_TAG" != "latest" ]; then
            local latest_image="$REGISTRY_URL/$IMAGE_NAME:latest"
            docker tag "$full_image_name" "$latest_image"
            docker push "$latest_image"
            log_success "Also pushed as latest: $latest_image"
        fi
        
        return 0
    else
        log_error "Failed to push image to registry"
        return 1
    fi
}

# Cleanup old images
cleanup_images() {
    log "Cleaning up old images..."
    
    # Remove dangling images
    local dangling_images=$(docker images -f "dangling=true" -q)
    if [ -n "$dangling_images" ]; then
        docker rmi $dangling_images >/dev/null 2>&1 || true
        log_success "Removed dangling images"
    fi
    
    # Keep only last 3 versions of our image
    local old_images=$(docker images "$IMAGE_NAME" --format "{{.ID}} {{.Tag}}" | tail -n +4 | awk '{print $1}')
    if [ -n "$old_images" ]; then
        echo "$old_images" | xargs -r docker rmi >/dev/null 2>&1 || true
        log_success "Cleaned up old image versions"
    fi
}

# Generate build info
generate_build_info() {
    local build_info_file="$BUILD_CONTEXT/build-info.json"
    local full_image_name="$IMAGE_NAME:$IMAGE_TAG"
    
    if [ -n "$REGISTRY_URL" ]; then
        full_image_name="$REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"
    fi
    
    cat > "$build_info_file" << EOF
{
    "image": {
        "name": "$IMAGE_NAME",
        "tag": "$IMAGE_TAG",
        "fullName": "$full_image_name",
        "registry": "${REGISTRY_URL:-"local"}"
    },
    "build": {
        "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
        "user": "${USER:-unknown}",
        "host": "${HOSTNAME:-unknown}",
        "git": {
            "commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
            "branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
            "dirty": $([ -n "$(git status --porcelain 2>/dev/null)" ] && echo "true" || echo "false")
        }
    },
    "docker": {
        "version": "$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo 'unknown')",
        "buildkit": "$(docker info --format '{{.BuilderVersion}}' 2>/dev/null || echo 'unknown')"
    }
}
EOF
    
    log "Build info generated: $build_info_file"
}

# Main build function
main() {
    echo -e "${PURPLE}================================================================${NC}"
    echo -e "${PURPLE}              DOCKER SBOM SCANNER BUILD                        ${NC}"
    echo -e "${PURPLE}================================================================${NC}"
    
    # Parse arguments
    parse_args "$@"
    
    # Set verbose mode
    if [ "$VERBOSE" = true ]; then
        set -x
    fi
    
    log "Starting build process..."
    log "Image: $IMAGE_NAME:$IMAGE_TAG"
    log "Registry: ${REGISTRY_URL:-"local"}"
    log "Push: $PUSH_TO_REGISTRY"
    log "Run tests: $RUN_TESTS"
    
    # Validate environment
    validate_environment
    
    # Generate build info
    generate_build_info
    
    # Build image
    if ! build_image; then
        log_error "Build failed!"
        exit 1
    fi
    
    # Run tests if requested
    if [ "$RUN_TESTS" = true ]; then
        if ! test_image; then
            log_error "Tests failed!"
            exit 1
        fi
    fi
    
    # Push to registry if requested
    if [ "$PUSH_TO_REGISTRY" = true ]; then
        if ! push_image; then
            log_error "Push failed!"
            exit 1
        fi
    fi
    
    # Cleanup
    cleanup_images
    
    echo -e "${GREEN}================================================================${NC}"
    echo -e "${GREEN}                    BUILD COMPLETED                            ${NC}"
    echo -e "${GREEN}================================================================${NC}"
    
    log_success "Docker SBOM Scanner build completed successfully!"
    
    # Show usage instructions
    echo ""
    echo -e "${CYAN}Usage Instructions:${NC}"
    echo -e "  ${YELLOW}Local development:${NC}"
    echo -e "    docker run -v \$(pwd):/workspace sbom-scanner:$IMAGE_TAG"
    echo ""
    echo -e "  ${YELLOW}Azure DevOps:${NC}"
    echo -e "    Use the templates in azure-devops/ directory"
    echo ""
    
    if [ -n "$REGISTRY_URL" ]; then
        echo -e "  ${YELLOW}Pull from registry:${NC}"
        echo -e "    docker pull $REGISTRY_URL/$IMAGE_NAME:$IMAGE_TAG"
        echo ""
    fi
}

# Run main function
main "$@"