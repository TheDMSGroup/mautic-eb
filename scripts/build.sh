#!/usr/bin/env bash
# Standard composer install for mautic-eb.

set -e

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

# echo ; echo "Pulling mautic-eb"
# git pull

# echo ; echo "Cleaning up the build space."
# rm -rf ./mautic ./bin ./vendor ./plugins
mkdir -p ./plugins
touch ./plugins/.gitkeep

echo ; echo "Standard build."
composer install --no-interaction

echo ; echo "Here's a diff of what this build changes."
git --no-pager diff --minimal

# The following may be needed if building for production (can be ran upon deployment to drop dev dependencies).
# composer install --no-dev --no-interaction