# all targets are phony (no files to check)
.PHONY: default build clean start stop restart update pull push

SHELL = /bin/bash

IMAGE := $(shell jq -er '.image' < config.json)
TAG := $(shell jq -er '"\(.image):\(.version)"' < config.json)

default: build

build:
	@if [ -f build-squash.sh ]; then \
		./build-squash.sh;       \
	else                             \
		./build.sh;              \
	fi

clean:
	@echo "Removing Docker images.."
	docker rmi "$(TAG)"; \
	docker rmi "$(IMAGE):latest"

start:
	@docker compose up -d

stop:
	@docker compose down || true

restart: stop start

update:	pull restart

pull:
	@docker compose pull

push:
	@echo "Pushing image to Docker Hub.."
	docker push "$(TAG)"
	docker push "$(IMAGE):latest"
