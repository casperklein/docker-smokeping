# docker-smokeping

![Version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Docker image size][image-size-shield]

Yet another containerized smokeping :)

## Setup

Adjust `docker-compose.yml` to your needs.
When you start the container and the mounted host directory `./config` is empty (on first start), smokeping's default configuration is copied.

If you change your Smokeping targets (`./config/config.d/Targets`) or something else, don't forget to restart the container.

## Start

    docker compose up -d

## Stop

    docker compose down

## Update

1. `docker compose pull`
2. `docker compose up --force-recreate`

## Smokeping Web UI

Open `http://hostname/` in a browser.

[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[version-shield]: https://img.shields.io/github/v/release/casperklein/docker-smokeping
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/smokeping/latest
