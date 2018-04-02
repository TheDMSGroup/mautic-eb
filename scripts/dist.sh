#!/usr/bin/env bash
# Rebuild all assets in place to test composer changes and prep for release.
# Will not update the core composer.lock file (to do so delete it first).

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

rm -rf ./mautic ./bin ./vendor ./plugins ./mautic_custom
mkdir -p ./plugins
touch ./plugins/.gitkeep

cp composer.lock.dist composer.lock
cp composer.custom.dist composer.custom

rm -rf ~/.composer/cache/files/thedmsgroup/*
composer install
git status
composer update "thedmsgroup/*"
composer assets

if cat ./mautic/media/css/app.css | grep '#00b49c' > /dev/null 2>&1
then
    echo "Warning. Default bootstrap styles detected. Theme compilation must have failed."
    echo "Trying again..."
    composer assets
	if cat ./mautic/media/css/app.css | grep '#00b49c' > /dev/null 2>&1
	then
	    echo "No luck. Abort build!"
	else
	    echo "And they look good."
	fi
    exit 1
fi

# Only needed if building for production:
# composer install --no-dev