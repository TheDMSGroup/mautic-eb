#!/usr/bin/env bash
# Link all files in a custom folder into the mautic directory.
# This is an alternative to using rsync, such that local development goes much more smoothly.
#
# usage:
#   bash mautic-custom.sh mautic_eb
#   bash mautic-custom.sh mautic_custom

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

if [ ! -d "$BASEDIR/$1" ]
then
    echo "There doesn't appear to be a $1 folder. Nothing to merge."
    exit 0
fi

echo "Linking $1 contents."
# Create directories (if they don't already exist) in ./mautic for all directories inside ./$1
cd "$BASEDIR/$1"
find * -mindepth 1 -depth -type d -exec echo {} \; | while read dir
do
    mkdir -p "../mautic/$dir"
done
# Create relative symlinks in ./mautic for all files inside ./$1 recursively.
cd "$BASEDIR/$1"
find * -type f ! -iname ".DS_Store" ! -iname ".gitkeep" -exec echo {} \; | while read file
do
    filepath=$(dirname "$file")
    filename=$(basename "$file")
    cd $BASEDIR/mautic/$filepath
    rm -f "$filename"
    slashes=$( echo "$file" | tr -d -c '/' )
    relative=${slashes//\//..\/}
    echo "Linking $file"
    ln -s "$relative../$1/$file" "$filename"
done

cd - > /dev/null
