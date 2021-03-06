
# Домашнее задание к занятию "6.3. MySQL" - Михаил Караханов

## Задача 1

>Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
>
>Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и восстановитесь из него.
>
>Перейдите в управляющую консоль `mysql` внутри контейнера.
>
>Используя команду `\h` получите список управляющих команд.
>
>Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.
>
>Подключитесь к восстановленной БД и получите список таблиц из этой БД.
>
>**Приведите в ответе** количество записей с `price` > 300.
>
>В следующих заданиях мы будем продолжать работу с данным контейнером.

**Ответ:**

Вывод статуса сервера (`\s`):

![server_status](/img/server_status.png "MySQL server status")

Запрос количества записей с `price > 300`:

```sql
SELECT COUNT(*) FROM orders WHERE price > 300;
```

Вывод запроса:

![select_price](/img/6_3_select_price.png "Select rows count with price > 300")

## Задача 2

>Создайте пользователя test в БД c паролем test-pass, используя:
>
>- плагин авторизации mysql_native_password
>- срок истечения пароля - 180 дней
>- количество попыток авторизации - 3
>- максимальное количество запросов в час - 100
>- аттрибуты пользователя:
>   - Фамилия "Pretty"
>   - Имя "James"
>
>Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.  
>Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и **приведите в ответе к задаче**.

**Ответ:**

Запрос получение аттрибутов пользователя `test`:

```sql
SELECT * FROM information_schema.USER_ATTRIBUTES WHERE user='test';
```

Результат выполнения запроса:

![user_attrb](/img/06_03_user_attrb.png "Select user attributes")

## Задача 3

>Установите профилирование `SET profiling = 1`.
>Изучите вывод профилирования команд `SHOW PROFILES;`.
>
>Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
>
>Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
>
>- на `MyISAM`
>- на `InnoDB`

**Ответ:**

Запрос типа `engine` таблиц БД `test_db`:

```sql
SELECT TABLE_SCHEMA,TABLE_NAME,ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA='test_db';
```

Результат выполнения запроса:

![show_engine](/img/06_03_show_engine.png "Show table engines")

Время выполнения запросов на изменение `engine` таблицы `test_db.orders`:

![change_engine](/img/06_03_change_engine.png "Show profiles")

## Задача 4

>Изучите файл `my.cnf` в директории /etc/mysql.
>
>Измените его согласно ТЗ (движок InnoDB):
>
>- Скорость IO важнее сохранности данных
>- Нужна компрессия таблиц для экономии места на диске
>- Размер буффера с незакомиченными транзакциями 1 Мб
>- Буффер кеширования 30% от ОЗУ
>- Размер файла логов операций 100 Мб
>
>Приведите в ответе измененный файл `my.cnf`.

**Ответ:**

Отредактированный согласно ТЗ файл `/etc/mysql/my.cnf`:

```bash
#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL
innodb-flush-log-at-trx-commit=2
innodb_file_per_table=ON
innodb-log-buffer-size=1048576
innodb-buffer-pool-size=321912832
innodb-log-file-size=104857600

# Custom config should go here
!includedir /etc/mysql/conf.d/
```
