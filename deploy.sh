#!/bin/sh
# get code
mkdir apps && cd apps/
git clone -b monolith https://github.com/express42/reddit.git
# install app
cd reddit && bundle install
# run app
puma -d
