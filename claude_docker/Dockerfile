# Start with
#
# docker run -it \
#   --user "$(id -u)":"$(id -g)"  \
#   -v "$(pwd):/workdir:z" \
#   -v claude-home:/home/dev/.claude \
#   -v "$HOME/.dotfiles:$HOME/.dotfiles:z" \
#   -v "$HOME/.claude.json:/home/dev/.claude.json:z" \
#   -v "$HOME/.netrc:/home/dev/.netrc:z" \
#   -v glab-config:/home/dev/.config/glab-cli \
#   claude-anb:latest
#
# claude-home and glab-config are named volumes that persist container state
# across runs. Create them once with:
#   docker volume create claude-home
#   docker volume create glab-config
#
# The entrypoint symlinks the dotfiles-managed files from claude/ (bind-mounted
# via $HOME/.dotfiles above) into the claude-home volume on every start, so
# those specific files stay live between host and container in both directions.

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

# Pre-create dirs owned by dev so named volumes mounted here inherit dev's
# ownership (1000) instead of being root-owned and unwritable.
RUN mkdir -p /home/dev/.config/glab-cli /home/dev/.claude

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/home/dev/.claude/local/bin:/home/dev/.local/bin:${PATH}"

COPY --chown=dev:dev entrypoint.sh /home/dev/entrypoint.sh
RUN chmod 755 /home/dev/entrypoint.sh

ENTRYPOINT ["/home/dev/entrypoint.sh"]
CMD ["bash"]
