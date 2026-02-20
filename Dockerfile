FROM	debian:13-slim AS build

ARG	SV_VERSION=0.14
ARG	YQ_VERSION=v4.52.4
ARG	PACKAGES="apache2 smokeping dumb-init iputils-ping curl"
ARG	DEBIAN_FRONTEND="noninteractive"
ARG	TARGETARCH

SHELL	["/bin/bash", "-e", "-c"]

# Upgrade base image and install packages
RUN <<EOF
	apt-get update
	apt-get -y upgrade
	apt-get -y --no-install-recommends install $PACKAGES
	rm -rf /var/lib/apt/lists/*
EOF

# Copy root filesystem
COPY	rootfs /

# Install yq
RUN <<EOF
	curl -sSLf -o /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$TARGETARCH"
	chmod +x /usr/bin/yq

	# Test binary
	yq --version
EOF

# Install supervisor.sh
RUN <<EOF
	curl -sSLf -o /usr/bin/supervisor.sh "https://raw.githubusercontent.com/casperklein/supervisor.sh/refs/tags/$SV_VERSION/supervisor.sh"
	chmod +x /usr/bin/supervisor.sh
	supervisor.sh --config /etc/supervisor.yaml convert

	mkdir -p /etc/bash_completion.d
	curl -sSLf -o /etc/bash_completion.d/supervisor-completion.bash "https://raw.githubusercontent.com/casperklein/supervisor.sh/refs/tags/$SV_VERSION/supervisor-completion.bash"
	echo "source /etc/bash_completion.d/supervisor-completion.bash" >> /etc/bash.bashrc
EOF

# Redirect / to /smokeping/
RUN <<EOF
	a2enmod rewrite
	sedfile -i 's|</VirtualHost>|RewriteEngine On\nRewriteRule ^/$ /smokeping/ [R=301]\n</VirtualHost>|' /etc/apache2/sites-available/000-default.conf
EOF

# Backup default config
RUN <<EOF
	cp -a /etc/smokeping /etc/.smokeping
	cp -a /var/lib/smokeping /var/lib/.smokeping
EOF

# Move directories
RUN <<EOF
	mv /etc/smokeping     /config
	mv /var/lib/smokeping /data

	ln -s /config /etc/smokeping
	ln -s /data   /var/lib/smokeping
EOF

# Needed for smokeping startup
RUN	mkdir /var/run/smokeping

# Disable access logging
RUN <<EOF
	a2disconf other-vhosts-access-log
	sedfile -i 's|^\s*CustomLog|#&|' /etc/apache2/sites-enabled/000-default.conf
EOF

# Clean up
RUN <<EOF
	apt-get -y purge curl
	apt-get -y autoremove

	rm /usr/bin/sedfile /usr/bin/yq
EOF

# Build final image
FROM	scratch

ARG	VERSION="unknown"

LABEL	org.opencontainers.image.description="Yet another containerized smokeping :)"
LABEL	org.opencontainers.image.source="https://github.com/casperklein/docker-smokeping/"
LABEL	org.opencontainers.image.title="docker-smokeping"
LABEL	org.opencontainers.image.version="$VERSION"

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD	["/usr/bin/supervisor.sh", "--config", "/etc/supervisor.yaml.sh"]

EXPOSE	80

COPY	--from=build / /
