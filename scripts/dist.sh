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
composer install --no-interaction
git status
cd ./mautic_custom ; git pull ; cd -
composer update "thedmsgroup/*" --no-interaction

echo "Applying patches"
cd ./mautic
echo "[Bug] Plugin content locking (referrer POST) causes 500. #5789"
curl -L "https://github.com/mautic/mautic/pull/5789.diff" | git apply -v

echo "[Enhancement] Allow filtering contacts by UTM data within campaigns. #5869"
curl -L "https://github.com/mautic/mautic/pull/5869.diff" | git apply -v

echo "[Bug] SQL error if no field is chosen for \"Form field value\" conditional. #5875"
curl -L "https://github.com/mautic/mautic/pull/5875.diff" | git apply -v

echo "[Enhancement] Allow filtering contacts by UTM data for segments. #5886"
curl -L "https://github.com/mautic/mautic/pull/5886.diff" | git apply -v

#echo "[Enhancement] Allow filtering contacts by Campaign Membership for segments. #5911"
#curl -L "https://github.com/mautic/mautic/pull/5911.diff" | git apply -v

echo "[Enhancement] Support includes/excludes with text fields for bulk filtering. #5925"
curl -L "https://gist.githubusercontent.com/heathdutton/6542c12e1f55c0c3d3cbe6fe51706728/raw/164cec9fde0bd56845b40285ae4579b28cd476a7/5925.diff" | git apply -v

echo "[Bug] Symfony Master/Slave support is broken #5969"
curl -L "https://github.com/mautic/mautic/pull/5970.diff" | git apply -v

echo "Rejected patches:"
find . -name \*.rej
cd -

composer assets --no-interaction
echo "Checking assets..."
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
else
    echo "And they look good."
fi

# Only needed if building for production:
# composer install --no-dev --no-interaction