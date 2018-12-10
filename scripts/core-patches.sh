#!/usr/bin/env bash
# Example of how to apply PRs as patches.
# Only needed if using dist-custom.sh!

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

# Ready for tagging.
echo "----------------------------------------------------"
echo "Campaign summary statistics (performance boost and date range specificity) #6651"
echo "https://github.com/mautic/mautic/pull/6651"
cat "../scripts/patches/6651.diff" | git apply -v

# Should go into 2.15.0 but is not merged yet.
echo "----------------------------------------------------"
echo "Create a Soft delete process for campaign events #6247"
echo "https://github.com/mautic/mautic/pull/6247"
# Removed campaign_schema.sql
cat "../scripts/patches/6247.diff" | git apply -v

# Ready for tagging.
echo "----------------------------------------------------"
echo "Applies patches for Campaign Tagging"
echo "https://github.com/mautic/mautic/pull/6152"
cat "../scripts/patches/6792.diff" | git apply -v

# Temporary state abbreviation patch
echo "----------------------------------------------------"
echo "Converts United States proper names to abbreviations"
cat "../scripts/patches/us_state_abbrev_acceptance.diff" | git apply -v

# Refactor queries for getting event counts on campaign trigger for performance ENG-620]
echo "----------------------------------------------------"
echo "Refactor queries for getting event counts on campaign trigger for performance [ENG-620]"
echo "https://github.com/mautic/mautic/pull/6787"
cat "../scripts/patches/6787.diff" | git apply -v

echo "----------------------------------------------------"
echo "Add a \"Created By\" column to the Imports list. #6929"
echo "https://github.com/mautic/mautic/pull/6929"
cat "../scripts/patches/6929.diff" | git apply -v

# Import Enhancements
echo "----------------------------------------------------"
echo "Import configuration enhancements #6962"
echo "https://github.com/mautic/mautic/pull/6962"
cat "../scripts/patches/6962.diff" | git apply -v
