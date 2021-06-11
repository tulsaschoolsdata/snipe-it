#!/usr/bin/env bash

set -e

/docker-compose/wait-for-it.sh ${DB_HOST}:3306

[ ! -f /docker-compose/steps/postdeploy.txt ] || exit 0

make -f .tps/heroku/Makefile postdeploy

mkdir -p /docker-compose/steps/
date > /docker-compose/steps/postdeploy.txt
