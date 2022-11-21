#!/usr/bin/env bash
# Migrate a list of images to a new registry and namespace.
# The list of images should be provided as a yaml file with one 'name: URI' per line.
set -euo pipefail

usage() {
	echo -e "Usage: $0 <images.yaml> <new_address>\n"
	echo "Example: Migrate all images in images.yaml to myregistry.com/my-namespace/<image_name>:<tag>"
	echo "         $0 images.yaml myregistry.com/my-namespace"
}

if [ $# -ne 2 ] ||
	[ "$1" == "-h" ] ||
	[ "$1" == "--help" ] ||
	[ ! -f "$1" ]; then
	usage
	exit 1
fi


migrate_img() {
    local img="${1##*: }"
    local new_path="$2"
    local new_img

    new_img=$(echo "$img" | sed "s#^.*/\([^/]*\)\$#${new_path}/\1#")
    echo "Migrating $img to $new_img"
    podman pull "$img"
    podman tag "$img" "$new_img"
    podman push "$new_img"
}

while read -r img; do
    migrate_img "$img" "$2"
done < "$1"
