#!//bin/sh

LATEST_HELM_RELEASE=$(./latestHelmVersion.sh)
NEW_RELEASE_TAG=$LATEST_HELM_RELEASE
if [ "$LATEST_HELM_RELEASE" = "$CURRENT_HELM_RELEASE" ]; then
  increment=$(echo $CURRENT_DOCKER_TAG | sed  's/\([0-9]*\.[0-9]*.[0-9]*\).-//g')

  increment=$((increment+1))
  NEW_RELEASE_TAG="${NEW_RELEASE_TAG}-${increment}"
fi

# replace tag in drone.yaml
sed "s/$CURRENT_HELM_RELEASE/$LATEST_HELM_RELEASE/g" <.drone.yml > drone.yml
mv .drone.yml .drone_old.yml
sed "s/"CURRENT_DOCKER_TAG:\ .*/CURRENT_DOCKER_TAG:\ "$NEW_RELEASE_TAG"/g  < drone.yml > .drone.yml
rm drone.yml .drone_old.yml

docker build docker/helm-builder -t $DOCKER_IMAGE:$NEW_RELEASE_TAG
docker login --username=$USERNAME --password=$PASSWORD
docker push $DOCKER_IMAGE:$NEW_RELEASE_TAG

cat <<EOF > release-notes.txt
$NEW_RELEASE_TAG Details

# Release versions for $NEW_RELEASE_TAG
**released**: $(date)
**helm version**: $LATEST_HELM_RELEASE
**kubectl version**: $(docker run -i $DOCKER_IMAGE:$NEW_RELEASE_TAG kubectl version --short=true | grep Client)
**hub**:
$(docker run -i $DOCKER_IMAGE:$NEW_RELEASE_TAG hub version)
EOF
**Dockerhub registry link**:

hub release create -c -F release-notes.txt $NEW_RELEASE_TAG

echo $NEW_RELEASE_TAG
