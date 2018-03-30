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
