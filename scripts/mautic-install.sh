#!/usr/bin/env bash
# Perform initial Mautic installation, and do not fail if installation has already been made.

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

# Load environment variables if available.
if [ -f "/opt/elasticbeanstalk/support/envvars" ]
then
    . /opt/elasticbeanstalk/support/envvars
fi

# Store the previous value established (if available)
if [ "$MAUTIC_INSTALL" == "1" ]
then
    DBCREATE=$( php ./mautic/app/console doctrine:database:create --no-interaction --if-not-exists )
    echo "$DBCREATE"
    if [[ $? == 0 && $DBCREATE == *"Skipped."* ]]
    then
        php ./mautic/app/console mautic:install:data -n -vvv
        if [ $? == 0 ]
        then
            php ./mautic/app/console doctrine:migrations:version --add --all --no-interaction -n -vvv
        else
            echo "Failure to install Mautic data."
            exit 1
        fi
    else
        echo "No installation required."
        exit 0
    fi
else
    echo "MAUTIC_INSTALL variable is not 1, assuming we have already installed."
fi