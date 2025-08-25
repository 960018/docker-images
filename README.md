# Docker Images

A collection of Docker images for various services and applications, built for arm64 architecture and published to GitHub Container Registry.

## Available Images

- **action-split**: Monorepo splitter that can be used in actions (https://github.com/ozo2003/split)
- **bun**: Bun.js runtime environment
- **cron**: Cron job service
- **curl**: Curl utility
- **debian**: Base image for debian based images
- **go**: Golang image with few extra tools
- **nginx**: Nginx web server
- **node**: Node.js runtime environment
- **php**: PHP environment with several variants (fpm, fpm-socket, fpm-testing, etc.)
- **postgres**: PostgreSQL database (versions 13, 14, 15, 16, 17)
- **scratch**: Minimal base image

## Usage

Images are available at `ghcr.io/960018/{image-name}:{tag}`

Example:
```bash
docker pull ghcr.io/960018/postgres:16
docker pull ghcr.io/960018/php-fpm:latest
```
