# Docker SBOM Scanner

A comprehensive Docker-based solution for generating Software Bill of Materials (SBOM) and license analysis across multiple programming languages and package ecosystems.

## 🚀 Features

- **Multi-Language Support**: .NET, Node.js, and Python projects
- **Auto-Detection**: Automatically identifies project types and scans accordingly
- **SPDX 2.3 Compliant**: Generates industry-standard SBOM files
- **License Resolution**: Advanced license detection using multiple APIs and databases
- **Azure DevOps Integration**: Ready-to-use pipeline templates and tasks
- **Security-First**: Non-root container execution with comprehensive validation
- **Developer-Friendly**: Rich CLI interface with verbose logging and error handling

## 📋 Supported Project Types

| Language | File Types | Package Managers | License Sources |
|----------|------------|------------------|-----------------|
| .NET | `*.csproj`, `*.sln`, `*.fsproj`, `*.vbproj` | NuGet | NuGet API, ClearlyDefined |
| Node.js | `package.json` | npm, yarn | npm registry, GitHub API |
| Python | `requirements.txt`, `setup.py`, `pyproject.toml` | pip, conda | PyPI, package metadata |

## 🏗️ Quick Start

### Using Published Image (Recommended)

```bash
# Pull from GitHub Container Registry
docker pull ghcr.io/sujitks/sbom-scanner:latest

# Scan a project
docker run --rm -v $(pwd):/workspace -v $(pwd)/reports:/output ghcr.io/sujitks/sbom-scanner:latest
```

### Development Container

For the best development experience, use the provided devcontainer:

```bash
# Open in VS Code with Dev Containers extension
code .
# Select "Reopen in Container" when prompted
```

### Build Locally

```bash
# Clone and build
cd docker-sbom-scanner
chmod +x build.sh test.sh
./build.sh

# Or build manually
docker build -t sbom-scanner .
```

### Basic Usage

```bash
# Scan current directory (auto-detect project type)
docker run --rm -v $(pwd):/workspace -v $(pwd)/reports:/output sbom-scanner

# Scan specific project type
docker run --rm -v $(pwd):/workspace -v $(pwd)/reports:/output sbom-scanner --type dotnet

# Verbose scanning
docker run --rm -v $(pwd):/workspace -v $(pwd)/reports:/output sbom-scanner --verbose --type nodejs
```

## 📖 Command Line Interface

### Basic Syntax
```bash
# Using published image
docker run [docker-options] ghcr.io/sujitks/sbom-scanner:latest [OPTIONS] [PATH]

# Using local image
docker run [docker-options] sbom-scanner [OPTIONS] [PATH]
```

### Options
- `--type TYPE` - Project type: `dotnet`, `nodejs`, `python`, `auto` (default: auto)
- `--path PATH` - Path to scan (default: /workspace)
- `--output PATH` - Output directory (default: /app/output)
- `--verbose` - Enable detailed logging
- `--help` - Show help information
- `--version` - Show version information

### Examples

```bash
# Auto-detect and scan with custom output
docker run --rm \
  -v $(pwd):/workspace:ro \
  -v $(pwd)/sbom-reports:/output \
  sbom-scanner --output /output

# Scan .NET solution with verbose output
docker run --rm \
  -v $(pwd)/MyApp:/workspace:ro \
  -v $(pwd)/reports:/output \
  sbom-scanner --type dotnet --verbose

# Multi-project repository scan
docker run --rm \
  -v $(pwd):/workspace:ro \
  -v $(pwd)/reports:/output \
  sbom-scanner --type auto
```

## 🏢 Azure DevOps Integration

### Using the Pipeline Template

1. **Copy Azure DevOps files** to your repository:
   ```bash
   cp -r docker-sbom-scanner/azure-devops/* .azure-pipelines/
   ```

2. **Use in your pipeline** (`azure-pipelines.yml`):
   ```yaml
   # Include SBOM scanning template
   - template: .azure-pipelines/sbom-scan-template.yml
     parameters:
       projectType: 'auto'
       scanPath: '$(Build.SourcesDirectory)'
       outputPath: '$(Build.ArtifactStagingDirectory)/sbom-reports'
       publishResults: true
       failOnLicenseIssues: false
   ```

### Simple Task Integration

For quick integration, use the simple task:

```yaml
steps:
- template: .azure-pipelines/simple-task.yml
  parameters:
    projectType: 'dotnet'
```

### Advanced Pipeline Example

```yaml
stages:
- stage: SecurityScan
  jobs:
  - job: SBOMAnalysis
    steps:
    - template: .azure-pipelines/sbom-scan-template.yml
      parameters:
        projectType: 'auto'
        verboseOutput: true
        githubToken: '$(GITHUB_TOKEN)'
        failOnLicenseIssues: true
```

## 📊 Output Files

The scanner generates comprehensive reports in the output directory:

### SBOM Files
- `{type}-sbom.spdx.json` - SPDX 2.3 compliant SBOM
- `scan-report.md` - Human-readable summary

### Detailed Reports
- `{type}-reports/license-summary.txt` - License distribution analysis
- `{type}-reports/scan-summary.txt` - Scan statistics and metrics
- `{type}-reports/dependency-tree.txt` - Project dependency tree

### Example Output Structure
```
output/
├── dotnet-sbom.spdx.json           # .NET SBOM
├── nodejs-sbom.spdx.json           # Node.js SBOM  
├── python-sbom.spdx.json           # Python SBOM
├── scan-report.md                  # Overall report
├── dotnet-reports/
│   ├── license-summary.txt
│   └── scan-summary.txt
├── nodejs-reports/
│   ├── npm-licenses.json
│   └── dependency-tree.txt
└── python-reports/
    ├── python-licenses.json
    └── license-summary.txt
```

