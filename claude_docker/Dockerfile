# Start with
#
# docker run -it \
#   --user "$(id -u)":"$(id -g)"  \
#   -v "$(pwd):/workdir:z" \
#   -v "$HOME/.claude:/home/dev/.claude:z" \
#   -v "$HOME/.claude.json:/home/dev/.claude.json:z" \
#   -v "$HOME/.netrc:/home/dev/.netrc:z" \
#   -v glab-config:/home/dev/.config/glab-cli \
#   claude-anb:latest
#
# The glab-config named volume persists your glab login. Create it once with:
#   docker volume create glab-config

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    less \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep \
    shellcheck \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install the GitLab CLI (glab) from the official release .deb
ARG GLAB_VERSION=1.103.0
RUN curl -fsSL -o /tmp/glab.deb \
    "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_amd64.deb" \
    && apt-get install -y --no-install-recommends /tmp/glab.deb \
    && rm -f /tmp/glab.deb /var/lib/apt/lists/* 2>/dev/null || true

# Create dev user with a known UID that --user will override at runtime
RUN userdel -r ubuntu 2>/dev/null || true
RUN useradd -m -s /bin/bash -u 1000 dev

USER dev
WORKDIR /workdir

# Pre-create the glab config dir owned by dev so a named volume mounted here
# inherits dev's ownership (1000) instead of being root-owned and unwritable.
RUN mkdir -p /home/dev/.config/glab-cli

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/home/dev/.claude/local/bin:/home/dev/.local/bin:${PATH}"

ENTRYPOINT ["bash"]
