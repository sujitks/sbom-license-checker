# SBOM Test Projects Guide

This directory contains example projects for testing SBOM (Software Bill of Materials) generation and license resolution using the `generate-sbom-ultimate.sh` and `test-external-packages.sh` scripts.

## 📁 Project Structure

```
test-projects/
├── dotnet-sample/          # .NET Console Application
├── nodejs-sample/          # Node.js Express Application  
├── python-sample/          # Python Flask Application
└── README.md              # This file
```

## 🎯 Purpose

These example projects demonstrate SBOM generation and license resolution across different ecosystems:

- **Package Managers**: NuGet, npm, pip
- **License Types**: MIT, Apache-2.0, BSD, Commercial, PostgreSQL, etc.
- **Popular Packages**: Including problematic packages that are hard to resolve

## 🔧 Quick Start

### 1. .NET Project Testing

```bash
# Navigate to .NET project
cd test-projects/dotnet-sample

# Run SBOM generation (from main directory)
cd ../..
./generate-sbom-ultimate.sh

# Or test specific packages
./test-external-packages.sh
```

### 2. Node.js Project Testing

```bash
# Navigate to Node.js project
cd test-projects/nodejs-sample

# Install dependencies
npm install

# Run the application
npm start

# Or run tests directly
node index.js
```

### 3. Python Project Testing

```bash
# Navigate to Python project
cd test-projects/python-sample

# Setup and install dependencies
./setup.py

# Or manually
python -m venv venv
source venv/bin/activate  # On macOS/Linux
# venv\Scripts\activate   # On Windows
pip install -r requirements.txt

# Run tests
python main.py --mode test

# Start server
python main.py --mode server
```

## 📦 Package Coverage

### .NET Packages (NuGet)
- **Bogus** (35.6.3) - MIT License - Fake data generation
- **Aspose.Cells** (25.9.0) - Commercial License - Excel manipulation
- **Npgsql** (9.0.3) - PostgreSQL License - PostgreSQL driver
- **SkiaSharp** (3.119.0) - MIT License - 2D graphics
- **Newtonsoft.Json** (13.0.3) - MIT License - JSON handling
- **Serilog** (4.0.2) - Apache-2.0 License - Logging
- **RestSharp** (112.0.0) - Apache-2.0 License - HTTP client
- **Entity Framework** (9.0.0) - MIT License - ORM

Project file: `dotnetsample.csproj`

### Node.js Packages (npm)
- **express** (^4.18.2) - MIT License - Web framework
- **lodash** (^4.17.21) - MIT License - Utility library
- **axios** (^1.6.0) - MIT License - HTTP client
- **moment** (^2.29.4) - MIT License - Date handling
- **bcrypt** (^5.1.1) - MIT License - Password hashing
- **jsonwebtoken** (^9.0.2) - MIT License - JWT handling
- **mongoose** (^8.0.3) - MIT License - MongoDB ODM
- **winston** (^3.11.0) - MIT License - Logging
- **helmet** (^7.1.0) - MIT License - Security middleware

### Python Packages (pip)
- **flask** (3.0.0) - BSD License - Web framework
- **requests** (2.31.0) - Apache-2.0 License - HTTP library
- **pandas** (2.1.4) - BSD License - Data analysis
- **numpy** (1.26.2) - BSD License - Numerical computing
- **tensorflow** (2.15.0) - Apache-2.0 License - Machine learning
- **cryptography** (41.0.8) - Apache-2.0/BSD License - Cryptographic recipes
- **sqlalchemy** (2.0.23) - MIT License - SQL toolkit
- **boto3** (1.34.0) - Apache-2.0 License - AWS SDK

## 🧪 Testing Scenarios

### License Resolution Tests
The projects include packages with various license types to test resolution capabilities:

1. **Easy to resolve**: Popular packages with clear licenses (MIT, Apache-2.0)
2. **Moderate difficulty**: Packages with multiple license files or complex structures
3. **Hard to resolve**: Commercial packages, deprecated packages, or packages with unclear licensing

### API Testing
The scripts test multiple license resolution strategies:
- Known license database lookup
- GitHub API license detection
- ClearlyDefined API queries
- NuGet/npm/PyPI package metadata parsing

## 📊 Expected Results

### .NET SBOM Generation
```bash
# Should resolve approximately 90-95% of licenses
✓ Bogus → MIT
✓ Aspose.Cells → LicenseRef-Aspose-Commercial
✓ Npgsql → PostgreSQL
✓ SkiaSharp → MIT
✓ Microsoft.* packages → MIT
✓ dotnetsample → MIT (your project)
```

### Node.js Analysis
Most npm packages should resolve to MIT licenses, with some Apache-2.0 packages.

### Python Analysis
Mix of BSD, MIT, and Apache-2.0 licenses, with some packages having multiple licenses.

## 🚀 Advanced Usage

### Custom SBOM Generation

1. **Modify project configurations**:
   - Edit `.csproj` files for .NET packages
   - Update `package.json` for Node.js dependencies
   - Modify `requirements.txt` for Python packages

2. **Run enhanced SBOM generation**:
   ```bash
   # From main directory
   ./generate-sbom-ultimate.sh
   ```

3. **Check results**:
   ```bash
   # View generated reports
   ls -la sbom-reports/
   cat sbom-reports/license-summary-ultimate.txt
   ```

### Testing New Packages

1. **Add packages to test projects**
2. **Run license resolution tests**:
   ```bash
   ./test-external-packages.sh
   ```
3. **Update known license database** in scripts if needed

## 📋 Troubleshooting

### Common Issues

1. **Missing dependencies**:
   - Ensure .NET SDK, Node.js, and Python are installed
   - Check version requirements in each project

2. **API rate limits**:
   - Scripts include delays between API calls
   - For heavy testing, consider adding GitHub token

3. **License resolution failures**:
   - Check network connectivity
   - Verify API endpoints are accessible
   - Review package names and versions

### Debug Mode
Run scripts with additional logging:
```bash
# Add debug output
bash -x ./generate-sbom-ultimate.sh
```

## 📈 Metrics and Reporting

After running SBOM generation, check these files:
- `sbom-reports/enhanced-manifest-ultimate.spdx.json` - Enhanced SBOM with licenses
- `sbom-reports/license_mapping_ultimate.json` - License mapping data
- `sbom-reports/license-summary-ultimate.txt` - Human-readable summary

### Success Metrics
- **Resolution Rate**: Percentage of packages with resolved licenses
- **API Coverage**: Number of successful API calls vs failures
- **License Distribution**: Breakdown of license types found

## 🔄 Continuous Integration

These test projects can be integrated into CI/CD pipelines:

1. **Automated Testing**: Run SBOM generation on each commit
2. **License Compliance**: Fail builds if unacceptable licenses detected
3. **Dependency Monitoring**: Track new dependencies and their licenses

## 🤝 Contributing

To add more test scenarios:
1. Add packages with different license types
2. Include packages from different ecosystems
3. Test edge cases (packages with no license info, multiple licenses, etc.)

## 📚 References

- [SPDX License List](https://spdx.org/licenses/)
- [ClearlyDefined API](https://clearlydefined.io/)
- [SBOM Tool Documentation](https://github.com/microsoft/sbom-tool)
- [Package Manager Documentation](https://docs.npmjs.com/, https://docs.nuget.org/, https://pip.pypa.io/)

---

**Note**: These are test projects for SBOM generation. In production, ensure proper license compliance and security scanning.