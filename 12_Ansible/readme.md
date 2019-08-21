 ### Подготовить стенд на Vagrant как минимум с одним сервером. 
 На этом сервере используя Ansible необходимо развернуть nginx со следующими условиями:
 - необходиимо использовать модуль yum/apt
 - конфигурационные файлы должны быть взяты из шаблона jinja2 с переменными
 - после установки nginx должен слушать нестандартный порт 8080
 - nginx должен быть enabled в systemd
 - должен быть использован notify для старта nginx после установки
 - сделать все с использованиес Ansible роли
 
 

Версия Ansible => 2.4 требует для работы Python 2.6
```
##python -V
Python 2.7.15

##ansible --version
ansible 2.6.0
```
Проверяем доступность узлов:
```
ansible nginx -i inventory/hosts -m ping
```
Если есть желание подключаться к Vagrant со своей машинки, то:
```
##vagrant ssh-config
Host nginx - имя хоста
HostName 127.0.0.1 - IP адрес
User vagrant - имя пользователя
Port 2222 - порт, который проброшен на 127.0.0.1
IdentifyFile .vagrant/machines/nginx/virtualbox/private_key
```
Используя эти параметры можно создать инвентори inventory/hosts
```
[web]
nginx ansible_host=127.0.0.1 ansible_port=2222 ansible_user=vagrant ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key
```

чтобы не писать одно и то же, например, пользователя, его можно занести в файл ansible.cfg
```
[defaults]
inventory = inventory/hosts
remote_user = ansible
host_key_checking = False
retry_files_enabled = False
```
Не забываем пользователю выдать права sudo без пароля

Однострочники:
```
ansible nginx -m command -a "uname -r" #посмотрим ядро
ansible nginx -m systemd -a name=firewalld #проверим статус сервиса
ansible nginx -m yum -a "name=epel-release state=present" -b #установим репу
```
Посмотреть теги:
```
ansible-playbook  -i inventory/hosts playbook/nginx_install.yml --list-tags

ansible-playbook playbook/nginx_install.yml -t nginx-package #установить только по тегу и только nginx

ansible-playbook  -i inventory/hosts playbook/nginx_install.yml 

ansible-playbook  -i inventory/hosts playbook/nginx_conf.yml  --syntax-check #проверить синтаксис

curl http://192.168.11.151:8080
```









