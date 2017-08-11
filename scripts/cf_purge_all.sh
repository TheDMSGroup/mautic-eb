#!/usr/bin/env bash

# Pure the Cloudflare zone completely.
# Should only be used if this project is the only thing on the domain (no subdomains or other applications).

cf_user="$CF_USER"
cf_token="$CF_TOKEN"
zone="$1"

curl -X DELETE "https://api.cloudflare.com/client/v4/zones/$zone/purge_cache" \
    -H "X-Auth-Email: $CF_USER" \
    -H "X-Auth-Key: $CF_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{"purge_everything":true}' -s -w "%{http_code}" -o /dev/null
