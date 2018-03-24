# docker-ttrss

Docker image, based on [docker-ttrss by x86dev](https://github.com/x86dev/docker-ttrss).

This Dockerfile installs Tiny Tiny RSS (TT-RSS) with the following features:

- Based on [Docker-Alpine](https://github.com/gliderlabs/docker-alpine) and [s6](http://skarnet.org/software/s6/) as the supervisor
- Works nicely with jwilder's [nginx-proxy](https://github.com/jwilder/nginx-proxy), e.g. to use for Let's Encrypt SSL certificates
- Immutable Docker container: TTRSS version is pulled during Docker build and left untouched afterwards
- Theme and Plugin folder are exposed via Docker volume
- Daily job checks themes and plugins for .git folders - if present, tries to update


## Configuration

A ttrss configuration file is generated based on the following Docker
environment settings:

- DB_TYPE (mysql or pgsql)
- DB_HOST
- DB_PORT
- DB_NAME
- DB_USER
- DB_PASS
- BASE_URL

The configuration file is located in the exposed Docker volume.
If it already exists, it won't be touched, so you can add your own
modifications.

### Themes and plugins

Local themes and plugins are located in the Docker volume. An example
installation could look like:

- Change your directory to the volume
- Issue the commands:

```bash
git clone https://github.com/sepich/tt-rss-mobilize.git plugins/mobilize
git clone https://github.com/hrk/tt-rss-newsplus-plugin.git plugins/api_newsplus
git clone https://github.com/m42e/ttrss_plugin-feediron.git plugins/feediron
git clone https://github.com/levito/tt-rss-feedly-theme.git themes/feedly-git
```

## Accessing your Tiny Tiny RSS (TT-RSS)

The default login credentials are:

```bash
Username: admin
Password: password
```

Obviously, you're recommended to change those ASAP.


## Reverse proxy support

A nice thing to have is jwilder's [nginx-proxy](https://github.com/jwilder/nginx-proxy) as a separate
Docker container running on the same machine as this one.

That way you easily can integrate your TT-RSS instance with an existing domain by using a sub domain
(e.g. https://ttrss.yourdomain.tld). 

### Enabling SSL/TLS encryption support 

In combination with an official Let's Encrypt certificate you
can get a nice A+ encryption/security rating over at [SSLLabs](https://www.ssllabs.com/ssltest/).
