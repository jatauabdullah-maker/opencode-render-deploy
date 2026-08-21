# Use official opencode Docker image
FROM ghcr.io/anomalyco/opencode:latest

# Install Node.js for npx (playwright MCP)
USER root
RUN apk add --no-cache nodejs npm

# Create opencode user and config directory
RUN mkdir -p /home/opencode/.config/opencode && \
    mkdir -p /home/opencode/.opencode/agent && \
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