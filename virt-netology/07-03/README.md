# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ" - Михаил Караханов

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно)

>Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием
терраформа и aws.
>
>1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя,
а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано [здесь](https://www.terraform.io/docs/backends/types/s3.html).
>1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше.

К сожалению, нет возможности использовать AWS...

## Задача 2. Инициализируем проект и создаем воркспейсы

1. Выполните `terraform init`:
   * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице dynamodb.
   * иначе будет создан локальный файл со стейтами.
2. Создайте два воркспейса `stage` и `prod`.
3. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные `instance_type`.
4. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два.
5. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.
6. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр
жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
7. При желании поэкспериментируйте с другими параметрами и рессурсами.

## Выполнение Задачи 2 (Yandex.Cloud)

1. Выполнил `terraform init` в созданном ранее каталоге `terraform`
2. Создал два workspace `stage` и `prod` командой `terraform workspace new <workspace_name>`. Список workspace:

    ![workspace_list](/img/07_03_workspace_list.png)

3. Добавил локальную переменную `instance_type_map` в файл `main.tf`:

    ```ruby
    locals {
    instance_type_map = {
        stage = "standard-v3"
        prod  = "standard-v1"
    }
    }
    ```

    В уже созданный `yandex_compute_instance` добавил зависимость `platform_id` от воркспейса:

    ```ruby
    resource "yandex_compute_instance" "test" {
      name        = "test-srv"
      hostname    = "test-srv1.netology.local"
      platform_id = local.instance_type_map[terraform.workspace]
      zone        = var.yc_default_zone
    ```

4. Добавил доплнительную локальную переменную и параметр count в конфигурацию instance:

    ```ruby
    locals {
      instance_count_map = {
        stage = 1
        prod = 2
      }
    }

    resource "yandex_compute_instance" "test" {
      name        = "test-srv${count.index}"
      hostname    = "test-srv${count.index}.netology.local"
      platform_id = local.instance_type_map[terraform.workspace]
      zone        = var.yc_default_zone
      count       = local.instance_count_map[terraform.workspace]
    ```

5. Добавил еще один instance с конфигурацией цикла:

    ```ruby
    locals {
      instances = {
        "standard-v1" = data.yandex_compute_image.my_image.id
        "standard-v3" = data.yandex_compute_image.my_image.id
      }
    }

    resource "yandex_compute_instance" "prod" {

      for_each    = local.instances
      platform_id = each.key
      zone        = var.yc_default_zone

      lifecycle {
        create_before_destroy = true
      }
        
      boot_disk {
        initialize_params {
        image_id = each.value
        type = "network-hdd"
        size = var.yc_disk_size
        }
      }
    ```

6. Добавил параметр `create_before_destroy = true` в раздел lifecycle одного из instance

В виде результата работы пришлите:

* Вывод команды `terraform workspace list`.

    ```bash
    netadmin@netstation:~/Documents/Repositories/devops-netology/terraform$ terraform workspace list
        default
        * prod
        stage
    ```

* Вывод команды `terraform plan` для воркспейса `prod`.

    ```bash
    netadmin@netstation:~/Documents/Repositories/devops-netology/terraform$ terraform plan
    data.yandex_iam_service_account.default: Reading...
    data.yandex_compute_image.my_image: Reading...
    data.yandex_compute_image.my_image: Read complete after 2s [id=fd87tirk5i8vitv9uuo1]
    data.yandex_iam_service_account.default: Read complete after 2s [id=ajepb2eu85q1id7ugefe]

    Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
    + create

    Terraform will perform the following actions:

    # yandex_compute_instance.prod["standard-v1"] will be created
    + resource "yandex_compute_instance" "prod" {
        + created_at                = (known after apply)
        + folder_id                 = (known after apply)
        + fqdn                      = (known after apply)
        + hostname                  = (known after apply)
        + id                        = (known after apply)
        + metadata                  = {
            + "ssh-keys" = <<-EOT
                    ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHJdkZERnC605Tjrc4YTECan+PD1MG7azHLG5uyIXYa New Home Notebook key
                EOT
            }
        + network_acceleration_type = "standard"
        + platform_id               = "standard-v1"
        + service_account_id        = (known after apply)
        + status                    = (known after apply)
        + zone                      = "ru-central1-c"

        + boot_disk {
            + auto_delete = true
            + device_name = (known after apply)
            + disk_id     = (known after apply)
            + mode        = (known after apply)

            + initialize_params {
                + block_size  = (known after apply)
                + description = (known after apply)
                + image_id    = "fd87tirk5i8vitv9uuo1"
                + name        = (known after apply)
                + size        = 50
                + snapshot_id = (known after apply)
                + type        = "network-hdd"
                }
            }

        + network_interface {
            + index              = (known after apply)
            + ip_address         = (known after apply)
            + ipv4               = true
            + ipv6               = (known after apply)
            + ipv6_address       = (known after apply)
            + mac_address        = (known after apply)
            + nat                = true
            + nat_ip_address     = (known after apply)
            + nat_ip_version     = (known after apply)
            + security_group_ids = (known after apply)
            + subnet_id          = (known after apply)
            }

        + placement_policy {
            + host_affinity_rules = (known after apply)
            + placement_group_id  = (known after apply)
            }

        + resources {
            + core_fraction = 100
            + cores         = 2
            + memory        = 4
            }

        + scheduling_policy {
            + preemptible = (known after apply)
            }
        }

    # yandex_compute_instance.prod["standard-v3"] will be created
    + resource "yandex_compute_instance" "prod" {
        + created_at                = (known after apply)
        + folder_id                 = (known after apply)
        + fqdn                      = (known after apply)
        + hostname                  = (known after apply)
        + id                        = (known after apply)
        + metadata                  = {
            + "ssh-keys" = <<-EOT
                    ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHJdkZERnC605Tjrc4YTECan+PD1MG7azHLG5uyIXYa New Home Notebook key
                EOT
            }
        + network_acceleration_type = "standard"
        + platform_id               = "standard-v3"
        + service_account_id        = (known after apply)
        + status                    = (known after apply)
        + zone                      = "ru-central1-c"

        + boot_disk {
            + auto_delete = true
            + device_name = (known after apply)
            + disk_id     = (known after apply)
            + mode        = (known after apply)

            + initialize_params {
                + block_size  = (known after apply)
                + description = (known after apply)
                + image_id    = "fd87tirk5i8vitv9uuo1"
                + name        = (known after apply)
                + size        = 50
                + snapshot_id = (known after apply)
                + type        = "network-hdd"
                }
            }

        + network_interface {
            + index              = (known after apply)
            + ip_address         = (known after apply)
            + ipv4               = true
            + ipv6               = (known after apply)
            + ipv6_address       = (known after apply)
            + mac_address        = (known after apply)
            + nat                = true
            + nat_ip_address     = (known after apply)
            + nat_ip_version     = (known after apply)
            + security_group_ids = (known after apply)
            + subnet_id          = (known after apply)
            }

        + placement_policy {
            + host_affinity_rules = (known after apply)
            + placement_group_id  = (known after apply)
            }

        + resources {
            + core_fraction = 100
            + cores         = 2
            + memory        = 4
            }

        + scheduling_policy {
            + preemptible = (known after apply)
            }
        }

    # yandex_compute_instance.test[0] will be created
    + resource "yandex_compute_instance" "test" {
        + created_at                = (known after apply)
        + folder_id                 = (known after apply)
        + fqdn                      = (known after apply)
        + hostname                  = "test-srv0.netology.local"
        + id                        = (known after apply)
        + metadata                  = {
            + "ssh-keys" = <<-EOT
                    ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHJdkZERnC605Tjrc4YTECan+PD1MG7azHLG5uyIXYa New Home Notebook key
                EOT
            }
        + name                      = "test-srv0"
        + network_acceleration_type = "standard"
        + platform_id               = "standard-v1"
        + service_account_id        = (known after apply)
        + status                    = (known after apply)
        + zone                      = "ru-central1-c"

        + boot_disk {
            + auto_delete = true
            + device_name = (known after apply)
            + disk_id     = (known after apply)
            + mode        = (known after apply)

            + initialize_params {
                + block_size  = (known after apply)
                + description = (known after apply)
                + image_id    = "fd87tirk5i8vitv9uuo1"
                + name        = "root-srv1"
                + size        = 50
                + snapshot_id = (known after apply)
                + type        = "network-hdd"
                }
            }

        + network_interface {
            + index              = (known after apply)
            + ip_address         = (known after apply)
            + ipv4               = true
            + ipv6               = (known after apply)
            + ipv6_address       = (known after apply)
            + mac_address        = (known after apply)
            + nat                = true
            + nat_ip_address     = (known after apply)
            + nat_ip_version     = (known after apply)
            + security_group_ids = (known after apply)
            + subnet_id          = (known after apply)
            }

        + placement_policy {
            + host_affinity_rules = (known after apply)
            + placement_group_id  = (known after apply)
            }

        + resources {
            + core_fraction = 100
            + cores         = 2
            + memory        = 4
            }

        + scheduling_policy {
            + preemptible = (known after apply)
            }
        }

    # yandex_compute_instance.test[1] will be created
    + resource "yandex_compute_instance" "test" {
        + created_at                = (known after apply)
        + folder_id                 = (known after apply)
        + fqdn                      = (known after apply)
        + hostname                  = "test-srv1.netology.local"
        + id                        = (known after apply)
        + metadata                  = {
            + "ssh-keys" = <<-EOT
                    ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFHJdkZERnC605Tjrc4YTECan+PD1MG7azHLG5uyIXYa New Home Notebook key
                EOT
            }
        + name                      = "test-srv1"
        + network_acceleration_type = "standard"
        + platform_id               = "standard-v1"
        + service_account_id        = (known after apply)
        + status                    = (known after apply)
        + zone                      = "ru-central1-c"

        + boot_disk {
            + auto_delete = true
            + device_name = (known after apply)
            + disk_id     = (known after apply)
            + mode        = (known after apply)

            + initialize_params {
                + block_size  = (known after apply)
                + description = (known after apply)
                + image_id    = "fd87tirk5i8vitv9uuo1"
                + name        = "root-srv1"
                + size        = 50
                + snapshot_id = (known after apply)
                + type        = "network-hdd"
                }
            }

        + network_interface {
            + index              = (known after apply)
            + ip_address         = (known after apply)
            + ipv4               = true
            + ipv6               = (known after apply)
            + ipv6_address       = (known after apply)
            + mac_address        = (known after apply)
            + nat                = true
            + nat_ip_address     = (known after apply)
            + nat_ip_version     = (known after apply)
            + security_group_ids = (known after apply)
            + subnet_id          = (known after apply)
            }

        + placement_policy {
            + host_affinity_rules = (known after apply)
            + placement_group_id  = (known after apply)
            }

        + resources {
            + core_fraction = 100
            + cores         = 2
            + memory        = 4
            }

        + scheduling_policy {
            + preemptible = (known after apply)
            }
        }

    # yandex_vpc_network.net will be created
    + resource "yandex_vpc_network" "net" {
        + created_at                = (known after apply)
        + default_security_group_id = (known after apply)
        + folder_id                 = (known after apply)
        + id                        = (known after apply)
        + labels                    = (known after apply)
        + name                      = "my-net"
        + subnet_ids                = (known after apply)
        }

    # yandex_vpc_subnet.subnet will be created
    + resource "yandex_vpc_subnet" "subnet" {
        + created_at     = (known after apply)
        + folder_id      = (known after apply)
        + id             = (known after apply)
        + labels         = (known after apply)
        + name           = (known after apply)
        + network_id     = (known after apply)
        + v4_cidr_blocks = [
            + "192.168.100.0/24",
            ]
        + v6_cidr_blocks = (known after apply)
        + zone           = "ru-central1-c"
        }

    Plan: 6 to add, 0 to change, 0 to destroy.

    Changes to Outputs:
    + instance_subnet_id = (known after apply)
    + yc_sa_account_id   = "ajepb2eu85q1id7ugefe"

    ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
    ```
