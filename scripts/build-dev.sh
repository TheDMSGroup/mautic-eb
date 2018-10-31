#!/usr/bin/env bash
# Custom installation example for mautic-eb
# Includes custom sha, theme and plugins.

set -e

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

if [ "upgrade" != "$1" ]
then
    echo ; echo "Pulling mautic-eb"
    git pull
fi

echo ; echo "Cleaning up the build space."
rm -rf ./mautic ./bin ./vendor ./plugins ./mautic_custom
mkdir -p ./plugins
touch ./plugins/.gitkeep

echo ; echo "Setting composer.lock and composer.custom files from the dist copies."
if [ "upgrade" = "$1" ]
then
    cp composer.lock composer.lock.dev
else
    cp composer.lock.dev composer.lock
fi
cp composer.custom.dev composer.custom

echo ; echo "Custom build."
composer install --no-interaction

bash ./scripts/core-patches.sh

echo ; echo "Forcing updates to distribution plugins"
rm -rf ./mautic_custom
git clone -b master --depth 1 https://github.com/TheDMSGroup/mautic-eb-custom.git ./mautic_custom
# rm -rf ~/.composer/cache/files/thedmsgroup/*
composer update "thedmsgroup/*" --no-interaction

echo ; echo "Compiling Mautic JS/CSS assets."
composer assets --no-interaction

echo ; echo "Checking assets."
if cat ./mautic/media/css/app.css | grep '#00b49c' > /dev/null 2>&1
then
    echo "Warning. Default bootstrap styles detected. Theme compilation must have failed."
    echo "Trying again..."
    composer assets
	if cat ./mautic/media/css/app.css | grep '#00b49c' > /dev/null 2>&1
	then
	    echo "No luck. Abort build!"
        exit 1
	else
	    echo "And they look good (on second try)."
	fi
else
    echo "And they look good."
fi

# Do not conflict with the standard distribution, we want the composer.lock to exclude customization examples.
cp composer.lock composer.lock.dev
git checkout composer.lock
rm -f composer.custom

echo ; echo "Here's a diff of what this build changes."
git --no-pager diff --minimal

# The following may be needed if building for production (can be ran upon deployment to drop dev dependencies).
# composer install --no-dev --no-interaction