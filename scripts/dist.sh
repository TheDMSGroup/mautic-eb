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

rm -rf ~/.composer/cache/files/thedmsgroup/*
# composer clear-cache
composer install
git status
composer assets

if cat ./mautic/media/css/app.css | grep '#00b49c' > /dev/null 2>&1
then
    echo "Warning. Default bootstrap styles detected. Theme compilation must have failed."
    echo "Trying again..."
    composer assets
	if cat ./mautic/media/css/app.css | grep '#00b49c' > /dev/null 2>&1
	then
	    echo "No luck. Abort build!"
	fi
    exit 1
fi

# Only needed if building for production:
# composer install --no-dev