#!/bin/bash

# Attribution: based on deploy.sh by Nat Tuck

export PORT=8000
DIR=$1

if [ ! -d "$DIR"]; then
    printf "Usage: ./deploy.sh <path>\n"
    exit
fi

echo "Deploy to [$DIR]"

mix deps.get
(cd assets && npm install)
(cd assets && ./node_modules/brunch/bin/brunch b - p)
mix phx.digest
MIX_ENV=prod mix release --env=prod

scp _build/prod/rel/micro/releases/0.0.1/micro.tar.gz micro@antares:~/ &&
ssh micro@antares

# pick up on VPS using vps_deploy.sh

