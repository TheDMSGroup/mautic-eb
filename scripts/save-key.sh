#!/usr/bin/env bash

# Pass this script a base64 encoded string, and it will be saved as the key name specified.
# Example:
#   bash save-key.sh id_rsa "LS0tLS1CRUdJT......."

# To be ran within a build server, not in production.

mkdir -p ~/.ssh
touch ~/.ssh/$1.tmp
echo "$2" > ~/.ssh/$1.tmp
touch ~/.ssh/$1
base64 -d ~/.ssh/$1.tmp > ~/.ssh/$1
rm -rf ~/.ssh/$1.tmp
chmod 400 ~/.ssh/$1
