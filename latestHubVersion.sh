#!/bin/sh

helm_release_url=https://github.com/github/hub/releases/latest
LATEST_HUB_RELEASE=$(curl -SsL $helm_release_url | awk '/\/tag\//' | grep -v no-underline | head -n 1 | cut -d '"' -f 2 | awk '{n=split($NF,a,"/"); print a[n]}' | sed 's/v//g')
echo $LATEST_HUB_RELEASE
