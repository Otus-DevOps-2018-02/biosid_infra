
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
```bash
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
```bash
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

### Дополнительное задание :: startup_script
Из скриптов `install_ruby.sh`, `install_mongodb.sh` и `deploy.sh` собран скрипт [startup_script.sh](https://gist.githubusercontent.com/biosid/551c4204d09edf00e886e976c2b69e65/raw/df898195796096b5b9ce48c81db8c4fdb744d182/startup_script.sh). Используем его при создании экземпляра виртуальной машины:
```bash
gcloud compute instances create reddit-app-2 \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=https://gist.githubusercontent.com/biosid/551c4204d09edf00e886e976c2b69e65/raw/df898195796096b5b9ce48c81db8c4fdb744d182/startup_script.sh
```
В качестве альтернативы можно хранить этот файл в Storage и обращаться к нему с ключом `--metadata startup-script-url=gs:/startup_script.sh`.

### Дополнительное задание :: firewall
Ручное создание правила брэндмауера можно заменить командой утилиты `gcloud`:
```bash
gcloud compute firewall-rules create default-puma-server \
  --allow=tcp:9292 \
  --network=default \
  --target-tags=puma-server
```

## Homework-6 :: Packer
### Самостоятельное задание
Описана конфигурация packer'а для запекания образа с предустановленными Ruby и MondoDb.
В конфигурации `ubuntu16.json` изменяeмые данные вынесены в раздел `variables` переменных, значение которых задаётся в файле `variables.json` (см. пример `variables.json.example`). Для их применения необходимо выполнять команду `packer build ubuntu16.json` с дополнительным параметром `-var-file=variables.json`, но можно значения передавать прям в командной строке строке ключом `-var`.
Так же добавлен *provisioner* для сохранения в теле образа его имени, чтобы после разворачивания экземпляра ВМ из него всегда было понятно, из какого образа он инстанциирован.
Благодаря созданному таким образом образу создавать виртуальную машину и деплоить на неё приложение reddit можно командой:
```shell
gcloud compute instances create reddit-app-14 \
  --image-family reddit-base \
  --image-project=otus-infra-199514 \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=scripts/startup_script.sh
```
