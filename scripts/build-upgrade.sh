#!/usr/bin/env bash
# For upgrading this mautic-eb package to a newer version of Mautic only. NOT for use in any environments.

set -e

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo ; echo "Cleaning up the build space."
rm -rf ./mautic ./bin ./vendor ./plugins ./mautic_custom ./composer.lock ./composer.lock.dev
mkdir -p ./plugins ./mautic_custom
touch ./plugins/.gitkeep
touch ./mautic_custom/.gitkeep

read -p 'Insert the SHA you wish to upgrade mautic to in the mautic-eb repo: ' SHA
echo "Setting new sha to $SHA"
composer require mautic/core:dev-master#$SHA

echo "Updating dev/custom to $SHA"
cp composer.custom.dev composer.custom
composer update --lock
cp composer.lock composer.lock.dev

echo "Updating core to $SHA"
rm -rf composer.lock composer.custom
composer update --lock

echo ; echo "Here's a diff of what this upgrade changes."
git --no-pager diff --minimal
