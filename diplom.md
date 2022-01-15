
# Курсовая работа по итогам модуля "DevOps и системное администрирование" - Михаил Караханов

## Выполненные работы

1. Создана ВМ `netologyvm` на базе Oracle VirtualBox, установлена OC **Debian 11 (bullseye)**
2. Установка и настройка `ufw`:
    - выполнена установка пакета командой `sudo apt install ufw`
    - ВМ имеет несколько сетевых интерфейсов (lo, NAT и для связности с хостом)

    ```bash
    netadmin@netologyvm:~$ ip -br addr
    lo               UNKNOWN        127.0.0.1/8 ::1/128 
    enp0s3           UP             10.0.2.15/24 fe80::a00:27ff:fe03:386d/64 
    enp0s8           UP             192.168.56.101/24 fe80::a00:27ff:fea8:f000/64 
    ```

    - трафик на интерфейсе lo разрешен правилами, прописанными в файле `/etc/ufw/before.rules`

    ```bash
    # allow all on loopback
    -A ufw-before-input -i lo -j ACCEPT
    -A ufw-before-output -o lo -j ACCEPT
    ```

    - разрешен входящий трафик на порты `22/TCP` и `443/TCP`

    ```bash
    sudo ufw allow in on enp0s3 from any proto tcp to any port 22
    sudo ufw allow in on enp0s8 from any proto tcp to any port 22
    sudo ufw allow in on enp0s3 from any proto tcp to any port 443
    sudo ufw allow in on enp0s8 from any proto tcp to any port 443
    ```

    - `ufw` запущен и активирован командой `sudo ufw enable` \
    ![ufw status](diplom_img/ufw_status.png "ufw status") \
    *ufw настроен и активирован*

3. Выполнена установка Hashicorp Vault согласно инструкции для Linux

    ```bash
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt update && sudo apt install vault
    ```

    ![vault_setup](diplom_img/vault_setup.png "Vault Status") \
    *Vault установлен корректно*

4. Настройка центра сертификации:

    - в файле `~/.profile` добавлены две переменные окружения для запуска Vault

    ```bash
    export VAULT_ADDR='http://127.0.0.1:8200'
    export VAULT_DEV_ROOT_TOKEN_ID='root'
    ```

    - Vault запущен в режиме dev в отдельной сессии tmux командой `vault server -dev`
    - создан корневой CA с именем `example.com` согласно инструкции

    ```bash
    netadmin@netologyvm:~$ vault secrets enable pki
    Success! Enabled the pki secrets engine at: pki/
    netadmin@netologyvm:~$ vault secrets tune -max-lease-ttl=87600h pki
    Success! Tuned the secrets engine at: pki/
    netadmin@netologyvm:~$ vault write -field=certificate pki/root/generate/internal common_name="example.com" ttl=87600h > CA_cert.crt
    netadmin@netologyvm:~$ vault write pki/config/urls \
        issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
        crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
    Success! Data written to: pki/config/urls
    netadmin@netologyvm:~$
    ```

    - скопировал сгенерированный выше корневой сертификат на хост (для импорта в браузер) командой `scp netadmin@192.168.56.101:~/CA_cert.crt ~/`
    - создан промежуточный CA с именем `example.com Intermediate Authority` согласно инструкции

    ```bash
    netadmin@netologyvm:~$ vault secrets enable -path=pki_int pki
    Success! Enabled the pki secrets engine at: pki_int/
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ vault secrets tune -max-lease-ttl=43800h pki_int
    Success! Tuned the secrets engine at: pki_int/
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ vault write -format=json pki_int/intermediate/generate/internal \
        common_name="example.com Intermediate Authority" \
        | jq -r '.data.csr' > pki_intermediate.csr
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate' > intermediate.cert.pem
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
    Success! Data written to: pki_int/intermediate/set-signed
    netadmin@netologyvm:~$
    ```

    - создана роль с именем `example-dot-com`, используемая для выпуска конечных сертификатов

    ```bash
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ vault write pki_int/roles/example-dot-com \
        allowed_domains="example.com" \
        allow_subdomains=true \
        max_ttl="720h"
    Success! Data written to: pki_int/roles/example-dot-com
    netadmin@netologyvm:~$
    ```

    - выпущен сертификат для домена `test.example.com`, срок действия 1 месяц. Созданы файлы сертификата и ключа для импорта в nginx

    ```bash
    netadmin@netologyvm:~$ vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="720h" > payload.json
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ jq -r '.data.private_key' payload.json > test.example.com.key
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ jq -r '.data.certificate' payload.json > test.example.com.crt
    netadmin@netologyvm:~$ 
    netadmin@netologyvm:~$ jq -r '.data.ca_chain[]' payload.json >> test.example.com.crt
    netadmin@netologyvm:~$
    ```
