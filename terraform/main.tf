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

resource "yandex_compute_instance" "test" {
  name        = "test-srv"
  hostname    = "test-srv1.netology.local"
  platform_id = "standard-v1"
  zone        = var.yc_default_zone

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

resource "yandex_vpc_network" "net" {
  name = "my-net"
}

resource "yandex_vpc_subnet" "subnet" {
  zone       = var.yc_default_zone
  network_id = "${yandex_vpc_network.net.id}"
  v4_cidr_blocks = ["192.168.100.0/24"]
}
