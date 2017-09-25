#!/bin/sh
#
# This script is executed by root when launching a new machine on Google Cloud.
# To actually launch a machine, use `launch-google-cloud-instance.sh`.

apt-get -yy -q update

apt-get -yy -q install \
  build-essential \
  bundler \
  git \
  haproxy \
  letsencrypt \
  libcurl4-openssl-dev \
  libmariadb-client-lgpl-dev \
  libssl-dev \
  mariadb-client \
  mariadb-server \
  nodejs \
  nodejs-legacy \
  openjdk-8-jre-headless \
  ruby \
  ruby-dev \
  ruby-passenger \
  zlib1g-dev

useradd -d /opt/rails -m -U -r rails
