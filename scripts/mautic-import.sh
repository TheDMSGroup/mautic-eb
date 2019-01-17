#!/usr/bin/env bash
# Ensures the symlink for imports exists (in case of a /tmp folder purge/drop)
# And runs the import process in a loop for maximum performance.
# Limited batches of 300 to overcome RAM leak issues currently in Mautic core.
# Relies on the console alias.

if [ -z $( which ps ) ]
then
  echo "ps is required to run this script."
  exit 1
fi
if [ -z $( which grep ) ]
then
  echo "grep is required to run this script."
  exit 1
fi
if [ -z $( which nohup ) ]
then
  echo "nohup is required to run this script."
  exit 1
fi

command="sudo nohup console mautic:import --limit=600 --quiet >/dev/null 2>&1"
count=$( ps aux --no-headers 2>&1 | grep -c "$command" 2>&1 )
while [ "$count" -lt "2" ]
do
    if [ ! -d /tmp/imports ]
    then
        sudo ln -sf /efs/mautic/imports /tmp
    fi
    eval ${command}
    sleep 1
    count=$( ps aux --no-headers 2>&1 | grep -c "$command" 2>&1 )
done
