
`vars.mk` is a Makefile fragment - intended to be
included into the main Makefile - which defines variables
used in the build.

Bump up the version by changing `BOX_VERSION` in this
file.

## Some files used in the build process

- ~/.vagrant.d: We use vagrant to pull the Alpine 3.14
  box, which gets dumped in this directory.

- podman.pkr.hcl: This is a Packer build file.
  It invokes `provision-vm.sh` to provision the Alpine VM.

- test-vm.sh: Run some (very basic) tests of the built box.
  Requires libvirt, podman and vagrant be installed, and
  the libvirt plugin for vagrant.

  Used in the GitHub CI scripts (see `.github`).

- publish.sh and topmost-changelog-sec.sh: Used for
  publishing the box to the Vagrant Cloud, and managing
  the changelog.

