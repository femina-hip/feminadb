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
# * copy the database over and set it up...
# * bundle install (on a dev computer)
# * cap production deploy
# * add feminadb.service and feminadb-index.service to /etc/systemd/system, and start them
# * copy haproxy.cfg and ssl.pem into /etc/haproxy/, and systemctl start haproxy
# * deploy with Capistrano...
# * reindex...
#
# Finally, BACKUPS!
# =================
#
# Create a bucket, feminadb-backups
# Log in as `rails@db.feminahip.or.tz`, run `crontab -e` and add this line:
#
# 0 0 * * * mysqldump -u feminadb --password=feminadb feminadb | gzip - | gsutil -q cp - "gs://feminadb-backups/feminadb-$(date '+%Y-%m-%d_%H:%M').sql.gz"
