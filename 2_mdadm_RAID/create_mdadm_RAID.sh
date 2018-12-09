#! /bin/bash

yum install mdadm -y

mdadm --create --verbose /dev/md0 -l 5 -n 3  /dev/sd{b,c,d}

yum install mc -y

mkdir /etc/mdadm

mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

parted -s /dev/md0 mklabel gpt

parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 100%