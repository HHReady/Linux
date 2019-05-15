## Домашнее задание
#### Работа с загрузчиком
1. Попасть в систему без пароля несколькими способами
2. Установить систему с LVM, после чего переименовать VG
3. Добавить модуль в initrd

4(*). Сконфигурировать систему без отдельного раздела с /boot, а только с LVM
Репозиторий с пропатченым grub: https://yum.rumyantsev.com/centos/7/x86_64/
PV необходимо инициализировать с параметром --bootloaderareasize 1m
Критерии оценки: Описать действия, описать разницу между методами получения шелла в процессе загрузки.
Где получится - используем script, где не получается - словами или копипастой описываем действия.

при выборе ядра для загрузки нажать ** e ** - в
данном контексте edit.

### Способ 1. init=/bin/sh
● В конце строки начинаящейся с linux16 добавляем init=/bin/sh и нажимаем сtrl-x для
загрузки в систему
● Рутовая ФС монтируется как Read-Only, чтобы исправить делаем:
[root@otuslinux ~]# mount -o remount,rw /


### Способ 2. rd.break
● В конце строки начинаящейся с linux16 добавляем rd.break и нажимаем сtrl-x длā
загрузки в систему
● Попадаем в emergency mode. Наша корневая файловая система смонтирована (в режиме Read-Only,
но мы не в ней. Далее будет пример как попасть в нее и поменять
пароль администратора:
```
[root@otuslinux ~]# mount -o remount,rw /sysroot
[root@otuslinux ~]# chroot /sysroot
[root@otuslinux ~]# passwd root
[root@otuslinux ~]# touch /.autorelabel
```
● После чего можно перезагружаться и заходить в систему с новым паролем. Полезно
когда вы потеряли или вообще не имели пароль администратор.

### Способ 3. rw init=/sysroot/bin/sh
● В строке начинающейся с linux16 заменяем ro на rw init=/sysroot/bin/sh и нажимаем сtrl-x
для загрузки в систему
● Далее нужно учитывать, что файловая система загружаемой системы будет находится в /sysroot и если вам нужно просто войти туда 
и посмотреть, что к чему, вы можете использовать команду
```
chroot /sysroot
```
## Включенный Selinux не дает залогинеться в ОС

Чтобы в этом случае попасть в консоль, при выборе ядра для загрузки нажать ** e ** 

чтобы отключить selinux нужно в параметрах ядра указать selinux=0 
Таким образом вы отключите возможность использовать selinux, поэтому когда поподете, решите проблему и включите обратно в grup selinux

## Установить систему с LVM, после чего переименовать VG

Первым делом посмотрим текущее состояние системы:
```
[root@otuslinux ~]# vgs
 VG #PV #LV #SN Attr VSize VFree
 VolGroup00 1 2 0 wz--n- <38.97g 0
● Нас интересует втораā строка с именем Volume Group
● Приступим к переименованиĀ:
[root@otuslinux ~]# vgrename VolGroup00 OtusRoot
Volume group "VolGroup00" successfully renamed to "OtusRoot"
```
Далее правим /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg. Везде заменяем старое
название на новое.
```
sed -i 's/centos/OtusRoot/' /etc/fstab
sed -i 's/centos/OtusRoot/g' /etc/default/grub
sed 's/centos/OtusRoot/g' /boot/grub2/grub.cfg -i

 ```
 
● Пересоздаем initrd image, чтобы он знал новое название Volume Group
```
[root@otuslinux ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
...
*** Creating image file done ***
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```
● После чего можем перезагружаться и если все сделано правильно успешно грузимся с
новым именем Volume Group и проверяем:
```
[root@otuslinux ~]# vgs
 VG #PV #LV #SN Attr VSize VFree
 OtusRoot 1 2 0 wz--n- <38.97g 0
 ```
● При желании можно так же заменить название Logical Volume


## Добавить модуль в initrd

Скрипты модулей хранятся в каталоге /usr/lib/dracut/modules.d/. Для того чтобы
добавить свой модуль создаем там папку с именем 01test:
```
[root@otuslinux ~]# mkdir /usr/lib/dracut/modules.d/01test
```
В нее поместим два скрипта:
1. module-setup.sh - который устанавливает модуль и вызывает скрипт test.sh
2. test.sh - собственно сам вызываемый скрипт, в нём у нас рисуется пингвинчик

● Пересобираем образ initrd
```
[root@otuslinux ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
или
[root@otuslinux ~]# dracut -f -v
```
● Можно проверить/посмотреть какие модули загружены в образ:
```
[root@otuslinux ~]# lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
test
```
####  После чего можно пойти двумя путями для проверки:
	* Перезагрузиться и руками выключить опции rghb и quiet и увидеть вывод
	* Либо отредактироватþ grub.cfg убрав эти опции
● В итоге при загрузке будет пауза на 10 секунд и вы увидите пингвина в выводе
терминала
