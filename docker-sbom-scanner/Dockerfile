# Multi-Language SBOM Scanner Docker Image
# Supports .NET, Node.js, and Python projects
# Author: Sujit Singh
# Usage: docker run sbom-scanner [project-type] [path]

FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    curl \
    jq \
    bash \
    git \
    ca-certificates \
    python3 \
    py3-pip \
    nodejs \
    npm \
    && update-ca-certificates

# Set working directory
WORKDIR /app

# Install .NET SBOM Tool
RUN dotnet tool install --global Microsoft.Sbom.DotNetTool

# Add .NET tools and Python venv to PATH
ENV PATH="$PATH:/root/.dotnet/tools:/app/venv/bin"

# Install Python packages for license detection using virtual environment
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir \
    pip-licenses \
    pipdeptree \
    requests

# Install Node.js license checker globally
RUN npm install -g license-checker --silent

# Create directories for output
RUN mkdir -p /app/output /app/temp

# Copy scanner scripts
COPY entrypoint.sh /app/
COPY scanner.sh /app/

# Make scripts executable
RUN chmod +x /app/entrypoint.sh /app/scanner.sh

# Set environment variables
ENV SBOM_OUTPUT_DIR="/app/output"
ENV SBOM_TEMP_DIR="/app/temp"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Create non-root user for security and devcontainer compatibility
RUN addgroup -g 1001 sbom && \
    adduser -D -u 1001 -G sbom -s /bin/bash sbom && \
    chown -R sbom:sbom /app && \
    # Add sbom user to sudoers for devcontainer
    apk add --no-cache sudo && \
    echo "sbom ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sbom

# Set default user (can be overridden in devcontainer)
USER sbom
ENV PATH="$PATH:/home/sbom/.dotnet/tools"
# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD dotnet sbom-tool --version || exit 1

# Entry point
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["--help"]