#!/bin/bash

set -e -o pipefail

cd $(git rev-parse --show-toplevel)
cd frontend

mkdir -p static/images
elm make src/Main.elm --output static/elm.js
browserify -t babelify js/main.js --outfile static/main.js

cd ..

./conf/compilescss.sh frontend/static

cd frontend

cp assets/* ../node_modules/bootstrap-sass/assets/fonts/bootstrap/* ../node_modules/font-awesome/fonts/* ../conf/assets/* static/
cp index.html static/
echo "assets copied"
