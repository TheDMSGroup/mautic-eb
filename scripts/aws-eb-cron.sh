#!/usr/bin/env bash

# Prevent cron tasks from being ran by multiple instances in Elastic Beanstalk.
# Automatically adjusts to new "leading instance" when scaling up or down.
# Stores the result in an environment variable for other uses as AWS_EB_CRON
#
# This must be ran by cron as the root user to function correctly.
# Anything after this file will be executed as webapp for security.
#
# Example Cron (should be created by .ebextensions):
#   # Every 5 minutes, execute cron.php, but only do so on one instance in the beanstalk environment.
#   */5 * * * * . /var/app/current/aws-eb-cron.sh php cron.php
#
# Alternatively, just use the environment variable AWS_EB_CRON in your code, just update the variable via cron.
#   */5 * * * * . /var/app/current/aws-eb-cron.sh
#   * * * * * php cron.php

# Load environment variables if available.
if [[ -f "/opt/elasticbeanstalk/support/envvars" ]]
then
    . /opt/elasticbeanstalk/support/envvars
fi

# Store the previous value established (if available)
if [[ -z "$AWS_EB_CRON" ]]
then
    PREV_AWS_EB_CRON="$AWS_EB_CRON"
else
    PREV_AWS_EB_CRON="NA"
fi

# Establish the frequency of lead checking.
if [[ -z "$AWS_EB_CRON_FREQ" ]]
then
    # By default, check every 5 minutes.
    # This is because it requires 4 curl actions, so you don't wanna run it ALL the time.
    AWS_EB_CRON_FREQ=5
fi

# Check if we've already established the leader recently.
if test $( find /tmp/AWS_EB_CRON -mmin -"$AWS_EB_CRON_FREQ" )
then
    echo "We have already recently determined the leader."
    AWS_EB_CRON=$( cat /tmp/AWS_EB_CRON )
else
    echo "Determining leader..."

    # Get the current instance ID.
    EC2_INSTANCE_ID=$( curl -s -m 5 http://169.254.169.254/latest/meta-data/instance-id )
    if [[ -z "$EC2_INSTANCE_ID" ]]
    then
        echo "Could not determine my EC2 instance. You may not be running this in an Amazon instance or something has gone terribly wrong. Aborting."
        exit
    fi
    echo "EC2 Instance ID: $EC2_INSTANCE_ID"

    # Get the current region. Note, we may have instances across availability zones, so we will not be using this variable further.
    EC2_AVAIL_ZONE=$( curl -s -m 5 http://169.254.169.254/latest/meta-data/placement/availability-zone )
    echo "EC2 Availability Zone: $EC2_AVAIL_ZONE"

    EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
    echo "EC2 Region: $EC2_REGION"

    # Get the elastic beanstalk environment id.
    EB_ENV_ID=$( aws ec2 describe-instances --region "$EC2_REGION" --instance-id "$EC2_INSTANCE_ID" --output text | grep "TAGS.*elasticbeanstalk:environment-id.*" | sed -e 's/TAGS\selasticbeanstalk:environment-id\s//' )
    if [[ -z "$EB_ENV_ID" ]]
    then
        echo "Could not determine my EB Environment ID. Perhaps you are not running this in Elastic Beanstalk? Aborting."
        exit
    fi
    echo "Elastic Beanstalk Environment ID: $EB_ENV_ID"

    # Get all running instances with this tag, just the instance ID and the LaunchTime.
    EC2_INSTANCES=$( aws ec2 describe-instances --region "$EC2_REGION" --output text --query 'Reservations[*].Instances[*].[LaunchTime,InstanceId]' --filters "Name=tag-key,Values=elasticbeanstalk:environment-id" "Name=tag-value,Values=$EB_ENV_ID" "Name=instance-state-code,Values=16" )

    if [[ -z "$EC2_INSTANCES" ]]
    then
        echo "No running sibling instances found, so I am the leader."
        AWS_EB_CRON=1
    else
        # The last instance in a sorted list will be the oldest, and will be our leader.
        EC2_INSTANCE_LEAD_ID=$( echo $EC2_INSTANCES | sort | tail -n 1 | sed -e 's/^.*\s//' )
        if [[ "$EC2_INSTANCE_LEAD_ID" == "$EC2_INSTANCE_ID" ]]
        then
            echo "I am the oldest instance running, so I am the leader."
            AWS_EB_CRON=1
        else
            echo "I am a younger instance, so I will not lead."
            AWS_EB_CRON=0
        fi
    fi

    # Update the current instance environment variable "AWS_EB_CRON" if needed.
    if [[ "$AWS_EB_CRON" != "$PREV_AWS_EB_CRON" ]]
    then
        # This is a change from previously known status.
        sudo chmod 0646 /opt/elasticbeanstalk/support/envvars
        if [[ -z "$( grep 'export AWS_EB_CRON=' /opt/elasticbeanstalk/support/envvars )" ]]
        then
            echo "Adding a new variable."
            sudo echo "export AWS_EB_CRON=\"$AWS_EB_CRON\"" >> /opt/elasticbeanstalk/support/envvars
        else
            echo "Replacing previous environment variable."
            sudo sed -i "/export AWS_EB_CRON=/c\export AWS_EB_CRON=\"$AWS_EB_CRON\"" /opt/elasticbeanstalk/support/envvars
        fi
        sudo chmod 0644 /opt/elasticbeanstalk/support/envvars
    fi

    # Store the value in a file in /tmp for quicker lookup during the check_frequency.
    echo "$AWS_EB_CRON" > /tmp/AWS_EB_CRON
fi

# Run commands following this script as parameters if we are the leader.
if [[ "$AWS_EB_CRON" == "1" ]]
then
    if [[ ! -z "$@" ]]
    then
        cmdstring=". /opt/elasticbeanstalk/support/envvars ; $@"
        echo "Executing: sudo -u webapp bash -c \"$cmdstring\""
        sudo -u webapp bash -c "$cmdstring"
    fi
fi
