FROM ghcr.io/tulsaschoolsdata/docker-snipe-it-base:latest

ARG TPS_CUSTOMIZATIONS_REPO='tulsaschoolsdata/snipe-it-customizations'
ARG TPS_CUSTOMIZATIONS_REF='5.x-dev'
ARG X_COMPOSER_GITHUB_OAUTH=''

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/snipe-it
COPY --chown=www-data:www-data . /var/www/snipe-it

RUN curl https://cli-assets.heroku.com/install.sh | sh

RUN TPS_CUSTOMIZATIONS_REPO=${TPS_CUSTOMIZATIONS_REPO} \
    TPS_CUSTOMIZATIONS_REF=${TPS_CUSTOMIZATIONS_REF} \
    X_COMPOSER_GITHUB_OAUTH=${X_COMPOSER_GITHUB_OAUTH} \
    .tps/docker-run.sh
