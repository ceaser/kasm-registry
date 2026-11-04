# Node.js Development workspace

Kasm workspace based on `kasmweb/ubuntu-noble-desktop` with:

| Tool     | Version | Source                                   |
| -------- | ------- | ---------------------------------------- |
| Node.js  | 22.23.4 | Official tarball, SHA256 verified        |
| npm      | bundled | Ships with Node.js                       |
| corepack | bundled | Ships with Node.js, enabled              |
| pnpm     | 12.16.1 | Installed and pinned through corepack    |
| git      | apt     | Ubuntu Noble package                     |
| yadm     | 3.5.0   | Pinned release script from GitHub        |

## Building

The image tag follows the Kasm release it is built against so that each
`compatibility` entry in `workspace.json` maps to one image.

```bash
cd "workspaces/Node.js Development"
./build.sh 1.19.0              # build only
PUSH=1 ./build.sh 1.17.0 1.18.0 1.19.0   # build and push every supported release
```

After building, copy the printed uncompressed size into `uncompressed_size_mb`
for the matching entry in `workspace.json`.

To bump Node.js, pnpm or yadm, change the `NODE_VERSION`, `PNPM_VERSION` or
`YADM_VERSION` build args in the `Dockerfile` and rebuild.

## Notes

* Images are pushed to `ghcr.io/ceaser/kasm-nodejs`. New GHCR packages are
  private by default; make the package public (or add registry credentials in
  Kasm) so Kasm can pull it.
* Only `amd64` is built by default. The Dockerfile also supports `arm64`; build
  with `docker buildx build --platform linux/amd64,linux/arm64` and add
  `"arm64"` to `architecture` in `workspace.json` if you need it.
