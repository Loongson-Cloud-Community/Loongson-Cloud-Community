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
|系统       |loongnix server8.4|

## 3.源码适配
lxc： 具体修改查看 https://github.com/Loongson-Cloud-Community/lxc/tree/loongarch64-lxc-3.1.0 的git log信息      
lxc-templates: 具体修改查看 https://github.com/Loongson-Cloud-Community/lxc-templates/tree/loongarch64-lxc-templates-3.0.4 的git log信息       

## 4.构建步骤
### 4.1 lxc二进制构建   
进入到lxc源码的根目录后，执行以下命令：
```
yum install -y libcap-devel  //避免问题1的出现
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

## 5.使用lxc-loongnixserver模板创建容器与启动
### 5.1 容器创建
```
lxc-create -n loongnixserver8.4-test -t loongnixserver //-n后面跟的是要创建的容器名称，-t后面跟的是模板文件
```
备注： -t后面也可以跟模板文件的全路径 /usr/local/share/lxc/templates/lxc-loongnixserver
```
[root@kubernetes-master-1 lxc]# lxc-create -n loongnixserver8.4-test -t loongnixserver
......
Copy /usr/local/var/cache/lxc/loongnixserver/loongarch64/8.4/rootfs to /usr/local/var/lib/lxc/loongnixserver8.4-test/rootfs ... 
Copying rootfs to /usr/local/var/lib/lxc/loongnixserver8.4-test/rootfs ...
Storing root password in '/usr/local/var/lib/lxc/loongnixserver8.4-test/tmp_root_pass'
正在终止用户 root 的密码。
passwd: 操作成功

Container rootfs and config have been created.
Edit the config file to check/enable networking setup.

The temporary root password is stored in:

        '/usr/local/var/lib/lxc/loongnixserver8.4-test/tmp_root_pass'


The root password is set up as expired and will require it to be changed
at first login, which you should do as soon as possible.  If you lose the
root password or wish to change it without starting the container, you
can change it from the host by running the following command (which will
also reset the expired flag):

        chroot /usr/local/var/lib/lxc/loongnixserver8.4-test/rootfs passwd
```
```
[root@kubernetes-master-1 lxc]# lxc-ls
loongnixserver8.4-test 
```

### 5.2 容器启动
此时直接启动容器会报错，如下：
```
[root@kubernetes-master-1 lxc]# lxc-start -n loongnixserver8.4-test --logfile=aaa
lxc-start: loongnixserver8.4-test: lxccontainer.c: wait_on_daemonized_start: 864 Received container state "ABORTING" instead of "RUNNING"
lxc-start: loongnixserver8.4-test: tools/lxc_start.c: main: 330 The container failed to start
lxc-start: loongnixserver8.4-test: tools/lxc_start.c: main: 333 To get more details, run the container in foreground mode
lxc-start: loongnixserver8.4-test: tools/lxc_start.c: main: 336 Additional information can be obtained by setting the --logfile and --logpriority options
[root@kubernetes-master-1 lxc]# cat aaa
lxc-start loongnixserver8.4-test 20231027072735.235 ERROR    utils - utils.c:run_command:1623 - Failed to exec command
lxc-start loongnixserver8.4-test 20231027072735.235 ERROR    network - network.c:lxc_ovs_attach_bridge:1887 - Failed to attach "lxcbr0" to openvswitch bridge "veth58EVGK": lxc-start: loongnixserver8.4-test: utils.c: run_command: 1623 Failed to exec command
lxc-start loongnixserver8.4-test 20231027072735.235 ERROR    network - network.c:instantiate_veth:172 - Operation not permitted - Failed to attach "veth58EVGK" to bridge "lxcbr0"
lxc-start loongnixserver8.4-test 20231027072735.259 ERROR    network - network.c:lxc_create_network_priv:2457 - Failed to create network device
lxc-start loongnixserver8.4-test 20231027072735.259 ERROR    start - start.c:lxc_spawn:1646 - Failed to create the network
lxc-start loongnixserver8.4-test 20231027072735.259 ERROR    start - start.c:__lxc_start:1972 - Failed to spawn container "loongnixserver8.4-test"
lxc-start loongnixserver8.4-test 20231027072735.259 ERROR    lxccontainer - lxccontainer.c:wait_on_daemonized_start:864 - Received container state "ABORTING" instead of "RUNNING"
lxc-start loongnixserver8.4-test 20231027072735.259 ERROR    lxc_start - tools/lxc_start.c:main:330 - The container failed to start
lxc-start loongnixserver8.4-test 20231027072735.259 ERROR    lxc_start - tools/lxc_start.c:main:333 - To get more details, run the container in foreground mode
lxc-start loongnixserver8.4-test 20231027072735.259 ERROR    lxc_start - tools/lxc_start.c:main:336 - Additional information can be obtained by setting the --logfile and --logpriority options
```

这是因为容器的配置文件/usr/local/var/lib/lxc/loongnixserver8.4-test/config 中第11行默认设置了容器网络连接到网桥lxcbr0，而系统上不存在该网桥所以报错:
```
 10 lxc.net.0.type = veth
 11 lxc.net.0.link = lxcbr0
 12 lxc.net.0.hwaddr = fe:e0:32:2e:57:82
 13 lxc.net.0.flags = up
 14 lxc.rootfs.path = dir:/usr/local/var/lib/lxc/loongnixserver8.4-test/rootfs
