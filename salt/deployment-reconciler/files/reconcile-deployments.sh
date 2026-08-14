#!/bin/bash
set -euo pipefail

readonly queue_dir="/var/lib/deployment-reconciler"
readonly pending="${queue_dir}/pending"
readonly processing="${queue_dir}/processing"
if [[ -e "${processing}" && ! -e "${pending}" ]]; then
    mv "${processing}" "${pending}"
fi

while [[ -e "${pending}" ]]; do
    mv "${pending}" "${processing}"

    if salt-call --local --retcode-passthrough state.apply; then
        rm -f "${processing}"
    else
        # Failed runs are not retried automatically. A new or explicitly
        # redelivered webhook creates a fresh pending marker.
        mv -f "${processing}" "${queue_dir}/failed"
        exit 1
    fi
done

