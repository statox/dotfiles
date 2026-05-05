FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

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

RUN useradd -m -s /bin/bash dev
USER dev
WORKDIR /workdir

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/dev/.local/bin:${PATH}"

ENTRYPOINT ["claude"]
