# This dockerfile uses extends image https://hub.docker.com/sinlov/go-micro-cli
# VERSION 1
# Author: sinlov
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/node?tab=tags&page=1&ordering=last_updated&name=15.12.0-alpine

# maintainer="https://github.com/sinlov/docker-verdaccio-gitea-auth"

# https://hub.docker.com/r/verdaccio/verdaccio/tags?page=1&ordering=last_updated
FROM verdaccio/verdaccio:5.1.2

USER root

RUN yarn add verdaccio-gitea-auth && \
  yarn install && \
  yarn code:docker-build && \
  yarn cache clean && \
  yarn workspaces focus --production

USER verdaccio
