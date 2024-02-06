ARG ALPINE_VERSION=3.19.1
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="supppig <supppig@163.com>"
LABEL Description="Lightweight container with Nginx 1.24 & PHP 8.3 based on Alpine Linux."
# Setup document root

ENV FTP_USER=foo \
	FTP_PASS=bar \
	GID=1000 \
	UID=1000

WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  php83 \
  php83-ctype \
  php83-curl \
  php83-dom \
  php83-fileinfo \
  php83-fpm \
  php83-gd \
  php83-intl \
  php83-mbstring \
  php83-mysqli \
  php83-opcache \
  php83-openssl \
  php83-phar \
  php83-session \
  php83-tokenizer \
  php83-xml \
  php83-xmlreader \
  php83-xmlwriter \
  supervisor \
  vsftpd==3.0.5-r2

# ftp
COPY [ "/ftp/vsftpd.conf", "/etc" ]

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
ENV PHP_INI_DIR /etc/php83
COPY config/fpm-pool.conf ${PHP_INI_DIR}/php-fpm.d/www.conf
COPY config/php.ini ${PHP_INI_DIR}/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html /run /var/lib/nginx /var/log/nginx

COPY /docker-entrypoint.sh /docker-entrypoint.sh

# Create symlink for php
RUN ln -s /usr/bin/php83 /usr/bin/php

# Switch to use a non-root user from here on
USER nobody

# Add application
# COPY --chown=nobody src/ /var/www/html/
COPY src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080
# ftp
EXPOSE 8095-8099/tcp

# Let supervisord start nginx & php-fpm
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
ENTRYPOINT [ "/docker-entrypoint.sh" ]


# Configure a healthcheck to validate that everything is up&running
# HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

