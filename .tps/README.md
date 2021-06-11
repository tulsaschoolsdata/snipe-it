# Snipe-IT for Tulsa Public Schools

This directory contains code relevant to Snipe-IT for TPS.

## Heroku

These files are specific to deploying Snipe-IT for TPS.

- [.tps/heroku/Makefile] targets for Heroku processes ([Review Apps], [Procfile])
  - `postdeploy`: Runs once when a review app is first deployed
  - `pr-destroy`: Runs once when a review app is destroyed
  - `release`: Runs during the release phase
  - `web`: Run by web dynos
- [.tps/heroku/run-apache2.sh] is a wrapper script for configuring the Apache port number with the one provided by Heroku
- [app.json] is a manifest for describing the app ([app.json Schema])
- [heroku.yaml] is a manifest for building Docker images and specifying add-ons. ([Building Docker Images with heroku.yml])

[.tps/heroku/Makefile]: heroku/Makefile
[Review Apps]: https://devcenter.heroku.com/articles/github-integration-review-apps
[Procfile]: https://devcenter.heroku.com/articles/procfile#procfile-format
[.tps/heroku/run-apache2.sh]: heroku/run-apache2.sh
[app.json]: ../app.json
[app.json Schema]: https://devcenter.heroku.com/articles/app-json-schema
[heroku.yaml]: ../heroku.yaml
[Building Docker Images with heroku.yml]: https://devcenter.heroku.com/articles/build-docker-images-heroku-yml
