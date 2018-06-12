#!/usr/bin/env bash
# Runs multiple concurrent threads of campaign event triggers.

# Check dependencies.
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

# Load environment variables (which may change during execution).
if [ -f "/opt/elasticbeanstalk/support/envvars" ]
then
    . /opt/elasticbeanstalk/support/envvars
fi

# Establish the current worker count based on environment variables.
if [ -z "$MAUTIC_WORKERS" ]
then
    workers=10
else
    workers=$MAUTIC_WORKERS
fi

# Get the count of instances running this script (including the current one).
for (( i = 1; i <= $workers; i++ ))
do
    cronloop mautic:campaign:trigger --thread-id $i --max-threads $workers --no-ansi --no-interaction --quiet --force &
done
