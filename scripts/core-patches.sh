#!/usr/bin/env bash
# Applying core Mautic patches that have not yet been merged in to the core version we are currently using.
# Using bash instead of composer so that we do not alter other dependencies outside of the core scope.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo ; echo "Applying selected patches to Mautic core."
cd ./mautic

echo ; echo "[Bug] Plugin content locking (referrer POST) causes 500. #5789"
curl -L "https://github.com/mautic/mautic/pull/5789.diff" | git apply -v

echo ; echo "[Enhancement] Allow filtering contacts by UTM data within campaigns. #5869"
curl -L "https://github.com/mautic/mautic/pull/5869.diff" | git apply -v

echo ; echo "[Bug] SQL error if no field is chosen for \"Form field value\" conditional. #5875"
curl -L "https://github.com/mautic/mautic/pull/5875.diff" | git apply -v

echo ; echo "[Enhancement] Allow filtering contacts by UTM data for segments. #5886"
curl -L "https://github.com/mautic/mautic/pull/5886.diff" | git apply -v

echo ; echo "[Enhancement] Allow filtering contacts by Campaign Membership for segments. #5911"
curl -L "https://github.com/mautic/mautic/pull/5911.diff" | git apply -v

echo ; echo "[Enhancement] Support includes/excludes with text fields for bulk filtering. #5925"
curl -L "https://gist.githubusercontent.com/heathdutton/6542c12e1f55c0c3d3cbe6fe51706728/raw/7cd4c3716210a9e6c2ad28909e6cc650976d2094/5925.diff" | git apply -v

echo ; echo "[Bug] Symfony Master/Slave support is broken #5969"
curl -L "https://github.com/mautic/mautic/pull/5970.diff" | git apply -v

echo ; echo "Dispatch event before Report's query execution for plugins to alter query #6036"
curl -L "https://github.com/mautic/mautic/pull/6036.diff" | git apply -v

echo ; echo "Apply Date filter option to Campaign Detail View for version 2.12.2 #2"
curl -L "https://patch-diff.githubusercontent.com/raw/scottshipman/mautic/pull/2.diff" | git apply -v

echo ; echo "Drastically improve performance of long-running campaign rendering. #6092"
curl -L "https://github.com/mautic/mautic/pull/6092.diff" | git apply -v

echo ; echo "API call to clone an existing campaign. #6125"
curl -L "https://github.com/mautic/mautic/pull/6125.diff" | git apply -v