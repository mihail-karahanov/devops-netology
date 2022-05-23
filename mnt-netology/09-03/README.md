# Домашнее задание к занятию "09.03 Jenkins" - Михаил Караханов

>## Подготовка к выполнению
>
>1. Установить jenkins по любой из [инструкций](https://www.jenkins.io/download/)
>2. Запустить и проверить работоспособность
>3. Сделать первоначальную настройку
>4. Настроить под свои нужды
>5. Поднять отдельный cloud
>6. Для динамических агентов можно использовать [образ](https://hub.docker.com/repository/docker/aragast/agent)
>7. Обязательный параметр: поставить label для динамических агентов: `ansible_docker`
>8. Сделать форк репозитория с [playbook](https://github.com/aragastmatb/example-playbook)
>
>## Основная часть
>
>1. Сделать Freestyle Job, который будет запускать `ansible-playbook` из форка репозитория
>2. Сделать Declarative Pipeline, который будет выкачивать репозиторий с плейбукой и запускать её
>3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`
>4. Перенастроить Job на использование `Jenkinsfile` из репозитория
>5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline)
>6. Заменить credentialsId на свой собственный
>7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозитрий в файл `ScriptedJenkinsfile`
>8. Отправить ссылку на репозиторий в ответе

## Выполнение основной части ДЗ

Установил Jenkins в Docker согласно инструкции. Поднял Docker Cloud, настроил использование рекомендуемого образа в качестве динамического агента. Выполнил форк указанного репозитория. Настройки Cloud:

![cloud1](/img/09_03_cloud1.png "Cloud params")

![cloud2](/img/09_03_cloud2.png "Agent params")

1. Создал Freestyle Job, настроил git checkout из репозитория. Настроил следующие параметры запуска shell:
![freestyle_shell](/img/09_03_freestyle_shell.png)
Добавил команду `java -version` для проверки корректной установки Java. Результат выполнения job:
![freestyle_log](/img/09_03_freestyle_log.png)
2. Создал и добавил в репо Jenkinsfile следующего содержания:

  ```groovy
  pipeline {
    agent {
      label 'ansible_docker'
    }
    stages {
      stage('First stage'){
        steps {
          echo "I'm runing"
          git credentialsId: 'GitHub-DemoRepo', url: 'git@github.com:mihail-karahanov/example-playbook.git'
        }
      }
      stage('Second stage'){
        steps {
          echo "And I'm too"
          sh '''
            export LC_ALL=en_US.utf8
            export LANG=en_US.utf8
            python3 -m pip install --upgrade molecule
            mkdir roles
            ansible-galaxy role install -p roles/ -r requirements.yml java && \
            ansible-playbook -i inventory/prod.yml site.yml
            java -version
          '''
        }
      }
    }
  }
  ```

Перенастроил job на исполнение Jenkinsfile из репо. Результат выполнения:
![pipeline_log](/img/09_03_pipeline_log.png)
3. Создал и перенос в репо файл `ScriptedJenkinsfile` следующего содержания:

  ```groovy
  node("ansible_docker") {

      stage("Git checkout"){
          git credentialsId: 'GitHub-DemoRepo', url: 'git@github.com:mihail-karahanov/example-playbook.git'
      }
      stage("Check ssh key"){
          secret_check=true
      }
      stage("Run playbook"){
          if (secret_check){
              sh '''
                  mkdir roles
                  ansible-galaxy role install -p roles/ -r requirements.yml java && \
                  ansible-playbook site.yml -i inventory/prod.yml
              '''
          }
          else{
              echo 'no more keys'
          }
          
      }
  }
  ```

Результат выполнения job в Jenkins:
![scripted_log](/img/09_03_scripted_log.png)

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решеним с названием `AllJobFailure.groovy`
2. Установить customtools plugin
3. Поднять инстанс с локальным nexus, выложить туда в анонимный доступ  .tar.gz с `ansible`  версии 2.9.x
4. Создать джобу, которая будет использовать `ansible` из `customtool`
5. Джоба должна просто исполнять команду `ansible --version`, в ответ прислать лог исполнения джобы
