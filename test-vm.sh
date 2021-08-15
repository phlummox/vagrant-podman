#!/usr/bin/env bash

# script to test podman box
# Prerequisites:
# - vagrant, qemu, podman, goss

set -euo pipefail
set -x

vagrant box remove vpodman || true

vagrant box add --name vpodman --provider libvirt \
  output/podman_0.0.1.box

tmpdir=$(mktemp --tmpdir -d packer-test-XXXXXX)

cd "$tmpdir"

# if running on a CI server (probably GitHub) --
# assume we don't have kvm acceleration and must
# use the slower but more general qemu driver.
# Else assume we have access to kvm.

# if not defined, initialized to empty string
CI=${CI:-}

# if empty string, use qemu
if [ -z "$CI" ]; then
  LIBVIRT_DRIVER=kvm;
else
  LIBVIRT_DRIVER=qemu;
fi

cat > Vagrantfile <<EOF
Vagrant.configure("2") do |config|
  config.vm.box = "vpodman"
  config.vm.provider :libvirt do |lv|
    lv.driver = '$LIBVIRT_DRIVER'
  end

  # on github's CI guest instances, at least, need to listen on 0.0.0.0
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "0.0.0.0"

  config.vm.provision "shell", inline: <<-SHELL
    rc-update add podman-rootless
    rc-service podman-rootless start
  SHELL
end
EOF

# show conts

grep -n ^ /dev/null Vagrantfile

# bring up

vagrant up --provider libvirt

# check running instance

vagrant ssh -- ps -aef | grep podman

cat > goss.yaml <<EOF
port:
  tcp:3000:
    listening: true
    ip:
    - 0.0.0.0
EOF

# see if port 3000 is up - try for 30s
goss validate --retry-timeout 30s --sleep 1s

# not needed, since we forward port 3000:
#
# get IP addr of box
#vagrant_ip_addr=$(vagrant ssh-config | grep HostName | awk '{print $2; }')

# Vagrantfile for "nested" vm
# to bring up.

# Test -
# can we connect to podman running in box?

podman-remote --url tcp://localhost:3000 ps -a


