SHELL = /bin/bash

DB_CHARSET ?= utf8mb4
DB_COLLATION ?= utf8mb4_unicode_ci
MYSQL_BIN ?= mysql --defaults-file=.my.cnf
MYSQLDUMP_BIN ?= mysqldump --defaults-file=.my.cnf

export HEROKU_API_KEY ?= $(shell echo $${X_HEROKU_API_KEY})
export HEROKU_ORGANIZATION ?= $(shell echo $${X_HEROKU_ORGANIZATION:-tulsaschools})

REDIS_PASSWORDHOST = $(shell echo $(REDISCLOUD_URL) | cut -d':' -f3)
export REDIS_HOST = $(shell echo $(REDIS_PASSWORDHOST) | cut -d'@' -f2)
export REDIS_PASSWORD = $(shell echo $(REDIS_PASSWORDHOST) | cut -d'@' -f1)
export REDIS_PORT = $(shell echo $(REDISCLOUD_URL) | cut -d':' -f4)

export DB_DATABASE ?= $(shell echo $${DB_DATABASE:-heroku_$${HEROKU_APP_NAME//-/_}})

S3_FILES_PUBLIC_REVIEW_APP = s3://tps-snipe-it-files-public/$${HEROKU_APP_NAME}/
S3_FILES_PUBLIC_PRODUCTION = s3://tps-snipe-it-files-public/production/
S3_FILES_PRIVATE_REVIEW_APP = s3://tps-snipe-it-files-private/$${HEROKU_APP_NAME}/
S3_FILES_PRIVATE_PRODUCTION = s3://tps-snipe-it-files-private/production/

default:
	echo "DB_DATABASE: $${DB_DATABASE}"

# The postdeploy runs only once after the app has been created
# https://devcenter.heroku.com/articles/github-integration-review-apps#the-postdeploy-script
postdeploy: .ensure-database .ensure-vendor
	@ echo "(postdeploy) HEROKU_APP_NAME: $${HEROKU_APP_NAME}"
	@ echo "(postdeploy) HEROKU_BRANCH: $${HEROKU_BRANCH}"
	@ echo "(postdeploy) HEROKU_PR_NUMBER: $${HEROKU_PR_NUMBER}"
	@ echo "(postdeploy) AWS_ACCESS_KEY_ID: $${AWS_ACCESS_KEY_ID}"
	[ -n "$${HEROKU_APP_NAME}" ]
	[ "$${HEROKU_APP_NAME}" == 'docker-compose' ] || heroku labs:enable runtime-new-layer-extract --app $${HEROKU_APP_NAME}
	[ "$${HEROKU_APP_NAME}" == 'docker-compose' ] || heroku --app $${HEROKU_APP_NAME} \
		config:set DB_DATABASE="$${DB_DATABASE}" \
		config:set PRIVATE_AWS_BUCKET_ROOT="$${HEROKU_APP_NAME}/" \
		config:set PUBLIC_AWS_BUCKET_ROOT="$${HEROKU_APP_NAME}/"
	aws s3 sync $(S3_FILES_PUBLIC_PRODUCTION) $(S3_FILES_PUBLIC_REVIEW_APP)
	aws s3 sync $(S3_FILES_PRIVATE_PRODUCTION) $(S3_FILES_PRIVATE_REVIEW_APP)
	$(MYSQLDUMP_BIN) heroku_template | $(MYSQL_BIN) "$${DB_DATABASE}"
# Migrate the database
	php artisan migrate --force
# Seed the database if settings is empty
	[ "$$($(MYSQL_BIN) "$${DB_DATABASE}" -e 'SELECT COUNT(*) FROM settings;' -N)" != "0" ] || \
		composer install && php artisan db:seed

# The pr-predestroy runs when review apps are destroyed once the associated pull request is merged or closed.
# https://devcenter.heroku.com/articles/github-integration-review-apps#pr-predestroy-script
pr-predestroy:
	@ echo "(pr-predestroy) HEROKU_APP_NAME: $${HEROKU_APP_NAME}"
	@ echo "(pr-predestroy) HEROKU_BRANCH: $${HEROKU_BRANCH}"
	@ echo "(pr-predestroy) HEROKU_PR_NUMBER: $${HEROKU_PR_NUMBER}"
	[ -n "$${HEROKU_APP_NAME}" ]
	aws s3 rm --recursive $(S3_FILES_PUBLIC_REVIEW_APP)
	aws s3 rm --recursive $(S3_FILES_PRIVATE_REVIEW_APP)
	$(MYSQL_BIN) -e "DROP DATABASE IF EXISTS $${DB_DATABASE};"

# The release process type
# https://devcenter.heroku.com/articles/procfile#the-release-process-type
# https://devcenter.heroku.com/articles/release-phase
release: .ensure-database .ensure-vendor
	php artisan migrate --force

# The web process type
# https://devcenter.heroku.com/articles/procfile#the-web-process-type
# https://github.com/docker-library/wordpress/issues/293#issuecomment-557860238
web:
	sed -i "s/Listen 80/Listen $${PORT:-80}/g" /etc/apache2/ports.conf
	sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:$${PORT:-80}>/g" /etc/apache2/sites-available/000-default.conf
	apache2-foreground

.ensure-vendor:
	composer install --no-cache --no-dev --optimize-autoloader

# Ensure the database exists and migrations are run
.ensure-database: .my.cnf
	$(MYSQL_BIN) -e "CREATE DATABASE IF NOT EXISTS $${DB_DATABASE} CHARACTER SET $(DB_CHARSET) COLLATE $(DB_COLLATION);"

# Generate a mysql client configuration file for convenience
.my.cnf:
	@ ( \
		echo '[client]' ; \
		echo "user = $${DB_USERNAME}" ; \
		echo "password = $${DB_PASSWORD}" ; \
		echo "host = $${DB_HOST}" ; \
		[ -z "$${DB_SSL_CA_PATH}" ] || echo "ssl-ca = $${DB_SSL_CA_PATH}" ; \
	) > .my.cnf
