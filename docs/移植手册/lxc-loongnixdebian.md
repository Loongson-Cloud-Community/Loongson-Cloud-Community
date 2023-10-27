# lxc & lxc-templates

## 1.项目信息

|名称       |描述|
|--         |--|
|名称       |lxc|
|版本       |3.1.0|
|官方项目地址   |[https://github.com/lxc/lxc](https://github.com/lxc/lxc)|

|名称       |描述|
|--         |--|
|名称       |lxc-templates|
|版本       |3.0.4|
|官方项目地址   |[https://github.com/lxc/lxc-templates](https://github.com/lxc/lxc-templates)|

## 2.环境信息
|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |loongnix debian10|

## 3.源码适配
lxc： 具体修改查看 https://github.com/Loongson-Cloud-Community/lxc/tree/loongarch64-lxc-3.1.0 的git log信息      
lxc-templates: 具体修改查看 https://github.com/Loongson-Cloud-Community/lxc-templates/tree/loongarch64-lxc-templates-3.0.4 的git log信息       

## 4.构建步骤
### 4.1 lxc二进制构建   
进入到lxc源码的根目录后，执行以下命令：
```
apt install -y libcap-dev  //避免问题1的出现
./autogen.sh
./configure
make  //make执行完后会生成在src/lxc/.libs目前，生成的lxc-create/lxc-start等二进制存储在这个目录当中
make install  //make install执行完后，二进制安装在/usr/local/bin目录下
```
### 4.2 lxc-templates模板文件构建
进入到源码根目录后执行以下命令：
```
./autogen.sh
./configure
make install  //make install 执行完后，模板文件将安装在/usr/local/share/lxc/templates/ 目录下
```

## 5.使用lxc-loongnixdebian模板创建容器与启动
### 5.1 容器创建
```
lxc-create -n loongnixdebian10-test -t loongnixdebian //-n后面跟的是要创建的容器名称，-t后面跟的是模板文件
```
备注： -t后面也可以跟模板文件的全路径 /usr/local/share/lxc/templates/lxc-loongnixdebian
```
root@zhaixiaojuan-pc:/home/zhaixiaojuan/workspace/lxc-project# lxc-create -n loongnixdebian10-test -t loongnixdebian |&tee create-1023.log
debootstrap 是 /usr/sbin/debootstrap
Checking cache download in /usr/local/var/cache/lxc/debian/rootfs-DaoXiangHu-stable-loongarch64 ... 

WARNING: apt does not have a stable CLI interface. Use with caution in scripts.


WARNING: apt does not have a stable CLI interface. Use with caution in scripts.

Downloading debian minimal ...
I: Retrieving InRelease 
I: Checking Release signature
......
Generation complete.
update-rc.d: error: cannot find a LSB script for checkroot.sh
update-rc.d: error: cannot find a LSB script for umountfs
Failed to disable unit, unit hwclock.sh.service does not exist.
update-rc.d: error: cannot find a LSB script for hwclockfirst.sh
Creating SSH2 RSA key; this may take some time ...
2048 SHA256:42wm3HO77t8nvgLxq4vaZhxAFtZFCKXJ4Tni7ASlbm8 root@zhaixiaojuan-pc (RSA)
Creating SSH2 ECDSA key; this may take some time ...
256 SHA256:2kmxe8IDk925tk6HX8jNGDHnSjybhCclmDLRKAj10Kk root@zhaixiaojuan-pc (ECDSA)
Creating SSH2 ED25519 key; this may take some time ...
256 SHA256:ACeocHsJsB+oVroRsHryt93MasbzXA24u+NvDt58wXg root@zhaixiaojuan-pc (ED25519)
invoke-rc.d: could not determine current runlevel
invoke-rc.d: policy-rc.d denied execution of start.

Current default time zone: 'Etc/UTC'
Local time is now:      2023年 10月 23日 星期一 02:10:32 UTC.
Universal Time is now:  Mon Oct 23 02:10:32 UTC 2023.
```

### 5.2 容器启动
```
root@zhaixiaojuan-pc:/home/zhaixiaojuan/workspace/lxc-project# lxc-start -n loongnixdebian10-test
root@zhaixiaojuan-pc:/home/zhaixiaojuan/workspace/lxc-project# lxc-attach -n loongnixdebian10-test
root@loongnixdebian10-test:/# ls
bin  boot  dev	etc  home  lib	lib64  media  mnt  opt	proc  root  run  sbin  selinux	srv  sys  tmp  usr  var
root@loongnixdebian10-test:/# cat /etc/apt/sources.list
deb https://pkg.loongnix.cn/loongnix          DaoXiangHu-stable         main
```
此时容器可以启动，但是容器内无法访问外部网络

## 6.网络设置
这里主要介绍两种网络方法：
方法1：创建网桥br0，将其绑定到物理网卡上      
方法2：使用virbr0/docker0网桥
### 6.1 使用virbr0/docker0网桥
其原理就是使用网桥virbr0/docker0这两个网桥将容器内的网络连接到主机网络上，从而使容器内使其可以访问外网。
这里介绍如何使用virbr0网桥    
(1) 安装libvirt0
```
apt install -y libvirt0
```
在安装完libvirt0软件后，使用ifconfig命令可以查看到虚拟网卡virbr0:
```
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:6b:17:ed  txqueuelen 1000  (Ethernet)
        RX packets 598  bytes 37039 (36.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 751  bytes 980279 (957.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

(2) 在主机上配置容器的虚拟网卡连接到virbr0
```
/usr/local/var/lib/lxc/loongnixdebian10-test/config：
lxc.net.0.type = veth  //要将之前的lxc.net.0.type配置删掉
lxc.net.0.link = virbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = fe:b0:82:ca:33:00  //注意这里的MAC地址是随机的，只要不和主机的MAC地址相同即可
```

（3）在容器内部添加虚拟网卡
在/etc/network/interfaces文件中添加以下内容：
```
auto  eth0 //在容器启动时自动启动该接口
iface eth0 inet dhcp //创建IPv4类型的接口eth0, 该接口通过dhcp自动获取IP地址
```

（4）重启容器使配置生效
```
lxc-stop -n loongnixdebian10-test
lxc-start -n loongnixdebian10-test
lxc-attach -n loongnixdebian10-test
```
此时容器可以看到容器内eth0的网络IP和主机上virbr0在同一网段上：
```
root@zhaixiaojuan-pc:/home/zhaixiaojuan/workspace/lxc-project# lxc-attach -n loongnixdebian10-test
root@loongnixdebian10-test:/# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.122.78  netmask 255.255.255.0  broadcast 192.168.122.255
        inet6 fe80::fcb0:82ff:feca:3300  prefixlen 64  scopeid 0x20<link>
        ether fe:b0:82:ca:33:00  txqueuelen 1000  (Ethernet)
        RX packets 31  bytes 2159 (2.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15  bytes 1878 (1.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```
容器内已经可以正常和外部通信了：
```
root@loongnixdebian10-test:/# ping baidu.com
PING baidu.com (39.156.66.10) 56(84) bytes of data.
64 bytes from 39.156.66.10: icmp_seq=1 ttl=50 time=24.7 ms
64 bytes from 39.156.66.10: icmp_seq=2 ttl=50 time=28.1 ms
64 bytes from 39.156.66.10: icmp_seq=3 ttl=50 time=24.5 ms
^C
--- baidu.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 24.531/25.798/28.122/1.655 ms
root@loongnixdebian10-test:/# apt update
命中:1 https://pkg.loongnix.cn/loongnix DaoXiangHu-stable InRelease
正在读取软件包列表... 完成
正在分析软件包的依赖关系树... 完成
所有软件包均为最新。
```

备注：若要使用docker0，则需要先在机器上安装docker, 然后将/usr/local/var/lib/lxc/loongnixdebian10-test/config中的lxc.net.0.link = virbr0 修改为lxc.net.0.link = docker0即可，这里不再具体展示。

### 6.2 创建网桥br0，将其绑定到物理网卡上
其基本原理就是在主机上创建一个网桥br0，br0的一端连接到主机网卡上，另外一端连接到容器上，从而使得容器获取与主机网卡相同的网络访问权限。      
（1）确认主机上的物理网卡    
通过ifconfig查看主机上的所有网卡(包括虚拟网卡和物理网卡）     
```
root@zhaixiaojuan-pc:/home/zhaixiaojuan/buildx# ifconfig
enp0s3f0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.130.0.184  netmask 255.255.255.0  broadcast 10.130.0.255
        inet6 fe80::4ad:d779:cf0d:108b  prefixlen 64  scopeid 0x20<link>
        ether 38:f7:cd:c4:2c:67  txqueuelen 1000  (Ethernet)
        RX packets 17370450  bytes 11557378838 (10.7 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 11381411  bytes 1028843109 (981.1 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 47  

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 838  bytes 46188 (45.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 838  bytes 46188 (45.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
/sys/devices/virtual/net/ 目录下存储的是虚拟网卡：
```
root@zhaixiaojuan-pc:/home/zhaixiaojuan/workspace/lxc-project# ls /sys/devices/virtual/net/
lo
```
故可以知道主机上的物理网卡是enp0s3f0      
（2）在主机上创建网桥br0,将网桥的一端连接到主机的网卡上      
在主机/etc/network/interfaces文件中，加入以下内容：     
```
auto br0  //在机器启动时自动启动该接口
iface br0 inet dhcp  //inet表示这是一个IPv4的接口，dhcp表示通过dhcp动态获取IP地址     
        bridge_ports enp0s3f0  //将主机网卡enp0s3f0绑定到网桥br0上    
        bridge_fd 0
        bridge_maxwait 0
```
备注： 其中br0要与下面(4)中的配置网络名称一致， enp0s3f0是主机网卡的名称      
（3）重启主机网络服务，使网络配置生效
执行以下的命令重启网络服务        
```
/etc/init.d/networking restart   //重启网络服务
```

此时便可以发现主机的网络中出现了虚拟网络br0，而且网络enp0s3f0的ip地址赋值给了br0：       
```
root@zhaixiaojuan-pc:/home/zhaixiaojuan/workspace/lxc-project# ifconfig
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.130.0.184  netmask 255.255.255.0  broadcast 10.130.0.255
        inet6 fe80::3af7:cdff:fec4:2c67  prefixlen 64  scopeid 0x20<link>
        ether 38:f7:cd:c4:2c:67  txqueuelen 1000  (Ethernet)
        RX packets 2166198  bytes 1039014791 (990.8 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 706798  bytes 81873829 (78.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s3f0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 38:f7:cd:c4:2c:67  txqueuelen 1000  (Ethernet)
        RX packets 2275039  bytes 1104326714 (1.0 GiB)
        RX errors 0  dropped 1  overruns 0  frame 0
        TX packets 713886  bytes 82435827 (78.6 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 47  
```

使用brctl show命令查看enp0s3f0已经绑定了br0上：     
```
root@zhaixiaojuan-pc:/home/zhaixiaojuan/workspace/lxc-project# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.38f7cdc42c67	no		enp0s3f0
```
（4）修改容器配置
该步骤设置了将网桥br0的另外一端连接到容器上     
1) 在主机上修改容器配置文件
在/usr/local/var/lib/lxc/loongnixdebian10-test/config中添加以下内容：
```
  lxc.net.0.type = veth  //注意要删除之前的lxc.net.0.type
  lxc.net.0.flags = up
  ## that's the interface defined above in host's interfaces file
  lxc.net.0.link = br0
  lxc.net.0.hwaddr = 00:FF:AA:00:00:01
```
2）在容器内部设置虚拟网络eth0
在容器内部/etc/network/interfaces文件中添加以下内容：
```
auto  eth0 //在容器启动时自动启动该接口
iface eth0 inet dhcp //创建IPv4类型的接口eth0, 该接口通过dhcp自动获取IP地址
```
备注：1）和 2）的作用将在容器内部创建虚拟网络eth0，只有在1中将type类型设置为veth，才能在容器中按照2）的配置创建网络eth0。       
(5) 重启网络
修改完网络配置后，必须重启容器才能生效：
```
lxc-stop -n loongnixdebian10-test
lxc-start -n loongnixdebian10-test
lxc-attach -n loongnixdebian10-test
```

```
root@loongnixdebian10-test:/# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.130.0.69  netmask 255.255.255.0  broadcast 10.130.0.255
        inet6 fe80::fcb0:82ff:feca:3300  prefixlen 64  scopeid 0x20<link>
        ether fe:b0:82:ca:33:00  txqueuelen 1000  (Ethernet)
        RX packets 18978  bytes 2497376 (2.3 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 49  bytes 4917 (4.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@loongnixdebian10-test:/# 
root@loongnixdebian10-test:/# brctl show
root@loongnixdebian10-test:/# ping baidu.com
PING baidu.com (110.242.68.66) 56(84) bytes of data.
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=1 ttl=54 time=20.8 ms
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=2 ttl=54 time=20.5 ms
^C
--- baidu.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 2ms
rtt min/avg/max/mdev = 20.466/20.631/20.797/0.219 ms

root@loongnixdebian10-test:/# apt update
命中:1 https://pkg.loongnix.cn/loongnix DaoXiangHu-stable InRelease
正在读取软件包列表... 完成
正在分析软件包的依赖关系树... 完成
所有软件包均为最新。
```









