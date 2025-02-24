// Build configuration
variable "DOCKER_BUILDKIT" {
    default = "1"
}

variable "COMPOSE_DOCKER_CLI_BUILD" {
    default = "1"
}

variable "COMPOSE_BAKE" {
    default = "true"
}

// Registry configuration
variable "REGISTRY_BASE" {
    default = "ghcr.io/960018"
}

variable "REGISTRY_PREFIX" {
    default = "${REGISTRY_BASE}/"
}

variable "PHP_REGISTRY_PREFIX" {
    default = "${REGISTRY_BASE}/php/"
}

// Build variables
variable "TARGETARCH" {
    default = "arm64"
}

variable "LATEST_TAG" {
    default = "latest"
}

variable "POSTGRES_VERSIONS" {
    default = ["13", "14", "15", "16", "17"]
}

target "common" {
    context = "."
    platforms = ["linux/${TARGETARCH}"]
    labels = {
        "maintainer" = "support@vairogs.com"
        "org.opencontainers.image.source" = "https://github.com/960018/docker-images"
        "org.opencontainers.image.licenses" = "MIT"
    }
}

variable "MULTIARCH_PLATFORMS" {
    default = ["linux/amd64", "linux/arm64"]
}

target "multiarch-base" {
    platforms = MULTIARCH_PLATFORMS
}

target "scratch" {
    inherits = ["common"]
    dockerfile = "scratch.dockerfile"
    tags = ["${REGISTRY_PREFIX}scratch:${TARGETARCH}"]
    labels = {
        "org.opencontainers.image.description" = "custom built image with same user (vairogs) throughout all images"
    }
}

target "bun" {
    inherits = ["common"]
    dockerfile = "bun.dockerfile"
    tags = ["${REGISTRY_PREFIX}bun:${TARGETARCH}"]
    args = {
        BUN_RUNTIME_TRANSPILER_CACHE_PATH = "0"
        BUN_INSTALL_BIN = "/usr/local/bin"
    }
}

target "cron" {
    inherits = ["common"]
    dockerfile = "cron.dockerfile"
    tags = ["${REGISTRY_PREFIX}cron:${TARGETARCH}"]
}

target "node" {
    inherits = ["common"]
    dockerfile = "node.dockerfile"
    tags = ["${REGISTRY_PREFIX}node:${TARGETARCH}"]
}

target "curl" {
    inherits = ["common"]
    dockerfile = "curl.dockerfile"
    tags = ["${REGISTRY_PREFIX}curl:${TARGETARCH}"]
}

target "nginx" {
    inherits = ["common"]
    dockerfile = "nginx.dockerfile"
    tags = ["${REGISTRY_PREFIX}nginx:${TARGETARCH}"]
}

target "php-fpm-base" {
    inherits = ["common"]
    dockerfile = "php-fpm-base.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-base:${TARGETARCH}"]
    args = {
        PHP_COMMIT_HASH = ""
        ARCH = "${TARGETARCH}"
    }
}

target "php-fpm" {
    inherits = ["common"]
    dockerfile = "php-fpm.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm:${TARGETARCH}"]
}

target "php-fpm-socket" {
    inherits = ["common"]
    dockerfile = "php-fpm-socket.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-socket:${TARGETARCH}"]
}

target "php-fpm-testing" {
    inherits = ["common"]
    dockerfile = "php-fpm-testing.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-testing:${TARGETARCH}"]
}

target "php-fpm-testing-socket" {
    inherits = ["common"]
    dockerfile = "php-fpm-testing-socket.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-testing-socket:${TARGETARCH}"]
}

target "postgres" {
    inherits = ["common"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = ""
        POSTGRES_LOCALE = "en_US"
    }
    labels = {
        "maintainer" = "support@vairogs.com"
        "org.opencontainers.image.source" = "https://github.com/960018/docker-images"
        "org.opencontainers.image.licenses" = "MIT"
    }
}

target "postgres-version" {
    inherits = ["postgres"]
    matrix = {
        version = POSTGRES_VERSIONS
    }
    args = {
        VERSION = "${version}"
    }
    tags = ["${REGISTRY_PREFIX}postgres:${version}-${TARGETARCH}"]
}

target "scratch-multiarch" {
    inherits = ["scratch", "multiarch-base"]
    tags = ["${REGISTRY_PREFIX}scratch:${LATEST_TAG}"]
}

target "postgres-multiarch" {
    inherits = ["postgres", "multiarch-base"]
    matrix = {
        version = POSTGRES_VERSIONS
    }
    args = {
        VERSION = "${version}"
    }
    tags = ["${REGISTRY_PREFIX}postgres:${version}"]
}

group "postgres-all" {
    targets = ["postgres-version"]
}

target "bun-multiarch" {
    inherits = ["bun", "multiarch-base"]
    tags = ["${REGISTRY_PREFIX}bun:${LATEST_TAG}"]
}

target "nginx-multiarch" {
    inherits = ["nginx", "multiarch-base"]
    tags = ["${REGISTRY_PREFIX}nginx:${LATEST_TAG}"]
}

target "node-multiarch" {
    inherits = ["node", "multiarch-base"]
    tags = ["${REGISTRY_PREFIX}node:${LATEST_TAG}"]
}

target "cron-multiarch" {
    inherits = ["cron", "multiarch-base"]
    tags = ["${REGISTRY_PREFIX}cron:${LATEST_TAG}"]
}

group "multiarch" {
    targets = ["scratch-multiarch", "postgres-multiarch"]
}

target "curl-multiarch" {
    inherits = ["curl", "multiarch-base"]
    tags = ["${REGISTRY_PREFIX}curl:${LATEST_TAG}"]
}

target "php-fpm-base-multiarch" {
    inherits = ["php-fpm-base", "multiarch-base"]
    tags = ["${PHP_REGISTRY_PREFIX}fpm-base:${LATEST_TAG}"]
}

target "php-fpm-multiarch" {
    inherits = ["php-fpm", "multiarch-base"]
    tags = ["${PHP_REGISTRY_PREFIX}fpm:${LATEST_TAG}"]
}

target "php-fpm-testing-multiarch" {
    inherits = ["php-fpm-testing", "multiarch-base"]
    tags = ["${PHP_REGISTRY_PREFIX}fpm-testing:${LATEST_TAG}"]
}

target "php-fpm-socket-multiarch" {
    inherits = ["php-fpm-socket", "multiarch-base"]
    tags = ["${PHP_REGISTRY_PREFIX}fpm-socket:${LATEST_TAG}"]
}

target "php-fpm-testing-socket-multiarch" {
    inherits = ["php-fpm-testing-socket", "multiarch-base"]
    tags = ["${PHP_REGISTRY_PREFIX}fpm-testing-socket:${LATEST_TAG}"]
}

group "dependants-multiarch" {
    targets = ["bun-multiarch", "nginx-multiarch", "node-multiarch", "cron-multiarch"]
}

group "php-socket-multiarch" {
    targets = ["php-fpm-socket-multiarch", "php-fpm-testing-socket-multiarch"]
}
