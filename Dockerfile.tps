ARG ENVIRONMENT=production
ARG COMPOSER_ALLOW_SUPERUSER=1
ARG COMPOSER_VERSION=2.1.1
ARG PECL_REDIS_VERSION=5.3.4
ARG PHP_VERSION=7.4.20
ARG APACHE_DOCUMENT_ROOT=/var/www/snipe-it/public
ARG TPS_CUSTOMIZATIONS_REPO='tulsaschoolsdata/snipe-it-customizations'
ARG TPS_CUSTOMIZATIONS_REF='5.x-dev'
ARG X_COMPOSER_GITHUB_OAUTH

FROM composer:${COMPOSER_VERSION} AS composer

FROM php:${PHP_VERSION}-apache AS php-apache

FROM php-apache AS snipe-it
COPY --from=composer /usr/bin/composer /usr/local/bin

ARG ENVIRONMENT
ENV ENVIRONMENT ${ENVIRONMENT}
ARG APACHE_DOCUMENT_ROOT
ENV APACHE_DOCUMENT_ROOT ${APACHE_DOCUMENT_ROOT}
ARG COMPOSER_ALLOW_SUPERUSER
ENV COMPOSER_ALLOW_SUPERUSER ${COMPOSER_ALLOW_SUPERUSER}

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
  ; sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

## Snipe-IT System Dependencies
RUN apt-get update && apt-get install -y \
        default-mysql-client \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libldap2-dev \
        libzip-dev \
        unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        ldap \
        mysqli \
        pdo_mysql \
        zip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /var/www/snipe-it
WORKDIR /var/www/snipe-it
RUN set -eux; \
    if [ "$ENVIRONMENT" = "production" ]; then \
        echo "production enviroment detected!"; \
        composer install \
            --no-cache \
            --no-dev \
            --optimize-autoloader; \
    else \
        echo "development enviroment detected!"; \
        composer install \
            --no-cache \
            --prefer-source \
            --optimize-autoloader; \
    fi; \
    chown -R www-data:www-data .;

FROM snipe-it

ARG COMPOSER_ALLOW_SUPERUSER
ENV COMPOSER_ALLOW_SUPERUSER ${COMPOSER_ALLOW_SUPERUSER}
ARG PECL_REDIS_VERSION
ENV PECL_REDIS_VERSION ${PECL_REDIS_VERSION}
ARG TPS_CUSTOMIZATIONS_REPO
ENV TPS_CUSTOMIZATIONS_REPO $TPS_CUSTOMIZATIONS_REPO
ARG TPS_CUSTOMIZATIONS_REF
ENV TPS_CUSTOMIZATIONS_REF $TPS_CUSTOMIZATIONS_REF
ARG X_COMPOSER_GITHUB_OAUT
ENV X_COMPOSER_GITHUB_OAUT $X_COMPOSER_GITHUB_OAUT

RUN pecl install \
        redis-${PECL_REDIS_VERSION} \
    && docker-php-ext-enable \
        redis \
    && ([ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g github-oauth.github.com "${X_COMPOSER_GITHUB_OAUTH}") \
    && composer config repositories."${TPS_CUSTOMIZATIONS_REPO}" vcs "https://github.com/${TPS_CUSTOMIZATIONS_REPO}" \
    && composer require --update-no-dev \
        "ext-redis:*" \
        "tulsaschoolsdata/snipe-it-customizations:${TPS_CUSTOMIZATIONS_REF}" \
    && ([ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g --unset github-oauth.github.com) \
    && a2enmod rewrite

# php default:
# - JSON PHP Extension
# - OpenSSL PHP Extension
# - PDO PHP Extension
# - Mbstring PHP Extension
# - Tokenizer PHP Extension
# - cURL PHP Extension
# - Fileinfo PHP extension
# - PHP BCMath PHP extension
# - PHP XML PHP extension

# php extensions
# - MySQL PHP Extension <mysqli, pdo_mysql>
# - LDAP PHP extension (only if using LDAP)
# - PHPZIP PHP extension <zip>
# - GD

# tps extensions
# - Redis

