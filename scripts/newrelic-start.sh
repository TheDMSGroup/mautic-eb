#!/usr/bin/env bash

# Configures and starts Newrelic based on environment variables not accessible in the .ebextensions yaml.
# This requires an environment variables $NR_INSTALL_KEY and $APP_NAME to be set.

. /opt/elasticbeanstalk/support/envvars

if [ -z "$NR_APPNAME" ]
then
    echo "Please set the global variable NR_APPNAME if you wish to use NewRelic reporting."
    rm -rf /etc/php.d/newrelic.ini
    exit 0
fi

# Configure the Application monitor.
cat > /etc/php.d/newrelic.ini <<- EOM
; For our purposes this only contains minimal settings that are not defaults.
; https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration
extension = "newrelic.so"
[newrelic]
newrelic.license = "$NR_APM_INSTALL_KEY"
newrelic.logfile = "/var/log/newrelic/php_agent.log"
newrelic.appname = "$NR_APPNAME"
newrelic.error_collector.record_database_errors = 1
newrelic.framework = "symfony2"
newrelic.framework.drupal.modules = 0
newrelic.framework.wordpress.hooks = 0
EOM

if [ ! -z "$NR_APM_INSTALL_KEY" ]
then

    chmod 000644 /etc/php.d/newrelic.ini
    chown root:root /etc/php.d/newrelic.ini

    export NR_INSTALL_KEY=$NR_APM_INSTALL_KEY
    export NR_INSTALL_SILENT=true

    # Start the Application monitor.
    newrelic-install install
else
    echo "Please set the global variable NR_APM_INSTALL_KEY if you wish to use NewRelic APM reporting."
fi

if [ ! -z "$NR_INF_INSTALL_KEY" ]
then
    # Start the System monitor.
    nrsysmond-config --set license_key=$NR_INF_INSTALL_KEY
    sudo /etc/init.d/newrelic-sysmond restart

    # Start the Infrastructure monitor.
    echo "license_key: $NR_INF_INSTALL_KEY" | sudo tee -a /etc/newrelic-infra.yml
    printf "[newrelic-infra]\nname=New Relic Infrastructure\nbaseurl=http://download.newrelic.com/infrastructure_agent/linux/yum/el/6/x86_64\nenable=1\ngpgcheck=0" | sudo tee -a /etc/yum.repos.d/newrelic-infra.repo

    yum-config-manager --save --setopt=newrelic-infra.skip_if_unavailable=true
    sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
    sudo yum install newrelic-infra -y
else
    echo "Please set the global variable NR_INF_INSTALL_KEY if you wish to use NewRelic Infrastructure reporting."
fi
