FROM php:8.3-cli

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl gd

# Set working directory
WORKDIR /var/www/html

# Copy all files (including spark)
COPY . .

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install dependencies (skip platform checks)
RUN composer install --no-dev --no-interaction --prefer-dist --ignore-platform-reqs

# Ensure spark is executable
RUN chmod +x spark

# Fix writable folder permissions
RUN mkdir -p writable && chown -R www-data:www-data writable

# Expose port for Dokploy
EXPOSE 8080

# Start CodeIgniter app
CMD ["php", "spark", "serve", "--host=0.0.0.0", "--port=8080"]
