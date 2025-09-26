# SBOM Scanner Docker Solution

A comprehensive Docker-based SBOM (Software Bill of Materials) scanner that supports .NET, Node.js, and Python projects with automated license detection and compliance checking.

## 🚀 Quick Start

### Using Pre-built Docker Image
```bash
# Scan current directory (auto-detect project type)
docker run --rm -v "$(pwd):/workspace" ghcr.io/YOUR_USERNAME/sbom-scanner:latest

# Scan specific project type
docker run --rm -v "$(pwd):/workspace" ghcr.io/YOUR_USERNAME/sbom-scanner:latest --type dotnet

# Scan specific path
docker run --rm -v "$(pwd):/workspace" ghcr.io/YOUR_USERNAME/sbom-scanner:latest --path /workspace/src
```

### Using in DevContainer
This repository includes DevContainer configurations for VS Code:
- **Production**: Uses published Docker image from GitHub Container Registry
- **Development**: Builds Docker image locally for testing

## 🛠 Supported Project Types

- **✅ .NET**: Projects with `.csproj`, `.fsproj`, `.vbproj`, or `.sln` files
- **✅ Node.js**: Projects with `package.json` files  
- **✅ Python**: Projects with `requirements.txt`, `setup.py`, or `pyproject.toml` files

## 📋 Features

- **Multi-language Support**: Automatic project detection and scanning
- **License Analysis**: Comprehensive license detection with multiple fallback APIs
- **SPDX Compliance**: Generates SPDX 2.3 format SBOMs
- **Docker Ready**: Multi-platform support (linux/amd64, linux/arm64)
- **CI/CD Integration**: Ready for Azure DevOps and GitHub Actions
- **DevContainer Support**: Seamless VS Code development experience

## 📁 Repository Structure

```
├── docker-sbom-scanner/     # Docker solution
│   ├── Dockerfile          # Multi-stage Docker build
│   ├── scanner.sh          # Core scanning logic
│   ├── entrypoint.sh       # CLI interface
│   └── README.md           # Detailed usage guide
├── .github/workflows/      # GitHub Actions automation
├── .devcontainer/          # VS Code DevContainer configs
├── test-projects/          # Sample projects for testing
└── setup-github.sh         # Repository setup automation
```

## 🚀 Getting Started

### 1. Setup Repository
Run the setup script to configure GitHub integration:
```bash
chmod +x setup-github.sh
./setup-github.sh
```

### 2. Push to GitHub
```bash
git add .
git commit -m "Initial SBOM scanner solution"
git remote add origin https://github.com/YOUR_USERNAME/sbom-scanner.git
git push -u origin main
```

### 3. Enable GitHub Actions
After pushing, GitHub Actions will automatically build and publish the Docker image to GitHub Container Registry.

## 🔧 Usage Examples

### CLI Usage
```bash
# Basic scan (auto-detect)
./docker-sbom-scanner/scanner.sh

# Specific project type
./docker-sbom-scanner/scanner.sh --type python --path ./my-python-app

# With custom output
./docker-sbom-scanner/scanner.sh --output ./reports
```

### Azure DevOps Integration
See `docker-sbom-scanner/azure-pipelines/` for ready-to-use pipeline templates.

### Docker Compose
```yaml
services:
  sbom-scanner:
    image: ghcr.io/YOUR_USERNAME/sbom-scanner:latest
    volumes:
      - ./:/workspace
    command: ["--type", "dotnet", "--path", "/workspace"]
```

## 🧪 Testing

The repository includes sample projects for testing:
- `test-projects/dotnet-sample/`: .NET 9.0 console application
- `test-projects/nodejs-sample/`: Node.js application with dependencies  
- `test-projects/python-sample/`: Python application with requirements

## 📖 Documentation

- [Docker Scanner Guide](docker-sbom-scanner/README.md)
- [DevContainer Setup](.devcontainer/README.md)
- [GitHub Actions Workflows](.github/workflows/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the sample projects
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🏷️ Tags
`sbom` `spdx` `license-compliance` `docker` `dotnet` `nodejs` `python` `devcontainer` `azure-devops` `github-actions`