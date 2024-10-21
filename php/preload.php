<?php declare(strict_types = 1);

function bool(
    mixed $value,
): bool {
    if (is_bool($value)) {
        return $value;
    }

    $value = strtolower((string) $value);

    return match ($value) {
        'y', '1', 'true' => true,
        'n', '0', 'false' => false,
        default => filter_var($value, FILTER_VALIDATE_BOOL),
    };
}

if ('cli' !== PHP_SAPI && bool($_ENV['ENABLE_PRELOAD'] ?? true)) {
    if (null === ($_ENV['PRELOAD_FILE'] ?? null)) {
        if ('prod' === ($_ENV['APP_ENV'] ?? null)) {
            $prefix = '/var/www/html';
            $path = '/var/cache/prod/';
            $filename = 'App_KernelProdContainer.preload.php';

            if (!is_dir($long = $prefix . '/api' . $path)) {
                $long = null;
            }

            $dir = $_ENV['PRELOAD_DIR'] ?? (is_dir($short = $prefix . $path) ? $short : $long);

            if (null !== $dir && file_exists($dir . $path . $filename)) {
                opcache_compile_file($dir . $path . $filename);
            }
        }
    } else {
        opcache_compile_file($_ENV['PRELOAD_FILE']);
    }
}
