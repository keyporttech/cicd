#!//bin/sh

new_helm_version=$(docker run -it $DOCKER_TAG helm version | \
    sed -nr 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' | \
    sort -Vu | \
    tail -n 1)

# get last release version from git
# prune all local tags that are not in remote
sh 'git tag -l | xargs git tag -d'
sh 'git fetch --tags'
sh 'git tag -l'
current_release_version=$(git describe --tags $(git rev-list --tags --max-count=1))

current_release_helm_version=$(cat $current_release_version | grep 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p')
new_version=$new_helm_version
if [ "$current_release_helm_version" eq "$new_helm_version"] then;
#increments last section indefinitely
  new_version=$(echo $last_version | gawk -F"." '{$NF+=1}{print $0RT}' OFS="." ORS="");
fi

echo $new_version
