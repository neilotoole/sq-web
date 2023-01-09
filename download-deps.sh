#!/usr/bin/env bash
# Miscellaneous pre-build tasks.
set -e
#
#BASE_URL=https://github.com/asciinema/asciinema-player/releases/download
#wget $BASE_URL/v3.0.1/asciinema-player.css -P ./static/css/
#wget $BASE_URL/v3.0.1/asciinema-player.min.js -P ./static/js/

BASE_URL=https://github.com/asciinema/asciinema-player/releases/download
curl -fsSL $BASE_URL/v2.6.1/asciinema-player.css -o ./static/css/asciinema-player.css
curl -fsSL  $BASE_URL/v2.6.1/asciinema-player.js -o ./static/js/asciinema-player.js

