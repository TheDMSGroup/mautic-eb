#!/usr/bin/env bash
# Optionally restrict UI access to a single IP address.
# To be used for staging/dev environments or for corporate VPNs.
# This does not in any way restrict API usage or paths other than /s/
# A subnet can also be used.

set -e

BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR/../
BASEDIR=$( pwd )

CONF="/etc/httpd/conf.d/ip-restrict.conf"
CHANGE=0
IP_RESTRICT=""
IP_RESTRICT_URI="/vpn"

# Load environment variables if available.
if [[ -f "/opt/elasticbeanstalk/support/envvars" ]]
then
    . /opt/elasticbeanstalk/support/envvars
fi

# Store the previous value established (if available)
if [[ ! -z "$IP_RESTRICT" ]] && [[ ! -z "$IP_RESTRICT_URI" ]]
then
    echo "IP Restrictions are enabled"
    echo "Anyone not matching $IP_RESTRICT will be directed to $IP_RESTRICT_URI"
    # IP Restricted, place the file if not already present.
    if [[ -f "$CONF" ]]
    then
        CHANGE=0
    else
        CHANGE=1
        cat >> "$CONF" <<EOT
<VirtualHost _default_:80>
    <LocationMatch "^/s/.*">
        Order deny,allow
        Deny from all
        Allow from ${IP_RESTRICT}
        ErrorDocument 403 ${IP_RESTRICT_URI}
    </LocationMatch>
</VirtualHost>
<VirtualHost _default_:443>
    ErrorLog logs/ssl_error_log
    TransferLog logs/ssl_access_log
    LogLevel warn
    SSLEngine on
    SSLProtocol all -SSLv3
    SSLProxyProtocol all -SSLv3
    SSLHonorCipherOrder on
    SSLCertificateFile /etc/pki/tls/certs/localhost.crt
    SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
    <FilesMatch "\.(cgi|shtml|phtml|php)$">
      SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory "/var/www/cgi-bin">
      SSLOptions +StdEnvVars
    </Directory>
    BrowserMatch "MSIE [2-5]" \
             nokeepalive ssl-unclean-shutdown \
             downgrade-1.0 force-response-1.0
    CustomLog logs/ssl_request_log \
              "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
    <LocationMatch "^/s/.*">
        Order deny,allow
        Deny from all
        Allow from ${IP_RESTRICT}
        ErrorDocument 403 ${IP_RESTRICT_URI}
    </LocationMatch>
</VirtualHost>
EOT
    fi
else
    echo "IP Restrictions are disabled"
    # No IP Restrictions, remove the file if present.
    if [[ -f "$CONF" ]]
    then
        CHANGE=1
        sudo rm -f "$CONF"
    fi
fi

if [[ "$CHANGE" == 1 ]]
then
    echo "Reloading Apache configuration"
    sudo service httpd graceful
fi
