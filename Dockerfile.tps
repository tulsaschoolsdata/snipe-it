FROM snipe/snipe-it:v5.0.0

ARG X_COMPOSER_GITHUB_OAUTH
ARG TPS_CUSTOMIZATIONS_REPO='tulsaschoolsdata/snipe-it-customizations'
ARG TPS_CUSTOMIZATIONS_REF='5.x-dev'

COPY app config resources /var/www/html/

USER docker
RUN \
    [ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g github-oauth.github.com ${X_COMPOSER_GITHUB_OAUTH}; \
    composer config \
        repositories."${TPS_CUSTOMIZATIONS_REPO}" \
        vcs "https://github.com/${TPS_CUSTOMIZATIONS_REPO}"; \
    composer require \
        tulsaschoolsdata/snipe-it-customizations:${TPS_CUSTOMIZATIONS_REF}; \
    [ -z "${X_COMPOSER_GITHUB_OAUTH}" ] || composer config -g --unset github-oauth.github.com
USER root
