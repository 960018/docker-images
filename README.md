# docker-images

This repository contains a collection of Docker images built using Docker Buildx Bake. The images follow a clear hierarchy:
- A custom `scratch` image serves as the foundation for most images
- The `curl` image, built on scratch, provides networking tools and serves as the base for PHP images
- All other images are built on either scratch or curl base, forming a clean dependency tree

## Build System

The project uses Docker Buildx Bake for building all images, with the configuration defined in `docker-bake.hcl`. The build system features:

- Common configuration inherited by all images
- Individual targets for per-architecture builds (amd64, arm64)
- Multiarch targets for creating combined platform images
- Logical groups for efficient parallel building
- Automated build chain with sequential workflow triggers

### Available Images

#### Base Image
- `scratch` - The foundational base image with custom user (vairogs) setup, used as a base for all other images

#### Database
- `postgres` - PostgreSQL image with version matrix (13-17), built on scratch image

#### Network Tools
- `curl` - Extended networking tools image built on scratch, serves as base for PHP images

#### Runtime Images
All built on scratch image:
- `bun` - Bun JavaScript runtime
- `node` - Node.js runtime
- `nginx` - Nginx web server
- `cron` - Cron service for scheduled tasks

#### PHP Images
All built on curl image:
- `php-fpm-base` - Minimal PHP-FPM installation
- `php-fpm` - PHP-FPM with additional extensions:
  - apcu, ds, igbinary, imagick, excimer
  - msgpack, ev, event, lzf, uuid
  - lz4, zstd, inotify, spx, zip, redis
- `php-fpm-socket` - PHP-FPM configured with socket support
- `php-fpm-testing` - PHP-FPM with xdebug and testing tools
- `php-fpm-testing-socket` - Testing variant with socket support

### Build Workflow

The build process is organized into 7 sequential workflows:

1. `1_independent.yaml` - Builds base images (scratch, postgres)
2. `2_dependants.yaml` - Builds images depending on scratch (bun, nginx, node, cron)
3. `3_curl.yaml` - Builds curl image
4. `4_php-fpm-base.yaml` - Builds PHP-FPM base image
5. `5_php-fpm.yaml` - Builds PHP-FPM with extensions
6. `6_php-fpm-testing.yaml` - Builds PHP-FPM testing image
7. `7_php-fpm-socket.yaml` - Builds socket variants of PHP-FPM images

Each workflow:
- Builds per-architecture images (amd64, arm64)
- Creates multiarch manifests
- Triggers the next workflow in the chain

### Registry

Images are published to GitHub Container Registry (ghcr.io) prefix:
- `ghcr.io/960018/` - For all images

### Local vs Workflow Builds

The build system automatically handles image tagging differently based on the build environment:

#### Workflow Builds
When building in GitHub Actions:
- Images use the standard registry prefix: `ghcr.io/960018/`
- Example: `ghcr.io/960018/nginx:latest`

#### Local Builds
When building locally:
- Images are automatically prefixed with "local:"
- Example: `local:ghcr.io/960018/nginx:latest`

This distinction helps prevent confusion between locally built images and official releases.

To override this behavior, you can set the IS_GITHUB_ACTIONS variable:
```bash
# Force workflow-style tags locally
docker buildx bake --set *.args.IS_GITHUB_ACTIONS=true target-name

# Force local-style tags
docker buildx bake --set *.args.IS_GITHUB_ACTIONS=false target-name
```
