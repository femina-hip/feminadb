#!/bin/sh
#
# TODO comment all the other steps to creating a Google Cloud for FeminaDB.
#
# Things you'll need to do before this:
# 
# * Set up a static IP address on Google Cloud, in zone us-central1
# * Make `db.feminahip.or.tz` point to that IP address
# * Set up your SSH key in Google Cloud: go to
#   https://console.cloud.google.com/compute/metadata?project=feminadb
#   and add sshKeys lines "adam:[id_rsa.pub contents]" and
#   "rails:[id_rsa.pub contents]"

DIR="$(dirname "$0")"
IP_ADDRESS="$(host db.feminahip.or.tz | cut -d' ' -f4)"

gcloud compute instances create db2 \
  --zone us-central1-f \
  --image-project ubuntu-os-cloud \
  --image-family ubuntu-minimal-2004-lts \
  --machine-type g1-small \
  --address $IP_ADDRESS \
  --scopes storage-rw \
  --tags http-server,https-server \
  --metadata-from-file startup-script="$DIR"/gcloud-startup-script.sh

gcloud compute config-ssh

# Now log in to the new "db" server, and...
# * install rbenv for the "rails" user in /opt/rails/.rbenv...
# * `rbenv install [version in .ruby-version]`
# * copy the database over and set it up...
#    * mysql -u root
#        * `CREATE DATABASE feminadb;`
#        * `GRANT ALL PRIVILEGES ON feminadb.* TO 'feminadb'@'localhost' IDENTIFIED BY 'feminadb';`
#        * `zcat db.sql.gz | mysql -u feminadb feminadb -p`
# * bundle install (on a dev computer)
# * bin/cap production deploy
#   [2021-08-16, adamhooper] this failed until I logged in, made sure
#   `ssh rails@db.feminahip.or.tz bin/bash -c env` shows PATH starting with
#   "/opt/rails/.rbenv/bin", then logged in and ran
#   `cd /opt/rails/feminadb/releases/* && gem install bundler`
# * on the production computer, `/opt/rails/.rbenv/bin/rbenv exec ruby /opt/rails/feminadb/shared/bundle/ruby/*/gems/sunspot_solr-*/bin/sunspot-installer -fv /opt/rails/feminadb/shared/solr`
# * add feminadb.service and feminadb-index.service to /etc/systemd/system, and start them
# * bin/cap production reindex
# You should be able to `curl localhost:3000` now.
#
# Haproxy:
# * copy doc/haproxy/* into `/etc/haproxy/` on the production server.
# * sudo service haproxy reload
# * sudo snap install --classic certbot  # https://certbot.eff.org/lets-encrypt/ubuntufocal-haproxy
# * sudo certbot certonly --standalone to generate cert
# * cat /etc/letsencrypt/live/db.feminahip.or.tz/{fullchain,privkey}.pem > /etc/haproxy/ssl.pem
# * copy doc/config/cert-renew.sh to /opt/rails/; chmod +x
# * `crontab -e` as root and add `0 0 * * * /opt/rails/cert-renew.sh`
#
# Finally, BACKUPS!
# =================
#
# Create a bucket, feminadb-backups.
# Create /opt/rails/backup.sh, chmod +x, owned by rails
# Log in as `rails@db.feminahip.or.tz`, run `crontab -e` and add this line:
#
# 0 0 * * * /opt/rails/backup.sh
