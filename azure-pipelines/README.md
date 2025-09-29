# Azure DevOps Pipeline Usage Guide

## 📋 **Quick Start**

### Step 1: Choose Your Pipeline Template

Copy one of these files to your repository as `azure-pipelines.yml`:

- **`simple-template.yml`** - Basic scanning with HTML report
- **`basic-sbom-scan.yml`** - Standard scanning with enhanced HTML
- **`enterprise-sbom-scan.yml`** - Full compliance checking with gates
- **`multi-project-sbom-scan.yml`** - Multiple language support

### Step 2: Customize Variables

Edit the variables section in your chosen pipeline:

```yaml
variables:
  projectType: 'dotnet'              # Change to your project type
  allowedLicenses: 'MIT,Apache-2.0'  # Add your approved licenses
  notificationEmail: 'your-team@company.com'
```

### Step 3: Commit and Push

```bash
git add azure-pipelines.yml
git commit -m "Add SBOM license scanning pipeline"
git push
```

## 🎯 **Common Use Cases**

### .NET Project Scanning
```yaml
variables:
  projectType: 'dotnet'
  scanPath: '/workspace'
```

### Node.js Project Scanning
```yaml
variables:
  projectType: 'nodejs'
  scanPath: '/workspace'
```

### Python Project Scanning
```yaml
variables:
  projectType: 'python'
  scanPath: '/workspace'
```

### Multi-Language Repository
```yaml
variables:
  projectType: 'auto'  # Auto-detects all project types
```

## 🔧 **Pipeline Features**

### Basic Features (All Templates)
- ✅ Automatic Docker image pulling
- ✅ Source code scanning
- ✅ HTML report generation
- ✅ Build artifacts publishing
- ✅ Multi-platform support

### Enterprise Features (Enterprise Template)
- ✅ License compliance checking
- ✅ Approval gates for production
- ✅ Email notifications
- ✅ Compliance rate calculation
- ✅ Blocked license detection
- ✅ Interactive HTML dashboard

### Multi-Project Features
- ✅ Parallel scanning of different project types
- ✅ Consolidated reporting
- ✅ Searchable package tables
- ✅ Project type filtering

## 📊 **Output Files**

Each pipeline run generates:

### SBOM Files
- `*-sbom.spdx.json` - SPDX 2.3 compliant SBOM
- `scan-report.md` - Markdown summary report
- `license-summary.txt` - Package to license mapping

### HTML Reports
- `license-report.html` - Interactive license dashboard
- `enterprise-license-report.html` - Full compliance dashboard
- `consolidated-license-report.html` - Multi-project overview

### Compliance Data
- `compliance-summary.json` - Machine-readable compliance data
- Build variables for pipeline decisions

## 🚀 **Advanced Configuration**

### Custom License Lists

```yaml
variables:
  # Approved licenses for your organization
  allowedLicenses: 'MIT,Apache-2.0,BSD-3-Clause,BSD-2-Clause,ISC,Unlicense'
  
  # Blocked licenses (will fail compliance)
  blockedLicenses: 'GPL-3.0,AGPL-3.0,SSPL-1.0'
  
  # Compliance threshold (percentage)
  complianceThreshold: 95
```

### Environment-Specific Scanning

```yaml
# Different rules for different environments
- ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
  - template: enterprise-sbom-scan.yml

- ${{ else }}:
  - template: basic-sbom-scan.yml
```

### Integration with Release Pipelines

```yaml
# In your release pipeline
- task: DownloadBuildArtifacts@0
  inputs:
    buildType: 'specific'
    project: 'YourProject'
    pipeline: 'YourBuildPipeline'
    artifactName: 'license-reports'

- task: PowerShell@2
  displayName: 'Check License Compliance'
  inputs:
    targetType: 'inline'
    script: |
      $complianceFile = "$(System.ArtifactsDirectory)/license-reports/compliance-summary.json"
      if (Test-Path $complianceFile) {
          $compliance = Get-Content $complianceFile | ConvertFrom-Json
          if ($compliance.complianceRate -lt 95) {
              Write-Host "##vso[task.logissue type=error]License compliance too low: $($compliance.complianceRate)%"
              exit 1
          }
      }
```

## 🔐 **Security Considerations**

### GitHub Token (Optional)
For enhanced license resolution, add GitHub token:

```yaml
- task: Docker@2
  inputs:
    arguments: |
      --rm \
      -e GITHUB_TOKEN=$(GITHUB_TOKEN) \
      -v $(Build.SourcesDirectory):/workspace \
      ghcr.io/sujitks/sbom-license-checker:latest
```

### Service Connections
No special service connections required - uses built-in Docker support.

## 📧 **Notifications**

### Email Integration
```yaml
- task: EmailReport@1
  inputs:
    to: '$(NotificationEmail)'
    subject: 'License Compliance Report'
    body: 'Compliance Rate: $(ComplianceRate)%'
    attachmentsPattern: '$(Pipeline.Workspace)/reports/*.html'
```

### Slack Integration
```yaml
- task: SlackNotification@1
  inputs:
    SlackApiToken: '$(SlackToken)'
    Channel: '#compliance'
    Message: 'License scan completed: $(ComplianceRate)% compliance'
```

## 🐛 **Troubleshooting**

### Common Issues

**Docker image not found:**
```yaml
# Add explicit image pull
- task: Docker@2
  inputs:
    command: 'pull'
    arguments: 'ghcr.io/sujitks/sbom-license-checker:latest'
```

**No packages found:**
- Check `projectType` variable matches your project
- Verify project structure contains expected files (.csproj, package.json, requirements.txt)

**Permission errors:**
```yaml
# Add user context if needed
arguments: |
  --rm \
  --user $(id -u):$(id -g) \
  -v $(Build.SourcesDirectory):/workspace \
```

### Debug Mode
```yaml
variables:
  dockerArguments: '--verbose'  # Enable verbose output
```

## 💡 **Best Practices**

1. **Start Simple**: Use `simple-template.yml` first, then upgrade
2. **Set Thresholds**: Define realistic compliance thresholds
3. **Review Regularly**: Schedule periodic license reviews
4. **Automate Decisions**: Use compliance gates for critical branches
5. **Document Exceptions**: Track approved license exceptions

## 📞 **Support**

For issues with the Docker scanner itself, check:
- [GitHub Repository](https://github.com/sujitks/sbom-license-checker)
- [Docker Image](https://ghcr.io/sujitks/sbom-license-checker)
- [Pipeline Templates](./azure-pipelines/)

---
**No Docker Compose Required!** Azure DevOps has built-in Docker support. 🐳