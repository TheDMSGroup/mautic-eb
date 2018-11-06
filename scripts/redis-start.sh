#!/usr/bin/env bash

# Configures PHPRedis for session storage.
# This requires an environment variable $REDIS_PATH to be set.

. /opt/elasticbeanstalk/support/envvars

if [ -z "$REDIS_PATH" ]
then
    echo "In order to use Redis for session storage, set the global variable REDIS_PATH"
    rm -rf /etc/php.d/z_redis.ini
    exit 0
fi

# Configure the Application monitor.
cat > /etc/php.d/z_redis.ini <<- EOM
; Use Redis for session storage.
; https://github.com/phpredis/phpredis
session.save_handler = redis
session.save_path = "$REDIS_PATH"
EOM
