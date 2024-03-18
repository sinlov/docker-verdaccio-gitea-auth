.PHONY: test check clean dist

TOP_DIR := $(shell pwd)

ENV_DIST_VERSION=latest

ROOT_SWITCH_TAG :=5.23.2
ROOT_BUILD_OS :=alpine

ROOT_BUILD_FOLDER ?=build
ROOT_BUILD_PATH ?=${ROOT_BUILD_FOLDER}
ROOT_SCRIPT_FOLDER ?=dist
ROOT_LOG_PATH ?=./log
ROOT_DIST ?=./out

TEST_BUILD_PARENT_IMAGE ?=verdaccio/verdaccio:5.23.2
TEST_BUILD_PARENT_CONTAINNER ?=test-verdaccio-build
TEST_TAG_BUILD_IMAGE_NAME ?=sinlov/docker-verdaccio-gitea-auth
TEST_TAG_BUILD_CONTAINER_NAME ?=test-docker-verdaccio-gitea-auth
TEST_TAG_EXAMPLE_PATH =example

all: buildLatestAlpine

checkBuildPath:
	@if [ ! -d ${ROOT_BUILD_PATH} ]; then mkdir -p ${ROOT_BUILD_PATH} && echo "~> mkdir ${ROOT_BUILD_PATH}"; fi

checkDistPath:
	@if [ ! -d ${ROOT_DIST} ]; then mkdir -p ${ROOT_DIST} && echo "~> mkdir ${ROOT_DIST}"; fi

cleanBuild:
	@$(RM) -r ${ROOT_BUILD_PATH}
	@echo "~> finish clean path ${${ROOT_BUILD_PATH}}"

cleanLog:
	@$(RM) -r ${ROOT_LOG_PATH}
	@echo "~> finish clean path ${${ROOT_LOG_PATH}}"

cleanDist:
	@$(RM) -r ${ROOT_DIST}
	@echo "~> finish clean path ${${ROOT_DIST}}"

dockerCleanImages:
	(while :; do echo 'y'; sleep 3; done) | docker image prune

dockerPruneAll:
	(while :; do echo 'y'; sleep 3; done) | docker container prune
	(while :; do echo 'y'; sleep 3; done) | docker image prune

clean: cleanBuild cleanLog
	@echo "~> clean finish"

runContainerToTestBuild:
	@echo "run rm container image: ${TEST_BUILD_PARENT_IMAGE}"
	docker run -d --rm --name ${TEST_BUILD_PARENT_CONTAINNER} \
	--user root \
	${TEST_BUILD_PARENT_IMAGE}
	@echo ""
	@echo "run rm container name: ${TEST_BUILD_PARENT_CONTAINNER}"
	@echo "into container use:  docker exec -it ${TEST_BUILD_PARENT_CONTAINNER} sh"

rmContainerToTestBuild:
	-docker rm -f ${TEST_BUILD_PARENT_CONTAINNER}

pruneContainerToTestBuild: rmContainerToTestBuild
	-docker rmi -f ${TEST_BUILD_PARENT_IMAGE}

buildTestLatestAlpine: checkBuildPath
	docker build --tag ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION} .

runTestLatestAlpine:
	docker image inspect --format='{{ .Created}}' ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}
	docker run -d --name ${TEST_TAG_BUILD_CONTAINER_NAME} -p 4873:4873 ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}
	-docker inspect --format='{{ .State.Status}}' ${TEST_TAG_BUILD_CONTAINER_NAME}

logTestLatestAlpine:
	-docker logs ${TEST_TAG_BUILD_CONTAINER_NAME}

rmTestLatestAlpine:
	-docker rm -f ${TEST_TAG_BUILD_CONTAINER_NAME}

rmiTestLatestAlpine:
	-TEST_TAG_BUILD_CONTAINER_NAME=$(TEST_TAG_BUILD_CONTAINER_NAME) \
	TEST_TAG_BUILD_IMAGE_NAME=$(TEST_TAG_BUILD_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION) \
	ENV_DIST_VERSION=${ENV_DIST_VERSION} \
	docker rmi -f ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}

restartTestLatestAlpine: rmTestLatestAlpine rmiTestLatestAlpine buildTestLatestAlpine runTestLatestAlpine
	@echo "restrat $(TEST_TAG_BUILD_CONTAINER_NAM{}"

