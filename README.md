# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML" - Михаил Караханов


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```json
    { "info" : "Sample JSON output from our service\\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

  Ответ:
  - 1 строка - добавил экранирование спецсимвола `\t`
  - 6 строка - добавил запятую после `}`
  - 9 строка - закрыл кавычки в ключе `ip`, значение обернул в кавычки

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import time
import os
import json
import yaml

# Подготовка структуры для хранения значений
service_list = [
    { "drive.google.com": None },
    { "mail.google.com": None },
    { "google.com": None }
]

while True:
    # Очистка кэша DNS
    os.popen("systemd-resolve --flush-caches")
    # Выполнение опроса для каждого домена
    for srv in service_list:
        for domain in srv.keys():
            try:
                response = socket.gethostbyname(domain)
                # Проверка полученных значений с предыдущими. Сохранение полученных значений
                if srv[domain] == None:
                    srv[domain] = response
                    print(f"{domain} - {response}")
                elif ( srv[domain] != None ) and ( srv[domain] != response ):
                    print(f"[ERROR] {domain} IP mismatch: {srv[domain]} {response}")
                    srv[domain] = response
                else:
                    print(f"{domain} - {response}")
                time.sleep(1)
            # Обработка исключений
            except socket.gaierror as err:
                print(f"[ERROR] {domain} - {err}")
    # Вывод собранной информации в файлы .json и .yml
    with open("services.json", "w", encoding="utf-8") as j:
        j.write(json.dumps(service_list, indent=4, ensure_ascii=False))
    print(".json file updated")
    with open("services.yml", "w", encoding="utf-8") as y:
        y.write(yaml.dump(service_list, default_flow_style=False, \
            explicit_start=True, explicit_end=True))
    print(".yml file updated")
```

### Вывод скрипта при запуске при тестировании:
```
netadmin@netstation:~/Scripts$ ./1.py 
drive.google.com - 142.251.31.194
mail.google.com - 173.194.69.19
google.com - 142.250.145.100
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
[ERROR] mail.google.com IP mismatch: 173.194.69.19 173.194.69.18
google.com - 142.250.145.100
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
[ERROR] mail.google.com IP mismatch: 173.194.69.18 173.194.69.83
google.com - 142.250.145.100
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
[ERROR] mail.google.com IP mismatch: 173.194.69.83 173.194.69.17
[ERROR] google.com IP mismatch: 142.250.145.100 142.250.145.101
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
[ERROR] mail.google.com IP mismatch: 173.194.69.17 173.194.69.19
[ERROR] google.com IP mismatch: 142.250.145.101 142.250.145.113
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
[ERROR] mail.google.com IP mismatch: 173.194.69.19 173.194.69.83
google.com - 142.250.145.113
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
[ERROR] mail.google.com IP mismatch: 173.194.69.83 173.194.69.17
[ERROR] google.com IP mismatch: 142.250.145.113 142.250.145.139
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
mail.google.com - 173.194.69.17
google.com - 142.250.145.139
.json file updated
.yml file updated
drive.google.com - 142.251.31.194
mail.google.com - 173.194.69.17
[ERROR] google.com IP mismatch: 142.250.145.139 142.250.145.113
.json file updated
.yml file updated
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
[
    {
        "drive.google.com": "142.251.31.194"
    },
    {
        "mail.google.com": "173.194.69.17"
    },
    {
        "google.com": "142.250.145.113"
    }
]
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
- drive.google.com: 142.251.31.194
- mail.google.com: 173.194.69.17
- google.com: 142.250.145.113
...
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
???
```

### Пример работы скрипта:
```
???
```