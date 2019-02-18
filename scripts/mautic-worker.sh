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

globalworkers=10
kickoffworkers=0
scheduledworkers=0
inactiveworkers=0

# Get the global worker count if defined.
if [ ! -z "$MAUTIC_WORKERS" ]
then
    globalworkers=$MAUTIC_WORKERS
fi

# Check for kickoff worker setting.
if [ ! -z "$MAUTIC_WORKERS_KICKOFF" ]
then
    globalworkers=0
    kickoffworkers=$MAUTIC_WORKERS_KICKOFF
fi

# Check for scheduled worker setting.
if [ ! -z "$MAUTIC_WORKERS_SCHEDULED" ]
then
    globalworkers=0
    scheduledworkers=$MAUTIC_WORKERS_SCHEDULED
fi

# Check for inactive worker setting.
if [ ! -z "$MAUTIC_WORKERS_INACTIVE" ]
then
    globalworkers=0
    inactiveworkers=$MAUTIC_WORKERS_INACTIVE
fi

if [ $globalworkers -gt 0 ]
then
    # Start global event workers
    for (( i = 1; i <= $globalworkers; i++ ))
    do
        cronloop mautic:campaign:trigger --thread-id $i --max-threads $globalworkers --batch-limit 250 --campaign-limit 1500 --quiet --force &
    done
else
    # Start kickoff event workers.
    if [ $kickoffworkers -gt 0 ]
    then
        for (( i = 1; i <= $kickoffworkers; i++ ))
        do
            cronloop mautic:campaign:trigger --thread-id $i --kickoff-only --max-threads $kickoffworkers --batch-limit 250 --campaign-limit 1500 --quiet --force &
        done
    fi

    # Start scheduled event workers.
    if [ $scheduledworkers -gt 0 ]
    then
        for (( i = 1; i <= $scheduledworkers; i++ ))
        do
            cronloop mautic:campaign:trigger --thread-id $i --scheduled-only --max-threads $scheduledworkers --batch-limit 250 --campaign-limit 1500 --quiet --force &
        done
    fi

    # Start inactive event workers.
    if [ $inactiveworkers -gt 0 ]
    then
        for (( i = 1; i <= $inactiveworkers; i++ ))
        do
            cronloop mautic:campaign:trigger --thread-id $i --inactive-only --max-threads $inactiveworkers --batch-limit 250 --campaign-limit 1500 --quiet --force &
        done
    fi
fi
