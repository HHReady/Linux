
# Настройка LDAP сервера

При настройке мы задействуем BIND сервер, из-за чего 
```
hostname node2.localhost
cat > /etc/hostname 
node2.localhost
cat >> /etc/hosts
10.23.200.5 node2.localhost
```
Так как в коде установщика условия на host_name, то требуется выполнить это условие
```
   if len(host_name.split(".")) < 2 or host_name == "localhost.localdomain":
       raise BadHostError("Invalid hostname '%s', must be fully-qualified." % host_name)
```

Далее идет сама установка:
```
ipa-server-install --domain=node2.localhost  --ds-password=12345678 --hostname=node2.localhost --setup-dns --forwarder=8.8.8.8 --no-host-dns  --admin-password=12345678 --realm=node2.localhost --no-ntp --no_hbac_allow --no-ui-redirect --ssh-trust-dns --unattended```

```
