#!/usr/bin/env bash
# Applying core Mautic patches that have not yet been merged in to the core version we are currently using.
# Using bash instead of composer so that we do not alter other dependencies outside of the core scope.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo ; echo "Applying selected patches to Mautic core."
cd ./mautic

echo ; echo "[Bug] Plugin content locking (referrer POST) causes 500. #5789"
echo "https://github.com/mautic/mautic/pull/5789"
curl -L "https://github.com/mautic/mautic/pull/5789.diff" | git apply -v

# Should go into 2.14.0 but is not merged yet.
echo ; echo "[Bug] SQL error if no field is chosen for \"Form field value\" conditional. #5875"
echo "https://github.com/mautic/mautic/pull/5875"
curl -L "https://github.com/mautic/mautic/pull/5875.diff" | git apply -v

# Should go into 2.14.0 but is not merged yet.
echo ; echo "[Enhancement] Allow filtering contacts by Campaign Membership for segments. #5911"
echo "https://github.com/mautic/mautic/pull/5911"
curl -L "https://github.com/mautic/mautic/pull/5911.diff" | git apply -v

# Needs refactoring before acceptance.
echo ; echo "[Enhancement] Support includes/excludes with text fields for bulk filtering. #5925"
echo "https://github.com/mautic/mautic/pull/5925"
curl -L "https://gist.githubusercontent.com/heathdutton/6542c12e1f55c0c3d3cbe6fe51706728/raw/7cd4c3716210a9e6c2ad28909e6cc650976d2094/5925.diff" | git apply -v

echo ; echo "[Bug] Symfony Master/Slave support is broken #5969"
echo "https://github.com/mautic/mautic/pull/5970"
curl -L "https://github.com/mautic/mautic/pull/5970.diff" | git apply -v

# Needs conflict resolution.
# echo ; echo "Campaign Details View tabbed content, allow filtering data by date range OR "to date" (current default) #6021"
# echo "https://github.com/mautic/mautic/pull/6021"
# curl -L "https://github.com/mautic/mautic/pull/6021.diff" | git apply -v

# Needs conflict resolution.
# echo ; echo "Config option for default date range on DateRangeFilter. #6091"
# echo "https://github.com/mautic/mautic/pull/6091"
# curl -L "https://github.com/mautic/mautic/pull/6091.diff" | git apply -v

# Should go into 2.14.0 but is not merged yet.
echo ; echo "Drastically improve performance of long-running campaign rendering. #6092"
echo "https://github.com/mautic/mautic/pull/6092"
curl -L "https://github.com/mautic/mautic/pull/6092.diff" | git apply -v

# Needs developer documentation.
echo ; echo "API call to clone an existing campaign. #6125"
echo "https://github.com/mautic/mautic/pull/6125"
curl -L "https://github.com/mautic/mautic/pull/6125.diff" | git apply -v