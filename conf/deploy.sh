#!/bin/bash

unset GIT_DIR

# Bail on error
set -e

cd /srv/checkout/tradenomiitti

git fetch origin
git reset --hard origin/master

npm install
npm run compilefrontend
npm run compilescss
npm run compileassets

sudo systemctl restart tradenomiitti
