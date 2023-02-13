#!/bin/bash

set -ueo pipefail

# directory /etc/smokeping/ empty? copy default config
if [ -z "$(ls -A /etc/smokeping/)" ]; then
	cp -a /etc/.smokeping/* /etc/smokeping/
fi

# mkdir -p /var/lib/smokeping/__cgi

# directory /var/lib/smokeping/ empty? copy default data
if [ -z "$(ls -A /var/lib/smokeping/)" ]; then
	cp -a /var/lib/.smokeping/* /var/lib/smokeping/
fi

# start smokeping
supervisorctl start smokeping
