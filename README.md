# Docker Images

A collection of Docker images for various services and applications, built for both amd64 and arm64 architectures and published to GitHub Container Registry.

## Available Images

- **scratch**: Minimal base image
- **bun**: Bun.js runtime environment
- **cron**: Cron job service
- **curl**: Curl utility
- **nginx**: Nginx web server
- **node**: Node.js runtime environment
- **php**: PHP environment with several variants (fpm, fpm-socket, fpm-testing, etc.)
- **postgres**: PostgreSQL database (versions 13, 14, 15, 16, 17)

## Usage

Images are available at `ghcr.io/960018/{image-name}:{tag}`

Example:
```bash
docker pull ghcr.io/960018/postgres:16
docker pull ghcr.io/960018/php-fpm:latest
```
