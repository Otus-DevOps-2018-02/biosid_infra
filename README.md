# biosid_infra
biosid Infra repository

## Homework-4 :: Бастион
### Самостоятельное задание
Параметры подключения:
```
bastion_IP = 35.204.59.98
someinternalhost_IP = 10.164.0.3
```
> Исследовать способ подключения к **someinternalhost** в одну команду из вашего рабочего устройства, проверить работоспособность найденного решения и внести его в README<span></span>.md в вашем репозитории
```shell
eval $(ssh-agent)
ssh-add ~/.ssh/gcp.biosid
ssh -A -t biosid@35.204.59.98 ssh 10.164.0.3
```
Команду `ssh-add` необходимо выполнять при открытии каждой новой консоли *Ubuntu for Windows*.

### Дополнительное задание
> Предложить вариант решения для подключения из консоли при помощи команды вида `ssh someinternalhost` из локальной консоли рабочего устройства, чтобы подключение выполнялось по алиасу **someinternalhost** и внести его в README<span></span>.md в вашем репозитории

Создать файл `~/.ssh/config`, если отсутствует.
Добавить конфигурацию:
```
Host gcp-bastion
  HostName 35.204.59.98
  Port 22
  User biosid
  IdentityFile ~/.ssh/gcp.biosid
```
В случае ошибки *"Bad owner or permissions on /home/biosid/.ssh/config"* выполнить `chmod 600 ~/.ssh/config`
В результате можно подключаться к **бастиону** как `ssh gcp-bastion`.
Добавить конфигурацию:
```
Host gcp-someinternalhost
  HostName 10.164.0.3
  Port 22
  User biosid
  ProxyCommand ssh -A -t biosid@35.204.59.98 -W %h:%p
```
В результате можно подключаться к **someinternalhost** как:
```shell
ssh-add ~/.ssh/gcp.biosid
ssh gcp-someinternalhost
```

## Homework-5 :: Reddit app deploy
### Самостоятельное задание
Параметры подключения:
```
testapp_IP = 35.189.201.70
testapp_port = 9292
```
В ходе работы выполнено:
 1. создана VM с внешним IP и правилом брэндмауэра на входящий трафик с порта 9292
 2. установлены Ruby и Bundler. Для быстрой установки создан скрипт `install_ruby.sh`
 3. установлен MongoDb. Для быстрой установки создан скрипт `install_mongodb.sh`
 4. установлено приложение из репозитория [express42/reddit](https://github.com/express42/reddit/tree/monolith). Для быстрой установки создан скрипт `deploy.sh`

Проверка приложения: http://35.189.201.70:9292/
