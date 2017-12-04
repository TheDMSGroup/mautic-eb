#!/usr/bin/env bash
# Link all mautic_custom files into the mautic directory.
# This is an alternative to using rsync, such that local development goes much more smoothly:
#       rsync -avh --exclude 'README.md' --progress mautic_custom/ mautic/

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

echo "Symlinking the vendor/bin contents."
cd $BASEDIR/mautic
rm -rf vendor bin
ln -s ../vendor vendor
ln -s ../bin bin

echo "Linking mautic_custom contents."
# Create directories (if they don't already exist) in ./mautic for all directories inside ./mautic_custom
cd $BASEDIR/mautic_custom
find * -mindepth 1 -depth -type d -exec echo {} \; | while read dir
do
    mkdir -p "../mautic/$dir"
done
# Create relative symlinks in ./mautic for all files inside ./mautic_custom recursively.
cd $BASEDIR/mautic_custom
find * -type f ! -iname ".DS_Store" ! -iname "README.md" -exec echo {} \; | while read file
do
    filepath=$(dirname "$file")
    filename=$(basename "$file")
    cd $BASEDIR/mautic/$filepath
    rm -f "$filename"
    slashes=$( echo "$file" | tr -d -c '/' )
    relative=${slashes//\//..\/}
    echo "Linking $file"
    ln -s "$relative../mautic_custom/$file" "$filename"
done

cd - > /dev/null