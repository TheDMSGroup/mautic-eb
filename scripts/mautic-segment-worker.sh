#!/usr/bin/env bash
# script to handle lauching high volume segment updates

# define a variable called MAUTIC_HV_SEGMENTS which is a comma delineated list of
# segment ids to update

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

# run the segment update for each high volume segment
if [ -n "$MAUTIC_HV_SEGMENTS" ]
then
    IFS=','
    while [ 1 ]
    do
        for segment in $MAUTIC_HV_SEGMENTS
        do
            consoleloop mautic:segments:update --list-id=$segment --batch-limit=10000 --max-contacts=10000 &
        done
    done
fi