stopTestLatestAlpine: rmTestLatestAlpine rmiTestLatestAlpine
	@echo "stop and remove $(TEST_TAG_BUILD_CONTAINER_NAM{}"

exampleRun:
	@echo "=> Now run as docker-compose at folder ${TEST_TAG_EXAMPLE_PATH}"
	@echo "-> env TEST_TAG_BUILD_IMAGE_NAME=$(TEST_TAG_BUILD_IMAGE_NAME)"
	@echo "-> env ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION)"
	@echo "-> env image: ${TEST_TAG_BUILD_IMAGE_NAME}:${ENV_DIST_VERSION}"
	@echo "-> env container_name: TEST_TAG_BUILD_CONTAINER_NAME=$(TEST_TAG_BUILD_CONTAINER_NAME)"
	@echo "-> env ENV_DIST_VERSION=${ENV_DIST_VERSION}"
	@echo ""
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	TEST_TAG_BUILD_CONTAINER_NAME=$(TEST_TAG_BUILD_CONTAINER_NAME) \
	TEST_TAG_BUILD_IMAGE_NAME=$(TEST_TAG_BUILD_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION) \
	ENV_DIST_VERSION=${ENV_DIST_VERSION} \
	docker-compose up -d
	-sleep 5
	@echo "=> container $(TEST_TAG_BUILD_CONTAINER_NAME) now status"
	docker inspect --format='{{ .State.Status}}' $(TEST_TAG_BUILD_CONTAINER_NAME)

exampleStop:
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	TEST_TAG_BUILD_CONTAINER_NAME=$(TEST_TAG_BUILD_CONTAINER_NAME) \
	TEST_TAG_BUILD_IMAGE_NAME=$(TEST_TAG_BUILD_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION) \
	ENV_DIST_VERSION=${ENV_DIST_VERSION} \
	docker-compose stop

exampleRm:
	cd ${TEST_TAG_EXAMPLE_PATH} && \
	TEST_TAG_BUILD_CONTAINER_NAME=$(TEST_TAG_BUILD_CONTAINER_NAME) \
	TEST_TAG_BUILD_IMAGE_NAME=$(TEST_TAG_BUILD_IMAGE_NAME) \
	ROOT_DOCKER_IMAGE_TAG=$(ENV_DIST_VERSION) \
	ENV_DIST_VERSION=${ENV_DIST_VERSION} \
	docker-compose rm

examplePrune: exampleStop rmiTestLatestAlpine
	@echo "stop and remove path $(TEST_TAG_EXAMPLE_PATH)"

buildTag:
	cd ${ROOT_SCRIPT_FOLDER}/$(ROOT_SWITCH_TAG) && bash build-tag.sh

dockerRemoveBuild:
	-docker rmi -f $(TEST_TAG_BUILD_IMAGE_NAME):test-$(ROOT_SWITCH_TAG)

dockerBuild:
	cd ${ROOT_BUILD_OS} && docker build -t $(TEST_TAG_BUILD_IMAGE_NAME):test-$(ROOT_SWITCH_TAG) .
	docker run --rm --name ${TEST_TAG_BUILD_CONTAINER_NAME} $(TEST_TAG_BUILD_IMAGE_NAME):test-$(ROOT_SWITCH_TAG) --help

help:
	@echo "~> make dockerStop      - stop docker-compose container-name at $(TEST_TAG_BUILD_CONTAINER_NAME)"
	@echo "~> make dockerPrune     - stop docker-compose container-name at $(TEST_TAG_BUILD_CONTAINER_NAME) and try to remove"
	@echo "Before run this project in docker must use"
	@echo "~> make dockerLocalImageInit to init Docker image"
	@echo "or use"
	@echo "make all ~> fast build"
	@echo ""
	@echo "make clean - remove binary file and log files"
	@echo ""
	@echo "make buildLatestAlpine ~> build latest alpine"
	@echo "make buildTag ~> build tag as $(ROOT_SWITCH_TAG) $(ROOT_BUILD_OS)"
	@echo ""
	@echo "local test build use"
	@echo "make dockerRemoveBuild ~> remove $(TEST_TAG_BUILD_IMAGE_NAME):test-$(ROOT_SWITCH_TAG)"
	@echo "make dockerBuild ~> build $(TEST_TAG_BUILD_IMAGE_NAME):test-$(ROOT_SWITCH_TAG)"