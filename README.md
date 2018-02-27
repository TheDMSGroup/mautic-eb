Mautic EB [![Build Status](https://travis-ci.org/TheDMSGroup/mautic-eb.svg?branch=master)](https://travis-ci.org/TheDMSGroup/mautic-eb)
=========

#### Deploy Mautic in an auto-scaling Amazon Elastic Beanstalk cluster.
![Mautic and AWS](https://i.imgur.com/LkFNgHr.jpg "Mautic and AWS")

The goal here is to make it simple and safe to scale Mautic up to millions of leads per week, 
while maintaining HIPAA & PCI compliance. Other helpful services such as CloudFlare and Newrelic are supported, but optional.

## Requirements

1) AWS EB environment running PHP 7.1 with environment variables described below.
2) AWS RDS MySQL instance (Aurora recommended, encrypted in a private VPC)
3) AWS EFS Volume (used for shared media and spool storage)
4) Add the AmazonEC2ReadOnlyAccess policy to the aws-elasticbeanstalk-ec2-role (for the cron script to self regulate)

## Environment variables in Elastic Beanstalk.

    APP_URL               - The default full URL for your site.
    DB_HOST               - RDS Host.
    DB_HOST_RO            - Optional: RDS Host for read-only slave cluster.
    DB_USER               - RDS User.
    DB_PASSWD             - RDS Password.
    DB_NAME               - RDS Database name.
    DB_PORT               - RDS port.
    SECRET_KEY            - Hash key for encryption.
    MAILER_FROM_NAME      - Default "from" email name.
    MAILER_FROM_EMAIL     - Default "from" email address.
    EFS_DNS_NAME          - The full DNS of the EFS mount.
    MAUTIC_INSTALL        - Optional: Set to "1" to initialize mautic, for the first deployment only.
    NR_APM_INSTALL_KEY    - Optional: NewRelic install key for Application Monitoring.
    NR_INF_INSTALL_KEY    - Optional: NewRelic install key for Infrastructure.

### EB Container Options:

- Document Root: `/mautic`

### Travis CI / Bitbucket Pipelines Environment Variables
This repo can be used to automatically build and deploy Mautic to Elastic Beanstalk using Bitbucket pipelines. To do so, the following environment variables must be added to your CI:
Note, we're using Travis CI since this is a 100% open source project and will remain so.

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

File structure in /mautic_eb will be copied (destructively) into the /mautic folder on composer install or update.
For configuration files and other changes that cannot be plugin-based.
Similarly you can use /mautic_custom for customizations that are brand-specific.
Third party plugins that use the "mautic-plugin" installer will have their folders symlinked into the correct location.

* mautic_eb/*  -->  mautic/*
* mautic_custom/*  -->  mautic/*
* plugins/* --> mautic/plugins/*

Custom dependencies can be included in a root composer.custom

### Quick local setup

1. Set up local host at http://mautic.loc that points to `./mautic`
2. Create a `./mautic/.env` file containing your local database credentials. 
3. Run: `composer install` to get all the dependencies together.
5. Run: `composer db-setup-dev` to create your local database.

#### Local tips and commands

* `composer cc` to clear all Mautic/Symfony caches.
* `composer custom` to update symlinks for all customizations to mautic core.
* `composer less` to compile LESS styles (should you need to extend the core styles).
* `composer assets` to regenerate core CSS and JS files for deployment.
* `composer test` to run the full codeception suite.
* The file `composer.custom` can be created to pull in third-party dependencies and customizations without altering this repo.
* Do not run `composer install` from within the `./mautic` folder, only in the root project folder.

### Additional Plugins *(work in progress)*

Need to process a million new contacts every day? 
Need to add a custom integration every day, without writing code?

These are the kinds of requirements we have on the bleeding edge of Performance Marketing.
With that in mind, we are actively working on some [additional plugins](https://github.com/thedmsgroup?q=mautic&type=public)
to augment this build. Eventually we hope these can be robust enough to make their way into core. For now, 
we can access and test them by renaming `composer.custom.dist` to `composer.custom` and running `composer install`. 

### Multisite *(work in progress)*

You may need to run several "sites" off of the same Elastic Beanstalk cluster.
This isn't likely a common need, we just wanted to make sure there was *some* room made for this.
More documentation incoming.

If you go multisite you'll need. Your database structure in RDS will look like this:

    mautic_eb_multi     - Database mapping hostnames to sites, based on [this](https://gist.github.com/heathdutton/46fc4514d8372cdda26b61cc0fe6a0cd).
    mautic_eb_site_0    - Default first site in the cluster.
    mautic_eb_site_1    - Second site... and so on.

Multisite environment variables:

    EB_MULTI            - Set to true to enable multisite (off by default).
