# This dockerfile uses extends image https://hub.docker.com/sinlov/go-micro-cli
# VERSION 1
# Author: sinlov
# dockerfile official document https://docs.docker.com/engine/reference/builder/
# https://hub.docker.com/_/node?tab=tags&page=1&ordering=last_updated&name=15.12.0-alpine

# maintainer="https://github.com/sinlov/docker-verdaccio-gitea-auth"

# https://github.com/verdaccio/verdaccio/blob/v6.0.5/Dockerfile
# FROM --platform=${BUILDPLATFORM:-linux/amd64} node:20.18.1-alpine as builder
FROM node:20.18.1-alpine as builder

ARG VERDACCIO_DIST_VERSION=6.0.5

ENV NODE_ENV=production \
    VERDACCIO_BUILD_REGISTRY=https://registry.npmmirror.com  \
    HUSKY_SKIP_INSTALL=1 \
    CI=true \
    HUSKY_DEBUG=1

# proxy settings github pull
ARG GITHUB_RPOXY_PREFIX=https://ghproxy.net/

# proxy settings apk repo with: mirrors.aliyun.com
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add --force-overwrite && \
    apk --no-cache add openssl ca-certificates wget git && \
    apk --no-cache add g++ gcc libgcc libstdc++ linux-headers make python3 && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r0/glibc-2.35-r0.apk && \
    apk add --force-overwrite glibc-2.35-r0.apk

WORKDIR /opt/verdaccio-build

RUN git clone ${GITHUB_RPOXY_PREFIX}https://github.com/verdaccio/verdaccio.git --depth=1 -b v${VERDACCIO_DIST_VERSION} /opt/verdaccio-build

## build the project and create a tarball of the project for later
## global installation
RUN yarn config set npmRegistryServer $VERDACCIO_BUILD_REGISTRY && \
    yarn config set enableProgressBars true && \
    yarn config set enableScripts false && \
    yarn install --immutable && \
    yarn add verdaccio-gitea-auth && \
    yarn add verdaccio-hello && \
    yarn build
## pack the project
RUN yarn pack --out verdaccio.tgz \
    && mkdir -p /opt/tarball \
    && mv /opt/verdaccio-build/verdaccio.tgz /opt/tarball
## clean up and reduce bundle size
RUN rm -Rf /opt/verdaccio-build

FROM node:20.18.1-alpine
LABEL maintainer="https://github.com/sinlov/docker-verdaccio-gitea-auth"

ENV VERDACCIO_APPDIR=/opt/verdaccio \
    VERDACCIO_USER_NAME=verdaccio \
    VERDACCIO_USER_UID=10001 \
    VERDACCIO_PORT=4873 \
    VERDACCIO_PROTOCOL=http
ENV PATH=$VERDACCIO_APPDIR/docker-bin:$PATH \
    HOME=$VERDACCIO_APPDIR

WORKDIR $VERDACCIO_APPDIR

# proxy settings apk repo with: mirrors.aliyun.com
RUN cp /etc/apk/repositories /etc/apk/repositories.bak && \
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# https://github.com/Yelp/dumb-init
RUN apk --no-cache add openssl dumb-init

RUN mkdir -p /verdaccio/storage /verdaccio/plugins /verdaccio/conf

COPY --from=builder /opt/tarball .

USER root

# proxy settings for npm
RUN npm config set registry https://registry.npmmirror.com

# install verdaccio as a global package so is fully handled by npm
# ensure none dependency is being missing and is prod by default
RUN npm install -g $VERDACCIO_APPDIR/verdaccio.tgz \
    ## clean up cache
    && npm cache clean --force \
    && rm -Rf .npm/ \
    && rm $VERDACCIO_APPDIR/verdaccio.tgz \
    # yarn is not need it after this step
    # Also remove the symlinks added in the [`node:alpine` Docker image](https://github.com/nodejs/docker-node/blob/02a64a08a98a472c6141cd583d2e9fc47bcd9bfd/18/alpine3.16/Dockerfile#L91-L92).
    && rm -Rf /opt/yarn-v1.22.19/ /usr/local/bin/yarn /usr/local/bin/yarnpkg

ADD conf/docker.yaml /verdaccio/conf/config.yaml
ADD docker-bin $VERDACCIO_APPDIR/docker-bin

RUN adduser -u $VERDACCIO_USER_UID -S -D -h $VERDACCIO_APPDIR -g "$VERDACCIO_USER_NAME user" -s /sbin/nologin $VERDACCIO_USER_NAME && \
    chmod -R +x /usr/local/lib/node_modules/verdaccio/bin/verdaccio $VERDACCIO_APPDIR/docker-bin && \
    chown -R $VERDACCIO_USER_UID:root /verdaccio/storage && \
    chmod -R g=u /verdaccio/storage /etc/passwd

USER $VERDACCIO_USER_UID

EXPOSE $VERDACCIO_PORT

VOLUME /verdaccio/storage

ENTRYPOINT ["uid_entrypoint"]

CMD verdaccio --config /verdaccio/conf/config.yaml --listen $VERDACCIO_PROTOCOL://0.0.0.0:$VERDACCIO_PORT