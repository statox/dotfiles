FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
# Match host user UID/GID so bind-mounted files (especially credentials) are readable
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    vim \
    neovim \
    bash \
    openssh-client \
    less \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu 24.04 ships a default 'ubuntu' user at UID 1000; remove it to free the UID
RUN userdel -r ubuntu 2>/dev/null || true && \
    groupadd -g "${USER_GID}" dev && \
    useradd -m -s /bin/bash -u "${USER_UID}" -g "${USER_GID}" dev
USER dev
RUN mkdir -p /home/dev/.claude /home/dev/.config
WORKDIR /workdir

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/dev/.local/bin:${PATH}"

ENTRYPOINT ["claude"]
