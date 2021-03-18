FROM	debian:10-slim as build

ENV	PACKAGES="apache2 smokeping supervisor patch dumb-init"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade base image and install packages
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY	rootfs /

# Backup default config
RUN	cp -a /etc/smokeping /etc/.smokeping

# Move directorys
RUN	mv /etc/smokeping /config	&& ln -s /config /etc/smokeping
RUN	mv /var/lib/smokeping /data	&& ln -s /data /var/lib/smokeping

# Create directory needed for smokeping startup
RUN	mkdir /var/run/smokeping

# Patch smokeping (got already fixed, but no new release yet --> https://github.com/oetiker/SmokePing/issues/183#issuecomment-533722180)
RUN	patch -i /Smokeping.pm.patch /usr/share/perl5/Smokeping.pm

# Build final image
FROM	scratch

EXPOSE	80

ENTRYPOINT ["dumb-init", "--"]
CMD	["supervisord", "-n"]

COPY	--from=build / /
