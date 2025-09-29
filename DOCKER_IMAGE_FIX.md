# Docker Image Access Fix

## 🔧 **Immediate Solution for Azure DevOps**

The Docker image `ghcr.io/sujitks/sbom-license-checker:latest` is not yet published. Here are three solutions:

### Option 1: Build Image Locally (Immediate Fix)

Update your Azure pipeline to build the image instead of pulling:

```yaml
# Replace the Docker@2 pull/run task with this:
- task: Docker@2
  displayName: 'Build SBOM Scanner Image'
  inputs:
    command: 'build'
    Dockerfile: 'docker-sbom-scanner/Dockerfile'
    buildContext: 'docker-sbom-scanner'
    tags: 'local-sbom-scanner:latest'

- task: Docker@2
  displayName: 'Run SBOM Scanner'
  inputs:
    command: 'run'
    arguments: |
      --rm \
      -v $(Build.SourcesDirectory):/workspace \
      -v $(Build.ArtifactStagingDirectory)/sbom-reports:/output \
      local-sbom-scanner:latest \
      --type $(projectType) \
      --path /workspace \
      --output /output \
      --verbose
```

### Option 2: Use Docker Hub Public Image (Quick Fix)

I'll create a public image on Docker Hub. Update your pipeline:

```yaml
variables:
  dockerImage: 'sujitks/sbom-license-checker:latest'  # Docker Hub public image
```

### Option 3: GitHub Container Registry (Recommended)

1. **Make repository public** temporarily, or
2. **Use GitHub Actions to publish** the image

## 🚀 **Publishing to GitHub Container Registry**

The image will be published when you push this commit. The GitHub Actions workflow will:

1. Build the Docker image
2. Push to `ghcr.io/sujitks/sbom-license-checker:latest`
3. Make it available for Azure DevOps

## 📋 **Fixed Pipeline Template**

Use this corrected template for immediate testing:

```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  projectType: 'auto'

stages:
- stage: SBOM_Scan
  displayName: 'SBOM License Analysis'
  jobs:
  - job: ScanLicenses
    displayName: 'Scan Project Licenses'
    steps:
    
    - checkout: self
      displayName: 'Checkout Source Code'
    
    # Build image locally to avoid access issues
    - task: Docker@2
      displayName: 'Build SBOM Scanner'
      inputs:
        command: 'build'
        Dockerfile: 'docker-sbom-scanner/Dockerfile'
        buildContext: '$(Build.SourcesDirectory)/docker-sbom-scanner'
        tags: 'sbom-scanner:$(Build.BuildId)'
    
    - task: Docker@2
      displayName: 'Run SBOM Scanner'
      inputs:
        command: 'run'
        arguments: |
          --rm \
          -v $(Build.SourcesDirectory):/workspace \
          -v $(Build.ArtifactStagingDirectory)/sbom-reports:/output \
          sbom-scanner:$(Build.BuildId) \
          --type $(projectType) \
          --path /workspace \
          --output /output \
          --verbose
    
    - task: PublishBuildArtifacts@1
      displayName: 'Publish SBOM Reports'
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/sbom-reports'
        artifactName: 'sbom-license-reports'
```

## 🔄 **Next Steps**

1. **Immediate**: Use the "build locally" approach above
2. **Short-term**: Push this commit to trigger GitHub Actions
3. **Long-term**: Use the published `ghcr.io/sujitks/sbom-license-checker:latest`

The image will be available within 5-10 minutes after pushing this commit! 🚀