#!/usr/bin/env bash

# Pure the Cloudflare zone completely.
# Should only be used if this project is the only thing on the domain (no subdomains or other applications).

if [ -z "$CF_ZONE" ]
then
    echo "No zone specified. Cloudflare will not be purged."
    exit 0
fi

if [ -z "$CF_USER" ]
then
    echo "No user specified. Cloudflare will not be purged."
    exit 0
fi

if [ -z "$CF_TOKEN" ]
then
    echo "No token specified. Cloudflare will not be purged."
    exit 0
fi

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$CF_ZONE/purge_cache" \
    -H "X-Auth-Email: $CF_USER" \
    -H "X-Auth-Key: $CF_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"purge_everything":true}' -s -w "%{http_code}" -o /dev/null
