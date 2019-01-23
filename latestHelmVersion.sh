#!/bin/sh

helm_release_url=https://github.com/helm/helm/releases/latest
LATEST_HELM_RELEASE=$(curl -SsL $helm_release_url | awk '/\/tag\//' | grep -v no-underline | head -n 1 | cut -d '"' -f 2 | awk '{n=split($NF,a,"/"); print a[n]}' | sed 's/v//g')
echo $LATEST_HELM_RELEASE
