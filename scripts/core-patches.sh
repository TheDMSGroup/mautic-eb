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

# Should go into 2.15.0 but is not merged yet.
echo "----------------------------------------------------"
echo "[Enhancement] Allow filtering contacts by Campaign Membership for segments. #5911"
echo "https://github.com/mautic/mautic/pull/5911"
cat "../scripts/patches/5911.diff" | git apply -v

# Needs refactoring before acceptance.
echo "----------------------------------------------------"
echo "[Enhancement] Support includes/excludes with text fields for bulk filtering. #5925"
echo "https://github.com/mautic/mautic/pull/5925"
curl -L "https://github.com/mautic/mautic/pull/5925.diff" | git apply -v

# Conflicts resolved. Ready for tagging. But needs fix for dashboard widgets.
echo "----------------------------------------------------"
echo "Config option for default date range on DateRangeFilter. #6091"
echo "https://github.com/mautic/mautic/pull/6091"
curl -L "https://github.com/mautic/mautic/pull/6091.diff" | git apply -v

# Ready for tagging. Needs developer documentation before merging.
echo "----------------------------------------------------"
echo "API call to clone an existing campaign. #6125"
echo "https://github.com/mautic/mautic/pull/6125"
curl -L "https://github.com/mautic/mautic/pull/6125.diff" | git apply -v

# Should go into 2.15.0 but is not merged yet.
echo "----------------------------------------------------"
echo "[Feature] Chained actions #6187"
echo "https://github.com/mautic/mautic/pull/6187"
# Removed app.js from diff.
cat "../scripts/patches/6187.diff" | git apply -v

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
#echo "https://github.com/mautic/mautic/pull/6152"
# Removed app.js and added mautic.campaign.model.summary
#cat "../scripts/patches/6152.diff" | git apply -v
echo "https://github.com/mautic/mautic/pull/6792"
cat "../scripts/patches/6792.diff" | git apply -v

# Temporary state abbreviation patch
echo "----------------------------------------------------"
echo "Converts United States proper names to abbreviations"
cat "../scripts/patches/us_state_abbrev_acceptance.diff" | git apply -v

# Should go into 2.15.0 but is not merged yet.
echo "----------------------------------------------------"
echo "Add Campaign Event object to event config array for pushLead processing accuracy"
echo "https://github.com/mautic/mautic/pull/6638"
curl -L "https://github.com/mautic/mautic/pull/6638.diff" | git apply -v

# Should go into 2.14.2 but is not merged yet.
echo "----------------------------------------------------"
echo "[Bug] Symfony Master/Slave support is broken #5970"
echo "https://github.com/mautic/mautic/pull/5970"
cat "../scripts/patches/5970.diff" | git apply -v

# Recreates campaign limit in mautic:campaigns:trigger as --camapign-limit
echo "----------------------------------------------------"
echo "[Feature] mautic:campaigns:trigger --camapign-limit=XXX"
echo "https://github.com/mautic/mautic/pull/6753"
cat "../scripts/patches/6753.diff" | git apply -v

# Refactor queries for getting event counts on campaign trigger for performance ENG-620]
echo "----------------------------------------------------"
echo "Refactor queries for getting event counts on campaign trigger for performance [ENG-620]"
echo "https://github.com/mautic/mautic/pull/6787"
cat "../scripts/patches/6787.diff" | git apply -v

# Set cache on Dashboard Widgets [ENG-624]
echo "----------------------------------------------------"
echo "Set cache on Dashboard Widgets [ENG-624]"
echo "https://github.com/mautic/mautic/pull/6798"
cat "../scripts/patches/6798.diff" | git apply -v

# Prefer a slave connection for segment counts [ENG-647] #6889
echo "----------------------------------------------------"
echo "Prefer a slave connection for segment counts [ENG-647] #6889"
echo "https://github.com/mautic/mautic/pull/6889"
cat "../scripts/patches/6889.diff" | git apply -v

echo "----------------------------------------------------"
echo "Add a \"Created By\" column to the Imports list. #6929"
echo "https://github.com/mautic/mautic/pull/6929"
cat "../scripts/patches/6929.diff" | git apply -v
