#!/bin/bash

# Test Docker Image Locally
# This script builds and tests the Docker image before pushing to avoid SBOM tool errors

set -e

echo "🔧 Testing Docker SBOM Scanner locally..."

# Build the Docker image
echo "Building Docker image..."
docker build -t local-sbom-test:latest docker-sbom-scanner/

# Test health check
echo "Testing health check..."
docker run --rm local-sbom-test:latest --version

# Test SBOM tool availability
echo "Testing SBOM tool directly..."
docker run --rm local-sbom-test:latest /bin/bash -c "sbom-tool --version"

# Create a simple test project
echo "Creating test project..."
mkdir -p test-project
cat > test-project/test.csproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Newtonsoft.Json" Version="13.0.3" />
  </ItemGroup>
</Project>
EOF

# Test actual scanning
echo "Testing SBOM scan..."
docker run --rm \
    -v $(pwd)/test-project:/workspace \
    -v $(pwd)/test-output:/output \
    local-sbom-test:latest \
    --type dotnet \
    --path /workspace \
    --output /output \
    --verbose

echo "✅ Local Docker test completed successfully!"
echo "Generated files:"
find test-output -type f 2>/dev/null || echo "No output files found"

# Cleanup
rm -rf test-project test-output

echo "🚀 Docker image is ready for deployment!"