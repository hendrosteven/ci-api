FROM php:8.3-cli AS app

RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

WORKDIR /var/www/html

COPY . .
RUN php spark cache:clear || true

RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist
RUN chown -R www-data:www-data writable

EXPOSE 8080
CMD ["php", "spark", "serve", "--host=0.0.0.0", "--port=8080"]