```

若想要启动容器，可将文件/usr/local/var/lib/lxc/loongnixserver8.4-test/config的第11行代码暂时注释:
```
 10 lxc.net.0.type = veth
 11 # lxc.net.0.link = lxcbr0
 12 lxc.net.0.hwaddr = fe:e0:32:2e:57:82
 13 lxc.net.0.flags = up
 14 lxc.rootfs.path = dir:/usr/local/var/lib/lxc/loongnixserver8.4-test/rootfs
```

此时便可以启动容器，但此时容器内的网络不通，具体如下：
```
[root@kubernetes-master-1 lxc]# lxc-ls 
loongnixserver8.4-test 
[root@kubernetes-master-1 lxc]# lxc-start -n loongnixserver8.4-test
[root@kubernetes-master-1 lxc]# lxc-attach -n loongnixserver8.4-test
[root@loongnixserver8 /]# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  selinux  srv  sys  tmp  usr  var
[root@loongnixserver8 /]# ping baidu.com
ping: baidu.com: Name or service not known
```

## 6.网络设置
这里主要介绍两种网络方法：        
方法1：创建网桥br0，将其绑定到物理网卡上        
方法2：使用virbr0/docker0网桥        
### 6.1 使用virbr0/docker0网桥
其原理就是使用网桥virbr0/docker0这两个网桥将容器内的网络连接到主机网络上，从而使容器内使其可以访问外网。
这里介绍如何使用virbr0网桥    
(1) 安装libvirt
```
yum install -y libvirt
```
在安装完libvirt软件后，使用ifconfig命令可以查看到虚拟网卡virbr0:
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
/usr/local/var/lib/lxc/loongnixserver8.4-test/config：
 10 lxc.net.0.type = veth
 11 lxc.net.0.link = virbr0  //替换默认的lxcbr0
 12 lxc.net.0.hwaddr = fe:e0:32:2e:57:82
 13 lxc.net.0.flags = up
 14 lxc.rootfs.path = dir:/usr/local/var/lib/lxc/loongnixserver8.4-test/rootfs
```

（3）在容器内部添加虚拟网卡eth0
在/etc/sysconfig/network-scripts/ 目录下添加ifcfg-eth0文件，内容如下：
```
DEVICE=eth0
BOOTPROTO=dhcp  //通过dhcp动态获取ip地址
ONBOOT=yes
HOSTNAME=loongnixserver8.4-test
NM_CONTROLLED=no
TYPE=Ethernet
MTU=
DHCP_HOSTNAME=`hostname`
```

（4）重启容器使配置生效
```
lxc-stop -n loongnixserver8.4-test
lxc-start -n loongnixserver8.4-test
lxc-attach -n loongnixserver8.4-test
```
此时容器可以看到容器内eth0的网络IP和主机上virbr0在同一网段上：
```
[root@kubernetes-master-1 lxc]# lxc-stop -n loongnixserver8.4-test
[root@kubernetes-master-1 lxc]# lxc-start -n loongnixserver8.4-test
[root@kubernetes-master-1 lxc]# lxc-attach -n loongnixserver8.4-test
[root@loongnixserver8 /]# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.122.217  netmask 255.255.255.0  broadcast 192.168.122.255
        inet6 fe80::fce0:32ff:fe2e:5782  prefixlen 64  scopeid 0x20<link>
        ether fe:e0:32:2e:57:82  txqueuelen 1000  (Ethernet)
        RX packets 202  bytes 11375 (11.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 18  bytes 2092 (2.0 KiB)
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
[root@loongnixserver8 /]# ping baidu.com
PING baidu.com (110.242.68.66) 56(84) bytes of data.
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=1 ttl=53 time=22.2 ms
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=2 ttl=53 time=24.1 ms
^C
--- baidu.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 22.227/23.166/24.106/0.951 ms
[root@loongnixserver8 /]# 
[root@loongnixserver8 /]# yum makecache
Loongnix server 8.4 - BaseOS                                                                                                                                   60 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - AppStream                                                                                                                                64 kB/s | 4.3 kB     00:00    
Loongnix server 8.4 - Extras                                                                                                                                   62 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - infra-buildtools-common                                                                                                                  37 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - infra-gitforge-pagure                                                                                                                    41 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - infra-common                                                                                                                             43 kB/s | 3.0 kB     00:00    
元数据缓存已建立。
```

