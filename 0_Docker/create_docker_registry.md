# Установка Docker registry

Для начала установим docker

```
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

Для /var/lib/docker создаем отдельную директорию
```
lvs
vgs
lvcreate -L 60G -n docker s9500fkcmn01
lvs
mkfs.ext4 /dev/s9500fkcmn01/docker
ll /var/lib/docker
mkdir /var/lib/docker
mount /dev/s9500fkcmn01/docker /var/lib/docker
cat >> /etc/fstab
/dev/mapper/s9500fkcmn01-docker  /var/lib/docker  ext4  defaults         1 1
```

Я предварительно загрузила на тестовую машину registry-raw командой 
```
docker run -d -p 19000:5000 --restart=always --name registry registry:2
```
потом скопировала и перенесла на другую машину
```
docker save -o registry-raw.tar docker.io/registry
```

На удаленной машине выгрузила registry
```
docker load -i registry-raw.tar
docker images
docker run -d -p 19000:5000 --restart=always --name registry-openshift registry:2
docker ps
```
в диретории /opt/docker-registry
создала 
```
cat > docker-compose.yml

version: '3.7'
services:
  registry-openshift:
    restart: always
    image: registry:2
    volumes:
      - type: bind
        source: /var/lib/registry
        target: /var/lib/registry
        consistency: consistent
    ports:
      - "19000:5000/tcp"

```

Создаем под реджистри отдельную ТМ
```
lvs
vgs
lvcreate -L 20G -n registry s9500fkcmn01
lvs
mkfs.ext4 /dev/s9500fkcmn01/registry
ll /var/lib/registry
mkdir /var/lib/registry
mount /dev/s9500fkcmn01/registry /var/lib/registry

cat >> /etc/fstab
/dev/mapper/s9500fkcmn01-registry  /var/lib/registry  ext4  defaults         1 1
```

Возвращаемся к /opt/docker-registry и запускаем там демонизированый контейнер с registry
```
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose -x 127.0.0.1:8888
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version
docker-compose up -d
docker ps
```
Если возникает ошибка, значит нужно предыдущий закрыть
```
docker rm -f b9edf9048092
docker ps
docker ps -a
```

СОбираем образы для последующего переноса:
```
for i in `docker images |awk 'BEGIN{OFS = ":"}{print $1, $2}'` ; do docker save -o `$i | awk 'BEGIN{FS = "/"}{print $3}'`.tar $i; done

```

Будут созданы файлы по именам образов для загрузки, мы их и перенесем.

на машине, куда переносим - выполняется 
```
for i in `ls`; do docker load -i $i; done
```

Теперь пытаемся забросить в репозиторий 

```
docker tag openshift/origin-node:v3.11 192.168.209.18:19000/origin-node:v3.11 #смена тега
# или скриптом 
for i in ` docker images | awk 'BEGIN{OFS = ":"}{print $1, $2}' | grep -v REPOSITORY | grep -v registry`; do echo " docker tag $i 192.168.209.18:19000/`echo $i | awk -F'/' '{print $2}'`" ; done

docker rmi -f openshift/origin-node:v3.11 #удаляем предыдущий
# или удалить сприптом
for i in ` docker images| grep 5000 | awk 'BEGIN{OFS = ":"}{print $1, $2}' | grep -v REPOSITORY | grep -v registry`; do echo " docker rmi -f $i " ; done

docker push localhost:19000/origin-deployer:v3.11.0 #загружаем в реджестри image
# или скриптом
for i in ` docker images| grep 19000 | awk 'BEGIN{OFS = ":"}{print $1, $2}' | grep -v REPOSITORY | grep -v registry`; do echo " docker push $i " ; done
```

Скачать образ из нашего репозитория
``` 
docker pull localhost:19000/origin-node:v3.11
```

Если не отвечает по внешнему Ip 

http: server gave HTTP response to HTTPS client


значит по пути /etc/docker нужно создать файлик 
daemon.json
```
{
  "insecure-registries" : ["192.168.209.18:19000"]
}
```

systemctl restart docker

