# docker-smokeping

![Version][version-shield]
![Supports amd64 architecture][amd64-shield]
![Supports aarch64 architecture][aarch64-shield]
![Supports armhf architecture][armhf-shield]
![Supports armv7 architecture][armv7-shield]
![Docker image size][image-size-shield]

Yet another containerized smokeping :)

## Setup

Adjust `docker-compose.yml` to your needs.
When you start the container and the mounted host directory `./config` is empty (on first start), the smokeping default configuration is copied.

If you change your Smokeping targets (`./config/config.d/Targets`) or something else, don't forget to restart the container.

## Start

    docker-compose up -d

## Stop

    docker-compose down

## Update

1. `docker-compose down`
1. `docker-compose pull`
1. `docker-compose up`

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-blue.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-blue.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-blue.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-blue.svg
[version-shield]: https://img.shields.io/github/v/release/casperklein/docker-smokeping
[image-size-shield]: https://img.shields.io/docker/image-size/casperklein/smokeping/latest
