# devops-netology

## 3.9. Элементы безопасности информационных систем - Михаил Караханов


**1. Установите Bitwarden плагин для браузера. Зарегестрируйтесь и сохраните несколько паролей.**
- Результат: выполнено \
  ![bitwarden](img/bitwarden.png)

**2. Установите Google authenticator на мобильный телефон. Настройте вход в Bitwarden акаунт через Google authenticator OTP.**
- Результат: выполнено

**3. Установите apache2, сгенерируйте самоподписанный сертификат, настройте тестовый сайт для работы по HTTPS.**
- Настроил проброс портов в vagrant
  ```
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8083
  ```
- Выполнил установку apache командой `sudo apt install apache2`. Включил модуль SSL командой `sudo a2enmod ssl`. Включил модуль mod_headers командой `sudo a2enmod headers`.
- Сгенерировал самоподписанный сертификат
- С помощью ресурса https://ssl-config.mozilla.org/ подготовил конфигурацию веб-сервера:
  ```
  <VirtualHost *:443>
    ServerName dumb.com
    DocumentRoot /var/www/html
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    # enable HTTP/2, if available
    Protocols h2 http/1.1
    # HTTP Strict Transport Security (mod_headers is required) (63072000 seconds)
    Header always set Strict-Transport-Security "max-age=63072000"
  </VirtualHost>

  # intermediate configuration
  SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
  SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
  SSLHonorCipherOrder     off
  SSLSessionTickets       off

  SSLUseStapling On
  SSLStaplingCache "shmcb:logs/ssl_stapling(32768)"
  ```
- Создал простую конфигурацию в файле `/var/www/html/index.html`:
  ```
  <h1>It worked!</h1>
  ```
- Активировал конфигурацию и перезагрузил веб-сервер. С хоста перешел в браузере по ссылке `https://127.0.0.1:8083`. Результат: \
  ![apache](img/apache.png)

**4. Проверьте на TLS уязвимости произвольный сайт в интернете...**
- Выполнил проверку тестового сервера (`https://127.0.0.1:8083`) и сайта `santehnica.ru`. Часть вывода: \
  ![testssl](img/testssl.png)