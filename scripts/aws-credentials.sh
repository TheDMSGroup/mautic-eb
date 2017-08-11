#!/usr/bin/env bash

# Pass this script the aws_access_key_id and aws_secret_access_key to be used for eb deployments.
# Example:
#   bash aws-credentials.sh "DKFJHIFUHEIWUHF" "ohoFhow3!JOfjlKSHFnxCdCddwo0*Fhq2"

# To be ran within a build server, not in production.

mkdir -p ~/.aws
touch ~/.aws/credentials
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id = $1" >> ~/.aws/credentials
echo "aws_secret_access_key = $1" >> ~/.aws/credentials
chmod 600 ~/.aws/credentials