## 🔧 Configuration

### Environment Variables

- `SBOM_OUTPUT_DIR` - Override default output directory
- `SBOM_TEMP_DIR` - Override temporary directory  
- `GITHUB_TOKEN` - GitHub API token for enhanced license resolution
- `SCAN_TIMEOUT` - Scanner timeout in seconds (default: 1800)

### Docker Build Arguments

```bash
# Build with proxy settings
docker build \
  --build-arg HTTP_PROXY=http://proxy:8080 \
  --build-arg HTTPS_PROXY=http://proxy:8080 \
  -t sbom-scanner .

# Build with custom base image
docker build \
  --build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/sdk:8.0-alpine \
  -t sbom-scanner .
```

## 🧪 Testing

### Run Test Suite

```bash
# Run all tests
./test.sh

# Test specific image
./test.sh --image myregistry.azurecr.io/sbom-scanner:v1.0.0

# Verbose testing with custom output
./test.sh --verbose --output ./test-results --no-cleanup
```

### Test Categories

- **Basic Functionality**: Help, version, argument validation
- **Container Functionality**: Startup, volume mounting, environment variables
- **Project Scanning**: .NET, Node.js, Python project analysis
- **SBOM Validation**: SPDX compliance, required fields, package validation
- **Performance**: Scan timing, memory usage
- **Error Handling**: Invalid inputs, read-only filesystems

## 🐳 Production Deployment

### Registry Push

```bash
# Build and push to Azure Container Registry
./build.sh --tag v1.0.0 --push --registry myregistry.azurecr.io

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64 \
  -t myregistry.azurecr.io/sbom-scanner:v1.0.0 \
  --push .
```

### Kubernetes Deployment

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: sbom-scan
spec:
  template:
    spec:
      containers:
      - name: sbom-scanner
        image: myregistry.azurecr.io/sbom-scanner:v1.0.0
        args: ["--type", "auto", "--path", "/workspace"]
        volumeMounts:
        - name: source-code
          mountPath: /workspace
          readOnly: true
        - name: reports
          mountPath: /output
      volumes:
      - name: source-code
        persistentVolumeClaim:
          claimName: source-pvc
      - name: reports
        persistentVolumeClaim:
          claimName: reports-pvc
      restartPolicy: Never
```

## 📈 Performance Optimization

### Build Optimization
- Multi-stage Docker build for smaller image size
- Alpine Linux base for minimal footprint
- Layer caching for faster rebuilds

### Runtime Optimization
- Parallel package analysis where possible
- Efficient dependency tree traversal
- Minimal memory footprint with streaming JSON processing

### CI/CD Optimization
- Pipeline caching for Docker layers
- Parallel scanning of multiple project types
- Incremental scanning for changed files only

## 🔒 Security Features

- **Non-root execution**: Container runs as unprivileged user
- **Read-only source mounting**: Prevents accidental source modification
- **Secure defaults**: No network access required for basic operation
- **Vulnerability scanning**: Regular base image updates
- **License compliance**: Automated detection of problematic licenses

## 🎯 Use Cases

### Development Environment
```bash
# Local development scanning
docker run --rm -v $(pwd):/workspace sbom-scanner --verbose
```

### CI/CD Pipeline
```yaml
# Azure DevOps integration
- template: sbom-scan-template.yml
  parameters:
    projectType: 'auto'
    failOnLicenseIssues: true
```

### Security Review
```bash
# Generate comprehensive security reports
docker run --rm \
  -v $(pwd):/workspace:ro \
  -v $(pwd)/security-reports:/output \
  -e GITHUB_TOKEN=$GITHUB_TOKEN \
  sbom-scanner --type auto --verbose
```

### Compliance Automation
```bash
# Automated compliance checking
docker run --rm \
  -v $(pwd):/workspace:ro \
  -v $(pwd)/compliance:/output \
  sbom-scanner --type auto
  
# Process results with compliance tools
jq '.packages[].licenseConcluded' compliance/*-sbom.spdx.json | sort | uniq -c
```

## 🔧 Troubleshooting

### Common Issues

**Issue**: Docker build fails with permission errors
```bash
# Solution: Ensure Docker daemon is running and user has permissions
sudo systemctl start docker
sudo usermod -aG docker $USER
```

**Issue**: .NET restore fails in container
```bash
# Solution: Ensure project files are valid and accessible
docker run --rm -v $(pwd):/workspace sbom-scanner --verbose --type dotnet
```

**Issue**: Node.js license analysis fails
```bash
# Solution: Ensure package.json exists and npm install works
cd your-project
npm install  # Verify this works locally first
```

### Debug Mode

```bash
# Enable verbose logging
docker run --rm -v $(pwd):/workspace sbom-scanner --verbose --type auto

# Check container logs
docker run --name debug-scan -v $(pwd):/workspace sbom-scanner --verbose
docker logs debug-scan
docker rm debug-scan
```

### Log Analysis

```bash
# Analyze scan results
find ./reports -name "*.txt" -exec echo "=== {} ===" \; -exec cat {} \;

# Check SBOM validity
for file in ./reports/*.spdx.json; do
  echo "Validating $file..."
  jq . "$file" > /dev/null && echo "✓ Valid JSON" || echo "✗ Invalid JSON"
done
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Setup

```bash
# Build development image
./build.sh --tag dev --no-tests

# Run tests
./test.sh --image sbom-scanner:dev --verbose

# Test with sample projects
docker run --rm -v $(pwd)/test-projects:/workspace sbom-scanner:dev --type auto
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Microsoft SBOM Tool for .NET SBOM generation
- SPDX Project for SBOM standards
- ClearlyDefined for license data
- Alpine Linux for minimal container base

---

**Need help?** Check the [issues](../../issues) or create a new one with detailed information about your use case.