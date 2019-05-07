Mautic EB [![Latest Stable Version](https://poser.pugx.org/thedmsgroup/mautic-eb/v/stable)](https://packagist.org/packages/thedmsgroup/mautic-eb) [![Build Status](https://travis-ci.org/TheDMSGroup/mautic-eb.svg?branch=master)](https://travis-ci.org/TheDMSGroup/mautic-eb)
=========

#### Deploy Mautic in a scalable Amazon Elastic Beanstalk cluster.
![Mautic and AWS](https://i.imgur.com/LkFNgHr.jpg "Mautic and AWS")

The goal here is to make it simple and safe to scale Mautic up to millions of leads per week, 
while maintaining HIPAA & PCI compliance. Other helpful services such as CloudFlare and Newrelic are supported, but optional.

## Requirements

1) AWS EB environment running PHP 7.1 with environment variables described below
2) AWS RDS MySQL instance (Aurora recommended, preferably encrypted)
3) AWS EFS Volume (used for shared media/spool/etc)
4) Add the AmazonEC2ReadOnlyAccess policy to the aws-elasticbeanstalk-ec2-role (for the cron script to run on leading instance only)
5) We recommend having the Elastic Beanstalk CLI [installed](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html) locally.

## Elastic Beanstalk Environment Variables

#### Required:

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

#### Optional:

    REDIS_HOST               - Set to the path of your Redis server/cluster to use Redis for session storage. Helps avoid CSRF errors when scaling. See https://github.com/phpredis/phpredis
    MAUTIC_INSTALL           - Set to "1" to initialize mautic for the first/cold deployment only!
    MAUTIC_WORKERS           - Number of concurrent campaign trigger workers to run on the leading instance.
                             - Instead of MAUTIC_WORKERS, we reccomend using the following 3 variables now to better control your timing.
    MAUTIC_WORKERS_KICKOFF   - Number of concurrent campaign trigger workers running kickoff actions only. Overrides MAUTIC_WORKERS when present.
    MAUTIC_WORKERS_SCHEDULED - Number of concurrent campaign trigger workers running scheduled actions only. Overrides MAUTIC_WORKERS when present.
    MAUTIC_WORKERS_INACTIVE  - Number of concurrent campaign trigger workers running inactive actions only. Overrides MAUTIC_WORKERS when present.
    NR_APPNAME               - Newrelic application name.
    NR_APPID                 - Newrelic application ID number for deployment notifications.
    NR_APM_INSTALL_KEY       - NewRelic install key for Application Monitoring.
    NR_INF_INSTALL_KEY       - NewRelic install key for Infrastructure.
    NR_API_KEY               - NewRelic API key (optional, for Health plugin).

### Travis CI Environment Variables

You will need to set these up if you wish to deploy your fork to an Elastic Beanstalk environment automatically from Travis.

    AWS_ACCESS_KEY_ID             - From your IAM console (keep hidden).
    AWS_SECRET_ACCESS_KEY         - From your IAM console (keep hidden).
    AWS_REGION                    - The region to deploy to (us-east-1).
    AWS_EB_APP                    - App name to deploy (mautic-eb).
    AWS_EB_ENV                    - Elastic beanstalk environment name (mautic-eb-dev).
    ELASTIC_BEANSTALK_LABEL       - Label name of the new version (optional).
    ELASTIC_BEANSTALK_DESCRIPTION - Description of the new version (optional). Defaults to the last commit message.

### Mautic Customizations

File structure in /mautic_eb will be copied (destructively) into the /mautic folder on composer install or update.
For configuration files and other changes that cannot be plugin-based.
Similarly you can use /mautic_custom for customizations that are brand-specific.
Third party plugins that use the "mautic-plugin" installer will have their folders symlinked into the correct location.

* mautic_eb/*  -->  mautic/*
* mautic_custom/*  -->  mautic/*
* plugins/* --> mautic/plugins/*

Custom dependencies can be included in a root composer.custom

### Local setup
Pretty much the same as working with Mautic core:

1. Clone & composer:
```
git clone https://github.com/TheDMSGroup/mautic-eb.git
cd mautic-eb
composer install
```
2. Set up local host at http://mautic.loc that points to the `.../mautic-eb/mautic` sub-folder.
3. Browse to http://mautic.loc and go through the standard setup. 

### Local setup for plugin/mautic-eb development

1. Clone & composer:
```
git clone https://github.com/TheDMSGroup/mautic-eb.git
cd mautic-eb
bash ./scripts/build-local.sh
```
2. Set up local host at http://mautic.loc that points to the `.../mautic-eb/mautic` sub-folder.
3. Browse to http://mautic.loc and go through the standard setup. 

### Traditional deployment (from local)
Should you not wish to use Travis to deploy for you, you can do it manually from your local machine:

* Make sure you've set up the *Requirements* above.
* run `bash ./scripts/build.sh`
* run `eb init` if you haven't already.
* run `eb deploy`

#### Local tips and commands

* Important: Do not run `composer install` from within the `./mautic` folder, only in the root project folder.
* `composer cc` to clear all Mautic/Symfony caches.
* `composer custom` to update symlinks for all customizations to mautic core (from mautic_eb and mautic_custom).
* `composer less` to compile LESS styles (should you need to extend or modify the core styles using SCSS).
* `composer assets` to regenerate core CSS and JS files for deployment (should you need to modify core JS or SCSS).
* `composer test` to run the full codeception suite.
* The file `composer.custom` can be created for third-party dependencies/plugins/customizations

### Additional Plugins / Customizations

Need to process a million new contacts every day? 
Need to add a custom integration every day, without writing code?

These are the kinds of requirements we have in Performance Marketing.
With that in mind, we include [optional plugins](https://github.com/thedmsgroup?q=mautic&type=public)
to augment this build. You can access them all at once by renaming `composer.custom.dev` to `composer.custom` and running `composer install`. 
