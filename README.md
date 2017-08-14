Mautic EB
=========

Deploy Mautic in a fully-scalable Amazon Elastic Beanstalk cluster.

## Requirements

1) AWS EB environment running PHP7
2) AWS RDS MySQL instance (Aurora or MariaDB recommended)
3) AWS EFS Volume (used for shared media and spool storage)
4) Bitbucket pipelines (optional, used to automate deployment)

### Bitbucket Pipelines Environment Variables
This repo can be used to automatically build and deploy Mautic to Elastic Beanstalk using Bitbucket pipelines. To do so, BitBucket Pipelines must be enabled for this repo, and the following environment variables must be added to Pipeline settings:

    AWS_ACCESS_KEY_ID     - The raw AWS key ID.
    AWS_SECRET_ACCESS_KEY - The raw AWS Secret Access Key.
    / AWS_EB_KEY            - The private SSH key for the AWS Elastic Beanstalk environment. Base64 encoded.
    / BB_KEY                - The private SSH key Bitbucket (optional, unless repo is public). Base64 encoded.
    NR_APPNAME            - APP name/url to report to.
    NR_API_KEY_STAGE      - The NewRelic API key for staging (optional).
    NR_API_KEY_PROD       - The NewRelic API key for production (optional).
    SLACK_WEBHOOK_URL     - The URL to use for sending a slack deployment notification (optional).
    CF_USER               - CloudFlare account user email (optional).
    CF_TOKEN              - CloudFlare account user API key (optional).
    CF_ZONE               - CloudFlare DNS zone to purge (optional).