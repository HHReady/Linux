#Сборка своего ядра
uname -r # Hi, my kernel!
sudo yum groupinstall "Development Tools"
yum install ncurses-devel
yum update #uodate OS
wget https://www.kernel.org/pub/linux/kernel
#download new kernel
tar xvtvj linux-3.10.x.tar.xz -C /usr/src
#before building the kernel, you have to configure the kernel
make menuconfig
#or use config old kernel
sh -c 'yes|make oldconfig'
#now we can make kernel
make
#and set modules and kernel in OS
make modules_install install
