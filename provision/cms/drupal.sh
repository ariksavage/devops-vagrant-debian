#!/bin/bash

# find the composer json
dir=$(dirname $(find /var/www -name 'composer.json' | tail -1))

cd "$dir"
pwd

if [ -f "./composer.json" ]; then
  composer diagnose
  composer self-update
  echo "Composer install - This might take a while..."
  composer install -vvv
fi