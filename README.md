[![ci](https://github.com/sinlov/docker-verdaccio-gitea-auth/actions/workflows/ci.yml/badge.svg)](https://github.com/sinlov/docker-verdaccio-gitea-auth/actions/workflows/ci.yml)


[![GitHub license](https://img.shields.io/github/license/sinlov/docker-verdaccio-gitea-auth)](https://github.com/sinlov/docker-verdaccio-gitea-auth)
[![GitHub latest SemVer tag)](https://img.shields.io/github/v/tag/sinlov/docker-verdaccio-gitea-auth)](https://github.com/sinlov/docker-verdaccio-gitea-auth/tags)
[![GitHub release)](https://img.shields.io/github/v/release/sinlov/docker-verdaccio-gitea-auth)](https://github.com/sinlov/docker-verdaccio-gitea-auth/releases)

# docker-verdaccio-gitea-auth

[![docker hub version semver](https://img.shields.io/docker/v/sinlov/docker-verdaccio-gitea-auth?sort=semver)](https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth/tags?page=1&ordering=last_updated)
[![docker hub image size](https://img.shields.io/docker/image-size/sinlov/docker-verdaccio-gitea-auth)](https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth)
[![docker hub image pulls](https://img.shields.io/docker/pulls/sinlov/docker-verdaccio-gitea-auth)](https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth/tags?page=1&ordering=last_updated)

- docker hub see https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth

## Features

- this is fast way to run https://verdaccio.org/ and auth by https://gitea.io/ or self-hosted gitea server.
- add healthy check plugin [verdaccio-hello](https://github.com/bruceman/verdaccio-hello) (image version 5.30+)

### Migration

#### Migration v5 to v6

from release note [6.0.0](https://github.com/verdaccio/verdaccio/releases/tag/v6.0.0)

> Update notes, no considerable changes on this major release, for npm.js users only dropping Node.js, 14 and 16 support, minimum now is Node.js 18 and no changes for Docker users.

please update to version [5.32.2](https://github.com/verdaccio/verdaccio/releases/tag/v5.32.2) (2024-09-12) before upgrade.

## devops docker-compose

### verdaccio app config.yaml

- new config at `./verdaccio/conf/config.yaml` full config see [app/config/config.yaml](app/config/config.yaml)

```yml
# This is the config file used for the docker images.
# It allows all users to do anything, so don't use it on production systems.
#
# Do not configure host and port under `listen` in this file
# as it will be ignored when using docker.
#
# Look here for more config file examples:
# https://verdaccio.org/docs/en/best

# path to a directory with all packages
storage: /verdaccio/storage/data

# path to a directory with plugins to include
plugins: /verdaccio/plugins

auth:
  # https://verdaccio.org/docs/en/plugin-auth
  gitea-auth:
    # gitea-auth.url is not the api to the URl but just the server itself. Underneath we're concatenating /api/v1/user/orgs
    url: https://url-to-your-gitea-server
    # gitea-auth.defaultOrg If no orgs are in the list it defaults to ["gitea"]
    defaultOrg: gitea
  # htpasswd:
  #   file: /verdaccio/conf/htpasswd
    # Maximum amount of users allowed to register, defaults to "+inf".
    # You can set this to -1 to disable registration.
    #max_users: 1000

## Adit
# To use `npm audit` uncomment the following section
# Since: `verdaccio@3.0.0`
# npm audit is a new command released with npm 6.x. Verdaccio includes a built-in middleware plugin to handle this command.
middlewares:
  audit:
    enabled: true
  hello: # image 5.30+ support healthy check by: curl https://verdaccio.xxx/hello
    path: /hello # optional, default value is /hello
    text: ok # optional, default value is ok

# log settings
log:
  - { type: stdout, format: pretty, level: trace }
  #- {type: file, path: verdaccio.log, level: info}
```

- more config see [https://www.npmjs.com/package/verdaccio-gitea-auth#configuration](https://www.npmjs.com/package/verdaccio-gitea-auth#configuration)

### config docker-compose

- write docker-compose.yml config as below

```yml
# copy right
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
version: '3.8'
networks:
  default:
services:
  # https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth
  verdaccio-v5-permissions:
    container_name: 'verdaccio-v5-permissions'
    image: 'sinlov/docker-verdaccio-gitea-auth:latest' # https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth/tags?page=1&ordering=last_updated
    user: root
    command: "chown -R verdaccio: /verdaccio/"
    volumes:
      - './verdaccio/conf:/verdaccio/conf'
      - './data/verdaccio/storage:/verdaccio/storage'
      - './data/verdaccio/plugins:/verdaccio/plugins' # use plugins
  # https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth
  verdaccio-v5:
    container_name: 'verdaccio-v5'
    image: 'sinlov/docker-verdaccio-gitea-auth:latest' # https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth/tags?page=1&ordering=last_updated
    depends_on:
      - 'verdaccio-v5-permissions'
    user: verdaccio
    ports:
      - '4873:4873'
    volumes:
      - './verdaccio/conf:/verdaccio/conf'
      - './data/verdaccio/storage:/verdaccio/storage'
      - './data/verdaccio/plugins:/verdaccio/plugins' # use plugins
    restart: on-failure:3 # on-failure:3 or unless-stopped always default "no"
```

- run docker container

```bash
docker-compose up -d
```

## usage

- open https://url-to-your-gitea-server and login
- to page https://url-to-your-gitea-server/user/settings/applications add Access Tokens
- then open [http://:0.0.0.0:4873](http://:0.0.0.0:4873)

> this url will change as you config of docker

- login as
  - user    `gitea user`
  - password `Access Tokens`

## source repo

[https://github.com/sinlov/docker-verdaccio-gitea-auth](https://github.com/sinlov/docker-verdaccio-gitea-auth)

## dev

### change version

now support verdaccio `v6.x` `v5.x`

- change verdaccio version `6.0.5`
    - glibc `2.35-r0`
    - node version `20.18.1`
    - yarn version `yarn-v1.22.19`

## Contributing

[![Contributor Covenant](https://img.shields.io/badge/contributor%20covenant-v1.4-ff69b4.svg)](.github/CONTRIBUTING_DOC/CODE_OF_CONDUCT.md)
[![GitHub contributors](https://img.shields.io/github/contributors/sinlov/docker-verdaccio-gitea-auth)](https://github.com/sinlov/docker-verdaccio-gitea-auth/graphs/contributors)

We welcome community contributions to this project.

Please read [Contributor Guide](.github/CONTRIBUTING_DOC/CONTRIBUTING.md) for more information on how to get started.

请阅读有关 [贡献者指南](.github/CONTRIBUTING_DOC/zh-CN/CONTRIBUTING.md) 以获取更多如何入门的信息
