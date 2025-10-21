# ===============================================================
# Stage 1: Composer dependencies
# ===============================================================
FROM composer:2 AS vendor

WORKDIR /app

# Copy only composer files first (for caching)
COPY composer.json composer.lock* ./

# Make sure PHP extensions exist for dependency resolution
RUN composer install --no-dev --no-interaction --prefer-dist --ignore-platform-reqs

# ===============================================================
# Stage 2: CodeIgniter runtime
# ===============================================================
FROM php:8.3-cli

# Install required system libraries and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip libpng-dev libonig-dev libxml2-dev git \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

# Set working directory
WORKDIR /var/www/html

# Copy app source
COPY . .

# Copy vendor folder from builder
COPY --from=vendor /app/vendor ./vendor

# Ensure writable folder permission
RUN mkdir -p writable && chown -R www-data:www-data writable

# Expose CodeIgniter server port
EXPOSE 8080

# Start CodeIgniter built-in server
CMD ["php", "spark", "serve", "--host=0.0.0.0", "--port=8080"]
