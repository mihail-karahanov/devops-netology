provider "yandex" {
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_default_zone
}

data "yandex_iam_service_account" "default" {
  name = var.yc_service_account_name
}

data "yandex_compute_image" "my_image" {
  family = "ubuntu-2004-lts"
}

locals {
  instance_type_map = {
    stage = "standard-v3"
    prod  = "standard-v1"
  }
}

locals {
  instance_count_map = {
    stage = 1
    prod = 2
  }
}

locals {
  instances = {
    "standard-v1" = data.yandex_compute_image.my_image.id
    "standard-v3" = data.yandex_compute_image.my_image.id
  }
}

resource "yandex_compute_instance" "test" {
  name        = "test-srv${count.index}"
  hostname    = "test-srv${count.index}.netology.local"
  platform_id = local.instance_type_map[terraform.workspace]
  zone        = var.yc_default_zone
  count       = local.instance_count_map[terraform.workspace]

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.my_image.id
      name = "root-srv1"
      type = "network-hdd"
      size = var.yc_disk_size
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "prod" {

  for_each    = local.instances
  platform_id = each.key
  zone        = var.yc_default_zone

  lifecycle {
    create_before_destroy = true
  }
  
  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = each.value
      type = "network-hdd"
      size = var.yc_disk_size
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_vpc_network" "net" {
  name = "my-net"
}

resource "yandex_vpc_subnet" "subnet" {
  zone       = var.yc_default_zone
  network_id = "${yandex_vpc_network.net.id}"
  v4_cidr_blocks = ["192.168.100.0/24"]
}
