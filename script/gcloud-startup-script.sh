#!/bin/sh
#
# This script is executed by root when launching a new machine on Google Cloud.
# To actually launch a machine, use `launch-google-cloud-instance.sh`.

apt-get -yy -q update

apt-get -yy -q install \
  build-essential \
  bundler \
  certbot \
  cron \
  git \
  haproxy \
  libcurl4-openssl-dev \
  libmariadb-dev \
  libssl-dev \
  mariadb-client \
  mariadb-server \
  nodejs \
  openjdk-8-jre-headless \
  zlib1g-dev

useradd -d /opt/rails -m -U -r rails -s /bin/bash
