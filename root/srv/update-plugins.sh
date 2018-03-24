#!/bin/sh

while true ; do
  for DIR in /var/www/ttrss/docker/plugins /var/www/ttrss/docker/plugins/themes ; do
    for SUBDIR in $DIR/* ; do
      if [ -d "$SUBDIR/.git" ] ; then
        cd "$SUBDIR"
        git pull
      fi
    done
  done
  sleep 24h
done

