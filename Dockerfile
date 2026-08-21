# Use Node.js base image (includes npm for MCP servers)
FROM node:20-alpine

# Install opencode CLI globally
RUN npm install -g opencode-ai

# Verify installation
RUN opencode --version

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

# Start server with explicit config path
CMD ["opencode", "serve", "--hostname", "0.0.0.0", "--port", "4096", "--config", "/home/opencode/.config/opencode/opencode.jsonc"]