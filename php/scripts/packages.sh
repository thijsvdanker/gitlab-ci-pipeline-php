#!/usr/bin/env bash

set -euo pipefail

############################################################
# Speedup DPKG and don't use cache for packages
############################################################
# Taken from here: https://gist.github.com/kwk/55bb5b6a4b7457bef38d
#
# this forces dpkg not to call sync() after package extraction and speeds up
# install
echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
# we don't need and apt cache in a container
echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf
export DEBIAN_FRONTEND=noninteractive

  dpkg-reconfigure -f noninteractive tzdata \
  && apt-get update \
  && apt-get install -yq \
      apt-transport-https \
      apt-utils \
      ca-certificates \
  && apt-get install -yq \
      build-essential \
      curl \
      git \
      gnupg2 \
      jq \
      libc-client-dev \
      mariadb-client \
      mongo-tools \
      openssh-client \
      python \
      python-dev \
      rsync \
      sudo \
      unzip \
      zip \
      zlib1g-dev \
      && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
      && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
      && apt-get update \
      && apt-get install -yq \
      unixodbc-dev \
      && rm -rf /var/lib/apt/lists/*
