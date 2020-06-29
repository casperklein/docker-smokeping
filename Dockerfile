FROM	debian:10-slim as build

ENV	USER="casperklein"
ENV	NAME="smokeping"
ENV	VERSION="0.1.1"

ENV	PACKAGES="apache2 smokeping supervisor patch"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade base image and install packages
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES

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
COPY	--from=build / /

EXPOSE	80
#HEALTHCHECK --retries=1 CMD bash -c "</dev/tcp/localhost/80"

CMD	["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
