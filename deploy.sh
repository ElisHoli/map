#!/usr/bin/env sh

set -e

npm run build

#cp stops.json dist/stops.json

cd dist

git init
git add -A
git commit -m 'New Deployment'

REMOTE_URL=$GIT_REMOTE_URL
DEFAULT_BRANCH=$GIT_DEFAULT_BRANCH

git push -f $REMOTE_URL $DEFAULT_BRANCH:gh-pages

cd -
