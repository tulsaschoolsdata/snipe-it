SHELL = /bin/bash

DB_CHARSET ?= utf8mb4
DB_COLLATION ?= utf8mb4_unicode_ci
MYSQL_BIN ?= mysql --defaults-file=.my.cnf
MYSQLDUMP_BIN ?= mysqldump --defaults-file=.my.cnf

export DB_DATABASE ?= $(shell echo $${DB_DATABASE:-heroku_$${HEROKU_APP_NAME//-/_}})

S3_FILES_PUBLIC_REVIEW_APP = tps-snipe-it-files-public/$${HEROKU_APP_NAME}/
S3_FILES_PUBLIC_PRODUCTION = tps-snipe-it-files-public/production/
S3_FILES_PRIVATE_REVIEW_APP = tps-snipe-it-files-public/$${HEROKU_APP_NAME}/
S3_FILES_PRIVATE_PRODUCTION = tps-snipe-it-files-public/production/

default:
	echo "DB_DATABASE: $${DB_DATABASE}"

# The postdeploy runs only once after the app has been created
# https://devcenter.heroku.com/articles/github-integration-review-apps#the-postdeploy-script
postdeploy: .ensure-database
	@ echo "(postdeploy) HEROKU_APP_NAME: $${HEROKU_APP_NAME}"
	@ echo "(postdeploy) HEROKU_BRANCH: $${HEROKU_BRANCH}"
	@ echo "(postdeploy) HEROKU_PR_NUMBER: $${HEROKU_PR_NUMBER}"
	[ -n "$${HEROKU_APP_NAME}" ]
#	heroku labs:enable runtime-new-layer-extract
	heroku --app $${HEROKU_APP_NAME} \
		config:set DB_DATABASE="$${DB_DATABASE}" \
		config:set PRIVATE_AWS_BUCKET_ROOT="$${HEROKU_APP_NAME}/" \
		config:set PUBLIC_AWS_BUCKET_ROOT="$${HEROKU_APP_NAME}/"
	aws s3 sync $(S3_FILES_PUBLIC_PRODUCTION) $(S3_FILES_PUBLIC_REVIEW_APP)
	aws s3 sync $(S3_FILES_PRIVATE_PRODUCTION) $(S3_FILES_PRIVATE_REVIEW_APP)
	$(MYSQLDUMP_BIN) heroku_example | $(MYSQL_BIN) "$${DB_DATABASE}"
	php artisan migrate
	componser install && php artisan db:seed

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
release: .ensure-database
	php artisan migrate

# The web process type
# https://devcenter.heroku.com/articles/procfile#the-web-process-type
web:
	.tps/heroku/run-apache2.sh

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
