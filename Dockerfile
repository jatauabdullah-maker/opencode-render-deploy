# Use Alpine base
FROM alpine:3.20

# Install dependencies: Node.js for MCP servers, curl for downloads, wget for health check
RUN apk add --no-cache nodejs npm curl wget

# Download and install opencode binary (musl version for Alpine)
ARG OPENCODE_VERSION=1.18.20
RUN curl -fsSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64-musl.tar.gz" \
    | tar -xz -C /usr/local/bin && \
    chmod +x /usr/local/bin/opencode && \
    opencode --version

# Create opencode user and config directory
RUN mkdir -p /home/opencode/.config/opencode && \
    mkdir -p /home/opencode/.opencode/agent && \
    adduser -D -h /home/opencode opencode && \
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

CMD ["opencode", "serve", "--hostname", "0.0.0.0", "--port", "4096", "--config", "/home/opencode/.config/opencode/opencode.jsonc"]