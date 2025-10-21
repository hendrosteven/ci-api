# ======================================================
# Stage: Production build for CodeIgniter 4 REST API
# ======================================================
FROM php:8.4-cli AS app

# Install required system packages and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev libicu-dev \
    && docker-php-ext-install mysqli pdo_mysql mbstring zip intl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy all project files including spark, composer.json, etc.
COPY . .

# Install Composer from the official image (no multi-stage complexity)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install dependencies (ignores platform extension mismatch)
RUN composer install --no-dev --no-interaction --prefer-dist --ignore-platform-reqs

# Ensure spark is executable
RUN chmod +x spark

# Create and fix permissions for writable directory
RUN mkdir -p writable && chown -R www-data:www-data writable

# Expose the app port for Dokploy
EXPOSE 8080

# Use CI4 built-in server as the main process
CMD ["php", "spark", "serve", "--host=0.0.0.0", "--port=8080"]
