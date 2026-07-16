# Builds mcp-language-server (Go binary) in an isolated stage so it doesn't
# depend on the node feature, which is layered onto this image by the
# devcontainers CLI *after* this Dockerfile builds.
FROM golang:1.24-alpine AS mcp-language-server-builder
RUN go install github.com/isaacphi/mcp-language-server@latest

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    less \
    netcat-openbsd \
    openssh-client \
    # Should not be needed with the uv feature (To be confirmed)
    # python3 \
    # python3-pip \
    # python3-venv \
    ripgrep \
    shellcheck \
    socat \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install the GitLab CLI (glab) from the official release .deb
ARG GLAB_VERSION=1.103.0
RUN curl -fsSL -o /tmp/glab.deb \
    "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_amd64.deb" \
    && apt-get install -y --no-install-recommends /tmp/glab.deb \
    && rm -f /tmp/glab.deb /var/lib/apt/lists/* 2>/dev/null || true

COPY --from=mcp-language-server-builder /go/bin/mcp-language-server /usr/local/bin/mcp-language-server

# Create dev user with a known UID; devcontainer CLI's updateRemoteUserUID
# remaps this to match the host user at container-creation time.
RUN userdel -r ubuntu 2>/dev/null || true
RUN useradd -m -s /bin/bash -u 1000 dev

USER dev
WORKDIR /workdir

# Pre-create dirs owned by dev so named volumes mounted here inherit dev's
# ownership (1000) instead of being root-owned and unwritable.
RUN mkdir -p /home/dev/.config/glab-cli /home/dev/.claude /home/dev/.vscode-server

COPY --chown=dev:dev postCreate.sh /home/dev/postCreate.sh
RUN chmod 755 /home/dev/postCreate.sh
