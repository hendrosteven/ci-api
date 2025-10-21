# ================================================================
# Stage 1: Build dependencies
# ================================================================
FROM composer:2 AS vendor

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist

# ================================================================
# Stage 2: Run CodeIgniter App
# ================================================================
FROM php:8.3-cli

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

WORKDIR /var/www/html

# Copy project files
COPY . .

# Copy vendor from the builder stage
COPY --from=vendor /app/vendor ./vendor

# Make writable directory accessible
RUN chown -R www-data:www-data writable

# Expose port 8080 (Dokploy will map this automatically)
EXPOSE 8080

# Run CodeIgniter using the built-in PHP server
CMD ["php", "spark", "serve", "--host=0.0.0.0", "--port=8080"]
