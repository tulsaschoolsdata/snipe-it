#!/usr/bin/env bash

set -e

[ ! -f /docker-compose/steps/release.txt ] || exit 0

until [ -f /docker-compose/steps/postdeploy.txt ]
do
  sleep 1
done

make -f .tps/heroku/Makefile release

mkdir -p /docker-compose/steps/
date > /docker-compose/steps/release.txt
