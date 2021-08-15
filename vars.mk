
# version being built

BOX_VERSION=0.0.1

# packer config file to use
PACKER_FILE=podman.pkr.hcl

# input box to use
BASE_BOX_NAME=alpine314
BASE_BOX=generic/$(BASE_BOX_NAME)
BASE_BOX_VERSION=3.3.4
ALPINE_BOX_PATH=$(HOME)/.vagrant.d/boxes/generic-VAGRANTSLASH-$(BASE_BOX_NAME)/$(BASE_BOX_VERSION)/libvirt/box.img

# name for our built box
BOX_NAME=podman

