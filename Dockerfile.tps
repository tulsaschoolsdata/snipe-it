FROM ghcr.io/tulsaschoolsdata/docker-snipe-it-base:latest

ARG TPS_CUSTOMIZATIONS_REPO='tulsaschoolsdata/snipe-it-customizations'
ARG TPS_CUSTOMIZATIONS_REF='5.x-dev'
ARG X_COMPOSER_GITHUB_OAUTH=''

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/snipe-it
COPY --chown=www-data:www-data . /var/www/snipe-it

RUN set -eux \
# Update Apache config files for document root
  && sed -ri -e "s!/var/www/html!/var/www/snipe-it/public!g" /etc/apache2/sites-available/*.conf \
# Set Composer authentication for GitHub if provided
  && ([ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g github-oauth.github.com "${X_COMPOSER_GITHUB_OAUTH}") \
# Install Composer dependencies
  && composer install --no-cache --no-dev --optimize-autoloader \
# Configure the customizations repo
  && composer config repositories."${TPS_CUSTOMIZATIONS_REPO}" vcs "https://github.com/${TPS_CUSTOMIZATIONS_REPO}" \
# Require customizations
  && composer require --update-no-dev "tulsaschoolsdata/snipe-it-customizations:${TPS_CUSTOMIZATIONS_REF}" \
# Unset Composer authentication for GitHub if provided
  && ([ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g --unset github-oauth.github.com)
