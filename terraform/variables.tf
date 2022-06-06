variable "yc_cloud_id" {
  description = "Yandex Cloud default cloud_id"
  type = string
  default = "b1g09mh5thcait7elhgk"
}

variable "yc_folder_id" {
  description = "Yandex Cloud default folder_id"
  type = string
  default = "b1g8n2j0mugfq1cee26l"
}

variable "yc_default_zone" {
  description = "Yandex Cloud default zone name"
  type = string
  default = "ru-central1-c"
}

variable "yc_disk_size" {
  description = "Disk size in GB"
  type = number
  default = 50
}

variable "yc_service_account_name" {
  type = string
  default = "my-sa"
}