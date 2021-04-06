FROM snipe/snipe-it:v4.9.5

ARG TPS_CUSTOMIZATIONS_REPO='tulsaschoolsdata/snipe-it-customizations'
ARG TPS_CUSTOMIZATIONS_REF='v1.0.0'
ARG X_COMPOSER_GITHUB_OAUTH

# Copy any directories that contain customizations
COPY --chown=docker:root app /var/www/html/app
COPY --chown=docker:root config /var/www/html/config
COPY --chown=docker:root resources /var/www/html/resources

USER docker
RUN \
    ([ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g github-oauth.github.com ${X_COMPOSER_GITHUB_OAUTH}) && \
    composer config repositories."${TPS_CUSTOMIZATIONS_REPO}" vcs "https://github.com/${TPS_CUSTOMIZATIONS_REPO}" && \
    composer require --update-no-dev tulsaschoolsdata/snipe-it-customizations:${TPS_CUSTOMIZATIONS_REF} && \
    ([ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g --unset github-oauth.github.com)
USER root

COPY --chown=docker:root version.tps.txt /var/www/html/version.tps.txt
