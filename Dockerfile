# Use Debian slim base (glibc, better compatibility)
FROM debian:12-slim

# Install dependencies: Node.js for MCP servers, curl for downloads, wget for health check
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs npm curl wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and install opencode binary
ARG OPENCODE_VERSION=1.18.20
RUN curl -fsSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" \
    | tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/opencode && \
    opencode --version

# Create opencode user and config directory
RUN mkdir -p /home/opencode/.config/opencode && \
    mkdir -p /home/opencode/.opencode/agent && \
    useradd -m -d /home/opencode -s /bin/bash opencode && \
    chown -R opencode:opencode /home/opencode

# Copy config with free models + websearch permissions
COPY --chown=opencode:opencode opencode.jsonc /home/opencode/.config/opencode/opencode.jsonc

# Copy agent definitions
COPY --chown=opencode:opencode .opencode/agent/ /home/opencode/.opencode/agent/

USER opencode
WORKDIR /home/opencode

EXPOSE 4096

# Health check for Render
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:4096/doc || exit 1

# Use default config location (should auto-detect ~/.config/opencode/opencode.jsonc)
CMD ["opencode", "serve", "--hostname", "0.0.0.0", "--port", "4096"]