#!/bin/bash -eu

sed -ne 's/^.*\(TAG.*\)$/\1/p' .travis.yml | while read -r env; do
    eval "$env"
    source ./generate.sh
done
