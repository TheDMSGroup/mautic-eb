#!/usr/bin/env bash

# Configures and starts Newrelic based on environment variables not accessible in the .ebextensions yaml.
# This requires an environment variables $NR_INSTALL_KEY and $APP_NAME to be set.

. /opt/elasticbeanstalk/support/envvars

if [ -z "$NR_INSTALL_KEY" ]
then
    echo "Please set the global variable NR_INSTALL_KEY"
    exit 1
fi

if [ -z "$APP_URL" ]
then
    echo "Please set the global variable APP_URL"
    exit 1
fi

# Configure the Application monitor.
cat > /etc/php.d/newrelic.ini <<- EOM
; For our purposes this only contains minimal settings that are not defaults.
; https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration
extension = "newrelic.so"
[newrelic]
newrelic.license = "$NR_INSTALL_KEY"
newrelic.logfile = "/var/log/newrelic/php_agent.log"
newrelic.appname = "$APP_URL;Engage"
newrelic.error_collector.record_database_errors = false
newrelic.framework = "laravel"
EOM

chmod 000644 /etc/php.d/newrelic.ini
chown root:root /etc/php.d/newrelic.ini

export NR_INSTALL_KEY=$NR_INSTALL_KEY
export NR_INSTALL_SILENT=true

# Start the Application monitor.
newrelic-install install

# Start the System monitor.
nrsysmond-config --set license_key=$NR_INSTALL_KEY
sudo /etc/init.d/newrelic-sysmond restart

# Start the Infrastructure monitor.
echo "license_key: $NR_INSTALL_KEY" | sudo tee -a /etc/newrelic-infra.yml
printf "[newrelic-infra]\nname=New Relic Infrastructure\nbaseurl=http://download.newrelic.com/infrastructure_agent/linux/yum/el/6/x86_64\nenable=1\ngpgcheck=0" | sudo tee -a /etc/yum.repos.d/newrelic-infra.repo

yum-config-manager --save --setopt=newrelic-infra.skip_if_unavailable=true
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
