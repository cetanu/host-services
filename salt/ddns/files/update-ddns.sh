#!/bin/bash
set -euo pipefail

metadata_url="http://169.254.169.254/v1/interfaces/0/ipv4/address"
update_url="https://dynamicdns.park-your-domain.com/update"

ip=$(curl --fail --silent --show-error --max-time 5 "$metadata_url")
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
        --data-urlencode "password=${DDNS_PASSWORD}" \
        --data-urlencode "ip=${ip}"); then
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

    echo "Updated ${fqdn} to ${ip}"
done

exit "$status"

