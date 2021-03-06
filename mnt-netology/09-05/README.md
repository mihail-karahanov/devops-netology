# Домашнее задание к занятию "09.05 Gitlab" - Михаил Караханов

>## Подготовка к выполнению
>
>1. Необходимо [зарегистрироваться](https://about.gitlab.com/free-trial/)
>2. Создайте свой новый проект
>3. Создайте новый репозиторий в gitlab, наполните его [файлами](./repository)
>4. Проект должен быть публичным, остальные настройки по желанию

## Основная часть

>### DevOps
>
>В репозитории содержится код проекта на python. Проект - RESTful API сервис. Ваша задача автоматизировать сборку образа с выполнением python-скрипта:
>
>1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)
>2. Python версии не ниже 3.7
>3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`
>4. Создана директория `/python_api`
>5. Скрипт из репозитория размещён в /python_api
>6. Точка вызова: запуск скрипта
>7. Если сборка происходит на ветке `master`: Образ должен пушится в docker registry вашего gitlab `python-api:latest`, иначе этот шаг нужно пропустить

### Выполнение этапа DevOps

Для оптимизации выполнения сборки подготовил образ на базе CentOS 7 с предустановленным Python версии 3.8.13 используя следующий Dockerfile:

```dockerfile
FROM centos:centos7

RUN yum -y update && yum -y groupinstall "Development Tools" && \
    yum -y install gcc openssl-devel bzip2-devel libffi-devel wget && \
    yum -y clean all  && rm -rf /var/cache && \
    wget https://www.python.org/ftp/python/3.8.13/Python-3.8.13.tgz && \
    tar xvf Python-3.8.13.tgz && cd Python-3.8.13 && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make && make altinstall && cd / && rm -rf /Python-3.8.13*
```

Для выполнения непосредственно самой сборки, подготовил следующий Dockerfile на базе ранее созданого образа:

```dockerfile
FROM mihailkarahanov/centos7-python38:latest

RUN python3.8 -m pip install --no-cache-dir flask flask-jsonpify flask-restful && \
    mkdir -p /python_api

COPY python-api.py /python_api

WORKDIR /python_api

EXPOSE 5290/tcp

ENTRYPOINT [ "python3.8", "./python-api.py" ]
```

Так как в данный момент использование `shared runners` невозможно, установил в Docker и зарегистрировал свой `specific runner` с executor type - `docker`:

![runner](/img/09_05_runner.png)

Для запуска сборки согласно условий из задания, подготовил файл `.gitlab-ci.yml` следующего содержания:

```yaml
image: docker:latest

services:
  - name: docker:dind
    alias: docker

variables:
  IMAGE: python-api
  DOCKER_HOST: tcp://docker:2375
  DOCKER_TLS_CERTDIR: ""

stages:
  - build

build:
  stage: build
  tags:
    - docker
  script:
    - docker build -t "$CI_REGISTRY_IMAGE/$IMAGE:latest" .
    - |
      if [[ "$CI_COMMIT_BRANCH" == "main" ]]; then
        docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" registry.gitlab.com
        docker push "$CI_REGISTRY_IMAGE/$IMAGE:latest"
      fi
  
  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile
```

После коммита сборка завершилась успешно. Docker-образ опубликован в Container registry проекта:

![pipeline_passed](/img/09_05_pipeline_passed.png)

![registry](/img/09_05_registry.png)

>### Product Owner
>
>Вашему проекту нужна бизнесовая доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:
>
>1. Какой метод необходимо исправить
>2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
>3. Issue поставить label: feature

### Выполнение этапа Product Owner

Создана Issue:

![issue](/img/09_05_issue.png)

>### Developer
>
>Вам пришел новый Issue на доработку, вам необходимо:
>
>1. Создать отдельную ветку, связанную с этим issue
>2. Внести изменения по тексту из задания
>3. Подготовить Merge Requst, влить необходимые изменения в `master`, проверить, что сборка прошла успешно

### Выполнение этапа Developer

Создал merge request и отдельный branch `issue_1`:

![merge_request](/img/09_05_merge_request.png)

Внес изменения в файл `python-api.py`, влил изменения в основную ветку. Сборка прошла успешно:

![merge_build](/img/09_05_merge_build.png)

>### Tester
>
>Разработчики выполнили новый Issue, необходимо проверить валидность изменений:
>
>1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность
>2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый

### Выполнение этапа Tester

Запустил контейнер на базе ранее собранного образа командой:

```bash
docker run -d --name=api -p 5290:5290 registry.gitlab.com/net_dev_man/example-gitlabci/python-api:latest
```

Результат выполнения тестового запроса:

![test_request](/img/09_05_test_request.png)

Закрыл Issue

>## Необязательная часть
>
>Автомазируйте работу тестировщика, пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер и выполняет проверку, например, при помощи curl. На основе вывода - будет приниматься решение об успешности прохождения тестирования

### Выполнение необязательной части

Добавил в pipeline дополнительный этап тестирования. Этап стартует только если успешно завершился этап сборки. Далее выполняется скачивание из репозитория и запуск собранного на предыдущем этапе образа. Тест ответа API выполняется с помощью `curl`. Для успешного прохождения этапа, в ответе должна присутствовать строка `Running`. Файл `.gitlab-ci.yml` имеет следующий вид:

```yaml
image: docker:latest

services:
  - name: docker:dind
    alias: docker

variables:
  IMAGE: python-api
  DOCKER_HOST: tcp://docker:2375
  DOCKER_TLS_CERTDIR: ""

stages:
  - build
  - test

api_build:
  stage: build
  tags:
    - docker
  script:
    - docker build -t "$CI_REGISTRY_IMAGE/$IMAGE:latest" .
    - |
      if [[ "$CI_COMMIT_BRANCH" == "main" ]]; then
        docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" registry.gitlab.com
        docker push "$CI_REGISTRY_IMAGE/$IMAGE:latest"
      fi
  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile

api_test:
  stage: test
  tags:
    - docker
  script:
    - docker run -d --name api "$CI_REGISTRY_IMAGE/$IMAGE:latest"
    - sleep 3s
    - RESP=$(docker exec -i api curl -s http://localhost:5290/get_info)
    - echo "$RESP"
    - |
      if [[ "$RESP" =~ "Running" ]]; then
        echo "Test - OK"
      else
        echo "Test - FAILED"
        exit 255
      fi
  when: on_success
```

Выполнение pipeline завершается успешно:

![testing_pipeline](/img/09_05_testing_pipeline.png)
