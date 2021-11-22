# devops-netology

## 3.4. Операционные системы, лекция 2 - Михаил Караханов

**1. На лекции мы познакомились с `node_exporter`. В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для `node_exporter`**
- Результат работы:
  - исполняемый файл распакован в директорию `/opt/node-exporter`
  - создан unit-файл `/etc/systemd/system/node-exporter.service`. Содержание файла:
    ```
    # /etc/systemd/system/node-exporter.service
    [Unit]
    Description=Node exporter daemon
    After=network.target

    [Service]
    EnvironmentFile=-/opt/node-exporter/main.conf
    ExecStart=/opt/node-exporter/node_exporter $EXTRA_OPTS
    KillMode=process
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    ```
  - выполнено подключение и запуск службы командами `sudo systemctl enable node-exporter` и `sudo systemctl start node-exporter`. Далее последовательно выполнены команды stop, start и restart службы. Результат проверки состояния службы:
    ![service status](img/node_exporter.png)