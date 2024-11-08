TOP_DIR := $(shell pwd)

# default latest
ENV_DIST_VERSION =latest

ROOT_NAME =docker-verdaccio-gitea-auth

ROOT_BUILD_FOLDER ?=build
ROOT_BUILD_PATH ?=${ROOT_BUILD_FOLDER}
ROOT_SCRIPT_FOLDER ?=dist
ROOT_LOG_PATH ?=./log
ROOT_DIST ?=./out

# MakeImage.mk settings start
ROOT_OWNER =sinlov
ROOT_PARENT_SWITCH_TAG :=20.14.0-alpine
# for image local build
INFO_TEST_BUILD_DOCKER_PARENT_IMAGE =node
INFO_BUILD_DOCKER_FILE =Dockerfile
INFO_TEST_BUILD_DOCKER_FILE =build.dockerfile
INFO_TEST_BUILD_DOCKER_CONTAINER_ENTRYPOINT =/bin/sh
INFO_TEST_BUILD_DOCKER_CONTAINER_ARGS =
# INFO_TEST_BUILD_DOCKER_PARENT_USER =--user root:root
# MakeImage.mk settings end

TEST_TAG_EXAMPLE_PATH         =example
TEST_EXAMPLE_COMPOSE_PROJECT  =${ROOT_NAME}
TEST_TAG_BUILD_IMAGE_NAME     =${ROOT_OWNER}/${ROOT_NAME}
TEST_TAG_BUILD_CONTAINER_NAME =test-${ROOT_NAME}

include z-MakefileUtils/MakeImage.mk

.PHONY: env
env: dockerEnv
	@echo "=> Now run as docker-compose folder: ${TEST_TAG_EXAMPLE_PATH}"
	@echo "TEST_EXAMPLE_COMPOSE_PROJECT       : ${TEST_EXAMPLE_COMPOSE_PROJECT}"
	@echo "TEST_TAG_BUILD_IMAGE_NAME          : $(TEST_TAG_BUILD_IMAGE_NAME)"
	@echo "-> env image                       : ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"
	@echo "TEST_TAG_BUILD_CONTAINER_NAME      : $(TEST_TAG_BUILD_CONTAINER_NAME)"
	@echo ""

.PHONY: all
all: dockerTestRestartLatest

.PHONY: clean
clean: dockerTestPruneLatest

.PHONY: bakeCheckConfig
bakeCheckConfigImageBasic:
	$(info docker bake: image-basic-all)
	docker buildx bake --print image-basic-all

# .PHONY: bakeCheckConfig
# bakeCheckConfigImageAlpine:
# 	$(info docker bake: image-alpine-all)
# 	docker buildx bake --print image-alpine-all

.PHONY: bakeCheckConfig
bakeCheckConfigAll: bakeCheckConfigImageBasic

.PHONY: example.check
example.check: export ROOT_DOCKER_IMAGE_TAG=${ENV_DIST_VERSION}
example.check:
	@echo "=> Now run as docker-compose at folder ${TEST_TAG_EXAMPLE_PATH}"
	@echo "-> env TEST_TAG_BUILD_IMAGE_NAME=$(TEST_TAG_BUILD_IMAGE_NAME)"
	@echo "-> env ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION)"
	@echo "-> env image: ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"
	@echo "-> env container_name: TEST_TAG_BUILD_CONTAINER_NAME=$(TEST_TAG_BUILD_CONTAINER_NAME)"
	@echo "-> env ENV_DIST_VERSION=${ENV_DIST_VERSION}"
	@echo ""
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	docker-compose -p ${TEST_EXAMPLE_COMPOSE_PROJECT} config -q

.PHONY: example.run
example.run: export ROOT_DOCKER_IMAGE_TAG=${ENV_DIST_VERSION}
example.run: example.check
	@echo "=> Now run as docker-compose at folder ${TEST_TAG_EXAMPLE_PATH}"
	@echo "-> env TEST_TAG_BUILD_IMAGE_NAME=$(TEST_TAG_BUILD_IMAGE_NAME)"
	@echo "-> env ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION)"
	@echo "-> env image: ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"
	@echo "-> env container_name: TEST_TAG_BUILD_CONTAINER_NAME=$(TEST_TAG_BUILD_CONTAINER_NAME)"
	@echo "-> env ENV_DIST_VERSION=${ENV_DIST_VERSION}"
	@echo ""
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	docker-compose -p ${TEST_EXAMPLE_COMPOSE_PROJECT} up -d --remove-orphans
	-sleep 5
	@echo "=> container $(TEST_TAG_BUILD_CONTAINER_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(TEST_TAG_BUILD_CONTAINER_NAME)

.PHONY: example.logs
example.logs: export ROOT_DOCKER_IMAGE_TAG=${ENV_DIST_VERSION}
example.logs: example.check
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	docker-compose -p ${TEST_EXAMPLE_COMPOSE_PROJECT} logs

.PHONY: example.stop
example.stop: export ROOT_DOCKER_IMAGE_TAG=${ENV_DIST_VERSION}
example.stop: example.check
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	docker-compose -p ${TEST_EXAMPLE_COMPOSE_PROJECT} stop

.PHONY: example.down
example.down: export ROOT_DOCKER_IMAGE_TAG=${ENV_DIST_VERSION}
example.down:
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	docker-compose -p ${TEST_EXAMPLE_COMPOSE_PROJECT} down --remove-orphans

.PHONY: example.prune
example.prune: export ROOT_DOCKER_IMAGE_TAG=${ENV_DIST_VERSION}
example.prune:
	-cd ${TEST_TAG_EXAMPLE_PATH} && \
	docker-compose -p ${TEST_EXAMPLE_COMPOSE_PROJECT} rm
	@$(RM) -r ${TEST_TAG_EXAMPLE_PATH}/data

.PHONY: help
help: helpDocker
	@echo "Before run this project in docker must install docker"
