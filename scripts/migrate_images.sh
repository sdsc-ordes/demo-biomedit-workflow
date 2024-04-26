#!/usr/bin/env bash
# Migrate a container images listed in input config file to a new registry and namespace.
set -euo pipefail

usage() {
	echo -e "Usage: $0 containers.conf <new_address>\n"
	echo "Example: Migrate all images in nextflow config to myregistry.com/my-namespace/<image_name>:<tag>"
	echo "         $0 conf/containers.conf myregistry.com/my-namespace"
}

if [ $# -ne 2 ] ||
	[ "$1" == "-h" ] ||
	[ "$1" == "--help" ] ||
	[ ! -f "$1" ]; then
	usage
	exit 1
fi


migrate_img() {
    local img="$1"
    local new_path="$2"
    local new_img

    # substitute registry and namespace
    new_img=$(echo "$img" | sed "s#^.*/\([^/]*\)\$#${new_path}/\1#")
    echo "Migrating $img to $new_img"
    podman pull "$img"
    podman tag "$img" "$new_img"
    podman push "$new_img"
}

# loop over container definitions, keeping only unquoted urls
grep 'container *= *' "$1" \
| sed -e 's/ +$//' -e 's/.* //' \
| tr -d \'\" \
| while read -r img; do
  migrate_img "$img" "$2"
done
