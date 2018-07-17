#!/usr/bin/env bash
# Script for setting up a local environment for development:
# Custom installation example for mautic-eb
# Includes custom sha, theme and plugins.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo ; echo "Pulling mautic-eb"
git pull

echo ; echo "Cleaning up the build space."
rm -rf ./mautic

echo ; echo "Setting composer.lock and composer.custom files from the dist coppies."
cp composer.lock.dist composer.lock
cp composer.custom.dist composer.custom

echo ; echo "Custom install."
composer install --no-interaction

bash ./scripts/core-patches.sh

if [ ! -f "./mautic/app/config/local.php" ]
then
    echo ; echo "Creating initial local.php"
    cp ./mautic_eb/app/config/parameters_local.php ./mautic/app/config/local.php
fi

echo ; echo "Re-cloning all custom plugins"
if [ ! -d "./plugins/MauticContactClientBundle/.git" ]
then
    rm -rf ./plugins/MauticContactClientBundle
    git clone -b master https://github.com/TheDMSGroup/mautic-contact-client.git ./plugins/MauticContactClientBundle
else
    cd ./plugins/MauticContactClientBundle
    git checkout master
    git pull
    cd -
fi

if [ ! -d "./plugins/MauticContactSourceBundle/.git" ]
then
    rm -rf ./plugins/MauticContactSourceBundle
    git clone -b master https://github.com/TheDMSGroup/mautic-contact-source.git ./plugins/MauticContactSourceBundle
else
    cd ./plugins/MauticContactSourceBundle
    git checkout master
    git pull
    cd -
fi

if [ ! -d "./plugins/MauticEnhancerBundle/.git" ]
then
    rm -rf ./plugins/MauticEnhancerBundle
    git clone -b master https://github.com/TheDMSGroup/mautic-enhancer.git ./plugins/MauticEnhancerBundle
else
    cd ./plugins/MauticEnhancerBundle
    git checkout master
    git pull
    cd -
fi

if [ ! -d "./plugins/MauticExtendedFieldBundle/.git" ]
then
    rm -rf ./plugins/MauticExtendedFieldBundle
    git clone -b master https://github.com/TheDMSGroup/mautic-extended-field.git ./plugins/MauticExtendedFieldBundle
else
    cd ./plugins/MauticExtendedFieldBundle
    git checkout master
    git pull
    cd -
fi

if [ ! -d "./plugins/MauticContactLedgerBundle/.git" ]
then
    rm -rf ./plugins/MauticContactLedgerBundle
    git clone -b master https://github.com/TheDMSGroup/mautic-contact-ledger.git ./plugins/MauticContactLedgerBundle
else
    cd ./plugins/MauticContactLedgerBundle
    git checkout master
    git pull
    cd -
fi

if [ ! -d "./plugins/MauticUsstateNormalizerBundle/.git" ]
then
    rm -rf ./plugins/MauticUsstateNormalizerBundle
    git clone -b master https://github.com/TheDMSGroup/mautic-usstate-normalizer.git ./plugins/MauticUsstateNormalizerBundle
else
    cd ./plugins/MauticUsstateNormalizerBundle
    git checkout master
    git pull
    cd -
fi

if [ ! -d "./plugins/MauticHealthBundle/.git" ]
then
    rm -rf ./plugins/MauticHealthBundle
    git clone -b master https://github.com/TheDMSGroup/mautic-health.git ./plugins/MauticHealthBundle
else
    cd ./plugins/MauticHealthBundle
    git checkout master
    git pull
    cd -
fi

if [ ! -d "./mautic_custom/.git" ]
then
    rm -rf ./mautic_custom
    git clone -b master https://github.com/TheDMSGroup/mautic-eb-custom.git ./mautic_custom
else
    cd ./mautic_custom
    git checkout master
    git pull
    cd -
fi

echo ; echo "Compiling Mautic JS/CSS assets."
composer custom
composer assets --no-interaction

# Do not conflict with the standard distribution, we want the composer.lock to exclude customization examples.
cp composer.lock composer.lock.dist
git checkout composer.lock
rm -f composer.custom