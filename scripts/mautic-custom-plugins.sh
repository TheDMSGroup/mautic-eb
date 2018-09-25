#!/usr/bin/env bash
# Link all folders in ./plugins into the ./mautic/plugins path.
#
# usage:
#   bash mautic-custom-plugins.sh

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

if [ ! -d "$BASEDIR/plugins" ]
then
    echo "There doesn't appear to be a plugins folder. Nothing to merge."
    exit 0
fi

cd "$BASEDIR/plugins"
for dir in *
do
    if [ ! -d "../mautic/plugins/$dir" ] && [ "$dir" != "*" ]
    then
        # Directory does not exist, symlink the entire folder.
        cd "$BASEDIR/mautic/plugins"
        echo "Linking plugin $dir"
        ln -s "../../plugins/$dir" "$dir"
        cd -
    fi
done