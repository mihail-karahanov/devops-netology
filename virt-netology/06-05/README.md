# Домашнее задание к занятию "6.5. Elasticsearch" - Михаил Караханов

## Задача 1

>В этом задании вы потренируетесь в:
>
>- установке elasticsearch
>- первоначальном конфигурировании elastcisearch
>- запуске elasticsearch в docker
>
>...
>
>В ответе приведите:
>
>- текст Dockerfile манифеста
>- ссылку на образ в репозитории dockerhub
>- ответ `elasticsearch` на запрос пути `/` в json виде

**Ответ:**

Содержимое Dockerfile для сборки образа:

```dockerfile
FROM centos:centos7

RUN yum -y install perl-Digest-SHA wget && yum -y clean all && \
    wget -c https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz && \
    wget -c https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.1.0-linux-x86_64.tar.gz && \
    rm -rf elasticsearch-8.1.0-linux-x86_64.tar.gz && rm -rf elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512 && \
    groupadd -g 1000 elasticsearch && useradd elasticsearch -u 1000 -g 1000 && \
    mkdir -p /var/lib/elasticsearch && chown -R 1000:1000 /var/lib/elasticsearch && \
    chown -R elasticsearch:root /elasticsearch-8.1.0 && \
    rm -rf /var/cache

COPY elasticsearch.yml /elasticsearch-8.1.0/config

WORKDIR /elasticsearch-8.1.0

USER 1000:1000

EXPOSE 9200 9300

CMD [ "./bin/elasticsearch" ]
```

Файл конфигурации `elasticsearch.yml`:

```yml
cluster.name: "my-cluster-app"
node.name: "netology_test"
cluster.initial_master_nodes: netology_test
path.data: "/var/lib/elasticsearch"
path.logs: "/var/lib/elasticsearch"
network.host: 0.0.0.0
xpack.security.enabled: false
xpack.security.http.ssl.enabled: false
xpack.security.transport.ssl.enabled: false
```

[Ссылка](https://hub.docker.com/r/mihailkarahanov/myelastic/tags) на репозиторий в DockerHub

Вывод запроса `curl http://localhost:9200/`:

```json
{
  "name": "netology_test",
  "cluster_name": "my-cluster-app",
  "cluster_uuid": "_f4G8CwTR5SP8p3kehOFow",
  "version": {
    "number": "8.1.0",
    "build_flavor": "default",
    "build_type": "tar",
    "build_hash": "3700f7679f7d95e36da0b43762189bab189bc53a",
    "build_date": "2022-03-03T14:20:00.690422633Z",
    "build_snapshot": false,
    "lucene_version": "9.0.0",
    "minimum_wire_compatibility_version": "7.17.0",
    "minimum_index_compatibility_version": "7.0.0"
  },
  "tagline": "You Know, for Search"
}
```

## Задача 2

>В этом задании вы научитесь:
>
>- создавать и удалять индексы
>- изучать состояние кластера
>- обосновывать причину деградации доступности данных
>
>Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:
>
>| Имя | Количество реплик | Количество шард |
>|-----|-------------------|-----------------|
>| ind-1| 0 | 1 |
>| ind-2 | 1 | 2 |
>| ind-3 | 2 | 4 |
>
>Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
>
>Получите состояние кластера `elasticsearch`, используя API.
>
>Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
>
>Удалите все индексы.
>
>...
>

**Ответ:**

Индексы добавил согласно таблицы в условии задачи. Вывод запроса состояния индексов в формате JSON:

```json
[
  {
    "health": "green",
    "status": "open",
    "index": "ind-1",
    "uuid": "TBheuxUjRs6oMdbSfcUBEA",
    "pri": "1",
    "rep": "0",
    "docs.count": "0",
    "docs.deleted": "0",
    "store.size": "225b",
    "pri.store.size": "225b"
  },
  {
    "health": "yellow",
    "status": "open",
    "index": "ind-3",
    "uuid": "xqgFWvUjR3a7nq8ciyCfWA",
    "pri": "4",
    "rep": "2",
    "docs.count": "0",
    "docs.deleted": "0",
    "store.size": "900b",
    "pri.store.size": "900b"
  },
  {
    "health": "yellow",
    "status": "open",
    "index": "ind-2",
    "uuid": "2zNJUiZWRN27NsR9_NYKMQ",
    "pri": "2",
    "rep": "1",
    "docs.count": "0",
    "docs.deleted": "0",
    "store.size": "450b",
    "pri.store.size": "450b"
  }
]
```

Часть индексов и, соответственно, кластер находятся в состоянии `yellow` т.к. при первоначальном конфигурировании кластера не были настроены параметры кол-ва шард и реплик для индексов (параметры `index.number_of_shards` и `index.number_of_replicas` были оставлены по умолчанию). Часть шардов неактивна, что и приводит к деградации кластера.

## Задача 3

В данном задании вы научитесь:

- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:

- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`
