# .NET SBOM Test Project

A sample .NET 9.0 console application for testing SBOM generation with various NuGet packages.

## 🎯 Purpose

This project includes packages with different license types to test the `generate-sbom-ultimate.sh` script:
- MIT licensed packages (Bogus, SkiaSharp, Microsoft packages)
- Commercial packages (Aspose.Cells)
- PostgreSQL licensed packages (Npgsql)
- Apache-2.0 licensed packages (RestSharp)

## 🏗️ Project Structure

```
dotnet-sample/
├── dotnetsample.csproj       # Project file with NuGet references
├── Program.cs                # Main application code
└── README.md                # This file
```

## 🚀 Quick Start

### Prerequisites
- .NET 9.0 SDK or later
- SBOM Tool (`dotnet tool install -g Microsoft.Sbom.DotNetTool`)

### Build and Run
```bash
# Restore packages and build
dotnet restore
dotnet build --configuration Release

# Run the application
dotnet run

# Or run the executable directly
./bin/Release/net9.0/dotnetsample
```

### Generate SBOM
```bash
# From the main SBOM directory
cd ../..
./generate-sbom-ultimate.sh

# View results
cat sbom-reports/license-summary-ultimate.txt
```

## 📦 Included Packages

| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| Bogus | 35.6.3 | MIT | Fake data generation |
| Aspose.Cells | 25.9.0 | Commercial | Excel file manipulation |
| Npgsql | 9.0.3 | PostgreSQL | PostgreSQL database driver |
| SkiaSharp | 3.119.0 | MIT | 2D graphics library |
| Newtonsoft.Json | 13.0.3 | MIT | JSON serialization |
| Serilog | 4.0.2 | Apache-2.0 | Structured logging |
| RestSharp | 112.0.0 | Apache-2.0 | REST API client |
| Microsoft.EntityFrameworkCore | 9.0.0 | MIT | Object-relational mapper |

## 🧪 Testing Features

The application demonstrates usage of each package:

1. **Bogus**: Generate fake user data
2. **JSON**: Serialize/deserialize objects
3. **SkiaSharp**: Create simple graphics
4. **Npgsql**: Build PostgreSQL connection strings
5. **Serilog**: Structured logging output

## 📊 Expected SBOM Results

When running `generate-sbom-ultimate.sh`, you should see:
- **Total packages**: ~15-20 (including dependencies)
- **Resolution rate**: ~95% success
- **License distribution**:
  - MIT: ~70%
  - Apache-2.0: ~10%
  - Commercial: ~5%
  - PostgreSQL: ~5%
  - Others: ~10%

## 🔧 Configuration

### Project Properties
- **Target Framework**: net9.0
- **Output Type**: Console application
- **Version**: 1.0.0
- **Company**: SujitKs

### Build Configuration
```bash
# Debug build
dotnet build

# Release build (recommended for SBOM)
dotnet build --configuration Release

# Clean build
dotnet clean && dotnet build
```

## 🚨 License Notes

This test project includes **Aspose.Cells**, which is a commercial package. In production:
1. Ensure you have proper licensing for commercial packages
2. Consider using open-source alternatives for testing
3. Review license compatibility with your project's license

## 📈 SBOM Analysis

After running SBOM generation, analyze:
1. **License compliance**: Check for acceptable license types
2. **Vulnerabilities**: Scan for known security issues
3. **Dependencies**: Review transitive dependencies
4. **Updates**: Check for newer package versions

### Sample SBOM Output
```json
{
  "name": "Bogus",
  "versionInfo": "35.6.3",
  "downloadLocation": "NOASSERTION",
  "filesAnalyzed": false,
  "licenseConcluded": "MIT",
  "licenseDeclared": "MIT"
}
```

## 🔄 Customization

To test different packages:
1. Edit `dotnetsample.csproj`
2. Add/remove `PackageReference` items
3. Update `Program.cs` to use new packages
4. Rebuild and regenerate SBOM

### Example: Adding a new package
```xml
<PackageReference Include="AutoMapper" Version="12.0.1" />
```

Then update `Program.cs` to include and test the new package.

## 🐛 Troubleshooting

### Common Issues
1. **Build failures**: Check .NET SDK version
2. **Missing packages**: Run `dotnet restore`
3. **SBOM generation fails**: Ensure clean build first
4. **Commercial license warnings**: Expected for Aspose.Cells

### Debug Commands
```bash
# Verbose build output
dotnet build --verbosity detailed

# List package dependencies
dotnet list package

# Check for updates
dotnet list package --outdated
```

---

This .NET project is designed to test SBOM generation capabilities with a realistic mix of package types and licenses.