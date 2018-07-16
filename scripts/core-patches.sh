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

# Ready for tagging.
echo "----------------------------------------------------"
echo "[Bug] Plugin content locking (referrer POST) causes 500. #5789"
echo "https://github.com/mautic/mautic/pull/5789"
curl -L "https://github.com/mautic/mautic/pull/5789.diff" | git apply -v

# Should go into 2.14.0 but is not merged yet.
echo "----------------------------------------------------"
echo "[Enhancement] Allow filtering contacts by Campaign Membership for segments. #5911"
echo "https://github.com/mautic/mautic/pull/5911"
curl -L "https://github.com/mautic/mautic/pull/5911.diff" | git apply -v

# Needs refactoring before acceptance.
echo "----------------------------------------------------"
echo "[Enhancement] Support includes/excludes with text fields for bulk filtering. #5925"
echo "https://github.com/mautic/mautic/pull/5925"
curl -L "https://github.com/mautic/mautic/pull/5925.diff" | git apply -v

# Conflicts resolved (again), needs testing.
echo "----------------------------------------------------"
echo "Campaign Details View tabbed content, allow filtering data by date range OR \"to date\" (current default) #6021"
echo "https://github.com/mautic/mautic/pull/6021"
curl -L "https://github.com/mautic/mautic/pull/6021.diff" | git apply -v

# Conflicts resolved. Ready for tagging.
echo "----------------------------------------------------"
echo "Config option for default date range on DateRangeFilter. #6091"
echo "https://github.com/mautic/mautic/pull/6091"
curl -L "https://github.com/mautic/mautic/pull/6091.diff" | git apply -v

# Should go into 2.14.0 but is not merged yet.
echo "----------------------------------------------------"
echo "Drastically improve performance of long-running campaign rendering. #6092"
echo "https://github.com/mautic/mautic/pull/6092"
curl -L "https://github.com/mautic/mautic/pull/6092.diff" | git apply -v

# Conflicts resolved. Ready for tagging. Needs developer documentation.
echo "----------------------------------------------------"
echo "API call to clone an existing campaign. #6125"
echo "https://github.com/mautic/mautic/pull/6125"
curl -L "https://github.com/mautic/mautic/pull/6125.diff" | git apply -v

# Ready for tagging.
echo "----------------------------------------------------"
echo "[Feature] Chained actions #6187"
echo "https://github.com/mautic/mautic/pull/6187"
curl -L "https://github.com/mautic/mautic/pull/6187.diff" | git apply -v

# Ready for tagging.
echo "----------------------------------------------------"
echo "[Bug] Contact limiter threads (2.14)"
echo "https://github.com/mautic/mautic/pull/6211"
curl -L "https://github.com/mautic/mautic/pull/6211.diff" | git apply -v

# chart time unit fix for single day or 3 or less day granularity
echo "----------------------------------------------------"
echo "Chart time unit fix for single day or 3 or less day granularity #6222"
echo "https://github.com/mautic/mautic/pull/6222"
curl -L "https://github.com/mautic/mautic/pull/6222.diff" | git apply -v

# Ready for tagging.
echo "----------------------------------------------------"
echo "Support --quiet for faster mautic:campaigns:trigger processing #6224"
echo "https://github.com/mautic/mautic/pull/6224"
curl -L "https://github.com/mautic/mautic/pull/6224.diff" | git apply -v

# Ready for tagging. Avoids conflicts with #6021.
echo "----------------------------------------------------"
echo "[Bug] Symfony Master/Slave support is broken #5969"
echo "https://github.com/mautic/mautic/pull/5970"
cat "../scripts/patches/5970.diff" | git apply -v

# Not to go into any PR.
echo "----------------------------------------------------"
echo "Disable the contacts view embedded in campaign view (temporary)."
cat "../scripts/patches/contact_list_disable.diff" | git apply -v

# Ready for tagging. Gist avoids conflicts with #6021 and #6187
echo "----------------------------------------------------"
echo "Create a Soft delete process for campaign events #6247"
echo "https://github.com/mautic/mautic/pull/6247"
cat "../scripts/patches/6247.diff" | git apply -v

# Gist Applies patches for Campaign Tagging
echo "----------------------------------------------------"
echo "Applies patches for Campaign Tagging"
echo "https://github.com/mautic/mautic/pull/6152"
cat "../scripts/patches/6152.diff" | git apply -v

# Temporary state abbreviation patch
echo "----------------------------------------------------"
echo "Converts United States proper names to abbreviations"
cat "../scripts/patches/us_state_abbrev_acceptance.diff" | git apply -v

# Report Event Dispatch called earlier to prevent fatal error when pagination used
echo "----------------------------------------------------"
echo "Report Event Dispatch called earlier to prevent fatal error when pagination used"
echo "https://github.com/mautic/mautic/pull/6330"
curl -L "https://github.com/mautic/mautic/pull/6330.diff" | git apply -v