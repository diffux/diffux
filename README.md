# [![Diffux](https://raw.github.com/diffux/diffux/master/app/assets/images/diffux.png)](https://github.com/diffux/diffux/tree/master/app/assets/images)


[![Build Status](https://travis-ci.org/diffux/diffux.png)](https://travis-ci.org/diffux/diffux)
[![Code Climate](https://codeclimate.com/github/diffux/diffux.png)](https://codeclimate.com/github/diffux/diffux)
[![Coverage Status](https://coveralls.io/repos/diffux/diffux/badge.png?branch=master)](https://coveralls.io/r/diffux/diffux)
[![Dependency Status](https://gemnasium.com/diffux/diffux.svg)](https://gemnasium.com/diffux/diffux)


Are you worried that your CSS changes will break the current design in
unexpected ways? Do you want to show a designer a page you've been working on,
before and after your changes? Do you want to be able to quickly look back at
how things looked a month or a year ago?

Diffux [dɪˈfjuːz] is a tool that generates and manages visual diffs of web
pages, so that you can easily see even the subtlest effects of your code
modifications.

[Documentation]

## Installing

Diffux requires:

- Redis
- Ruby 2.0.0+
- ImageMagick (only as part of generating thumbnails, not for creating the
  diffs)

Optional requirements:

- PostgreSQL (SQLite is used by default)

### Mac OS X (Using Homebrew)

Below are some example installation instructions that might help you get Diffux
up and running on Mac OS X using Homebrew.

```bash
# clone repo
git clone https://github.com/diffux/diffux.git
cd diffux

# install dependencies
brew update
brew doctor
brew install imagemagick redis

# optionally install and start PostgreSQL (you can leave this step out if you
# are ok with using SQLite)
brew install postgresql
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start

# install gems
bundle install

# start redis
redis-server
```

## Initialize database configuration

Before you start the server for the first time, you need to tell Diffux about
your database setup. This is done by copying `config/database.yml.example` to
`config/database.yml` and editing to fit your environment.

```bash
cp config/database.yml.example config/database.yml
```

When you are done with that, it's time to setup the database schema.

```bash
# create tables, load the schema, and run migrations
bundle exec rake db:setup
```

## Running the server

Diffux is a [Rails] app, so if you are familiar with that web framework the
following should be fairly straightforward.

```bash
bundle exec rails s
```

[Rails] runs on port 3000 by default, so you should be able to fire up your
browser with the following URL:

```
http://localhost:3000
```

## Running a worker

Snapshot creation and comparing is handled asynchronously, through [Sidekiq]
workers. To start a worker, run:

```bash
bundle exec sidekiq
```

## Running Diffux on Heroku

Diffux can run on Heroku.

Diffux stores snapshots in Amazon Web Services (AWS) S3, so you will need to
configure diffux with a Secret Key and a Access Key Id from Amazon. The best
way to do this is to create IAM user for diffux and assign it to a group with
the policy template "Amazon S3 Full Access". (This will help prevent large AWS
bills in case your diffux credentials are compromised.)

Once you have your AWS credentials, you're all set!

Follow these steps:

```bash
# clone repo
git clone https://github.com/diffux/diffux.git
cd diffux

# create and configure the heroku application
heroku create [your-diffux-app-name]
heroku addons:add heroku-postgresql
heroku addons:add rediscloud
heroku config:set PHANTOMJS_PATH=/app/vendor/phantomjs/bin/phantomjs \
  BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git \
  AWS_SECRET_KEY=[secret-key] \
  AWS_ACCESS_KEY=[access-key]

# deploy!
git push heroku master

# initialize the database
heroku run rake db:migrate

# add a worker thread to take snapshots and generate compared images:
# This will cost you money if you leave it running!
heroku ps:scale worker=1

# done! you should now be able to access your application at
# http://[your-diffux-app-name].herokuapp.com
```

## Triggering sweeps

A sweep is a full set of snapshots taken for a project. You can trigger sweeps
from a project in the web UI or through making a simple API call to
`/projects/{project_id}/sweeps/trigger`. The API endpoint sends back a JSON
object containing a `url` to a page showing the results of the newly created
sweep. Remember: snapshotting is done asynchronously, so don't expect immediate
results.

```bash
# Example of triggering a sweep using curl for a project with id=1
curl --header "Accept: application/json" \
     --header "Content-Type: application/json" \
     --data '{
               "title": "Deploy 1",
               "description": "Release Notes: Fixed layout bug",
               "delay_seconds": 20,
               "email": "foo@bar.com"
             }' \
     http://my-diffux-domain/projects/1/sweeps/trigger
```

More about the JSON data:

key             | required | description
--------------- | -------- | -----------
`title`         | Yes      | A name/short description of the sweep, e.g. the name of the release/deploy.
`description`   | No       | A longer description, e.g. the full release notes.
`delay_seconds` | No       | Number of seconds to delay the sweep with. This could be useful if you have an async release process.
`email`         | No       | An email address to send a message to when the sweep is ready (all snapshots taken and compared).

## License

Released under the MIT License.

[Documentation]: http://rubydoc.info/github/diffux/diffux
[Rails]: http://rubyonrails.org/
[Sidekiq]: http://sidekiq.org/
