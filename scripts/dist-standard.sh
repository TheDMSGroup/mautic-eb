#!/usr/bin/env bash
# Standard composer install.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo ; echo "Pulling mautic-eb"
git pull

echo ; echo "Cleaning up the build space."
rm -rf ./mautic ./bin ./vendor ./plugins ./mautic_custom
mkdir -p ./plugins
touch ./plugins/.gitkeep

echo ; echo "Standard install."
composer install --no-interaction

echo ; echo "Here's a diff of what this build changes."
git --no-pager diff --minimal

# Only needed if building for production:
# composer install --no-dev --no-interaction