# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами" - Михаил Караханов

---

## Задача 1

>- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
>- Какой из принципов IaaC является основополагающим?

**Ответ:**

- Основные преимущества применения паттернов IaaC

  - **CI (Continuous Integration)** - данная практика позволяет значительно ускорить процесс разработки и тестирования нового кода продукта за счет частых и автоматизированных слияний рабочих веток в основную ветку кода. На практике позволяет на раннем этапе обнаруживать ошибки в коде за счет автоматизированного тестирования нового кода
  - **CD (Continuous Delivery)** - данный подход на практике позволяет повысить частоту подготовки новых релизов продукта за счет уменьшения количества изменений в них. Небольшие по размеру релизы, после прохождения этапа CI, повторно тестируются на ошибки в тестовой среде и автоматически откатываются на предыдущую версию в случае их обнаружения
  - **CD (Continuous Deployment)** - данная практика позволяет автоматизировать и ускорить процесс развертывания нового релиза продукта в продуктивной среде и доставки его до конечного потребителя

- Основополагающим принципом IaaC является **идемпотентность**. Это принцип, при котором целевая инфраструктура получает одну и ту же конфигурацию, независимо от первоначального состояния.

## Задача 2

>- Чем Ansible выгодно отличается от других систем управление конфигурациями?
>- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

**Ответ:**

- Основные премущества Ansible: не требует дополнительной инфраструктуры для подключения к целевым хостам, использует существующее SSH-окружение; декларативное описание конфигураций в YAML-формате; легко расширяется функционал за счет подключения дополнительных модулей
- На мой взгляд, наиболее надежным методом работы является Push. При таком подходе центральный управляющий сервер контролирует, кому из целевых хостов была доставлена новая конфигурация, а кому - нет. Также есть возможность быстрого опроса хостов по нужным параметрам

## Задача 3

>Установить на личный компьютер:
>
>- VirtualBox
>- Vagrant
>- Ansible
>
>*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

**Ответ:**

```bash
netadmin@netstation:~$ virtualbox -h
Oracle VM VirtualBox VM Selector v6.1.28
(C) 2005-2021 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
netadmin@netstation:~$ 
netadmin@netstation:~$ 
netadmin@netstation:~$ vagrant -v
Vagrant 2.2.19
netadmin@netstation:~$ 
netadmin@netstation:~$ ansible --version
ansible [core 2.12.1]
  config file = None
  configured module search path = ['/home/netadmin/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/netadmin/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/netadmin/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/netadmin/.local/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 3.0.3
  libyaml = True
netadmin@netstation:~$
```

## Задача 4 (*)

>Воспроизвести практическую часть лекции самостоятельно.
>
>- Создать виртуальную машину.
>- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды

**Ответ:**

- создал директорию `Vagrant` в корне домашней директории
- выполнил инициализацию проекта командой `vagrant init`
- добавил образ

  ```bash
  netadmin@netstation:~/Vagrant$ vagrant box add bento/ubuntu-20.04 --provider=virtualbox
  ==> box: Loading metadata for box 'bento/ubuntu-20.04'
      box: URL: https://vagrantcloud.com/bento/ubuntu-20.04
  ==> box: Adding box 'bento/ubuntu-20.04' (v202112.19.0) for provider: virtualbox
      box: Downloading: https://vagrantcloud.com/bento/boxes/ubuntu-20.04/versions/202112.19.0/providers/virtualbox.box
  ==> box: Successfully added box 'bento/ubuntu-20.04' (v202112.19.0) for 'virtualbox'!
  netadmin@netstation:~/Vagrant$ 
  netadmin@netstation:~/Vagrant$ vagrant box list
  bento/ubuntu-20.04 (virtualbox, 202112.19.0)
  netadmin@netstation:~/Vagrant$
  ```

- оригинальный `Vagrantfile` заменил файлом из директории `src` в репозитории с домашним заданием
- создал директорию `ansible` в корне домашней директории. Скопировал из репозитория с домашним заданием файлы `inventory` и `provision.yml`
- выполнил команду `vagrant up`. Результат:

  ```bash
  netadmin@netstation:~/Vagrant$ vagrant up
  Bringing machine 'server1.netology' up with 'virtualbox' provider...
  ==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202112.19.0' is up to date...
  ==> server1.netology: Clearing any previously set network interfaces...
  ==> server1.netology: Preparing network interfaces based on configuration...
      server1.netology: Adapter 1: nat
      server1.netology: Adapter 2: hostonly
  ==> server1.netology: Forwarding ports...
      server1.netology: 22 (guest) => 20011 (host) (adapter 1)
      server1.netology: 22 (guest) => 2222 (host) (adapter 1)
  ==> server1.netology: Running 'pre-boot' VM customizations...
  ==> server1.netology: Booting VM...
  ==> server1.netology: Waiting for machine to boot. This may take a few minutes...
      server1.netology: SSH address: 127.0.0.1:2222
      server1.netology: SSH username: vagrant
      server1.netology: SSH auth method: private key
      server1.netology: 
      server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
      server1.netology: this with a newly generated keypair for better security.
      server1.netology: 
      server1.netology: Inserting generated public key within guest...
      server1.netology: Removing insecure key from the guest if it's present...
      server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
  ==> server1.netology: Machine booted and ready!
  ==> server1.netology: Checking for guest additions in VM...
  ==> server1.netology: Setting hostname...
  ==> server1.netology: Configuring and enabling network interfaces...
  ==> server1.netology: Mounting shared folders...
      server1.netology: /vagrant => /home/netadmin/Vagrant
  ==> server1.netology: Running provisioner: ansible...
      server1.netology: Running ansible-playbook...

  PLAY [nodes] *******************************************************************

  TASK [Gathering Facts] *********************************************************
  ok: [server1.netology]

  TASK [Create directory for ssh-keys] *******************************************
  ok: [server1.netology]

  TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
  changed: [server1.netology]

  TASK [Checking DNS] ************************************************************
  changed: [server1.netology]

  TASK [Installing tools] ********************************************************
  ok: [server1.netology] => (item=git)
  ok: [server1.netology] => (item=curl)

  TASK [Installing docker] *******************************************************
  changed: [server1.netology]

  TASK [Add the current user to docker group] ************************************
  changed: [server1.netology]

  PLAY RECAP *********************************************************************
  server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

  netadmin@netstation:~/Vagrant$ 
  ```

- подключился по SSH к ВМ командой `vagrant ssh`. Проверил корректную работу Docker:

  ```bash
  vagrant@server1:~$ docker ps
  CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
  vagrant@server1:~$ 
  vagrant@server1:~$ 
  vagrant@server1:~$ docker run hello-world
  Unable to find image 'hello-world:latest' locally
  latest: Pulling from library/hello-world
  2db29710123e: Pull complete 
  Digest: sha256:507ecde44b8eb741278274653120c2bf793b174c06ff4eaa672b713b3263477b
  Status: Downloaded newer image for hello-world:latest

  Hello from Docker!
  This message shows that your installation appears to be working correctly.

  To generate this message, Docker took the following steps:
  1. The Docker client contacted the Docker daemon.
  2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
      (amd64)
  3. The Docker daemon created a new container from that image which runs the
      executable that produces the output you are currently reading.
  4. The Docker daemon streamed that output to the Docker client, which sent it
      to your terminal.

  To try something more ambitious, you can run an Ubuntu container with:
  $ docker run -it ubuntu bash

  Share images, automate workflows, and more with a free Docker ID:
  https://hub.docker.com/

  For more examples and ideas, visit:
  https://docs.docker.com/get-started/

  vagrant@server1:~$
  ```
