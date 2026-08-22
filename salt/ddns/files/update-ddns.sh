#!/bin/bash
set -euo pipefail

update_url="https://dynamicdns.park-your-domain.com/update"
status=0

for record in ${DDNS_RECORDS}; do
    host=${record%%:*}
    domain=${record#*:}
    fqdn=${domain}
    if [ "$host" != "@" ]; then
        fqdn="${host}.${domain}"
    fi

    if ! response=$(curl --fail --silent --show-error --get "$update_url" \
        --data-urlencode "host=${host}" \
        --data-urlencode "domain=${domain}" \
        --data-urlencode "password=${DDNS_PASSWORD}"); then
        echo "Namecheap DDNS request failed for ${fqdn}" >&2
        status=1
        continue
    fi

    if ! grep -q '<ErrCount>0</ErrCount>' <<<"$response"; then
        echo "Namecheap DDNS update failed for ${fqdn}" >&2
        echo "$response" >&2
        status=1
        continue
    fi

    echo "Updated ${fqdn}"
done

exit "$status"
