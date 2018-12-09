#Create software RAID
fdisk -l #show disk in OS
lshw -short #show microcore, kernel, RAM, CPU, disk
lsblk #all disk and partitions, you can see UUID, vendor, serial, etc
lsscsi

#clean superblock
mdadm --zero-superblock --force /dev/sdd
mdadm --create --verbose /dev/md0 -l 6 -n 5 /dev/sd{b,c,d,e,f} #create RAID 6 from 5 disks
#show status
cat /proc/mdstat
mdstat -D /dev/md0
#change mdadm.conf for save configure
mdadm --detail --scan --verbose
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan -- verbose | awk 'ARRAY /{print}' >> /etc/mdadm/mdadm.conf

#remove disk
mdadm /dev/md0 --remove /dev/sdd
#add disk
mdadm /dev/md0 --add /dev/sdd

#Task: create GPT and 5 partitions, mount it on disks
parted -s /dev/md0 mklable gpt #key -s =don't ask 
#create partitions
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done