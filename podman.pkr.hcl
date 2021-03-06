
# various variables, typically
# got from environment

variable "ALPINE_IMG_PATH" {
  type        = string
  description = "path to ubuntu qcow .img"
}

variable "DISK_SIZE" {
  type        = number
  description = "size of disk in bytes"
}

variable "DISK_CHECKSUM" {
  type        = string
  description = "checksum of qcow2 image"
}

variable "BOX_VERSION" {
  type        = string
  description = "our versioning -- version of the produced vagrant box"
}

# input - a qcow2 image

source "qemu" "podman" {

  iso_url            = "file:///${var.ALPINE_IMG_PATH}"
  disk_image        = true

  disk_size         = "${var.DISK_SIZE}b"
  iso_checksum      = "md5:${var.DISK_CHECKSUM}"
  format            = "qcow2"


  output_directory  = "output"

  # name of output file
  vm_name           = "{{build_name}}_${var.BOX_VERSION}.qcow2"

  shutdown_command  = "sudo shutdown now"

  # Needn't specify an accelerator - packer docco
  # says kvm will be used by default if available,
  # else tcg: https://www.packer.io/docs/builders/qemu.

  #accelerator       = "kvm"

  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
  #ssh_timeout       = "20m"
  net_device        = "virtio-net"
  disk_interface    = "virtio-scsi"
  boot_wait         = "20s"

  display           = "none"

  # needed, see https://github.com/hashicorp/packer/issues/8693
  # (??still)
  qemuargs         = [
      ["-display", "none"]
    ]
}

# how to build an output qcow2 image, then vagrant box
# and md5sum of the vagrant box.

build {
  sources = ["source.qemu.podman"]

  provisioner "file" {
    source = "./files-to-add-to-vm/podman-rootless"
    destination = "/tmp/podman-rootless"
  }

  provisioner "shell" {
      script = "./provision-vm.sh"
  }

  post-processors {

    post-processor "vagrant" {

       compression_level = 9
       keep_input_artifact = true
       vagrantfile_template = "templates/developer.rb"
       output = "output/{{build_name}}_${var.BOX_VERSION}.box"
       include = [
           "templates/info.json"
       ]
    }

    post-processor "checksum" {
      checksum_types = ["md5"]
      output = "output/{{build_name}}_${var.BOX_VERSION}.box.md5"
    }

  }

}
