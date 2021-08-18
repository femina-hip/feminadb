#!/bin/sh

/usr/bin/mysqldump -u feminadb --password=feminadb feminadb \
  | /bin/gzip - \
  | /usr/bin/gsutil -q cp - "gs://feminadb-backups/feminadb-$(date '+%Y-%m-%dT%H:%MZ').sql.gz"
