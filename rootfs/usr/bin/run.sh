#!/bin/bash

set -ueo pipefail

# directory /etc/smokeping/ empty? copy default config
if [ -z "$(ls -A /etc/smokeping/)" ]; then
	echo "Empty /config mount detected. Copying default configuration.."
	cp -a /etc/.smokeping/* /etc/smokeping/
fi

# mkdir -p /var/lib/smokeping/__cgi

# directory /var/lib/smokeping/ empty? copy default data
if [ -z "$(ls -A /var/lib/smokeping/)" ]; then
	echo "Empty /data mount detected. Copying default data.."
	cp -a /var/lib/.smokeping/* /var/lib/smokeping/
fi

# start smokeping
exec supervisor.sh --config /etc/supervisor.yaml.sh start smokeping > /dev/null
