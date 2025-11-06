#!/bin/sh

# Create .env file from environment variables if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from environment variables..."
    cat > .env << EOF
APP_NAME=${APP_NAME:-Velstore}
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY:-}
APP_DEBUG=${APP_DEBUG:-true}
APP_URL=${APP_URL:-http://localhost}

LOG_CHANNEL=${LOG_CHANNEL:-stack}
LOG_LEVEL=${LOG_LEVEL:-debug}

DB_CONNECTION=${DB_CONNECTION:-mysql}
DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE:-velstore}
DB_USERNAME=${DB_USERNAME:-velstore_user}
DB_PASSWORD=${DB_PASSWORD:-velstore_password}

BROADCAST_DRIVER=${BROADCAST_DRIVER:-log}
CACHE_DRIVER=${CACHE_DRIVER:-file}
FILESYSTEM_DISK=${FILESYSTEM_DISK:-local}
QUEUE_CONNECTION=${QUEUE_CONNECTION:-database}
SESSION_DRIVER=${SESSION_DRIVER:-file}
SESSION_LIFETIME=${SESSION_LIFETIME:-120}

CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS:-*}
CORS_SUPPORTS_CREDENTIALS=${CORS_SUPPORTS_CREDENTIALS:-false}
EOF
    echo ".env file created successfully"
fi

# Read APP_DEBUG from .env file to ensure correct value
if [ -f .env ]; then
    APP_DEBUG_VALUE=$(grep "^APP_DEBUG=" .env | cut -d '=' -f2-)
    if [ ! -z "$APP_DEBUG_VALUE" ]; then
        export APP_DEBUG="$APP_DEBUG_VALUE"
        echo "APP_DEBUG set to: $APP_DEBUG"
    fi
fi

# Generate application key if not set
if [ -z "$APP_KEY" ] || ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    echo "Generating application key..."
    php artisan key:generate --force
    # Update APP_KEY in .env file if it was generated
    if [ -f .env ]; then
        # Read the generated key from .env file
        APP_KEY_VALUE=$(grep "^APP_KEY=" .env | cut -d '=' -f2-)
        if [ ! -z "$APP_KEY_VALUE" ] && [ "$APP_KEY_VALUE" != "" ]; then
            export APP_KEY="$APP_KEY_VALUE"
            echo "Application key generated and set"
        fi
    fi
fi

# Ensure storage/logs directory exists and has write permissions
echo "Setting up storage permissions..."
mkdir -p storage/logs
chown -R www-data:www-data storage/logs bootstrap/cache
chmod -R 775 storage/logs bootstrap/cache

# Create PHP-FPM error log directory
mkdir -p /var/log/php-fpm
chmod 777 /var/log/php-fpm
touch /var/log/php-fpm/error.log
chmod 666 /var/log/php-fpm/error.log

# Clear and cache config
echo "Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Remove old config cache to ensure fresh values
echo "Removing old config cache..."
rm -f bootstrap/cache/config.php bootstrap/cache/routes.php bootstrap/cache/services.php

# Enable PHP error display
echo "Configuring PHP error display..."
echo "display_errors = On" >> /usr/local/etc/php/conf.d/error.ini
echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/error.ini
echo "log_errors = On" >> /usr/local/etc/php/conf.d/error.ini
echo "error_log = /var/log/php-fpm/error.log" >> /usr/local/etc/php/conf.d/error.ini

# Test database connection
echo "Testing database connection..."
php artisan tinker --execute="try { DB::connection()->getPdo(); echo 'Database connection: OK'; } catch(Exception \$e) { echo 'Database connection FAILED: ' . \$e->getMessage(); }" 2>&1 || echo "WARNING: Database connection test failed"

# Cache config for production (skip if DEBUG is true or not production)
if [ "$APP_ENV" = "production" ] && [ "$APP_DEBUG" != "true" ]; then
    echo "Caching configuration for production..."
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
else
    echo "Skipping config cache (DEBUG mode enabled or not production)"
fi

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Show Laravel log if exists (last 30 lines)
if [ -f storage/logs/laravel.log ]; then
    echo "=== Last 30 lines of Laravel log ==="
    tail -30 storage/logs/laravel.log
    echo "=== End of Laravel log ==="
else
    echo "Laravel log file not found yet"
fi

# Start PHP-FPM
php-fpm -D

# Start Nginx
nginx -g "daemon off;"

