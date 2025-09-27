# Multi-Language SBOM Scanner Docker Image
# Supports .NET, Node.js, and Python projects
# Author: Sujit Singh
# Usage: docker run sbom-scanner [project-type] [path]

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS base

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

# Create non-root user first
RUN addgroup -g 1001 sbom && \
    adduser -D -u 1001 -G sbom -s /bin/bash sbom

# Install .NET SBOM Tool (compatible with .NET 8.0) for both root and sbom user
RUN dotnet tool install --global Microsoft.Sbom.DotNetTool

# Switch to sbom user and install the tool for sbom user as well
USER sbom
RUN dotnet tool install --global Microsoft.Sbom.DotNetTool
USER root

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

# Make scripts executable and create sbom-scanner command alias
RUN chmod +x /app/entrypoint.sh /app/scanner.sh && \
    ln -sf /app/entrypoint.sh /usr/local/bin/sbom-scanner

# Set environment variables
ENV SBOM_OUTPUT_DIR="/app/output"
ENV SBOM_TEMP_DIR="/app/temp"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Set ownership and configure sudo
RUN chown -R sbom:sbom /app && \
    apk add --no-cache sudo && \
    echo "sbom ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sbom

# Set default user (can be overridden in devcontainer)
USER sbom
ENV PATH="$PATH:/home/sbom/.dotnet/tools"
# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/entrypoint.sh --version || exit 1

# Entry point
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["--help"]