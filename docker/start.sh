#!/bin/sh
# Start script: runs every time Render starts the container.
# Save as docker/start.sh in your project. The Dockerfile copies it into the image.
set -e
cd /var/www/html

# 1. Listen on the port Render gives us (Render's default is 10000)
sed -i "s/__PORT__/${PORT:-10000}/" /etc/nginx/sites-available/default

# 2. SQLite (the Laravel default): create the database file if it is missing.
#    It is reset on every deploy, which is fine for the training lab.
if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
  touch database/database.sqlite
  chown www-data:www-data database/database.sqlite
fi

# 3. Laravel start-up work
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan migrate --force

# 4. Start PHP in the background, then NGINX in the foreground
php-fpm -D
exec nginx -g 'daemon off;'
