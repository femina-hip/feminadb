#!/bin/sh
#
# TODO comment all the other steps to creating a Google Cloud for FeminaDB.
#
# Things you'll need to do before this:
# 
# * Set up a static IP address on Google Cloud, in zone us-central1
# * Make `db.feminahip.or.tz` point to that IP address
# * Set up your SSH key in Google Cloud

DIR="$(dirname "$0")"
IP_ADDRESS="$(host db.feminahip.or.tz | cut -d' ' -f4)"

gcloud compute instances create db \
  --zone us-central1-f \
  --image ubuntu-15-04 \
  --machine-type g1-small \
  --address $IP_ADDRESS \
  --scopes storage-rw \
  --tags http-server,https-server \
  --metadata-from-file startup-script="$DIR"/gcloud-startup-script.sh

gcloud compute config-ssh

# Now log in to the new "db" server, and...
# * copy ~/.ssh to /opt/rails/.ssh so you can SSH to "rails"
# * install rbenv for the "rails" user in /opt/rails
# * copy the database over and set it up...
# * bundle install (on a dev computer)
# * bin/cap production deploy
# * on the production computer, `/opt/rails/.rbenv/bin/rbenv exec ruby /opt/rails/feminadb/shared/bundle/ruby/2.4.0/gems/sunspot_solr-2.2.7/bin/sunspot-installer -fv /opt/rails/feminadb/shared/solr`
# * bin/cap production reindex
# * add feminadb.service and feminadb-index.service to /etc/systemd/system, and start them
# You should be able to `curl localhost:3000` now.
#
# Haproxy:
# * copy doc/haproxy/* into `/etc/haproxy/` on the production server.
# * sudo service haproxy reload
# * Follow instructions at https://github.com/janeczku/haproxy-acme-validation-plugin#3-issue-certificate:
#   * sudo letsencrypt certonly --text --webroot --webroot-path /var/lib/haproxy -d db.feminahip.or.tz --renew-by-default --agree-tos --email adam@adamhooper.com
#   * sudo cat /etc/letsencrypt/live/db.feminahip.or.tz/privkey.pem /etc/letsencrypt/live/db.feminahip.or.tz/fullchain.pem | sudo tee /etc/letsencrypt/live/db.feminahip.or.tz/haproxy.pem >/dev/null
#   * sudo service haproxy reload
#   * cp doc/haproxy/cert-renewal-haproxy.sh /etc/cron.daily/
#
# Finally, BACKUPS!
# =================
#
# Create a bucket, feminadb-backups
# Log in as `rails@db.feminahip.or.tz`, run `crontab -e` and add this line:
#
# 0 0 * * * mysqldump -u feminadb --password=feminadb feminadb | gzip - | gsutil -q cp - "gs://feminadb-backups/feminadb-$(date '+%Y-%m-%d_%H:%M').sql.gz"
