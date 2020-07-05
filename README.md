# jenkins-docker

This Dockerfile builds a Jenkins docker image that can run docker commands directly from Jenkins jobs.

The image is based on [Official Jenkins Docker Images](https://github.com/jenkinsci/docker/blob/master/README.md) and can be run using:

```bash
docker build . -t jenkins-docker
docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins-docker
```
