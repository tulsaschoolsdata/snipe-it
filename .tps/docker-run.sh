#!/usr/bin/env bash

# Exit on error
set -e

# Treat missing variables as an error
#set -u

# Output commands
set -x

# Ensure this script is run from the project root
[ -f .tps/heroku/Makefile ] || \
  (>&2 "Error: this script should be run from project root" ; exit 1)

# Symlink the Makefile at the root
ln -s .tps/heroku/Makefile Makefile

# Update Apache config files for document root
APACHE_DOCUMENT_ROOT="$(pwd)/public"
sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" \
  /etc/apache2/sites-available/*.conf
sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" \
  /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set Composer authentication for GitHub if provided
[ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || \
  composer config -g github-oauth.github.com "${X_COMPOSER_GITHUB_OAUTH}"

# Install Composer dependencies
composer install --no-cache --no-dev --optimize-autoloader

# Configure the customizations repo
composer config repositories."${TPS_CUSTOMIZATIONS_REPO}" \
  vcs "https://github.com/${TPS_CUSTOMIZATIONS_REPO}"

# Require customizations
composer require --update-no-dev \
  "tulsaschoolsdata/snipe-it-customizations:${TPS_CUSTOMIZATIONS_REF}"

# Unset Composer authentication for GitHub if provided
[ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || \
  composer config -g --unset github-oauth.github.com
