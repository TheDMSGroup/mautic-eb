#!/usr/bin/env bash
# Rebuild all assets in place to test composer changes and prep for release.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

rm -rf ./mautic ./bin ./vendor ./composer.lock ./plugins ./mautic_custom
mkdir -p ./plugins
touch ./plugins/.gitkeep
mkdir -p ./mautic_custom
touch ./mautic_custom/.gitkeep

cp composer.custom.dist composer.custom

composer clear-cache
composer install
composer assets

if grep -Fxq '#00b49c' ./mautic/media/css/app.css
then
    echo "Warning. Default bootstrap styles detected. Theme compilation must have failed."
    return 1
fi

# Only needed if building for production:
# composer install --no-dev