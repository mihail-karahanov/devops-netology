# Домашнее задание к занятию "08.01 Введение в Ansible" - Михаил Караханов

>## Подготовка к выполнению
>
>1. Установите ansible версии 2.10 или выше.
>2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
>3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть

>1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
>2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
>3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
>4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
>5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
>6. Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
>7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
>8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
>9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
>10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
>11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
>12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Выполнение основной части

1. Выполнил команду `ansible-playbook -i inventory/test.yml site.yml`. Значение перменной `some_fact`:

    ![some_fact](/img/08_01_01_fact.png)

2. Это файл `group_vars/all/examp.yml`. Изменил значение переменной.
3. Запустил два контейнера локально с именами `centos7` и `ubuntu`
4. Выполнил команду `ansible-playbook -i inventory/prod.yml site.yml`. Значения переменных:

    ![facts](/img/08_01_04_facts.png)

5. Внес изменения в переменные
6. Выполнил повторный запуск playbook. Результат:

    ![facts](/img/08_01_06_facts.png)

7. Зашифровал файлы командами `ansible-vault encrypt group_vars/deb/examp.yml` и `ansible-vault encrypt group_vars/el/examp.yml`
8. Выполнил запуск playbook командой `ansible-playbook -i inventory/prod.yml --ask-vault-pass site.yml`. После ввода пароля все отработало корректно.
9. Посмотрел список доступных типов подключений командой `ansible-doc -t connection -l`. Для работы с Control Node подходит тип подключения - `local`
10. Добавил следующую группу в файл `inventory/prod.yml`:

    ```yaml
    local:
      hosts:
        localhost:
          ansible_connection: local
    ```

11. Выполнил запуск playbook. Результат:

    ![facts](/img/08_01_11_facts.png)

## Необязательная часть

>1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
>2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
>3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
>4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
>5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
>6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

## Выполнение необязательной части

1. Расшифровал ранее зашифрованные файлы командами `ansible-vault decrypt group_vars/deb/examp.yml` и `ansible-vault decrypt group_vars/el/examp.yml`
2. Выполнил шифрование значения переменной командой `ansible-vault encrypt_string`
3. Выполнил запуск playbook для `test.yml`. Результат:

    ![facts](/img/08_01_optional_fact.png)

4. Создал новую группу хостов `rpm`. Переменная для этой группы имеет значение - `rpm default fact`. В файл `prod.yml` добавил следующее:

    ```yaml
      rpm:
        hosts:
          fedora:
            ansible_connection: docker
    ```

5. Создал скрипт `test.sh` следующего содержания:

    ```bash
    #!/bin/bash

    set -eu

    # Start docker containers
    docker run -d --name ubuntu pycontribs/ubuntu:latest sleep 3600
    docker run -d --name fedora pycontribs/fedora:latest sleep 3600
    docker run -d --name centos7 pycontribs/centos:7 sleep 3600

    # Run playbook
    ansible-playbook -i ./inventory/prod.yml --ask-vault-pass ./site.yml

    # Stop containers
    docker stop ubuntu fedora centos7

    # Remove containers
    docker rm ubuntu fedora centos7
    ```

    Результат работы скрипта:

    ![script_run](/img/08_01_optional_script_run.png)
