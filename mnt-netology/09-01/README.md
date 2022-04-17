# Домашнее задание к занятию "09.01 Жизненный цикл ПО" - Михаил Караханов

## Основная часть

>В рамках основной части необходимо создать собственные workflow для двух типов задач: bug и остальные типы задач. Задачи типа bug должны проходить следующий жизненный цикл:
>
>1. Open -> On reproduce
>2. On reproduce <-> Open, Done reproduce
>3. Done reproduce -> On fix
>4. On fix <-> On reproduce, Done fix
>5. Done fix -> On test
>6. On test <-> On fix, Done
>7. Done <-> Closed, Open
>
>Остальные задачи должны проходить по упрощённому workflow:
>
>1. Open -> On develop
>2. On develop <-> Open, Done develop
>3. Done develop -> On test
>4. On test <-> On develop, Done
>5. Done <-> Closed, Open
>
>Создать задачу с типом bug, попытаться провести его по всему workflow до Done. Создать задачу с типом epic, к ней привязать несколько задач с типом task, провести их по всему workflow до Done. При проведении обеих задач по статусам использовать kanban. Вернуть задачи в статус Open.
>Перейти в scrum, запланировать новый спринт, состоящий из задач эпика и одного бага, стартовать спринт, провести задачи до состояния Closed. Закрыть спринт.
>
>Если всё отработало в рамках ожидания - выгрузить схемы workflow для импорта в XML. Файлы с workflow приложить к решению задания.

**Ответ:**

Создал проект `devops-netology` и настроил workflow согласно задания. Создал одну задачу с типом `bug`, одну задачу `epic` и две обычные задачи, прилинкованые к epic. Скрин доски kanban:

![open_kanban_tasks](/img/09_01_open_kanban.png "Open tasks")

Провел все задачи по настроенному workflow до статуса `Done`. Скрин:

![done_kanban_tasks](/img/09_01_done_kanban.png "Done tasks")

Схемы workflow выгружены в XML и отправлены отдельными вложениями.
