#!/bin/bash

# Setup script for SBOM Scanner GitHub publishing
# Updates configurations with your GitHub username

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 SBOM Scanner GitHub Setup${NC}"
echo "This script will configure the repository for GitHub Container Registry publishing."
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER
if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}❌ GitHub username is required${NC}"
    exit 1
fi

echo -e "${YELLOW}📝 Updating configurations for GitHub user: $GITHUB_USER${NC}"

# Update devcontainer.json
if [ -f ".devcontainer/devcontainer.json" ]; then
    sed -i.bak "s/ghcr.io\/sujitsingh\/sbom-scanner/ghcr.io\/$GITHUB_USER\/sbom-scanner/g" .devcontainer/devcontainer.json
    echo -e "${GREEN}✅ Updated .devcontainer/devcontainer.json${NC}"
fi

# Update README files
if [ -f "docker-sbom-scanner/README.md" ]; then
    sed -i.bak "s/ghcr.io\/sujitsingh\/sbom-scanner/ghcr.io\/$GITHUB_USER\/sbom-scanner/g" docker-sbom-scanner/README.md
    echo -e "${GREEN}✅ Updated docker-sbom-scanner/README.md${NC}"
fi

# Update devcontainer README
if [ -f ".devcontainer/README.md" ]; then
    sed -i.bak "s/ghcr.io\/yourusername\/sbom-scanner/ghcr.io\/$GITHUB_USER\/sbom-scanner/g" .devcontainer/README.md
    echo -e "${GREEN}✅ Updated .devcontainer/README.md${NC}"
fi

# Clean up backup files
find . -name "*.bak" -delete 2>/dev/null || true

echo ""
echo -e "${CYAN}📋 Next Steps:${NC}"
echo ""
echo -e "1. ${YELLOW}Commit and push your changes:${NC}"
echo "   git add ."
echo "   git commit -m 'Configure SBOM Scanner for GitHub publishing'"
echo "   git push origin main"
echo ""
echo -e "2. ${YELLOW}The GitHub Actions will automatically:${NC}"
echo "   • Build the Docker image"
echo "   • Push to ghcr.io/$GITHUB_USER/sbom-scanner"
echo "   • Test the devcontainer"
echo ""
echo -e "3. ${YELLOW}Enable GitHub Container Registry:${NC}"
echo "   • Go to your GitHub repository settings"
echo "   • Navigate to Actions > General"
echo "   • Ensure 'Read and write permissions' is enabled for GITHUB_TOKEN"
echo ""
echo -e "4. ${YELLOW}Use your published image:${NC}"
echo "   docker pull ghcr.io/$GITHUB_USER/sbom-scanner:latest"
echo ""
echo -e "5. ${YELLOW}Open in devcontainer:${NC}"
echo "   code ."
echo "   # Select 'Reopen in Container' when prompted"
echo ""
echo -e "${GREEN}🎉 Setup complete! Your SBOM Scanner is ready for GitHub publishing.${NC}"