备注：若要使用docker0，则需要先在机器上安装docker, 然后将/usr/local/var/lib/lxc/loongnixserver8.4-test/config中的lxc.net.0.link = virbr0 修改为lxc.net.0.link = docker0即可，这里不再具体展示。

### 6.2 创建网桥br0，将其绑定到物理网卡上
其基本原理就是在主机上创建一个网桥br0，br0的一端连接到主机网卡上，另外一端连接到容器上，从而使得容器获取与主机网卡相同的网络访问权限。      
（1）确认主机上的物理网卡    
通过ifconfig查看主机上的所有网卡(包括虚拟网卡和物理网卡）     
```
[root@kubernetes-master-1 lxc]# ifconfig
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:aff:feff:12c8  prefixlen 64  scopeid 0x20<link>
        ether 02:42:0a:ff:12:c8  txqueuelen 0  (Ethernet)
        RX packets 2535728  bytes 137783421 (131.4 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4804202  bytes 7437553909 (6.9 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s3f0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.130.0.98  netmask 255.255.255.0  broadcast 10.130.0.255
        inet6 fe80::2807:a5f2:8ab6:eae4  prefixlen 64  scopeid 0x20<link>
        ether 38:f7:cd:c4:2d:46  txqueuelen 1000  (Ethernet)
        RX packets 28478114  bytes 17123123101 (15.9 GiB)
        RX errors 0  dropped 5208473  overruns 0  frame 0
        TX packets 8171673  bytes 3287300224 (3.0 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 47  
.......
```
/sys/devices/virtual/net/ 目录下存储的是虚拟网卡：
```
[root@kubernetes-master-1 lxc]# ls /sys/devices/virtual/net/
docker0  dummy0  lo  nerdctl0  sit0  veth551E9Q  virbr0  virbr0-nic
```
故可以知道主机上的物理网卡是enp0s3f0   

（2）在主机上创建网桥br0,将网桥的一端连接到主机的网卡上      
在主机上执行以下命令： 
1）创建网桥br0
```
[root@kubernetes-master-1 network-scripts]# nmcli connection add type bridge con-name br0 ifname br0 autoconnect yes
连接 "br0" (98039fb8-bce4-49d5-9dc4-413c1f070482) 已成功添加。
```
在成功创建网桥br0以后可以看到：
```
[root@kubernetes-master-1 network-scripts]# nmcli connection
NAME        UUID                                  TYPE      DEVICE   
有线连接 1  face2e91-cade-3e71-a39e-83e334f42e3f  ethernet  enp0s3f0 
docker0     2ee07799-6074-4cc8-a2e6-a0385ae46bf5  bridge    docker0  
nerdctl0    acf5f4d7-1322-45cb-b3ac-bc66859cdda7  bridge    nerdctl0 
virbr0      f9160b73-9080-4bad-a207-d8f275c66955  bridge    virbr0   
br0         98039fb8-bce4-49d5-9dc4-413c1f070482  bridge    --   
```
备注： 此时在会在/etc/sysconfig/network-scripts/目录下生成文件ifcfg-br0
```
 cat /etc/sysconfig/network-scripts/ifcfg-br0 
STP=yes
BRIDGING_OPTS=priority=32768
TYPE=Bridge
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=br0
UUID=2acac4a7-e8da-4bbe-9133-9486eb7d1221
DEVICE=br0
```

2) 将物理网卡enp0s3f0桥接到网桥br0上
```
[root@kubernetes-master-1 network-scripts]# nmcli connection add type bridge-slave ifname enp0s3f0 master br0
连接 "bridge-slave-enp0s3f0" (b860efd2-c0e9-4b06-9954-b5615f34bf54) 已成功添加。
```
当执行完这个命令后会在/etc/sysconfig/network-scripts 目录下生成文件ifcfg-bridge-slave-enp0s3f0：      
```
cat /etc/sysconfig/network-scripts/ifcfg-bridge-slave-enp0s3f0 
TYPE=Ethernet
NAME=bridge-slave-enp0s3f0
UUID=27d5721f-de75-48ae-9245-1b04dbb4ef3c
DEVICE=enp0s3f0
ONBOOT=yes
BRIDGE=br0
```

3）启动br0
```
[root@kubernetes-master-1 network-scripts]# nmcli connection up br0
连接已成功激活（master waiting for slaves）（D-Bus 活动路径：/org/freedesktop/NetworkManager/ActiveConnection/8）
```

