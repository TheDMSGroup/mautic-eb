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
# curl -L "https://github.com/mautic/mautic/pull/6224.diff" | git apply -v
# Temporary patch for the current staging ref.
curl -L "https://gist.githubusercontent.com/heathdutton/75da2cdf2a562ac42a97f2976a517626/raw/8b52d8c182c3d8ae459172f373828da7805fd224/6224.diff" | git apply -v

# Ready for tagging. Gist avoids conflicts with #6021.
echo "----------------------------------------------------"
echo "[Bug] Symfony Master/Slave support is broken #5969"
echo "https://github.com/mautic/mautic/pull/5970"
#curl -L "https://github.com/mautic/mautic/pull/5970.diff" | git apply -v
curl -L "https://gist.githubusercontent.com/heathdutton/5ed0edc0a3dd7dd77eb478a918868812/raw/e52ba2deadaaaa4e19943b6059bc9d19b34b90d3/5970.diff" | git apply -v

# Not to go into any PR.
echo "----------------------------------------------------"
echo "Disable the contacts view embedded in campaign view (temporary)."
curl -L "https://gist.githubusercontent.com/heathdutton/27065426ff16f2b0834a550d8a27aa76/raw/d8a6bc4667ed6d8b3474fd49736a385741656151/contact_list_disable.diff" | git apply -v

# Gist avoids conflicts with #6021 and #6187
echo "----------------------------------------------------"
echo "Create a Soft delete process for campaign events #6247"
echo "https://github.com/mautic/mautic/pull/6247"
curl -L "https://gist.githubusercontent.com/scottshipman/3e7b62c3728b300cd7d06521d83a490d/raw/592775e5714211151e2778466166f42d6e85af6f/6247.diff" | git apply -v

# Gist Applies patches for Campaign Tagging
echo "----------------------------------------------------"
echo "Applies patches for Campaign Tagging"
echo "https://github.com/mautic/mautic/pull/6152"
curl -L "https://gist.githubusercontent.com/cykonetic/dd517bc45f633c00f2435e4c8ff6d0f0/raw/e8a05d667fccd378dec1f7bc7b5306cdc44a3469/6152.diff" | git apply -v

# Temporary state abbreviation patch
echo "----------------------------------------------------"
echo "Converts United States proper names to abbreviations"
curl -L "https://gist.githubusercontent.com/cykonetic/521b38133797e2a3f48060c519a1870e/raw/6e4a04d3e7202b66c437fff3234c900c073d3441/stateacceptancepatch.diff" | git apply -v
