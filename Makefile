# all targets are phony (no files to check)
.PHONY: default build clean start stop restart push

SHELL = /bin/bash

USER := $(shell grep -P 'ENV\s+USER=".+?"' Dockerfile | cut -d'"' -f2)
NAME := $(shell grep -P 'ENV\s+NAME=".+?"' Dockerfile | cut -d'"' -f2)
VERSION := $(shell grep -P 'ENV\s+VERSION=".+?"' Dockerfile | cut -d'"' -f2)

default: build

build:
	@./build.sh

clean:
	@echo "Removing Docker images.."
	docker rmi "$(USER)/$(NAME):$(VERSION)"; \
	docker rmi "$(USER)/$(NAME):latest"

start:
	@docker-compose up -d

stop:
	@docker-compose down

restart: stop start

push:
	@echo "Pushing image to Docker Hub.."
	docker push "$(USER)/$(NAME):$(VERSION)"
	docker push "$(USER)/$(NAME):latest"
