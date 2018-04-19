#!/usr/bin/env bash
# Rebuild all assets in place to test composer changes and prep for release.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

rm -rf ./mautic_custom
git clone -b master https://github.com/TheDMSGroup/mautic-eb-custom.git ./mautic_custom

rm -rf ./plugins/MauticContactClientBundle
git clone -b master https://github.com/TheDMSGroup/mautic-contact-client.git ./plugins/MauticContactClientBundle

rm -rf ./plugins/MauticContactSourceBundle
git clone -b master https://github.com/TheDMSGroup/mautic-contact-source.git ./plugins/MauticContactSourceBundle

rm -rf ./plugins/MauticEnhancerBundle
git clone -b master https://github.com/TheDMSGroup/mautic-enhancer.git ./plugins/MauticEnhancerBundle

rm -rf ./plugins/MauticExtendedFieldBundle
git clone -b master https://github.com/TheDMSGroup/mautic-extended-field.git ./plugins/MauticExtendedFieldBundle

rm -rf ./plugins/MauticContactLedgerBundle
git clone -b master https://github.com/TheDMSGroup/mautic-contact-ledger.git ./plugins/MauticContactLedgerBundle

bash ./scripts/core-patches.sh

composer custom