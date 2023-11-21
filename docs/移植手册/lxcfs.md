# lxcfs

## 1. 源码移植
移植版本：5.0.4      
具体参考https://github.com/Loongson-Cloud-Community/lxcfs/tree/loongarch64-5.0.4    的git log信息     

## 2. 源码构建
构建环境：loongnix server 8.4      
构建命令如下：
```
yum install -y fuse3 fuse3-libs fuse3-devel help2man 
meson setup -Dinit-script=systemd --prefix=/usr build/
meson compile -C build/
sudo meson install -C build/
```
在上面的命令执行完成后会将lxcfs命令安装在/bin和/usr/bin目录下。

## 3. lxcfs使用
这里介绍了在docker中如何使用lxcfs。         
### 3.1 安装
使用上面步骤2中的源码编译安装，或者下载rpm包(https://github.com/Loongson-Cloud-Community/lxcfs/releases/download/loongarch64-v5.0.4/lxcfs-5.0.4-abi1.0-rpm.tar.gz) 进行安装。

### 3.2 在docker中使用
（1）启动lxcfs服务：
```
mkdir -p /var/lib/lxcfs
sudo lxcfs /var/lib/lxcfs
# sudo lxcfs /var/lib/lxcfs &  #后台启动
```
（2）运行容器，下面的命令限制了容器的内存大小以及swap大小是256M，限制使用主机上的0,1两个CPU：     
```
docker run -it -m 256m --memory-swap 256m --cpus 2 --cpuset-cpus "0,1" \
       -v /var/lib/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw \
       -v /var/lib/lxcfs/proc/diskstats:/proc/diskstats:rw \
       -v /var/lib/lxcfs/proc/meminfo:/proc/meminfo:rw \
       -v /var/lib/lxcfs/proc/stat:/proc/stat:rw \
       -v /var/lib/lxcfs/proc/swaps:/proc/swaps:rw \
       -v /var/lib/lxcfs/proc/uptime:/proc/uptime:rw \
cr.loongnix.cn/library/debian:buster-slim
```
（3）在容器中查看运行结果，可以看到容器中的mem和swap大小就是docker命令行中设置的大小，cpu也是命令行中设置的0,1
```
root@e55fecbf5d0f:/# apt update && apt install -y procps
......
root@e55fecbf5d0f:/# free -h
              total        used        free      shared  buff/cache   available
Mem:          256Mi       6.0Mi       199Mi          0B        50Mi       249Mi
Swap:         256Mi          0B       256Mi
root@e55fecbf5d0f:/# cat /proc/cpuinfo 
processor	: 0
package			: 0
core			: 0
cpu family		: Loongson-64bit
model name		: Loongson-3A5000-HV
CPU Revision		: 0x11
FPU Revision		: 0x00
CPU MHz			: 2500.00
BogoMIPS		: 5000.00
TLB entries		: 2112
Address sizes		: 48 bits physical, 48 bits virtual
isa			: loongarch32 loongarch64
features		: cpucfg lam ual fpu lsx lasx complex crypto lvz lbt_x86 lbt_arm lbt_mips
hardware watchpoint	: yes, iwatch count: 8, dwatch count: 8

processor	: 1
package			: 0
core			: 1
cpu family		: Loongson-64bit
model name		: Loongson-3A5000-HV
CPU Revision		: 0x11
FPU Revision		: 0x00
CPU MHz			: 2500.00
BogoMIPS		: 5000.00
TLB entries		: 2112
Address sizes		: 48 bits physical, 48 bits virtual
isa			: loongarch32 loongarch64
features		: cpucfg lam ual fpu lsx lasx complex crypto lvz lbt_x86 lbt_arm lbt_mips
hardware watchpoint	: yes, iwatch count: 8, dwatch count: 8
```


## 4. 备注
在未启动lxcfs服务时，查看容器中的内存和CPU信息。     

（1）容器启动：
```
docker run -it -m 256m --memory-swap 256m --cpus 2 --cpuset-cpus "0,1" cr.loongnix.cn/library/debian:buster-slim
```
（2）在容器中查看内存和CPU信息，可以发现在容器中查看到内存和CPU信息并不是容器真实的信息，而是宿主机上的信息：
```
root@2b8fe77f1098:/# apt update && apt install -y procps
......
root@2b8fe77f1098:/# free -h
              total        used        free      shared  buff/cache   available
Mem:           15Gi       1.3Gi       3.1Gi        64Mi        10Gi        11Gi
Swap:         7.9Gi       130Mi       7.8Gi
root@2b8fe77f1098:/# cat /proc/cpuinfo 
system type		: generic-loongson-machine
processor		: 0
package			: 0
core			: 0
cpu family		: Loongson-64bit
model name		: Loongson-3A5000-HV
CPU Revision		: 0x11
FPU Revision		: 0x00
CPU MHz			: 2500.00
BogoMIPS		: 5000.00
TLB entries		: 2112
Address sizes		: 48 bits physical, 48 bits virtual
isa			: loongarch32 loongarch64
features		: cpucfg lam ual fpu lsx lasx complex crypto lvz lbt_x86 lbt_arm lbt_mips
hardware watchpoint	: yes, iwatch count: 8, dwatch count: 8

processor		: 1
package			: 0
core			: 1
cpu family		: Loongson-64bit
model name		: Loongson-3A5000-HV
CPU Revision		: 0x11
FPU Revision		: 0x00
CPU MHz			: 2500.00
BogoMIPS		: 5000.00
TLB entries		: 2112
Address sizes		: 48 bits physical, 48 bits virtual
isa			: loongarch32 loongarch64
features		: cpucfg lam ual fpu lsx lasx complex crypto lvz lbt_x86 lbt_arm lbt_mips
hardware watchpoint	: yes, iwatch count: 8, dwatch count: 8

processor		: 2
package			: 0
core			: 2
cpu family		: Loongson-64bit
model name		: Loongson-3A5000-HV
CPU Revision		: 0x11
FPU Revision		: 0x00
CPU MHz			: 2500.00
BogoMIPS		: 5000.00
TLB entries		: 2112
Address sizes		: 48 bits physical, 48 bits virtual
isa			: loongarch32 loongarch64
features		: cpucfg lam ual fpu lsx lasx complex crypto lvz lbt_x86 lbt_arm lbt_mips
hardware watchpoint	: yes, iwatch count: 8, dwatch count: 8

processor		: 3
package			: 0
core			: 3
cpu family		: Loongson-64bit
model name		: Loongson-3A5000-HV
CPU Revision		: 0x11
FPU Revision		: 0x00
CPU MHz			: 2500.00
BogoMIPS		: 5000.00
TLB entries		: 2112
Address sizes		: 48 bits physical, 48 bits virtual
isa			: loongarch32 loongarch64
features		: cpucfg lam ual fpu lsx lasx complex crypto lvz lbt_x86 lbt_arm lbt_mips
hardware watchpoint	: yes, iwatch count: 8, dwatch count: 8
```
