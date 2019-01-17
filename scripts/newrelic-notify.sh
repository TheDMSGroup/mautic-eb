#!/usr/bin/env bash
# Notifies newrelic of a deployment.

. /opt/elasticbeanstalk/support/envvars

if [ -z "$NR_APPNAME" ]
then
    echo "Will not notify NewRelic of a deployment without NR_APPNAME."
    exit
fi

if [ -z "$NR_APPID" ]
then
    echo "Will not notify NewRelic of a deployment without NR_APPID."
    exit
fi

if [ -z "$NR_API_KEY" ]
then
    echo "Will not notify NewRelic of a deployment without NR_API_KEY."
    exit
fi

APP_VER=$( tail /var/log/eb-activity.log | grep -i "\[Application update .*\] : Completed activity." | tail -1 | sed -E 's/.*Application update (.*)@.*/\1/' )

if [ -z "$APP_VER" ]
then
    echo "Could not discern app version."
    exit
fi

curl -X POST 'https://api.newrelic.com/v2/applications/${NR_APPID}/deployments.json' \
   -H 'X-Api-Key:${NR_API_KEY}' -i \
   -H 'Content-Type: application/json' \
   -d \
'{
    "deployment": {
        "revision": "${APP_VER}"
    }
}'