#!/bin/bash

set -e -o pipefail

tempfile=$(mktemp)
cleanup () {
  rm -f "$tempfile"
}
trap cleanup 0

node "$(dirname "$0")"/jsontoscss.js

echo "Compiling sass"
node-sass --precision 8 --include-path node_modules/bootstrap-sass/assets/stylesheets -r frontend/stylesheets/styles.scss >"$tempfile"

echo "Sass compiled"
postcss "$tempfile" --use autoprefixer -o "$1"/styles.css
echo "autoprefixer run"