4）给网桥br0设置ip地址       
可选择静态设置ip地址，或动态获取ip地址。     
静态设置ip地址：    
```
[root@kubernetes-master-1 network-scripts]# nmcli c m br0 ipv4.address 10.130.0.112/24 ipv4.gateway 10.130.1.1 ipv4.method manual
```
动态获取ip地址：
```
nmcli c m br0 ipv4.method auto
```
5）重启网络使上面的配置生效
```
[root@kubernetes-master-1 network-scripts]# systemctl restart network
```
此时可以看到，网桥br0上已经绑定了IP地址10.130.0.112, 而主机上的物理网卡enp0s3f0的ip地址已经没有了
```
[root@kubernetes-master-1 workspace]# ifconfig
br0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.130.0.112  netmask 255.255.255.0  broadcast 10.130.0.255
        inet6 fe80::5189:f7ec:e685:bad2  prefixlen 64  scopeid 0x20<link>
        ether 38:f7:cd:c4:2d:46  txqueuelen 1000  (Ethernet)
        RX packets 52481  bytes 3229883 (3.0 MiB)
        RX errors 0  dropped 1929  overruns 0  frame 0
        TX packets 2558  bytes 231555 (226.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp0s3f0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 38:f7:cd:c4:2d:46  txqueuelen 1000  (Ethernet)
        RX packets 28558055  bytes 17129537503 (15.9 GiB)
        RX errors 0  dropped 5212469  overruns 0  frame 0
        TX packets 8177499  bytes 3287944288 (3.0 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        device interrupt 47  
```
网桥br0已经连接到物理网卡enp0s3f0上：
```
[root@kubernetes-master-1 workspace]# brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.38f7cdc42d46	yes		enp0s3f0
docker0		8000.02420aff12c8	no		
nerdctl0		8000.000000000000	no		
virbr0		8000.5254006b17ed	yes		virbr0-nic
```

（3）在主机上配置lxc容器的网络连接到网桥br0
/usr/local/var/lib/lxc/loongnixserver8.4-test/config:
```
 10 lxc.net.0.type = veth
 11 lxc.net.0.link = br0 //将默认的lxcbr0修改为br0
 12 lxc.net.0.hwaddr = fe:e0:32:2e:57:82
 13 lxc.net.0.flags = up
 14 lxc.rootfs.path = dir:/usr/local/var/lib/lxc/loongnixserver8.4-test/rootfs
```

(4)在容器内创建虚拟网络eth0
在/etc/sysconfig/network-scripts/目录下创建文件ifcfg-eth0，具体内容如下：
```
[root@loongnixserver8 /]# cat /etc/sysconfig/network-scripts/ifcfg-eth0 
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
HOSTNAME=loongnixserver8.4-test
NM_CONTROLLED=no
TYPE=Ethernet
MTU=
DHCP_HOSTNAME=`hostname`
```

(5) 重新启动容器使配置生效
重启容器后需要等待一会，然后便可以看到容器内的网络eth0已经获取到了ip地址，并且和网桥ip在同一个网段上
```
[root@kubernetes-master-1 workspace]# lxc-stop -n loongnixserver8.4-test
[root@kubernetes-master-1 workspace]# lxc-start -n loongnixserver8.4-test
[root@kubernetes-master-1 workspace]# lxc-attach -n loongnixserver8.4-test
[root@loongnixserver8 /]# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.130.0.156  netmask 255.255.255.0  broadcast 10.130.0.255
        inet6 fe80::fce0:32ff:fe2e:5782  prefixlen 64  scopeid 0x20<link>
        ether fe:e0:32:2e:57:82  txqueuelen 1000  (Ethernet)
        RX packets 2860  bytes 214588 (209.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 25  bytes 3778 (3.6 KiB)
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

此时容器内已经可以连接外部网络：
```
[root@loongnixserver8 /]# yum makecache
Loongnix server 8.4 - BaseOS                                                                                                                                   66 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - AppStream                                                                                                                                56 kB/s | 4.3 kB     00:00    
Loongnix server 8.4 - Extras                                                                                                                                   32 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - infra-buildtools-common                                                                                                                  60 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - infra-gitforge-pagure                                                                                                                    62 kB/s | 3.0 kB     00:00    
Loongnix server 8.4 - infra-common                                                                                                                             38 kB/s | 3.0 kB     00:00    
元数据缓存已建立。
[root@loongnixserver8 /]# ping baidu.com
PING baidu.com (110.242.68.66) 56(84) bytes of data.
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=1 ttl=54 time=22.1 ms
64 bytes from 110.242.68.66 (110.242.68.66): icmp_seq=2 ttl=54 time=28.9 ms
^C
--- baidu.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 22.113/25.513/28.913/3.400 ms
```
