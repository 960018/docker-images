// Build configuration
variable "DOCKER_BUILDKIT" { default = "1" }
variable "COMPOSE_DOCKER_CLI_BUILD" { default = "1" }
variable "COMPOSE_BAKE" { default = "true" }

// Environment detection
variable "IS_GITHUB_ACTIONS" { default = "" }

// Registry configuration
variable "REGISTRY_BASE" { default = "ghcr.io/960018" }
variable "LOCAL_PREFIX" { default = notequal("true",IS_GITHUB_ACTIONS) ? "local:" : "" }
variable "REGISTRY_PREFIX" { default = "${LOCAL_PREFIX}${REGISTRY_BASE}/" }
variable "PHP_REGISTRY_PREFIX" { default = "${LOCAL_PREFIX}${REGISTRY_BASE}/php/" }

// Build variables
variable "TARGETARCH" { default = "arm64" }
variable "LATEST_TAG" { default = "latest" }
variable "POSTGRES_VERSIONS" { default = ["13", "14", "15", "16", "17"] }
variable "MULTIARCH_PLATFORMS" { default = ["linux/amd64", "linux/arm64"] }

// Common labels
variable "COMMON_LABELS" {
    default = {
        "maintainer" = "support@vairogs.com"
        "org.opencontainers.image.source" = "https://github.com/960018/docker-images"
        "org.opencontainers.image.licenses" = "MIT"
    }
}

// Base targets for inheritance
target "common" {
    context = "."
    platforms = ["linux/${TARGETARCH}"]
    labels = COMMON_LABELS
}

// Base target for multiarch support
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

// Individual postgres version targets
target "postgres-13" {
    inherits = ["common"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "13"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:13-${TARGETARCH}"]
}

target "postgres-14" {
    inherits = ["common"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "14"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:14-${TARGETARCH}"]
}

target "postgres-15" {
    inherits = ["common"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "15"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:15-${TARGETARCH}"]
}

target "postgres-16" {
    inherits = ["common"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "16"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:16-${TARGETARCH}"]
}

target "postgres-17" {
    inherits = ["common"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "17"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:17-${TARGETARCH}"]
}

// Individual postgres multiarch version targets
target "postgres-multiarch-13" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "13"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:13"]
}

target "postgres-multiarch-14" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "14"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:14"]
}

target "postgres-multiarch-15" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "15"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:15"]
}

target "postgres-multiarch-16" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "16"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:16"]
}

target "postgres-multiarch-17" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "postgres.dockerfile"
    args = {
        VERSION = "17"
        POSTGRES_LOCALE = "C.UTF-8"
    }
    tags = ["${REGISTRY_PREFIX}postgres:17"]
}

// Multiarch variants for basic images
target "scratch-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "scratch.dockerfile"
    tags = ["${REGISTRY_PREFIX}scratch:${LATEST_TAG}"]
}

target "bun-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "bun.dockerfile"
    tags = ["${REGISTRY_PREFIX}bun:${LATEST_TAG}"]
}

target "nginx-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "nginx.dockerfile"
    tags = ["${REGISTRY_PREFIX}nginx:${LATEST_TAG}"]
}

target "node-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "node.dockerfile"
    tags = ["${REGISTRY_PREFIX}node:${LATEST_TAG}"]
}

target "cron-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "cron.dockerfile"
    tags = ["${REGISTRY_PREFIX}cron:${LATEST_TAG}"]
}

target "curl-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "curl.dockerfile"
    tags = ["${REGISTRY_PREFIX}curl:${LATEST_TAG}"]
}

// PHP multiarch variants
target "php-fpm-base-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "php-fpm-base.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-base:${LATEST_TAG}"]
}

target "php-fpm-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "php-fpm.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm:${LATEST_TAG}"]
}

target "php-fpm-testing-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "php-fpm-testing.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-testing:${LATEST_TAG}"]
}

target "php-fpm-socket-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "php-fpm-socket.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-socket:${LATEST_TAG}"]
}

target "php-fpm-testing-socket-multiarch" {
    inherits = ["common", "multiarch-base"]
    dockerfile = "php-fpm-testing-socket.dockerfile"
    tags = ["${PHP_REGISTRY_PREFIX}fpm-testing-socket:${LATEST_TAG}"]
}

// Groups
group "postgres-versions" {
    targets = ["postgres-13", "postgres-14", "postgres-15", "postgres-16", "postgres-17"]
}

group "postgres-multiarch" {
    targets = ["postgres-multiarch-13", "postgres-multiarch-14", "postgres-multiarch-15", "postgres-multiarch-16", "postgres-multiarch-17"]
}

group "postgres-all" {
    targets = ["postgres-versions", "postgres-multiarch"]
}

group "basic-multiarch" {
    targets = ["scratch-multiarch", "bun-multiarch", "nginx-multiarch", "node-multiarch", "cron-multiarch", "curl-multiarch"]
}

group "php-multiarch" {
    targets = ["php-fpm-base-multiarch", "php-fpm-multiarch", "php-fpm-testing-multiarch"]
}

group "php-socket-multiarch" {
    targets = ["php-fpm-socket-multiarch", "php-fpm-testing-socket-multiarch"]
}

group "multiarch" {
    targets = ["basic-multiarch", "postgres-multiarch", "php-multiarch", "php-socket-multiarch"]
}
