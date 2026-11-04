#!/usr/bin/env bash
# Build (and optionally push) the Node.js Development workspace image for one
# or more Kasm releases. The Kasm release tag selects the kasmweb base image
# and becomes the tag of the resulting image, matching workspace.json.
#
# Usage:
#   ./build.sh                 # build 1.19.0 (default)
#   ./build.sh 1.17.0 1.18.0   # build specific Kasm releases
#   PUSH=1 ./build.sh          # build and push to the registry
#
# Env:
#   IMAGE   image name without tag (default ghcr.io/ceaser/kasm-nodejs)
#   PUSH    set to 1 to push after building
set -euo pipefail

cd "$(dirname "$0")"

IMAGE="${IMAGE:-ghcr.io/ceaser/kasm-nodejs}"
VERSIONS=("$@")
[ ${#VERSIONS[@]} -eq 0 ] && VERSIONS=(1.19.0)

for KASM_VERSION in "${VERSIONS[@]}"; do
    TAG="${IMAGE}:${KASM_VERSION}"
    echo "==> Building ${TAG} from kasmweb/ubuntu-noble-desktop:${KASM_VERSION}"
    docker build \
        --build-arg "BASE_TAG=${KASM_VERSION}" \
        -t "${TAG}" \
        .

    SIZE_MB=$(docker image inspect "${TAG}" --format '{{.Size}}' | awk '{printf "%d", $1/1000000}')
    echo "==> ${TAG} uncompressed size: ${SIZE_MB} MB (use for uncompressed_size_mb in workspace.json)"

    if [ "${PUSH:-0}" = "1" ]; then
        echo "==> Pushing ${TAG}"
        docker push "${TAG}"
    fi
done
