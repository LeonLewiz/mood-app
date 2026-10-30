variable "node_name" {
  type    = string
  default = "proxmox"
}

variable "vm_prefix" {
  type    = string
  default = "mood-k3s"
}

variable "disk_datastore_id" {
  type    = string
  default = "local-lvm"
}

variable "image_datastore_id" {
  type    = string
  default = "local"
}
variable "imasdsaage_datastore_id" {
  type    = string
  default = "local"
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "gateway" {
  type    = string
  default = "192.168.3.1"
}

variable "dns_servers" {
  type    = list(string)
  default = ["192.168.3.1"]
}

variable "image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "dedicated_control_plane" {
  type    = bool
  default = false
}

variable "nodes" {
  type = map(object({
    address = string
    mac     = string
    cores   = number
    memory  = number
    disk    = number
    role    = string
  }))

  default = {
    control = {
      address = "192.168.3.151/24"
      mac     = "bc:24:11:00:00:51"
      cores   = 2
      memory  = 4096
      disk    = 15
      role    = "server"
    }
    worker1 = {
      address = "192.168.3.152/24"
      mac     = "bc:24:11:00:00:52"
      cores   = 2
      memory  = 3072
      disk    = 20
      role    = "agent"
    }
    worker2 = {
      address = "192.168.3.153/24"
      mac     = "bc:24:11:00:00:53"
      cores   = 2
      memory  = 5120
      disk    = 25
      role    = "agent"
    }
  }
}
