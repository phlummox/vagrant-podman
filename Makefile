
.PHONY: packer-build clean print_img_path print_box_name
.DELETE_ON_ERROR:

SHELL=bash

include vars.mk

print_img_path:
	@echo $(ALPINE_BOX_PATH)

print_box_name:
	@echo $(BOX_NAME)

print_box_version:
	@echo $(BOX_VERSION)

$(ALPINE_BOX_PATH):
	vagrant box add \
	  --provider libvirt \
	  --box-version $(BASE_BOX_VERSION) \
	  $(BASE_BOX)

.img_checksum.md5: $(ALPINE_BOX_PATH)
	set -euo pipefail;  \
	set -vx; \
	cat $(ALPINE_BOX_PATH) | pv | md5sum | awk '{ print $$1; }' > $@


# to work out the disk size:
# we need to run `qemu-img info /path/to/box.img`,
# and look for a line in the output that says:
#     virtual size: 128G (137438953472 bytes)
# or similar.

packer-build: output/podman_0.0.1.box.md5 \
	            output/podman_0.0.1.box \
	            output/podman_0.0.1.qcow2

packer-test: packer-build
	./test-vm.sh


output/podman_0.0.1.box.md5 \
output/podman_0.0.1.box \
output/podman_0.0.1.qcow2: $(ALPINE_BOX_PATH) \
	                .img_checksum.md5
	@if [ ! -f $(ALPINE_BOX_PATH) ]; then \
	  printf 'no box.img found at %s!\n' $(ALPINE_BOX_PATH); \
	  exit 1; \
	fi
	set -ex; \
	export PKR_VAR_ALPINE_IMG_PATH=$(ALPINE_BOX_PATH); \
	export PKR_VAR_DISK_SIZE=`qemu-img info $(ALPINE_BOX_PATH) | grep '^virtual size' | sed 's/(//g' | awk '{ print $$4; }'`; \
	export PKR_VAR_DISK_CHECKSUM=`cat .img_checksum.md5`; \
	export PKR_VAR_BOX_VERSION=$(BOX_VERSION); \
	packer validate $(PACKER_FILE); \
	PACKER_LOG=1 packer build $(PACKER_FILE)

clean:
	-rm -rf \
    .img_checksum.md5 \
		output \
    packer_cache

##
# targets to build vagrant plugin a docker container
##

DOCKER_IMG=phlummox/libvirt-plugin:0.1

docker-build:
	docker build -f Dockerfile -t $(DOCKER_IMG) .


# may be useful for debugging
docker-run:
	docker -D run -it --rm  \
	    -v $$PWD:/opt/work \
	    $(DOCKER_IMG)


vagrant-up:
	vagrant up --provider=libvirt
