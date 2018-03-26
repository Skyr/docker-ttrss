# docker-ttrss

[This Docker image](https://hub.docker.com/r/skyr0/ttrss/) installs
[Tiny Tiny RSS (TT-RSS)](https://tt-rss.org/) with the following features:

- Based on [Docker-Alpine](https://github.com/gliderlabs/docker-alpine) and [s6](http://skarnet.org/software/s6/) as the supervisor
- Works nicely with jwilder's [nginx-proxy](https://github.com/jwilder/nginx-proxy), e.g. to use for Let's Encrypt SSL certificates
- Immutable Docker container: TTRSS version is pulled during Docker build and left untouched afterwards
- Theme and Plugin folder are exposed via Docker volume
- Daily job checks themes and plugins for .git folders - if present, tries to update

This Docker image is based on [docker-ttrss by x86dev](https://github.com/x86dev/docker-ttrss).


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
modifications. Additionally, on each container start a template
configuration file is placed in your volume - so you always have
a fresh template in case of config file changes (which can happen
if you pull/update the "latest" label).

### Image labels

The label of the published image is equal to the config version number.
This means that if you pull the image using a number (and not just "latest"),
your configuration will never break on image updates. Due to the rolling
release approach of tt-rss, your installation will just stop updating if
the config version number changes.

### Docker volume: Config, themes and plugins

Your config, local themes and plugins are located in the Docker volume.
The config file resides in the root of the volume, themes and plugins reside
in the subdirectories `themes` and `plugins` respectively.

If you want to get the same themes/plugins that are bundled in the Docker
image of x86dev, do the following:

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

In combination with an official Let's Encrypt certificate you
can get a nice A+ encryption/security rating over at [SSLLabs](https://www.ssllabs.com/ssltest/).
