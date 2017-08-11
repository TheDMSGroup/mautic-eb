#!/usr/bin/env bash
# Automated PHP deployment script.
#
# For use locally, or via Bitbucket Pipelines.
#
# Examples:
#   bash scripts/deploy.sh <eb-environment> <app-url>
#   bash scripts/deploy.sh <eb-environment> <app-url> <newrelic-app-id> <issues-url> <app-thumbnail-url> <optional-dashboard-url>
#
# This requires variables set up in Bitbucket Pipelines (at the team is fine):
#   NR_API_KEY_PROD     - API key for production NewRelic use
#   NR_API_KEY_STAGE    - API key for non-production NewRelic use
#   SLACK_WEBHOOK_URL   - Webhook for sending slack notifications
#
# Agile Version Numbers explained:
#   1.11-3-gef15299 - The full 'git describe --long' command output. This is deterministic and can be checked out as-is.
# Broken down:
#   1.11            - The most recent tag
#   1               - Major application version
#     11            - Sprint number (one week per sprint)
#        3          - Number of commits since the tag of 1.11
#          gef15299 - Short SHA of the most recent commit
#
# These version numbers can be checked out as such:
#   git checkout 1.11            - Checks out the code as it was at the start of sprint 11.
#   git checkout 1.11-3-gef15299 - Checks out the code as it was deployed to production, which was 3 commits into the sprint.
#
# When this script is ran, if a tag doesn't exist for the current sprint, it will be auto-created.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
EB_ENV=$1
APP_URL=$2
NR_APP_ID=$3
ISSUES_URL=$4
APP_THUMBNAIL_URL=$5
DASHBOARD_URL=$6
PIPELINE_URL="https://bitbucket.org/$BITBUCKET_REPO_OWNER/$BITBUCKET_REPO_SLUG/addon/pipelines/home"
COMMIT_URL="https://bitbucket.org/$BITBUCKET_REPO_OWNER/$BITBUCKET_REPO_SLUG/commits/$BITBUCKET_COMMIT"
SLACK_SUCCESS_CHANNEL="#deployments"
SLACK_FAILURE_CHANNEL="#triage"

# Discern how we should present the dashboard URL if provided.
if [ -z "$DASHBOARD_URL" ]
then
    DASHBOARD_TEXTA=""
    DASHBOARD_TEXTB=""
    DASHBOARD_LINK=""
else
    DASHBOARD_TEXTA="Performance"
    DASHBOARD_TEXTB="Impact logged"
    DASHBOARD_LINK="<$DASHBOARD_URL|$DASHBOARD_TEXTB>"
fi

# Discern if this is dev/staging/production/other by the url.
NR_API_KEY=$NR_API_KEY_STAGE
if [[ $APP_URL == *"dev."* ]]
then
    EB_ENV_NAME=Development
    EB_ENV_COLOR=44C42B
else
    if [[ $APP_URL == *"stage."* ]]
    then
      EB_ENV_NAME=Staging
      EB_ENV_COLOR=24E289
    else
        if [ ! -z "$APP_URL" ]
        then
            EB_ENV_NAME=Production
            EB_ENV_COLOR=23AFE4
            NR_API_KEY=$NR_API_KEY_PROD
        else
            EB_ENV_NAME=Unknown
            EB_ENV_COLOR=E0A42C
        fi
    fi
fi


# Ensure execution of the eb script from within the Docker instance of Pipelines.
if [ -f "/root/.local/bin/eb" ]
then
    # Default location within Ubuntu.
    export PATH=/root/.local/bin:$PATH
fi

# Ensure the destination environment has been literally specified (we will not follow defaults).
if [ -z "$EB_ENV" ]
then
    echo -e "${RED}ERROR:${NC} Please include the environment you wish to deploy to."
    exit 1
fi

# Output the version of the Elastic Beanstalk CLI, and ensure it functions.
eb --version
if [ $? != 0 ]
then
    echo -e "${RED}ERROR:${NC} Cannot execute elastic beanstalk CLI."
    exit 1
fi

# Check for local changes (only applicable for local deployment).
changes=$( git ls-files -m | sed '/^\s*$/d' )
if [ ! -z "$changes" ]
then
    echo -e "${RED}WARNING:${NC} There are code changes:"
    echo "${RED}$changes${NC}"
    read -p "Do you still want to deploy with these changes uncommitted? The git reference will be incorrect." -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        echo "Stopping deployment"
        exit 1
    fi
fi

