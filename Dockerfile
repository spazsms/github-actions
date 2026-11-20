# Dockerfile for Laravel 13 on Render
# Put this file in the ROOT of your Laravel project (next to composer.json).
# Render reads it and builds the image for you. You do not need Docker on your laptop.

# 1. Start from an official image that already has PHP 8.4 (Laravel 13 needs 8.3 or newer)
FROM php:8.4-fpm

# 2. Install NGINX (the web server) and the libraries some PHP extensions need
RUN apt-get update \
 && apt-get install -y --no-install-recommends nginx git unzip libzip-dev libpq-dev \
 && docker-php-ext-install pdo_mysql pdo_pgsql zip bcmath opcache \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

# 3. Bring in Composer (the PHP package manager)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 4. Work inside this folder
WORKDIR /var/www/html

# 5. Copy your project into the image
COPY . .

# 6. Install the PHP packages for production (no dev tools like Pint or Larastan)
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
 && chown -R www-data:www-data storage bootstrap/cache database

# 7. Add the web server settings and the start script from the docker/ folder
COPY docker/nginx.conf /etc/nginx/sites-available/default
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# 8. What runs every time the container starts
CMD ["start.sh"]
