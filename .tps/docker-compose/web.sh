#!/usr/bin/env bash

set -e

until [ -f /docker-compose/steps/release.txt ]
do
  sleep 1
done

make -f .tps/heroku/Makefile web
