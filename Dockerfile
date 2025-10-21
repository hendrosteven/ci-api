# ==========================================
# Stage 1: PHP with extensions and Composer
# ==========================================
FROM php:8.4-fpm AS app

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev libicu-dev \
    && docker-php-ext-install mysqli pdo_mysql mbstring zip intl gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY . .

# Copy composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --no-interaction --prefer-dist --ignore-platform-reqs

RUN chmod +x spark && chown -R www-data:www-data writable

# ==========================================
# Stage 2: Nginx + PHP-FPM runtime
# ==========================================
FROM nginx:alpine

# Copy Nginx configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy app from previous stage
COPY --from=app /var/www/html /var/www/html

WORKDIR /var/www/html

EXPOSE 80

# Start both services (Nginx + PHP-FPM)
CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]
