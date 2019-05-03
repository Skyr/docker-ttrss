# Using https://github.com/gliderlabs/docker-alpine,
# plus  https://github.com/just-containers/s6-overlay for a s6 Docker overlay.
# alpine 3.8 php is currently broken: https://bugs.alpinelinux.org/issues/9237
FROM alpine:edge
# Initially was based on work of Christian Lück <christian@lueck.tv>.
LABEL description="A self-hosted Tiny Tiny RSS (TTRSS) environment." \
      maintainer="Stefan Schlott <stefan@ploing.de>"

# Expose Nginx ports.
EXPOSE 8080

# Expose default database credentials via ENV
ENV DB_HOST ttrssdb
ENV DB_PORT 3306
ENV DB_TYPE mysql
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss
ENV BASE_URL http://localhost:8080/

# Expose volumes
VOLUME [ "/var/www/ttrss/docker" ]

# Add s6 overlay.
RUN cd /var/tmp && \
  wget -q https://github.com/just-containers/s6-overlay/releases/download/v1.21.7.0/s6-overlay-amd64.tar.gz && \
  tar xzf s6-overlay-amd64.tar.gz -C /  && rm s6-overlay-amd64.tar.gz

# Install dependencies
RUN set -xe && \
    apk update && apk upgrade && \
    apk add --no-cache --virtual=run-deps \
    nginx git ca-certificates \
    py-setuptools \
    php7-fpm php7-cli php7-curl php7-dom php7-gd php7-json php7-mcrypt php7-pcntl php7-iconv \
    php7-pdo php7-pdo_mysql php7-mysqli php7-pgsql php7-pdo_pgsql php7-posix php7-intl \
    php7-mbstring php7-fileinfo php7-session && \
    apk del --progress --purge && \
    rm -rf /var/cache/apk/*
RUN easy_install-2.7 j2cli
# RUN ln -s /usr/bin/php7 /usr/bin/php && \
RUN ln -s /usr/sbin/php-fpm7 /usr/bin/php-fpm

# Add user www-data for php-fpm.
# 82 is the standard uid/gid for "www-data" in Alpine.
RUN adduser -u 82 -D -S -G www-data www-data

# Fetch ttrss
ENV ttrss_rev ae376bdfbf96242a3b0df13f6c26a0785da573fe
RUN mkdir -p /var/www/ttrss && \
  cd /var/www/ttrss && \
  git init . && \
  git fetch --depth=1 https://tt-rss.org/gitlab/fox/tt-rss.git ${ttrss_rev}:refs/remotes/origin/dockerrev && \
  git checkout -b dockerrev origin/dockerrev

RUN cd /var/www/ttrss && \
  rm -rf .git themes.local plugins.local && \
  ln -s /var/www/ttrss/docker/themes themes.local && \
  ln -s /var/www/ttrss/docker/plugins plugins.local && \
  ln -s /var/www/ttrss/docker/config.php config.php && \
  chown -R www-data:www-data /var/www/ttrss/cache /var/www/ttrss/lock /var/www/ttrss/feed-icons

# Copy root file system.
COPY root /

HEALTHCHECK --interval=1m --timeout=10s --start-period=1m \
  CMD wget -q -O - http://127.0.0.1:8080/ > /dev/null 2>&1

ENTRYPOINT ["/init"]
