#!/usr/bin/env bash

# Optionally pull in a composer.custom file from a remote location for additional local customizations.
#
# The idea here is that customizations that are brand-specific do not go into the mautic-eb repository.

if [ -z "$COMPOSER_CUSTOM" ]
then
    echo "No remote composer.custom defined in environment variables."
    exit 0
fi

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

curl "$COMPOSER_CUSTOM" -o "$BASEDIR/composer.custom" -s