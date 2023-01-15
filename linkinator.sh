#!/usr/bin/env bash
# Use linkinator to verify links.
# For best results, we start a local web server (as a background process),
# and point linkinator at it.
#
# Note also: linkinator.config.json
set -e

# Kill the web server background process when the script exits
# https://stackoverflow.com/a/2173421
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

port=31313
base_url="http://localhost:$port"

# Build a nice fresh site (into the public dir)
npm run clean && ./node_modules/.bin/hugo/hugo --gc --minify -b $base_url

# Start a local webserver (background process)
echo "Starting server for linting at: $base_url"
npx serve -l $port public/ > /dev/null &
sleep 2 # Give server time to start
echo "Server started"

npx linkinator -r --verbosity error $base_url
