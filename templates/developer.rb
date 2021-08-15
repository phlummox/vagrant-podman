# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  #config.vm.boot_timeout = 1800
  config.vm.box = "phlummox/podman"
  config.vm.hostname = "podman.local"
  #config.vm.synced_folder ".", "/vagrant", disabled: true

end
