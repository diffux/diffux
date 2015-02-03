#!/usr/bin/env bash

# Remove since it takes up space unnecessarily
apt-get purge puppet

# Install dependencies
apt-get install -y imagemagick redis-server postgresql libpq-dev nodejs
