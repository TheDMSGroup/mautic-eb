Mautic EB [![Build Status](https://travis-ci.org/heathdutton/mautic-eb.svg?branch=master)](https://travis-ci.org/heathdutton/mautic-eb)
=========

Deploy Mautic in a fully-scalable Amazon Elastic Beanstalk cluster.

## Requirements

1) AWS EB environment running PHP 7.1
2) AWS RDS MySQL instance (Aurora or MariaDB recommended)
3) AWS EFS Volume (used for shared media and spool storage)
4) Bitbucket pipelines (optional, used to automate deployment)

## Environment variables in Elastic Beanstalk for a single site.

    DB_HOST               - RDS Host.
    DB_USER               - RDS User.
    DB_PASSWD             - RDS Password.
    DB_NAME               - RDS Database name.
    SECRET_KEY            - Hash key for encryption.
    DB_PORT               - RDS port.
    MAILER_FROM_NAME      - Default "from" email name.
    MAILER_FROM_EMAIL     - Default "from" email address.
    APP_URL               - Domain upon which you are running by default.
    EFS_DNS_NAME          - The full DNS of the EFS mount.
    MAUTIC_INSTALL        - Set to "1" to initialize mautic for the first time.
    NR_APM_INSTALL_KEY    - Optional NewRelic install key for Application Monitoring.
    NR_INF_INSTALL_KEY    - Optional NewRelic install key for Infrastructure.

### Bitbucket Pipelines / Travis CI Environment Variables
This repo can be used to automatically build and deploy Mautic to Elastic Beanstalk using Bitbucket pipelines. To do so, BitBucket Pipelines must be enabled for this repo, and the following environment variables must be added to Pipeline settings:

    AWS_ACCESS_KEY_ID     - The raw AWS key ID.
    AWS_SECRET_ACCESS_KEY - The raw AWS Secret Access Key.
    AWS_EB_KEY            - The private SSH key for the AWS Elastic Beanstalk environment. Base64 encoded.
    APP_URL_PROD          - URL of production environment.
    APP_URL_STAGE         - URL of staging environment (optional).
    APP_URL_DEV           - URL of development environment (optional).
    APP_ENV_PROD          - Name of production environment in Elastic Beanstalk.
    APP_ENV_STAGE         - Name of staging environment in Elastic Beanstalk (optional).
    APP_ENV_DEV           - Name of development environment in Elastic Beanstalk (optional).
    NR_APPNAME            - APP name/url to report to.
    NR_API_KEY_STAGE      - The NewRelic API key for staging (optional).
    NR_API_KEY_PROD       - The NewRelic API key for production (optional).
    SLACK_WEBHOOK_URL     - The URL to use for sending a slack deployment notification (optional).
    CF_USER               - CloudFlare account user email (optional).
    CF_TOKEN              - CloudFlare account user API key (optional).
    CF_ZONE               - CloudFlare DNS zone to purge (optional).

### Mautic Customizations
Custom files and configuration can be placed in /mautic_custom

The contents of this folder will be linked as if it is in the /mautic folder on composer install/update.

If new files are added to the /mautic_custom folder you can run `composer reset` to ensure they are reflected
in the core /mautic folder.

Custom dependencies can be included in a root composer.custom

Do not run `composer install` from within the mautic folder, only in the root project folder.

### Multisite Abstraction *(expirimental)*

You may need to run several "sites" off of the same Elastic Beanstalk cluster.

To that end, the RDS databases will be as follows:
* _sites
  * id 
  * active      - boolean, to indicate if the site is enabled or not.
  * name
* _domains
  * domain 
  * site_id
 

#### Environment variables for multisite

    EB_MULTI            - Set to true to enable multisite (off by default).
    
#### Local setup

Host at http://mautic.loc

#### Custom folders

File structure in /mautic_eb will be copied (destructively) into the /mautic folder on composer install or update.
For configuration files and other changes that cannot be plugin-based.
Similarly you can use /mautic_custom for customizations that are brand-specific.

* mautic_eb/*  -->  mautic/*
* mautic_custom/*  -->  mautic/*