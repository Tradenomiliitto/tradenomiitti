#!/bin/bash

unset GIT_DIR

# Bail on error
set -e

cd /srv/checkout/tradenomiitti

git fetch origin
git reset --hard origin/master

npm install
cd frontend
../node_modules/.bin/elm-package install -y
cd ..
npm run compilefrontend
npm run compilescss
npm run compileassets

sudo systemctl restart tradenomiitti
