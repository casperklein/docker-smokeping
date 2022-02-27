FROM	debian:11-slim as build

ENV	PACKAGES="apache2 smokeping supervisor dumb-init iputils-ping"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade base image and install packages
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Change supervisord defaults
# Fix for: CRIT Supervisor is running as root. Privileges were not dropped because no user is specified in the config file.
RUN	sed -i 's|\[supervisord\]|[supervisord]\nuser=root|'				/etc/supervisor/supervisord.conf \
# Fix for: CRIT Server 'unix_http_server' running without any HTTP authentication checking.
&&	sed -i 's|\[unix_http_server\]|[unix_http_server]\nusername=foo\npassword=foo|'	/etc/supervisor/supervisord.conf \
&&	sed -i 's|\[supervisorctl\]|[supervisorctl]\nusername=foo\npassword=foo|'	/etc/supervisor/supervisord.conf

# Copy root filesystem
COPY	rootfs /

# Backup default config
RUN	cp -a /etc/smokeping /etc/.smokeping

# Move directorys
RUN	mv /etc/smokeping /config	&& ln -s /config /etc/smokeping
RUN	mv /var/lib/smokeping /data	&& ln -s /data /var/lib/smokeping

# Create directory needed for smokeping startup
RUN	mkdir /var/run/smokeping

# Build final image
FROM	scratch

ARG	VERSION
LABEL	Version=$VERSION

ENTRYPOINT ["dumb-init", "--"]
CMD	["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE	80

COPY	--from=build / /
