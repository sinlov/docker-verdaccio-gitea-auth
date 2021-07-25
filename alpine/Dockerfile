# This dockerfile uses extends image https://hub.docker.com/sinlov/go-micro-cli
# VERSION 1
# Author: sinlov
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/node?tab=tags&page=1&ordering=last_updated&name=15.12.0-alpine

# maintainer="https://github.com/sinlov/docker-verdaccio-gitea-auth"

# https://hub.docker.com/r/verdaccio/verdaccio/tags?page=1&ordering=last_updated
FROM verdaccio/verdaccio:4.12.2

USER root

RUN npm i && \
 npm i verdaccio-gitea-auth && \
 npm cache clean --force

USER verdaccio