# Get the last commit log message.
log=$( git log --oneline --decorate --first-parent -1 )
log=${log//>/}
log=${log//\'/}
if [ $? != 0 ]
then
    echo -e "${RED}ERROR:${NC} Could not discern git log."
    exit 1
fi

# Discern our version number from a long git describe. If no tags are found, a hash will be used.
version=$( git describe --long --always )
version=${version//>/}
version=${version//\'/}
if [ $? != 0 ]
then
    echo -e "${RED}ERROR:${NC} Could not discern version."
    exit 1
fi

# Initialize the app, which is not always necessary but ensures we can deploy.
echo "Initializing app."
echo -ne 'n' | eb init --verbose
if [ $? != 0 ]
then
    echo -e "${RED}ERROR:${NC} Could not initialize the application."
    exit 1
fi

# Explicitly set the environment to prevent warnings during eb deploy, this will alter the config file.
echo "Setting environment to $EB_ENV"
eb use "$EB_ENV" --verbose
if [ $? != 0 ]
then
    echo -e "${RED}ERROR:${NC} Unable to select environment."
    exit 1
fi

# Get a quicklink for use later if possible.
echo "Getting quicklink"
link=$( eb labs quicklink )
if [ $? != 0 ]
then
    echo -e "${RED}WARNING:${NC} Unable to discern quicklink."
fi

# Attempt to deploy a previously uploaded copy of this version first, then upload this version if that fails.
echo "Attempting to re-deploy $version in case it has been previously deployed."
eb deploy "$EB_ENV" --timeout=60 --version="$version" --verbose 2>&1 | tee -a eb-activity.log | grep "Environment update completed successfully."
if [ $? != 0 ]
then
    echo "Deploying $version as a new version."
    eb deploy "$EB_ENV" --timeout=60 --label="$version" --verbose 2>&1 | tee -a eb-activity.log | grep "Environment update completed successfully."
fi
if [ $? == 0 ]
then
    echo -e "${GREEN}SUCCESS:${NC} Deployment of $version to $EB_ENV is complete."

    # Notify NewRelic of a successful deployment.
    if [[ ! -z "$APP_URL" && ! -z "$NR_API_KEY" && ! -z "$NR_APP_ID" ]]
    then
        echo "Sending notification to NewRelic."
        payload='{"deployment": {
                    "revision": "'$version'",
                    "changelog": "'$log'",
                    "description": "Deployment of '$version' to '$APP_URL'"
                }}'
        curl -X POST "https://api.newrelic.com/v2/applications/$NR_APP_ID/deployments.json" \
             -H "X-Api-Key:$NR_API_KEY" -i \
             -H "Content-Type: application/json" \
             -d "$payload"
    fi

    # Notify us via slack of a successful deployment.
    if [[ ! -z "$APP_URL" && ! -z "$SLACK_WEBHOOK_URL" ]]
    then
        echo "Sending notification to Slack of success to '$SLACK_SUCCESS_CHANNEL'."
        payload='payload={
            "channel": "'$SLACK_SUCCESS_CHANNEL'",
            "username": "'$EB_ENV_NAME' Deployment Complete",
            "icon_emoji": ":passenger_ship:",
            "mrkdwn": true,
            "attachments": [
                {
                    "fallback": "'$APP_URL'.",
                    "color": "#'$EB_ENV_COLOR'",
                    "fields": [
                        {
                            "title": "Domain",
                            "value": "<http://'$APP_URL'|'$APP_URL'>",
                            "short": true
                        },
                        {
                            "title": "Issues",
                            "value": "Please see the <'$ISSUES_URL'|issues for review>.",
                            "short": true
                        },
                        {
                            "title": "Release",
                            "value": "<'$PIPELINE_URL'|'$version'>",
                            "short": true
                        },
                        {
                            "title": "Environment",
                            "value": "<'$link'|'$EB_ENV'>",
                            "short": true
                        },
                        {
                            "title": "Last Commit",
                            "value": "<'$COMMIT_URL'|'$BITBUCKET_COMMIT'>",
                            "short": true
                        },
                        {
                            "title": "'$DASHBOARD_TEXTA'",
                            "value": "'$DASHBOARD_LINK'",
                            "short": true
                        }
                    ],
                    "thumb_url": "'$APP_THUMBNAIL_URL'",
                    "footer": "Deployment Automation"
                }
            ]
        }'
        curl -X POST $SLACK_WEBHOOK_URL \
             --data-urlencode "$payload"
    fi
else
    echo -e "${RED}ERROR:${NC} Deployment of $version to $EB_ENV resulted in an error."

    if [[ -f "eb-activity.log" ]]
    then
        cat eb-activity.log
    fi

    # Notify us via slack of a failed deployment.
    if [[ ! -z "$APP_URL" && ! -z "$SLACK_WEBHOOK_URL" ]]
    then
        echo "Sending notification to Slack of failure to '$SLACK_FAILURE_CHANNEL'."
        payload='payload={
            "channel": "'$SLACK_FAILURE_CHANNEL'",
            "username": "'$EB_ENV_NAME' Deployment Failed",
            "icon_emoji": ":passenger_ship:",
            "mrkdwn": true,
            "attachments": [
                {
                    "fallback": "'$APP_URL'.",
                    "color": "#C4471D",
                    "fields": [
                        {
                            "title": "Domain",
                            "value": "<http://'$APP_URL'|'$APP_URL'>",
                            "short": true
                        },
                        {
                            "title": "Issues",
                            "value": "Please see the <'$ISSUES_URL'|issues for review>.",
                            "short": true
                        },
                        {
                            "title": "Release",
                            "value": "<'$PIPELINE_URL'|'$version'>",
                            "short": true
                        },
                        {
                            "title": "Environment",
                            "value": "<'$link'|'$EB_ENV'>",
                            "short": true
                        },
                        {
                            "title": "Last Commit",
                            "value": "<'$COMMIT_URL'|'$BITBUCKET_COMMIT'>",
                            "short": true
                        },
                        {
                            "title": "'$DASHBOARD_TEXTA'",
                            "value": "'$DASHBOARD_LINK'",
                            "short": true
                        }
                    ],
                    "thumb_url": "'$APP_THUMBNAIL_URL'",
                    "footer": "Deployment Automation"
                }
            ]
        }'
        curl -X POST $SLACK_WEBHOOK_URL \
             --data-urlencode "$payload"
    fi

    # Exit with 1 to report a failed deployment to Pipelines.
    exit 1
fi
