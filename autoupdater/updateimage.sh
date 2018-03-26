#!/bin/bash
set -e
cd `dirname $0`

# Pull repos
git pull -a
if [[ -d tt-rss ]] ; then
  pushd tt-rss >/dev/null
  git pull -a
  popd >/dev/null
else
  git clone https://git.tt-rss.org/fox/tt-rss.git -q
fi

# Get revisions
CURRENT_DOCKER_REV=`git log -n 1 --format="%H"`
CURRENT_TTRSS_REV=`cd tt-rss ; git log -n 1 --format="%H"`

# Get old revisions
if [[ -f lastupdate.sh ]] ; then
  . ./lastupdate.sh
fi

# Update necessary?
if [[ "$DOCKER_REV" == "$CURRENT_DOCKER_REV" && "$TTRSS_REV" == "$CURRENT_TTRSS_REV" ]] ; then
  exit 0
fi

# Get config version (will be the Docker label)
CFG_VERSION=`grep CONFIG_VERSION tt-rss/config.php-dist | sed "s/^.*, *\([0-9]*\).*$/\1/"`

# Update git rev in Dockerfile
sed -i "s/ENV ttrss_rev .*$/ENV ttrss_rev $CURRENT_TTRSS_REV/" ../Dockerfile
git add ../Dockerfile
git commit -m "Bump ttrss git rev" -q || true
CURRENT_DOCKER_REV=`git log -n 1 --format="%H"`

# Build and push Docker
pushd .. > /dev/null
docker build  -t skyr0/ttrss:latest -t skyr0/ttrss:$CFG_VERSION .
docker push skyr0/ttrss:$CFG_VERSION
docker push skyr0/ttrss:latest
popd > /dev/null

# Update data
echo "DOCKER_REV=$CURRENT_DOCKER_REV" > lastupdate.sh
echo "TTRSS_REV=$CURRENT_TTRSS_REV" >> lastupdate.sh

