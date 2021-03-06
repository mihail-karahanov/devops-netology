
# Домашнее задание к занятию "6.4. PostgreSQL" - Михаил Караханов

## Задача 1

>Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
>
>Подключитесь к БД PostgreSQL используя `psql`.
>
>Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.
>
>**Найдите и приведите** управляющие команды для:
>
>- вывода списка БД
>- подключения к БД
>- вывода списка таблиц
>- вывода описания содержимого таблиц
>- выхода из psql

**Ответ:**

Управляющие команды для:

- *вывода списка БД* - для вывода списка БД используется команда `\l` или `\l+` для более детального вывода
- *подключения к БД* - для подключения к БД используется команда `\c {DBNAME}` или `\connect {DBNAME}`
- *вывода списка таблиц* - можно использовать команду `\d` или `\dt`
- *вывода описания содержимого таблиц* - для вывода описания таблиц можно использовать команду `\d+ {TABLENAME}`
- *выхода из psql* - для выхода из `psql` используется команда `\q`

## Задача 2

>Используя `psql` создайте БД `test_database`.
>
>Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).
>
>Восстановите бэкап БД в `test_database`.
>
>Перейдите в управляющую консоль `psql` внутри контейнера.
>
>Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
>
>Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах.
>
>**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

**Ответ:**

Команда запроса:

```sql
SELECT tablename,attname,avg_width
FROM "pg_stats"
WHERE
avg_width = (SELECT MAX(avg_width) FROM "pg_stats" WHERE tablename='orders');
```

Результат запроса:

![select_max_value](/img/06_04_select_max.png "Select max avg_width value")

## Задача 3

>Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
>поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
>провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
>
>Предложите SQL-транзакцию для проведения данной операции.
>
>Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

**Ответ:**

Транзакция для выполнения разбиения таблицы:

```sql
CREATE TABLE public.orders_new
    (LIKE public.orders INCLUDING ALL EXCLUDING INDEXES)
    PARTITION BY RANGE (price);

CREATE TABLE public.orders_new_lower499 PARTITION OF public.orders_new
    FOR VALUES FROM (MINVALUE) TO (499);

CREATE TABLE public.orders_new_higher499 PARTITION OF public.orders_new
    FOR VALUES FROM (499) TO (MAXVALUE);

CREATE INDEX ON public.orders_new_lower499 (price);
CREATE INDEX ON public.orders_new_higher499 (price);

START TRANSACTION;
INSERT INTO public.orders_new
    SELECT * FROM public.orders;
COMMIT;
```

Ручное разбиение можно было бы исключить, если бы на этапе проектирования таблицы она создавалась как изначально секционированная (с указанием оператора `PARTITION BY`).

## Задача 4

>Используя утилиту `pg_dump` создайте бекап БД `test_database`.
>
>Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

**Ответ:**

Выполнен бэкап БД `test_database` командой:

```bash
pg_dump -U postgres test_database > /var/lib/postgresql/data/backup/test_database_backup.sql
```

Для добавления уникальности значений в столбце `title` можно добавить в бэкап-файл следующую команду:

```sql
ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_utitle UNIQUE (title);
```
