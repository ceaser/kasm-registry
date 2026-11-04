# Kasm Workspaces image: Ubuntu Noble desktop + Node.js, corepack, pnpm, git, yadm
#
# Build (see build.sh):
#   docker build --build-arg BASE_TAG=1.19.0 -t ghcr.io/ceaser/kasm-nodejs:1.19.0 .

ARG BASE_IMAGE=kasmweb/ubuntu-noble-desktop
ARG BASE_TAG=1.19.0
FROM ${BASE_IMAGE}:${BASE_TAG}

USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

ARG NODE_VERSION=22.23.4
ARG PNPM_VERSION=12.16.1
ARG YADM_VERSION=3.5.0

# git (needed by yadm and general development), plus tools used below.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gnupg \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Node.js from the official tarball, verified against the published SHASUMS256.
# The tarball bundles npm, npx and corepack.
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
        amd64) NODE_ARCH=x64 ;; \
        arm64) NODE_ARCH=arm64 ;; \
        *) echo "unsupported architecture" >&2; exit 1 ;; \
    esac; \
    TARBALL="node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"; \
    cd /tmp; \
    curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/${TARBALL}"; \
    curl -fsSLO "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt"; \
    grep " ${TARBALL}\$" SHASUMS256.txt | sha256sum -c -; \
    tar -xJf "${TARBALL}" -C /usr/local --strip-components=1 --no-same-owner; \
    rm -f "${TARBALL}" SHASUMS256.txt; \
    ln -sf /usr/local/bin/node /usr/local/bin/nodejs; \
    node --version; npm --version; corepack --version

# corepack: enable the shims (pnpm, yarn) and pre-install the pinned pnpm so
# it works offline. COREPACK_HOME lives outside $HOME so the cache survives
# the Kasm profile copy and is writable by the session user (uid 1000).
ENV COREPACK_HOME=/opt/corepack
RUN set -eux; \
    mkdir -p "${COREPACK_HOME}"; \
    corepack enable --install-directory /usr/local/bin; \
    corepack install -g "pnpm@${PNPM_VERSION}"; \
    pnpm --version; \
    chown -R 1000:0 "${COREPACK_HOME}"; \
    chmod -R g+rwX "${COREPACK_HOME}"

# pnpm global installs (`pnpm add -g`) need PNPM_HOME on PATH.
ENV PNPM_HOME=/home/kasm-user/.local/share/pnpm
ENV PATH=$PNPM_HOME:$PATH

# yadm (dotfile manager) is a single bash script; install the pinned release.
RUN set -eux; \
    curl -fsSL "https://raw.githubusercontent.com/yadm-dev/yadm/${YADM_VERSION}/yadm" \
        -o /usr/local/bin/yadm; \
    chmod 755 /usr/local/bin/yadm; \
    mkdir -p /etc/bash_completion.d; \
    curl -fsSL "https://raw.githubusercontent.com/yadm-dev/yadm/${YADM_VERSION}/completion/bash/yadm" \
        -o /etc/bash_completion.d/yadm; \
    yadm version

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
