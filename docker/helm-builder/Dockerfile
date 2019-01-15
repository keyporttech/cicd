FROM ubuntu

ENV KUBERNETES_VERSION=v1.13.0 \
  HELM_VERSION=v2.12.1 \
  DOCKER_API_VERSION=1.38

RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    bash \
    curl \
    git \
    hub \
    make \
    dnsutils \
    lsb-release \
    wget \
    gnupg2 \
    html-xml-utils \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK and kubectl
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update && apt-get install -y -q google-cloud-sdk kubectl

# Install helm
RUN wget http://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && tar xzf ./helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin \
  && rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh
