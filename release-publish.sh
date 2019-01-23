#!//bin/sh

#check for a new version of helm - if not then increment current tag
LATEST_HELM_RELEASE=$(./latestHelmVersion.sh)
echo "lastest helm release: $LATEST_HELM_RELEASE"
echo "dockerhub user: $DOCKERHUB_USERNAME"
echo "dockerhub password: $DOCKERHUB_PASSWORD"
echo "github key: $GITHUB_KEY"
NEW_RELEASE_TAG=$LATEST_HELM_RELEASE
if [ "$LATEST_HELM_RELEASE" = "$CURRENT_HELM_RELEASE" ]; then
  increment=$(echo $CURRENT_DOCKER_TAG | sed  's/\([0-9]*\.[0-9]*.[0-9]*\).-//g')

  increment=$((increment+1))
  NEW_RELEASE_TAG="${NEW_RELEASE_TAG}-${increment}"
fi

# update tags in drone.yaml
sed "s/$CURRENT_HELM_RELEASE/$LATEST_HELM_RELEASE/g" <.drone.yml > drone.yml
mv .drone.yml .drone_old.yml
sed "s/"CURRENT_DOCKER_TAG:\ .*/CURRENT_DOCKER_TAG:\ "$NEW_RELEASE_TAG"/g  < drone.yml > .drone.yml
rm drone.yml .drone_old.yml

#Publish to docker
docker build docker/helm-builder --build-arg HELM_VERSION=$LATEST_HELM_RELEASE -t $DOCKER_IMAGE:$NEW_RELEASE_TAG
echo $DOCKERHUB_PASSWORD | docker login --username $DOCKERHUB_USERNAME --password-stdin
docker push $DOCKER_IMAGE:$NEW_RELEASE_TAG

cat <<EOF > release-notes.txt
$NEW_RELEASE_TAG Details

# Release versions for $NEW_RELEASE_TAG
**released**: $(date)
**helm version**: $LATEST_HELM_RELEASE
**kubectl version**: $(docker run -i $DOCKER_IMAGE:$NEW_RELEASE_TAG kubectl version --short=true | grep Client)
**hub**:
$(docker run -i $DOCKER_IMAGE:$NEW_RELEASE_TAG hub version)
**Dockerhub registry link**:
EOF


hub release create -c -F release-notes.txt $NEW_RELEASE_TAG

echo $NEW_RELEASE_TAG
