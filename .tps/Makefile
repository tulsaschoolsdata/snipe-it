SHELL = /bin/bash

HEROKU_ORGANIZATION ?= tulsaschools
export HEROKU_ORGANIZATION

HEROKU_APP_NAME ?= $(shell heroku apps:info | grep '===' | cut -d' ' -f2)
PASSPORT_PRIVATE_KEY_FILE ?= .tmp/oauth-private.key
PASSPORT_PUBLIC_KEY_FILE ?= .tmp/oauth-public.key

APP_URL = $(shell heroku info -s | grep web_url | cut -d= -f2)
APP_KEY = $(shell (heroku config:get APP_KEY | grep '.') || echo "base64:$$(openssl rand -base64 32)")
REDISCLOUD_URL = $(shell heroku config:get REDISCLOUD_URL)
REDIS_PASSWORDHOST = $(shell echo $(REDISCLOUD_URL) | cut -d':' -f3)
REDIS_HOST = $(shell echo $(REDIS_PASSWORDHOST) | cut -d'@' -f2)
REDIS_PASSWORD = $(shell echo $(REDIS_PASSWORDHOST) | cut -d'@' -f1)
REDIS_PORT = $(shell echo $(REDISCLOUD_URL) | cut -d':' -f4)
GRAPH_REDIRECT_URI = "$(APP_URL)login/graph/callback"


default: help


help:
	@ echo "$${HELP}"
define HELP

  Convienent make targets for Tulsa Public Schools deployments

    help                  This help message
    heroku-create         Create a new Heroku app
		heroku-config         Deploy config variables
    heroku-deploy-head    Deploy the currently committed work

endef
export HELP


# Use this target to create a new Heroku app
#
heroku-create: .heroku-install-plugin-manifest
# Abort if we already have an active heroku remote
	@ git remote get-url heroku >/dev/null ; [ "$$?" = "128" ] || (>&2 echo "heroku remote already exists" ; exit 1)
# Create the Heroku app from heroku.yml
	cd .. && heroku create --manifest
# Enable runtime-new-layer-extract from labs for running Apache in Docker?
	heroku labs:enable runtime-new-layer-extract
# Load environment variables into the app
	make heroku-config


# Use this target to deploy the currently committed work
#
heroku-deploy-head:
	git push -f heroku HEAD:main


# Deploy config variables
#
heroku-config:
	export \
		PASSPORT_PRIVATE_KEY="$${PASSPORT_PRIVATE_KEY:-$$(cat $(PASSPORT_PRIVATE_KEY_FILE))}" \
		PASSPORT_PUBLIC_KEY="$${PASSPORT_PUBLIC_KEY:-$$(cat $(PASSPORT_PUBLIC_KEY_FILE))}" \
	; \
	heroku config:set \
		APP_URL=$(APP_URL) \
		APP_KEY=$(APP_KEY) \
		REDIS_HOST=$(REDIS_HOST) \
		REDIS_PASSWORD=$(REDIS_PASSWORD) \
		REDIS_PORT=$(REDIS_PORT) \
		GRAPH_REDIRECT_URI=$(GRAPH_REDIRECT_URI) \
		$(shell (make .parse-env && make .parse-oauth-keys) | tr '\n' ' ')


# Install the Heroku manifest plugin
#
# https://devcenter.heroku.com/changelog-items/1441
#
.heroku-install-plugin-manifest:
	@ heroku plugins | grep -q '^manifest ' || ( \
		heroku update beta && \
		heroku plugins:install @heroku-cli/plugin-manifest \
	)


# Parse the .env file for environment variable arguments for `heroku config:set`
#
.parse-env:
	@ [ ! -f .env ] || sed '/^#/d ; s/"/\\"/g ; s/^\([^=]*\)=\(.*\)$$/\1="\2"/g' .env


# Output PASSPORT_*_KEY environment variable arguments for `heroku config:set`
#
.parse-oauth-keys:
	@ [ -z "$${PASSPORT_PRIVATE_KEY}" ] || echo 'PASSPORT_PRIVATE_KEY="$$PASSPORT_PRIVATE_KEY"'
	@ [ -z "$${PASSPORT_PUBLIC_KEY}" ] || echo 'PASSPORT_PUBLIC_KEY="$$PASSPORT_PUBLIC_KEY"'
