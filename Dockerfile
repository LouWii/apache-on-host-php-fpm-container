FROM php:7.4-fpm

# Use https://github.com/mlocati/docker-php-extension-installer to easily install PHP extensions
# This is a rough example, we don't even need those for getting the example project running, remove it to speed up the container build
RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions gd xdebug @composer-1

# Copy default dev config to be used as php fpm config
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
