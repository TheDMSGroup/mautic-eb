#!/usr/bin/env bash
# Applying core Mautic patches that have not yet been merged in to the core version we are currently using.
# Using bash instead of composer so that we do not alter other dependencies outside of the core scope.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo "----------------------------------------------------"
echo "Applying selected patches to Mautic core."
cd ./mautic

# Testing...
#echo "----------------------------------------------------"
#echo "Segment refactoring #5755"
#echo "https://github.com/mautic/mautic/pull/5755"
#curl -L "https://github.com/mautic/mautic/pull/5755.diff" | git apply -v

## Testing...
#echo "----------------------------------------------------"
#echo "Contact ID column to plugin integration mapping #5655"
#echo "https://github.com/mautic/mautic/pull/5655"
#curl -L "https://github.com/mautic/mautic/pull/5655.diff" | git apply -v

## Testing...
#echo "----------------------------------------------------"
echo "Correct the method used to clean URL #6174"
#echo "https://github.com/mautic/mautic/pull/6174"
#curl -L "https://github.com/mautic/mautic/pull/6174.diff" | git apply -v

# Ready for tagging.
echo "----------------------------------------------------"
echo "[Bug] Plugin content locking (referrer POST) causes 500. #5789"
echo "https://github.com/mautic/mautic/pull/5789"
curl -L "https://github.com/mautic/mautic/pull/5789.diff" | git apply -v

# Should go into 2.14.0 but is not merged yet.
echo "----------------------------------------------------"
echo "[Bug] SQL error if no field is chosen for \"Form field value\" conditional. #5875"
echo "https://github.com/mautic/mautic/pull/5875"
curl -L "https://github.com/mautic/mautic/pull/5875.diff" | git apply -v

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

# Conflicts resolved, needs testing.
echo "----------------------------------------------------"
echo "Campaign Details View tabbed content, allow filtering data by date range OR \"to date\" (current default) #6021"
echo "https://github.com/mautic/mautic/pull/6021"
curl -L "https://github.com/mautic/mautic/pull/6021.diff" | git apply -v
# 2.12.2 equivalent backup: https://gist.githubusercontent.com/heathdutton/753486f204d034ee681a9849eda3e922/raw/6cc47a0f7de46a832b158a2f58edc20aa6402fd5/6021-2.12.2.diff

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

# Ready for tagging. Currently conflicts with existing patches.
#echo "----------------------------------------------------"
#echo "Campaign Tags #6152"
#echo "https://github.com/mautic/mautic/pull/6152"
#curl -L "https://github.com/mautic/mautic/pull/6152.diff" | git apply -v

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

# Ready for tagging. Gist avoids conflicts with #6021.
echo "----------------------------------------------------"
echo "[Bug] Symfony Master/Slave support is broken #5969"
echo "https://github.com/mautic/mautic/pull/5970"
#curl -L "https://github.com/mautic/mautic/pull/5970.diff" | git apply -v
curl -L "https://gist.githubusercontent.com/heathdutton/5ed0edc0a3dd7dd77eb478a918868812/raw/e52ba2deadaaaa4e19943b6059bc9d19b34b90d3/5970.diff" | git apply -v

# Not to go into any PR.
echo "----------------------------------------------------"
echo "Disable the contacts view embedded in campaign view (temporary)."
curl -L "https://gist.githubusercontent.com/heathdutton/27065426ff16f2b0834a550d8a27aa76/raw/f6a287de8db40722f674f388757f0c13236cd182/contact_list_disable.diff" | git apply -v
