# jenkins-docker

## TL;DR

This Dockerfile builds a Jenkins docker image that can run docker commands directly from Jenkins jobs.

The image is based on [Official Jenkins Docker Images](https://github.com/jenkinsci/docker/blob/master/README.md) and can be run using:

```bash
docker build . -t jenkins-docker
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins-docker
```

## Rationale behind this project

[Jenkins](<https://en.wikipedia.org/wiki/Jenkins_(software)>) is an open source server that facilitates continuous integration and continuous delivery (CI/CD). Being self-hosted is a great choice for those who want full control over their DevOps tools.

Since you probably already use docker containers for your projects, adding Jenkins to the mix as a docker container seems like a natural choice. It is, indeed it is the [first method of installation](https://www.jenkins.io/doc/book/installing/) on Jenkins' website.

Running Jenkins with docker is as simply as running:

```bash
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

In a few minutes you can have your own CI/CD tool up and running like a charm. However soon you'll face with the following situation: _I need to deploy my project using Jenkins but my project runs itself inside the same docker jenkins is running!_.

Docker exposes an [API](https://docs.docker.com/engine/api/) that can be used to interact with it. There are [three ways](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-socket-option) to access this API: a unix domain socket, a TCP/IP socket and systemd sockets.

Since we're running Jenkins on the same host of the docker daemon, the simplest way is to make sure jenkins can access to this unix socket bind mounting `/var/run/docker.sock` and making sure the jenkins container has the docker command line tools to communicate with it.

This is what this `Dockerfile` does. First it pulls the official `jenkins/jenkins:lts` image and on top of it installs docker using the official instructions.

However this is not enough because Jenkins should be run by the `jenkins` user, however when we bind mount `/var/run/docker.sock` its ownership its owned by `root:root` making it inaccessible to jenkins.

One solution is to run jenkins as `root`, however this gives all Jobs inside jenkins `root` access and this can be a security concern. A second solution could be adding the user jenkins to the `root` group, however this also can represent a security issue.

The solution I present here is to add jenkins to the `docker` group, and inside the `entrypoint.sh` script that is run before starting jenkins we change the group of the docker socket to `docker`, making it accessible to Jenkins. Since this change can only be made after the container is started (because it's only mounted at this stage) we need to add a `sudoers` rule allowing jenkins to run the `chgrp` command (and nothing else) using `sudo`.
