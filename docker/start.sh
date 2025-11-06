#!/bin/sh

# Create .env file from environment variables if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from environment variables..."
    cat > .env << EOF
APP_NAME=${APP_NAME:-Velstore}
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY:-}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-http://localhost}

LOG_CHANNEL=${LOG_CHANNEL:-stack}
LOG_LEVEL=${LOG_LEVEL:-error}

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

# Clear and cache config
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Cache config for production
if [ "$APP_ENV" = "production" ]; then
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
fi

# Run migrations
php artisan migrate --force

# Start PHP-FPM
php-fpm -D

# Start Nginx
nginx -g "daemon off;"

