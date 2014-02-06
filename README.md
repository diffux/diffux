# Diffux

[![Build Status](https://travis-ci.org/trotzig/diffux.png)](https://travis-ci.org/trotzig/diffux)
[![Code Climate](https://codeclimate.com/github/trotzig/diffux.png)](https://codeclimate.com/github/trotzig/diffux)
[![Coverage Status](https://coveralls.io/repos/trotzig/diffux/badge.png)](https://coveralls.io/r/trotzig/diffux)

Are you worried that your CSS changes will break the current design in
unexpected ways? Do you want to show a designer a page you've been working on,
before and after your changes? Do you want to be able to quickly look back at
how things looked a month or a year ago?

Diffux is a tool that generates and manages visual diffs of web pages, so that
you can easily see even the subtlest effects of your code modifications.

## Installing

Diffux requires:

- ImageMagick
- PostgreSQL
- Redis
- Ruby 2.0.0+

### Mac OS X (Using Homebrew)

Below are some example installation instructions that might help you get Diffux
up and running on Mac OS X using Homebrew.

```bash
# clone repo
git clone https://github.com/trotzig/diffux.git
cd diffux

# install dependencies
brew update
brew doctor
brew install imagemagick postgresql redis

# install gems
bundle install

# start postgres
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start

# start redis
redis-server

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

## License

Released under the MIT License.

[Rails]: http://rubyonrails.org/
[Sidekiq]: http://sidekiq.org/
