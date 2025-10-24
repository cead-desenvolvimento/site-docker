FROM wordpress:php8.2-fpm

RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && echo "America/Sao_Paulo" > /etc/timezone

RUN chown -R www-data:www-data /var/www/html
