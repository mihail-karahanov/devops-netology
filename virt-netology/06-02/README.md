# Домашнее задание к занятию "6.2. SQL" - Михаил Караханов

## Задача 1

>Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.
>
>Приведите получившуюся команду или docker-compose манифест.

**Ответ:**

Для запуска инстанса PostreSQL 12 подготовил следующий файл `docker-compose.yml`:

```yaml
version: "3.9"

networks:
  db_backend:
    driver: bridge

volumes:
    pg_data:
    pg_backup:

services:

  db:
    image: postgres:12
    container_name: postgres
    env_file:
      - .env
    volumes:
      - pg_data:/var/lib/postgresql/data
      - pg_backup:/var/lib/postgresql/data/backup
    restart: always
    ports:
      - 5432:5432
    networks:
      - db_backend
  
  adminer:
    image: adminer:4.8.1-standalone
    container_name: adminer
    restart: always
    ports:
      - 8080:8080
    networks:
      - db_backend

```

И дополнительный файл `.env` с переменными окружения:

```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=f2mNjNJrXy
POSTGRES_DB=test_db
PGDATA=/var/lib/postgresql/data/pgdata
```

Результат выполнения команды `docker-compose -f ./docker-compose.yml up -d`:

![postgres_docker](/img/postgres_docker.png "Running containers")

## Задача 2

>В БД из задачи 1:
>
>- создайте пользователя test-admin-user и БД test_db
>- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
>- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
>- создайте пользователя test-simple-user  
>- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
>
>Таблица orders:
>
>- id (serial primary key)
>- наименование (string)
>- цена (integer)
>
>Таблица clients:
>
>- id (serial primary key)
>- фамилия (string)
>- страна проживания (string, index)
>- заказ (foreign key orders)
>
>Приведите:
>
>- итоговый список БД после выполнения пунктов выше,
>- описание таблиц (describe)
>- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
>- список пользователей с правами над таблицами test_db

**Ответ:**

Результаты выполнения задачи:

- итоговый список БД после выполнения пунктов выше

  ![db_list](/img/db_list.png "Databases")

- описание таблиц (describe)

  ![descr_tables](/img/descr_tables.png "Tables structures")

- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db

  ```sql
  SELECT grantee,table_name,privilege_type
  FROM information_schema.role_table_grants
  WHERE (grantee != 'postgres' AND grantee != 'PUBLIC');
  ```

- список пользователей с правами над таблицами test_db

  ![list_priv](/img/list_priv.png "User privileges list")

## Задача 3

>Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:
>
>Таблица orders
>
>|Наименование|цена|
>|------------|----|
>|Шоколад| 10 |
>|Принтер| 3000 |
>|Книга| 500 |
>|Монитор| 7000|
>|Гитара| 4000|
>
>Таблица clients
>
>|ФИО|Страна проживания|
>|------------|----|
>|Иванов Иван Иванович| USA |
>|Петров Петр Петрович| Canada |
>|Иоганн Себастьян Бах| Japan |
>|Ронни Джеймс Дио| Russia|
>|Ritchie Blackmore| Russia|
>
>Используя SQL синтаксис:
>
>- вычислите количество записей для каждой таблицы
>- приведите в ответе:
> - запросы
> - результаты их выполнения.

**Ответ:**

SQL-запросы количества записей в таблицах `orders` и `clients`:

```sql
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM clients;
```

Результаты выполнения запросов:

![select_count](/img/select_count.png "Request results")

## Задача 4

>Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.
>
>Используя foreign keys свяжите записи из таблиц, согласно таблице:
>
>|ФИО|Заказ|
>|------------|----|
>|Иванов Иван Иванович| Книга |
>|Петров Петр Петрович| Монитор |
>|Иоганн Себастьян Бах| Гитара |
>
>Приведите SQL-запросы для выполнения данных операций.
>
>Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.  
>Подсказка - используйте директиву `UPDATE`.

**Ответ:**

SQL-запросы для установки `order_id` в таблице `clients` согласно задачи:

```sql
UPDATE clients SET order_id = 3 WHERE surname = 'Иванов Иван Иванович';
UPDATE clients SET order_id = 4 WHERE surname = 'Петров Петр Петрович';
UPDATE clients SET order_id = 5 WHERE surname = 'Иоганн Себастьян Бах';
```

SQL-запрос всех пользователей, совершивших заказ:

```sql
SELECT surname,country,order_id FROM clients WHERE order_id IS NOT NULL;
```

Результат запроса:

![select_clients_worders](/img/select_client_worders.png "Client list with orders ID")

## Задача 5

>Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).
>
>Приведите получившийся результат и объясните что значат полученные значения.

**Ответ:**

Результат выполнения запроса из предыдущего задания с использованием директивы `EXPLAIN`:

![explain_result](/img/explain_result.png "EXPLAIN output")

Директива `EXPLAIN` возвращает execution plan (план выполнения) запроса, указанного после директивы. В выводе указывается тип используемого сканирования целевой таблицы (`Seq scan`), наименование таблицы (`clients`), и в скобках примерные метрики выполнения запроса:

- `cost=0.00..13.30` - стартовая и конечная предполагаемая "стоимость" выполнения запроса. Измеряется в единицах чтения "страниц" с диска
- `rows=328` - это предполагаемое количество строк, по подсчетам PostgreSQL, которое может быть возвращено данным запросом
- `width=212` - предполагаемый размер в байтах каждой строки, возвращенной данным запросом

Также в строке `Filter` выводится условие отбора полученных запросом данных.

Параметры, для расчета этих значений, задаются в файле `postgresql.conf`, раздел `Planner Cost Constants`.

## Задача 6

>Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).
>
>Остановите контейнер с PostgreSQL (но не удаляйте volumes).
>
>Поднимите новый пустой контейнер с PostgreSQL.
>
>Восстановите БД test_db в новом контейнере.
>
>Приведите список операций, который вы применяли для бэкапа данных и восстановления.

**Ответ:**

Для выполнения полного бэкапа я использовал утилиту `pg_dumpall` со следующими параметрами:

```bash
pg_dumpall -U postgres > /var/lib/postgresql/data/backup/my_psql_backup.sql
```

Для запуска "пустого" контейнера с PostgreSQL пришлось выполнить команду `docker-compose down` и удалить volume `pg_data`. Volume `pg_backup` остался нетронутым.

После запуска контейнера, выполнил восстановление БД из бэкапа следующей командой:

```bash
psql -f /var/lib/postgresql/data/backup/my_psql_backup.sql -U postgres
```
