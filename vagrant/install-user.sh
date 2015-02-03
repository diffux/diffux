#!/usr/bin/env bash

gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -L https://get.rvm.io | bash -s stable

source $HOME/.rvm/scripts/rvm

rvm use --install 2.2 --default

cd /vagrant

gem install bundler
bundle install

# set up the DB
cp config/database.yml.example config/database.yml
bundle exec rake db:setup

foreman start
