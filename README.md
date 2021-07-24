# docker-verdaccio-gitea-auth

[![docker build](https://img.shields.io/docker/cloud/build/sinlov/docker-verdaccio-gitea-auth)](https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth)
[![docker version semver](https://img.shields.io/docker/v/sinlov/docker-verdaccio-gitea-auth?sort=semver)](https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth/tags?page=1&ordering=last_updated)
[![docker image size](https://img.shields.io/docker/image-size/sinlov/docker-verdaccio-gitea-auth)](https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth)

- docker hub see https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth
- this is fast way to run https://verdaccio.org/

## repo

[https://github.com/sinlov/docker-verdaccio-gitea-auth](https://github.com/sinlov/docker-verdaccio-gitea-auth)


## fast use

```sh
docker run --rm \
  --name verdaccio-gitea-auth \
  -p 4873:4873 \
  sinlov/docker-verdaccio-gitea-auth:latest
```

## docker-compose

```yml
# copy right
# Licenses http://www.apache.org/licenses/LICENSE-2.0
# more info see https://docs.docker.com/compose/compose-file/ or https://docker.github.io/compose/compose-file/
version: '3.7'
networks:
  default:
services:
  verdaccio-gitea-auth:
    container_name: 'verdaccio-gitea-auth'
    image: sinlov/docker-verdaccio-gitea-auth:4.12.2-alpine # https://hub.docker.com/r/sinlov/docker-verdaccio-gitea-auth/tags?page=1&ordering=last_updated
    ports:
      - '4873:4873'
    # environment:
    #   - NODE_ENV=production
    restart: on-failure:3 # on-failure:3 or unless-stopped always default no
```