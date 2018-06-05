
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
```bash
gcloud compute instances create reddit-app-14 \
  --image-family reddit-base \
  --image-project=otus-infra-199514 \
  --machine-type=f1-micro \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=scripts/startup_script.sh
```

### Задание со *
Создана конфигурация `immutable.json`, согласно которой собирается образ с предустановленными Ruby, MongoDb. а так же проинсталлированным приложением Reddit, запускающемся на http-сервере puma в качестве службы посредством `systemd unit`. У данного образа image_family = reddit-full.
С помощью скрипта `config-scripts/create-reddit-vm.sh` в одну команду (с помощью утилиты `gcloud`) создаётся экземпляр виртуальной машины с запущенным приложением Reddit.

## Homework-7 :: Terraform
### Самостоятельное задание
Описана конфигурация terraform'а для создания экземпляра виртуальной машины с развёрнутым приложением Reddit.
Согласно конфигурации создаётся правило файрвола с тегом сети reddit-app, экземпляр вирутальной машины из актуального образа семейства reddit-base, машине назначается тег сети reddit-app. Кроме того инструментарием provisioner на виртуальную машину доставляется приложение Reddit и добавляется в службы http-сервер puma, который обслуживает это приложение.
Последовательными командами `terraform plan` и `terraform apply` можно развернуть инфраструктуру и задеплоить приложение. Благодаря output-параметрам, в консоли сразу видим внешний ip-адрес созданной машины, а с помощью `terraform.tfvars` (создаётся из `terraform.tfvars.example`) можно задать существенные параметры (ID проекта в GCP, пути к ssh-ключам, регион и зона хостинга).
Очистка созданной инфраструктуры (правило файрвола и виртуальная машина) выполняется командой `terraform destroy`.

### Задание со *
В конфигурацию terraform в метаданные проекта добавлен набор ssh-ключей:
```
resource "google_compute_project_metadata" "default" {
  metadata {
    ssh-keys = "appuser1:${file("${var.public_key_path}")} appuser2:${file("${var.public_key_path}")} appuser3:${file("${var.public_key_path}")}
}
```
Но после повторного выполнения `terraform apply` добавленные в метаданные проекта вручную через web-консоль ssh-ключи пропадают, т.к. конфигурация terraform приводит инфраструктуру всегда в состояние, описанное в конфигурации.

## Homework-8 :: Terraform Modules
### Самостоятельное задание
Созданная в предыдущем задании инфраструктура в виде одной виртуальной машины с приложением и субд преобразована в *сервер приложений* и *сервер баз данных*. Для этого конфигурация переписана в виде модулей **app**, **db**, **vpc** для создания соответственно сервера приложений, сервера баз данных и настройки файрволла. Благодаря описанию инфраструктуры модулями удалось без значительного дублирования кода создать конфигурации для окружений **prod** и **stage**. Так же ознакомился с различными видами хранилищ модулей: Terraform Registry, GitHub, Bitbucket, Local.
Деплой инфраструктуры в разные окружения ничем не отличается и выполняется одной командой:
```bash
cd terraform/stage && terraform init && terraform apply
```
при наличии сконфигурированного `terraform.tfvars`.

### Задание со *
Хранение состояния инфраструктур перенесено в backend.
Для этого в Google Cloud Storage создан Bucket (**Важно!** имя bucket должно быть уникальным на весь GCS). В файле `backend.tf` описана конфигурация, где **удалённо** должно храниться состояние. Благодаря параметру *prefix* можно для каждого окружения задать свой путь хранения (в случае с GCP *prefix* используется как путь на диске).
Так же в качестве хранилища можно использовать другие облачные провайдеры, такие как consul, etcd и прочие key-value-хранилища.

### Задание со *
Модуль app (создание сервера приожения) расширен provisioner-ами для деплоя на него приложения Reddit. Т.к. теперь сервер БД размещён на другом хосте, то приложению (службе) указан DATABASE_URL с приватным адресом сервера БД.
Модуль db (создание сервера баз данных) расширен provisioner-ами для настройки MongoDb, чтобы он слушал не только 127.0.0.1, но и приватный адрес виртуалки - задаётся [net]bindIp в mongod.conf. В противном случае приложение не может подключиться к БД.

## Homework-9 :: Ansible base configuration
Описана базовая конфигурация `ansible` для выполнения команд на серверах, созданных с помощью `cd terraform/stage && terraform init && terraform apply`.
Примеры команд:
```bash
ansible all -m ping -i inventory.yml
ansible app -m shell -a 'ruby -v; bundler -v'
ansible db -m service -a name=mongod
ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/sologm/reddit'
ansible-playbook clone.yml
```

### Задание со *
Изучен и реализован динамический inventory.
```bash
# inventory, прочитанный из файла **inventory.json**
ansible all -m ping -i json_inventory.sh

# совсем динамический inventory
ansible db -m ping -i gce_inventory.sh
```
> По какой-то причине в обоих случаях в консоль пишется
> ```
> [ERROR]:
> ```

Более динамический есть только [gce.py](https://github.com/ansible/ansible/blob/devel/contrib/inventory/gce.py) :)
При желании параметр `-i gce_inventory.sh` можно унести в `ansible.cfg`

## Homework-10 :: Ansible playbooks
Настройка серверов выполняется с помощью ansible-плейбуков. Все сценарии разделены на раздельные плейбуки `app.yml`, `db.yml`, `deploy.yml` и побъединены в единый плейбук `site.yml`. Теперь конфигурация сервисов и установка приложений выполняется в одну команду:
```bash
ansible-playbook site.yml
```
Так же `ansible`-плейбуки использованы взамен `shell`-команд для настройки базовых образов с помощью `packer`. Зампекание образов теперь выполняется из корня репозитория:
```bash
packer build -var-file=packer/variables.json packer/app.json
packer build -var-file=packer/variables.json packer/db.json
```

### Задание со *
Случайно было выполнено в предыдущем задании.
Теперь по умолчанию в `ansible.cfg` используется динамический `inventory = ./gce_inventory.sh`.

## Homework-11 :: Ansible roles, environments
С помощью утилиты `ansible-galaxy` удобно созданы шаблоны ролей `app` и `db`, в них перенесены задачи и обработчики из `app.yml` и `db.yml` соответсвенно. Теперь модули можно будет переиспользовать, например, для разных окружений `stage` и `prod`, перечисленных в папке `environments`.
При такой структуре настройках хостов будет выполняться командами:
```bash
ansible-playbook -i environments/stage/gce_inventory.sh playbooks/site.yml
ansible-playbook -i environments/prod/inventory playbooks/site.yml
```
Первая команда может и не содержать параметр `-i`, т.к. этот inventory указан по умолчанию в `ansible.cfg`.
