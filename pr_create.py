#!/usr/bin/env python3

import os
import requests
import subprocess
import json
from sys import argv
from datetime import datetime
from pprint import pprint

PR_MESSAGE = argv[1]
GIT_TOKEN = os.getenv("GIT_TOKEN")
BRANCH_NAME = f"{os.getenv('USER')}_{datetime.now().strftime('%d%m%Y')}"

# Создание отдельной ветки от текущей
with subprocess.Popen(f"git switch -c {BRANCH_NAME}", shell=True, stdout=subprocess.DEVNULL) as proc:
    proc.wait(timeout=3)
    if proc.returncode != 0:
        print("Error! Branch not created!")
    else:
        print(f"Branch {BRANCH_NAME} successfully created!")

# Редактирование файла в новой ветке  
with open("config.txt", "a", encoding="utf-8") as f:
    f.write("This is a new config patch\n")

# Добавление изменений в индекс
with subprocess.Popen("git add .", shell=True, stdout=subprocess.DEVNULL) as proc:
    proc.wait(timeout=3)

# commit и push ветки
with subprocess.Popen(f"git commit -m \"{PR_MESSAGE}\" && git push -u origin {BRANCH_NAME}", \
    shell=True, stdout=subprocess.DEVNULL) as proc:
    proc.wait(timeout=3)
    if proc.returncode != 0:
        print("Error with commit or push!")
    else:
        print("Success!")

# custom_headers = {'Authorization': f"token {GIT_TOKEN}"}
# r = requests.get("https://api.github.com/user", headers=custom_headers)
# pprint(r.json())