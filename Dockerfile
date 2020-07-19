FROM jenkins/jenkins:lts


# Install docker following the official instructions
# https://docs.docker.com/engine/install/debian/
USER root

RUN apt-get update

RUN apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

COPY docker.gpg .
RUN apt-key add docker.gpg

RUN sh -c 'add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"'

RUN apt-get update

ARG DOCKER_GID
RUN groupadd -g $DOCKER_GID docker
RUN apt-get -y install docker-ce docker-ce-cli containerd.io

RUN apt-get clean

# Add jenkins to docker group so it can read/write docker.sock
RUN usermod -a -G docker jenkins


ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create a specific sudoer file to allow jenkins to change the group
# of the docker.sock file bound by the volume
COPY 01_jenkins_docker /etc/sudoers.d/

# Drop privileges to docker
USER jenkins

# Run our entrypoint to first change docker.sock group and
# then start jenkins
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]