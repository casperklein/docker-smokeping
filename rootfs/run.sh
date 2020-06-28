#!/bin/bash

set -ueo pipefail

mkdir -p /var/lib/smokeping/__cgi

# directory empty? copy default config
if [ -z "$(ls -A /etc/smokeping/)" ]; then
	cp -a /etc/.smokeping/* /etc/smokeping/
fi

# start smokeping
supervisorctl start smokeping
