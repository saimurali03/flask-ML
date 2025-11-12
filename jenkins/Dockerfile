FROM jenkins/jenkins:lts

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    docker.io \
    python3 \
    python3-pip \
    unzip \
    curl \
    gnupg \
    software-properties-common && \
    pip install awscli && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get install -y terraform && \
    apt-get clean

USER jenkins

