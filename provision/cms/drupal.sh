#!/bin/bash

# find the composer json
dir=$(dirname $(find /var/www -name 'composer.json' | tail -1))

echo '====='
cd "$dir"
pwd
echo '====='


if [ -f "./composer.json" ]; then
  composer diagnose
  composer self-update
  echo "Composer install - This might take a while..."
  composer install -vvv
  composer drupal:scaffold
  echo "Installing Drush..."
  composer global require drush/drush -vvv
  if [ -f vendor/bin/drush ]; then
    vendor/bin/drush init -y
  else
    echo "Drush not installed."
  fi

  # move drush aliases?
fi
