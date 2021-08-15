# vagrant-podman

[![build](https://github.com/phlummox/vagrant-podman/actions/workflows/ci.yml/badge.svg)](https://github.com/phlummox/vagrant-podman/actions/workflows/ci.yml)

A [Vagrant][vagrant] box, based on Alpine 3.14, with
podman installed. (And also docker, and a few other packages, and an
`init.d` script for starting rootless podman as a service on port 3000.)
A copy of the box is downloadable from the GitHub [releases
page][releases], and from the Vagrant Cloud.

[vagrant]: https://www.vagrantup.com
[releases]: https://github.com/phlummox/vagrant-podman/releases 

## Quick start

```
$ mkdir somedir && cd somedir
$ vagrant init phlummox/podman
$ vagrant up --provider=libvirt
```

See [Using the box](#using-the-box) for more detail.

## Build prerequisites

`packer` and `vagrant` need to be installed - see the `.github` CI
file for how to do this.

The build also requires the following Ubuntu packages to be
installed:

- `pv` - used for giving progress feedback in the makefile
-  `qemu-utils` and `qemu-kvm`

## Building

```
make packer-build
```

## Using the box

### 1. Use `vagrant` to create a `Vagrantfile`.

```
$ vagrant init phlummox/podman
```

### 2. Enable the podman-rootless service

There's an `/etc/init.d/podman-rootless` file on the box which allows
you to run podman rootless as a service (it's run as user id `vagrant`),
exposing the Podman [RESTful HTTP API][podman-api].

You can then create and run Podman containers in the Vagrant box
using `curl` or similar tools, or [`podman-remote`][podman-remote].

[podman-api]: https://docs.podman.io/en/latest/_static/api.html
[podman-remote]: https://github.com/containers/podman/blob/main/docs/source/markdown/podman-remote.1.md

On the other hand, if you don't need the podman-rootless service to
start, then you can skip to running `vagrant up`.

If you are happpy with port 3000 as the port to serve on,
then modify the created `Vagrantfile` to look as follows:

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "phlummox/podman"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"

  # optionally: uncomment the following to specify memory
  # and cpu limits.
  #config.vm.provider "libvirt" do |lv|
  #  # Customize the amount of memory on the VM:
  #  lv.memory = "800"
  #  lv.cpus = 1
  #end

  config.vm.provision "shell", inline: <<-SHELL
    rc-update add podman-rootless
    rc-service podman-rootless start
  SHELL

end
```

### 3. Start the vagrant box

Bring the box up:


```
$ vagrant up
```

<!--
  vim: ts=2 sw=2 et tw=72 :
-->
