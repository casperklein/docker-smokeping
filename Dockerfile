FROM	debian:12-slim as build

ARG	PACKAGES="apache2 smokeping supervisor dumb-init iputils-ping"

SHELL	["/bin/bash", "-o", "pipefail", "-c"]

# Upgrade base image and install packages
RUN	apt-get update \
&&	apt-get -y upgrade \
&&	apt-get -y --no-install-recommends install $PACKAGES \
&&	rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY	rootfs /

# Change supervisord defaults
# Fix for: CRIT Supervisor is running as root. Privileges were not dropped because no user is specified in the config file.
RUN	sedfile -i 's|\[supervisord\]|[supervisord]\nuser=root|'                            /etc/supervisor/supervisord.conf \
# Fix for: CRIT Server 'unix_http_server' running without any HTTP authentication checking.
&&	sedfile -i 's|\[unix_http_server\]|[unix_http_server]\nusername=foo\npassword=foo|' /etc/supervisor/supervisord.conf \
&&	sedfile -i 's|\[supervisorctl\]|[supervisorctl]\nusername=foo\npassword=foo|'       /etc/supervisor/supervisord.conf

# Redirect / to /smokeping/
RUN	a2enmod rewrite \
&&	sedfile -i 's|</VirtualHost>|RewriteEngine On\nRewriteRule ^/$ /smokeping/ [R=301]\n</VirtualHost>|' /etc/apache2/sites-available/000-default.conf

RUN	rm /bin/sedfile

# Backup default config
RUN	cp -a /etc/smokeping /etc/.smokeping
RUN	cp -a /var/lib/smokeping /var/lib/.smokeping

# Move directorys
RUN	mv /etc/smokeping /config	&& ln -s /config /etc/smokeping
RUN	mv /var/lib/smokeping /data	&& ln -s /data /var/lib/smokeping

# Create directory needed for smokeping startup
RUN	mkdir /var/run/smokeping

# Build final image
FROM	scratch

ARG	VERSION="unknown"

LABEL	org.opencontainers.image.description="Yet another containerized smokeping :)"
LABEL	org.opencontainers.image.source="https://github.com/casperklein/docker-smokeping/"
LABEL	org.opencontainers.image.title="docker-smokeping"
LABEL	org.opencontainers.image.version="$VERSION"

ENTRYPOINT ["dumb-init", "--"]
CMD	["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

EXPOSE	80

COPY	--from=build / /
