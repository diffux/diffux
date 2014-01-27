# Diffux

[![Code Climate](https://codeclimate.com/github/trotzig/diffux.png)](https://codeclimate.com/github/trotzig/diffux)

Diffux can generate visual diffs of web pages, allowing you to spot changes and
style regressions more easily.

## Installing

Diffux requires:

- PostgreSQL
- Ruby

### Mac OS X (Using Homebrew)

Below are some example installation instructions that might help you get Diffux
up and running on Mac OS X using Homebrew.

```bash
# clone repo
git clone https://github.com/trotzig/diffux.git
cd diffux

# install postgres
brew update
brew doctor
brew install postgresql

# install gems
bundle install

# start postgres
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start

# create users
createuser -s -r diffux
createuser -s -r diffux_development

# create tables, load the schema, and run migrations
bundle exec rake db:create db:schema:load db:migrate
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

## License

Released under the MIT License.

  [Rails]: http://rubyonrails.org/
