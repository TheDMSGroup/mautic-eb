#!/usr/bin/env bash
# Example of how to apply PRs as patches.
# Only needed if using build-dev.sh!
#
# To test:
#   cd ./mautic
#   git clean -fd ; git reset --hard origin ; bash ../scripts/core-patches.sh

set -e

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo "----------------------------------------------------"
echo "Applying selected patches to Mautic core."
cd ./mautic

## MUST BE REFACTORED.
#echo "----------------------------------------------------"
#echo "[Enhancement] Support includes/excludes with text fields for bulk filtering. #5925"
#echo "https://github.com/mautic/mautic/pull/5925"
#curl -L "https://github.com/mautic/mautic/pull/5925.diff" | git apply -v
#git add . ; git commit -nm "PATCH https://github.com/mautic/mautic/pull/5925"

# Ready for tagging.
echo "----------------------------------------------------"
echo "Campaign summary statistics (performance boost and date range specificity) #6651"
echo "https://github.com/mautic/mautic/pull/6651"
git apply -v "../scripts/patches/6651.diff"
git add . ; git commit --author="6651 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/6651"

# Should go into 2.15.0 but is not merged yet.
echo "----------------------------------------------------"
echo "Create a Soft delete process for campaign events #6247"
echo "https://github.com/mautic/mautic/pull/6247"
# Removed campaign_schema.sql
git apply -v "../scripts/patches/6247.diff"
git add . ; git commit --author="6247 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/6247"

# Ready for tagging.
echo "----------------------------------------------------"
echo "Applies patches for Campaign Tagging"
echo "https://github.com/mautic/mautic/pull/6152"
git apply -v "../scripts/patches/6792.diff"
git add . ; git commit --author="6792 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/6792"

# Temporary state abbreviation patch
echo "----------------------------------------------------"
echo "Converts United States proper names to abbreviations"
git apply -v "../scripts/patches/us_state_abbrev_acceptance.diff"
git add . ; git commit --author="us_state_abbrev_acceptance <info@thedmsgrp.com>" -nm "us_state_abbrev_acceptance.diff"

# Refactor queries for getting event counts on campaign trigger for performance ENG-620]
echo "----------------------------------------------------"
echo "Refactor queries for getting event counts on campaign trigger for performance [ENG-620]"
echo "https://github.com/mautic/mautic/pull/6787"
git apply -v "../scripts/patches/6787.diff"
git add . ; git commit --author="6787 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/6787"

echo "----------------------------------------------------"
echo "Add a \"Created By\" column to the Imports list. #6929"
echo "https://github.com/mautic/mautic/pull/6929"
git apply -v "../scripts/patches/6929.diff"
git add . ; git commit --author="6929 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/6929"

# Import Enhancements
echo "----------------------------------------------------"
echo "Import configuration enhancements #6962"
echo "https://github.com/mautic/mautic/pull/6962"
git apply -v "../scripts/patches/6962.diff"
git add . ; git commit --author="6962 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/6962"

# Pass LeadEventLog into event config so it persists to all pushLead integrations
echo "----------------------------------------------------"
echo "Pass LeadEventLog into event config so it persists to all pushLead integrations #7131"
echo "https://github.com/mautic/mautic/pull/7131"
git apply -v "../scripts/patches/7131.diff"
git add . ; git commit --author="7131 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/7131"

# Will be in 2.15.1
echo "----------------------------------------------------"
echo "Fix error: Got a packet bigger than 'max_allowed_packet' bytes #6973"
echo "https://github.com/mautic/mautic/pull/6973"
git apply -v "../scripts/patches/6973.diff"
git add . ; git commit --author="6973 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/6973"

# Not essential
echo "----------------------------------------------------"
echo "If present, give NewRelic transactional awareness for console commands. #7145"
echo "https://github.com/mautic/mautic/pull/7145"
git apply -v "../scripts/patches/7145.diff"
git add . ; git commit --author="7145 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/7145"

# Slave Connection for Reports
echo "----------------------------------------------------"
echo "Set connection to Slave for report generator and report graph if available. #7201"
echo "https://github.com/mautic/mautic/pull/7201"
git apply -v "../scripts/patches/7201.diff"
git add . ; git commit --author="7201 <info@thedmsgrp.com>" -nm "https://github.com/mautic/mautic/pull/7201"
