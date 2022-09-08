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
      openssh-client \
      procps \
      python \
      python-dev \
      rsync \
      sudo \
      zip \
      unzip \
      zip \
      zlib1g-dev \
      libgtk2.0-0 libgtk-3-0 libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb \
      && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
      && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
      && apt-get update \
      && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
      && ACCEPT_EULA=Y apt-get install -y mssql-tools18 \
      && apt-get install -yq \
      unixodbc-dev \
      && rm -rf /var/lib/apt/lists/*
