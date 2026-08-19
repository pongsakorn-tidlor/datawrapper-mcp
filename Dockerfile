FROM --platform=linux/amd64 python:3.11-slim AS build

# Install minimal system dependencies required
RUN apt-get update && \
    apt-get install -y \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists

# Create deployment user and group
RUN groupadd -g 1234 deploymentgroup && \
    useradd -m -u 1234 -g deploymentgroup deployment

# Create a directory for the .env file as root, since /app (created below
# by WORKDIR) is root-owned and the non-root deployment user can't write to it
RUN mkdir -p /app/config

USER deployment
ENV PATH="/home/deployment/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy application code
COPY ./datawrapper_mcp /app/datawrapper_mcp
COPY ./deployment /app/deployment

# Install dependencies
RUN pip install --no-cache-dir -r /app/deployment/requirements.txt

# Expose the server port
EXPOSE 8080

# Set environment variables (can be overridden at runtime)
ENV MCP_SERVER_HOST="0.0.0.0"
ENV MCP_SERVER_PORT=8080
ENV MCP_SERVER_NAME="datawrapper-mcp"

# Run the HTTP server
CMD ["python", "-m", "deployment.app"]
