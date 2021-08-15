#!/usr/bin/env sh

# script to provision podman vm

set -eu
set -x

sudo apk add \
  bridge-utils  \
  docker        \
  podman        \
  podman-remote \
  procps        \
  shadow

sudo usermod --add-subuids 100000-165535 vagrant
sudo usermod --add-subgids 100000-165535 vagrant

sudo modprobe fuse
sudo modprobe tun

sudo rc-update add cgroups
sudo rc-service cgroups start
sudo rc-service docker start

sudo cp /tmp/podman-rootless /etc/init.d
sudo chmod a+rx /etc/init.d/podman-rootless

