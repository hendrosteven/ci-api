# ==========================================
# Base image: PHP 8.4 + FPM + Alpine
# ==========================================
FROM php:8.4-fpm-alpine

# Install system dependencies + Nginx
RUN apk add --no-cache nginx git unzip icu-dev libzip-dev libpng-dev oniguruma-dev libxml2-dev bash curl

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo_mysql mbstring zip intl gd

# Set working directory
WORKDIR /var/www/html

# Copy app files
COPY . .

# Copy composer from official image and install dependencies
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --no-interaction --prefer-dist --ignore-platform-reqs

# Copy Nginx config
COPY nginx.conf /etc/nginx/http.d/default.conf

# Fix permissions
RUN chmod +x spark && chown -R www-data:www-data writable

# Expose ports
EXPOSE 80

# Healthcheck (optional)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD curl -f http://localhost/ || exit 1

# Start both services
CMD sh -c "php-fpm -D && nginx -g 'daemon off;'"
