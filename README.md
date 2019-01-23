# Keyporttech CICD

This repository contains the docker images and tooling used by keyporttech for continuous integration and continuous delivery (cicd).

Our workflows are designed for reusability across public/private projects.

## Design

We use our own kubernetes drone.io for cicd and our workflow is designed to be fully autonomous.  For public open source projects there are 2 basic pipeline types:

* cicd for docker images
* cicd for helm charts.  

This repo contains a cicd workflow for docker the helm-build docker image.  We simplify and reuse our drone pipelines as much as possible to reduce maintenance.

## helm-builder docker image

The helm-builder image is a major component of Keyporttech's cicd tooling.  It contains all the necessary software to execute builds in our pipelines:

Includes the up-to-date versions of:

* [helm](https://helm.sh/) for helm workflows
* [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/) installed via the [Google Cloud SDK](https://cloud.google.com/sdk/)
* [hub](https://hub.github.com/) used to automate gtihub api fucntions like creating releases and auto-generation of pull requests
* [docker](https://www.docker.com/) for docker image workflows


## Docker image workflow

There are 2 scenarios handled. pull-requests and merges to master/releases.

CICD for pull requests is simple.  The pipeline attempts to build the docker file.  This requires starting a docker service that uses the docker:dnd image.  

Merges to master are more complex.  When a pull request is merged the pipeline:
* makes sure the docker image is up to date with the latest versions of the tools listed above.  It pulls the latest versions from their respective github releases page.
* creates a docker image tag based on the semantic helm version.  If the helm version has not changed then the docker tag is incremented with by adding -(+1) to the end of the tag.
* tags the docker image with the new tag
* pushes the docker image to dockerhub
* creates a new release on github.  This is automated by using the [hub](https://hub.github.com/).
* updates the drone.yml file to use the latest tag it just created.
* updates the master branch with the new drone.yml

Much of the logic for creating the release is contained in the release-publish.sh script.

Daily cron Jobs

There is a cron job that checks for a new version of helm.  If a new version of helm is released it generates a PR, merges it, and then creates a new release.
