# This dockerfile uses extends image https://hub.docker.com/sinlov/go-micro-cli
# VERSION 1
# Author: sinlov
# dockerfile offical document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/node?tab=tags&page=1&ordering=last_updated&name=15.12.0-alpine

# maintainer="https://github.com/sinlov/docker-verdaccio-gitea-auth"

# https://hub.docker.com/r/verdaccio/verdaccio/tags?page=1&ordering=last_updated
FROM verdaccio/verdaccio:4.12.2

# RUN apk add --no-cache -U \
#   make

WORKDIR /opt/verdaccio

# RUN yarn config --global set registry https://registry.npm.taobao.org && \
#   yarn config set disturl https://npm.taobao.org/dist --global
# RUN yarn config set npmRegistryServer https://registry.npm.taobao.org

RUN yarn add verdaccio-gitea-auth && \
  yarn cache clean

# ENV NODE_ENV=production

# EXPOSE 4873

ENTRYPOINT ["uid_entrypoint"]

CMD $VERDACCIO_APPDIR/bin/verdaccio --config /verdaccio/conf/config.yaml --listen $VERDACCIO_PROTOCOL://0.0.0.0:$VERDACCIO_PORT

#CMD ["tail",  "-f", "/etc/alpine-release"]
#ENTRYPOINT [ "go", "env" ]