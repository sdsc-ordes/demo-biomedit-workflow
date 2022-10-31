#!/usr/bin/env bash
# Listen for nextflow weblog on input PORT and store it in OUT
# The http header is stripped to keep only the JSON body

# Usage: ./logger.sh 31212 my.log
# Note: requires socat
set -euo pipefail

PORT="$1"
OUT="$2"
TMP=$(mktemp)

if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
	exec >&2
	echo "error: Input must be a port number"
	exit 1
fi

while true; do
	socat TCP4-LISTEN:${PORT},reuseaddr file:${TMP},create &&
		sed '1,/^\r\{0,1\}$/d' ${TMP} >${OUT} &&
		rm ${TMP}
done
