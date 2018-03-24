# Using https://github.com/gliderlabs/docker-alpine,
# plus  https://github.com/just-containers/s6-overlay for a s6 Docker overlay.
FROM alpine:3.7
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
  wget -q https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz && \
  tar xzf s6-overlay-amd64.tar.gz -C /  && rm s6-overlay-amd64.tar.gz

# Install dependencies
RUN set -xe && \
    apk update && apk upgrade && \
    apk add --no-cache --virtual=run-deps \
    nginx git ca-certificates \
    py-setuptools \
    php5 php5-fpm php5-curl php5-dom php5-gd php5-json php5-mcrypt php5-pcntl php5-iconv \
    php5-pdo php5-pdo_pgsql php5-pgsql php5-pdo_mysql php5-mysql php5-mysqli php5-posix && \
    apk del --progress --purge && \
    rm -rf /var/cache/apk/*
RUN easy_install-2.7 j2cli

# Add user www-data for php-fpm.
# 82 is the standard uid/gid for "www-data" in Alpine.
RUN adduser -u 82 -D -S -G www-data www-data

# Fetch ttrss
ENV ttrss_rev 4fa64e8446563a89f04badfdfecc8a57750c083d
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

ENTRYPOINT ["/init"]
