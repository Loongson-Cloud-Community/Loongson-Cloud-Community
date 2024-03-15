# lxc & lxc-templates

## 1.项目信息

|名称       |描述|
|--         |--|
|名称       |lxc|
|版本       |5.0.3|
|官方项目地址   |[https://github.com/lxc/lxc](https://github.com/lxc/lxc)|

|名称       |描述|
|--         |--|
|名称       |lxc-templates|
|版本       |3.0.3|
|官方项目地址   |[https://github.com/lxc/lxc-templates](https://github.com/lxc/lxc-templates)|

## 2.环境信息
|名称       |描述|
|--         |--|
|系统       |loongnix alpine|

## 3.软件包安装
```
apk add lxc-templates
apk add lxc-templates-legacy
apk add lxc-templates-legacy-alpine
apk add lxc
```

## 4. 环境准备
### 4.1 开启cgroup服务
需要启动cgroup服务，确保/proc/1/cgroup 文件不为空：
```
/home/lxc-alpine-package/lxc-templates-legacy # rc-service cgroups start
 * Caching service dependencies ...                                                                                                                                                     [ ok ]
/home/lxc-alpine-package/lxc-templates-legacy # rc-update add cgroups
 * service cgroups added to runlevel default
```

```
/home/lxc-alpine-package/lxc-templates-legacy # cat /proc/1/cgroup 
0::/
```
### 4.2 开启ip转发功能
只有保证ip转发功能开启，才可以保证配置的路由可以生效
/home/alpine # sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 0
0表示未开启ip转发功能，或者也可以直接查看文件/proc/sys/net/ipv4/ip_forward，使用下命令开启ip转发功能
sudo sysctl -w net.ipv4.ip_forward=1
   以上只是临时设置，若要长久设置，可在文件/etc/sysctl.conf中写入：
vim /etc/sysctl.conf
net.ipv4.ip_forward=1

## 5.使用lxc-alpine模板创建容器与启动
### 5.1 容器创建
```
lxc-create -n test -t alpine //-n后面跟的是要创建的容器名称，-t后面跟的是模板文件
......
==> Container's rootfs and config have been created
Edit the config file /var/lib/lxc/test/config to check/enable networking setup.
The installed system is preconfigured for a loopback and single network
interface configured via DHCP.

To start the container, run "lxc-start -n test".
The root password is not set; to enter the container run "lxc-attach -n test".
```
备注： -t后面也可以跟模板文件的全路径 /usr/share/lxc/templates/lxc-alpine

此时容器test已经创建：
```
/home/alpine/alpine/lxc-templates-legacy # lxc-ls
test 
```

### 5.2 容器启动
此时直接启动容器会报错，如下：
```
/home/alpine/alpine/lxc-templates-legacy # lxc-start -n test --logfile=aaa
lxc-start: test: ../src/lxc/lxccontainer.c: wait_on_daemonized_start: 878 Received container state "ABORTING" instead of "RUNNING"
lxc-start: test: ../src/lxc/tools/lxc_start.c: main: 306 The container failed to start
lxc-start: test: ../src/lxc/tools/lxc_start.c: main: 309 To get more details, run the container in foreground mode
lxc-start: test: ../src/lxc/tools/lxc_start.c: main: 311 Additional information can be obtained by setting the --logfile and --logpriority options
/home/alpine/alpine/lxc-templates-legacy # cat aaa
lxc-start test 20240312083640.836 ERROR    network - ../src/lxc/network.c:netdev_configure_server_veth:711 - No such file or directory - Failed to attach "veth6KwNcs" to bridge "lxcbr0", bridge interface doesn't exist
lxc-start test 20240312083640.924 ERROR    network - ../src/lxc/network.c:lxc_create_network_priv:3427 - No such file or directory - Failed to create network device
lxc-start test 20240312083640.924 ERROR    start - ../src/lxc/start.c:lxc_spawn:1840 - Failed to create the network
lxc-start test 20240312083640.924 ERROR    lxccontainer - ../src/lxc/lxccontainer.c:wait_on_daemonized_start:878 - Received container state "ABORTING" instead of "RUNNING"
lxc-start test 20240312083640.924 ERROR    lxc_start - ../src/lxc/tools/lxc_start.c:main:306 - The container failed to start
lxc-start test 20240312083640.924 ERROR    lxc_start - ../src/lxc/tools/lxc_start.c:main:309 - To get more details, run the container in foreground mode
lxc-start test 20240312083640.924 ERROR    lxc_start - ../src/lxc/tools/lxc_start.c:main:311 - Additional information can be obtained by setting the --logfile and --logpriority options
lxc-start test 20240312083640.924 ERROR    start - ../src/lxc/start.c:__lxc_start:2107 - Failed to spawn container "test"
```
这是因为容器的配置文件/var/lib/lxc/test/config 中第11行默认设置了容器网络连接到网桥lxcbr0，而系统上不存在该网桥所以报错:
```
 10 lxc.net.0.type = veth
 11 lxc.net.0.link = lxcbr0
 12 lxc.net.0.flags = up
 13 lxc.net.0.hwaddr = 00:16:3e:82:db:3a
 14 lxc.rootfs.path = dir:/var/lib/lxc/test/rootfs
```

若想要启动容器，可将文件/var/lib/lxc/test/config的第11行代码暂时注释:
```
 10 lxc.net.0.type = veth
 11 #lxc.net.0.link = lxcbr0
 12 lxc.net.0.flags = up
 13 lxc.net.0.hwaddr = 00:16:3e:82:db:3a
 14 lxc.rootfs.path = dir:/var/lib/lxc/test/rootfs
```
此时便可以正常启动容器，并进入容器，但此时容器内的网络不通
```
/home/alpine/alpine/lxc-templates-legacy # lxc-start test
/home/alpine/alpine/lxc-templates-legacy # lxc-attach test
/ # pwd
/
/ # ls
bin    dev    etc    home   lib    media  mnt    opt    proc   root   run    sbin   srv    sys    tmp    usr    var
/ # cd /home
/home #

/home # ping baidu.com
^C
```

## 6.网络设置
这里通过网桥和路由的方式来配置容器网络，将要创建的网络名称是br0。
### 6.1 修改容器网络通过网桥br0进行通信
首先将容器配置文件/var/lib/test/config中网络设置为通过br0进行通信：
```
lxc.net.0.type = veth
lxc.net.0.link = br0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:e0:d6:08
lxc.rootfs.path = dir:/var/lib/lxc/test/rootfs
```

### 6.2 在宿主机上创建网桥br0
```
/home/alpine # brctl addbr br0
/home/alpine # brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.000000000000	no
/home/alpine # ip add
11: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether fe:c8:e8:4c:79:15 brd ff:ff:ff:ff:ff:ff
```
此时可以看到网桥br0创建成功，interfaces为空是因为还没有接口连接该网桥上。当启动容器后，此时再查看网桥br0:
```
/home/alpine # lxc-start test
/home/alpine # brctl show
bridge name	bridge id		STP enabled	interfaces
br0		8000.fec8e84c7915	no		vethc7wLS1
```
这是因为在6.1中设置了容器通过br0通信。

### 6.3 给网桥br0分配ip
为了实现网桥所在的主机和网桥所桥接的容器进行通信，需要给网桥和容器分配同一网段的ip地址。
主机上有两个物理网卡，eth2,eth3，网段分别为10.130.0.xxx和192.168.0.xxx，为了防止ip冲突，故给br0设置在192.168.200.xxx的网段
```
5: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:26:f8:90:10:4a brd ff:ff:ff:ff:ff:ff
    inet 10.130.0.143/24 brd 10.130.0.255 scope global eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::226:f8ff:fe90:104a/64 scope link 
       valid_lft forever preferred_lft forever
6: sit0@NONE: <NOARP,UP,LOWER_UP> mtu 1480 qdisc noqueue state UNKNOWN qlen 1000
    link/sit 0.0.0.0 brd 0.0.0.0
    inet6 ::c0a8:314/96 scope global 
       valid_lft forever preferred_lft forever
    inet6 ::a82:8f/96 scope global 
       valid_lft forever preferred_lft forever
    inet6 ::7f00:1/96 scope host 
       valid_lft forever preferred_lft forever
7: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 48:72:65:65:6e:01 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.20/24 scope global eth3
       valid_lft forever preferred_lft forever
    inet6 fe80::4a72:65ff:fe65:6e01/64 scope link 
       valid_lft forever preferred_lft forever
```

给br0设置ip地址：
```
/home/alpine # ip addr add 192.168.200.11/24 dev br0
/home/alpine # ip add
......
11: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether fe:c8:e8:4c:79:15 brd ff:ff:ff:ff:ff:ff
    inet 192.168.200.11/24 scope global br0
       valid_lft forever preferred_lft forever
.......
```
注意：br0的ip地址不能设置为物理网卡同一个网段，否则会导致路由出错，如当将br0的ip设置为10.130.0.xxx时，br0的路由会与eth2一样：
```
/home/alpine/alpine/lxc-templates-legacy # route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.130.0.1      0.0.0.0         UG    205    0        0 eth2
10.130.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth2
10.130.0.0      0.0.0.0         255.255.255.0   U     0      0        0 br0
192.168.3.0     0.0.0.0         255.255.255.0   U     0      0        0 eth3
```

启动br0:
```
/home/alpine # ifconfig br0 up
/home/alpine # ifconfig
......
br0       Link encap:Ethernet  HWaddr FE:C8:E8:4C:79:15  
          inet addr:192.168.200.11  Bcast:0.0.0.0  Mask:255.255.255.0
          inet6 addr: fe80::fcc8:e8ff:fe4c:7915/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:844 (844.0 B)
......
```
此时主机路由：
```
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.130.0.1      0.0.0.0         UG    205    0        0 eth2
10.130.0.0      0.0.0.0         255.255.255.0   U     0      0        0 eth2
192.168.3.0     0.0.0.0         255.255.255.0   U     0      0        0 eth3
192.168.200.0   0.0.0.0         255.255.255.0   U     0      0        0 br0
```

### 6.4 给容器分配ip地址
这里同样使用固定分配ip的方式
查看容器内的虚拟网卡，如下，共有2个虚拟网卡。其中，lo是回环网卡通常用于测试数据包和软件配置是否正常。故这里使用eth0：
```
/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 00:16:3E:E0:D6:08  
          inet6 addr: fe80::216:3eff:fee0:d608/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:12 errors:0 dropped:0 overruns:0 frame:0
          TX packets:25 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1016 (1016.0 B)  TX bytes:5926 (5.7 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

给网卡eth0设置ip地址，网段需要与br0一致：
```
/ # ip addr add 192.168.200.12/24 dev eth0
/ # ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN qlen 1000
    link/sit 0.0.0.0 brd 0.0.0.0
3: eth0@if14: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP qlen 1000
    link/ether 00:16:3e:e0:d6:08 brd ff:ff:ff:ff:ff:ff
    inet 192.168.200.12/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::216:3eff:fee0:d608/64 scope link 
       valid_lft forever preferred_lft forever
```
此时容器内可以ping通192.168.200.11，但是没有办法ping通主机ip 10.130.0.143:
```
/ # ping 192.168.200.11
PING 192.168.200.11 (192.168.200.11): 56 data bytes
64 bytes from 192.168.200.11: seq=0 ttl=64 time=0.213 ms
64 bytes from 192.168.200.11: seq=1 ttl=64 time=0.023 ms
^C
/ # ping 10.130.0.143
PING 10.130.0.143 (10.130.0.143): 56 data bytes
ping: sendto: Network unreachable
```
但在主机上可以ping通192.168.200.12/11，这说明主机上从10.130.0.143到192.168.200.12/11的路由没有问题，而容器内的路由需要设置。

### 6.5 在容器内添加到主机的路由
下面的命令表示容器(192.168.200.12)发送给10.130.0.0网段的包，将通过192.168.200.11转发出去。
```
/ # route add -net 10.130.0.0/24 gw 192.168.200.11 dev eth0 
/ # route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.130.0.0      192.168.200.11  0.0.0.0         UG    0      0        0 eth0
192.168.200.0   0.0.0.0         255.255.255.0   U     0      0        0 eth0
/ # ping 10.130.0.143
PING 10.130.0.143 (10.130.0.143): 56 data bytes
64 bytes from 10.130.0.143: seq=0 ttl=64 time=0.100 ms
64 bytes from 10.130.0.143: seq=1 ttl=64 time=0.032 ms
^X^C
--- 10.130.0.143 ping statistics ---
/ # ping 10.130.0.20
PING 10.130.0.20 (10.130.0.20): 56 data bytes
^C^C
--- 10.130.0.20 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss
/ # ping baidu.com
^C
```
此时虽然可以ping通主机143，但是没有办法ping通与10.130.0.xxx网段的其他机器，这是因为其他机器中没有添加到192.168.200.xxx的路由，
此时可以在其他主机上通过下面的命令添加到192.168.200.xxx的路由规则，但这样比较麻烦，需要在每个主机都单独添加路由，此时可以使用6.6中的nat规则来进行设置
```
route add -net 192.168.200.0/24 gw 10.130.0.143 dev enp0s3f0
```

### 6.6 添加nat规则
nat规则只需要在启动容器的主机上设置
查看当前主机上的nat规则，为空：
```
/home/alpine # iptables -nvL --line-number   //查看nat规则
/home/alpine # iptables -nvL -t nat --line-numbers
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 320 packets, 23842 bytes)
num   pkts bytes target     prot opt in     out     source               destination     
```

在主机上设置nat规则：
```
iptables -t nat -A POSTROUTING -s 192.168.200.12 -j SNAT --to-source 10.130.0.143
```
这条规则的作用是将容器192.168.200.12发送的包中的ip地址全部改成ip 10.130.0.143，故对于其他机器而言识别到的是主机10.130.0.143发送的包（实际是容器192.168.200.12发送的包）。
故此时主机所拥有的网络通信，容器192.168.200.12也全部拥有。从而实现与10.130.0.xxx网段其他ip之间的通信，以及ping通百度(前提是主机10.130.0.143可以ping通百度)。

备注：
删除nat规则：
```
/home/alpine/alpine/lxc-templates-legacy # iptables -nvL -t nat --line-numbers
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 1 packets, 136 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 SNAT       0    --  *      *       192.168.200.12       0.0.0.0/0            to:10.130.0.143
/home/alpine/alpine/lxc-templates-legacy # iptables -t nat -D POSTROUTING 1  //这里的1指向的是上面的num 1
```

## 7. 从源码构建lxc & lxc-templates
### 7.1 lxc
源码修改：参考https://github.com/Loongson-Cloud-Community/lxc/tree/loongarch64-lxc-5.0.2的补丁
依赖包安装：
```
apk add build-base docbook2x libapparmor-dev libcap-dev libcap-static libseccomp-dev linux-headers linux-pam-dev meson
apk add automake autoconf libmagic file  libstdc++-dev musl-dev g++ fortify-headers build-base linux-headers  binutils
```
构建命令
```
abuild-meson -Db_lto= -Ddistrosysconfdir=/etc/default -Dpam-cgroup=true -Dtests=true -Dinit-script=[]  . output   //在构建时会在当前目录创建一个output目录，用来存储构建结果
meson compile -C output
meson install --no-rebuild -C output  //若这里没有-C output则默认安装在/usr/local/bin或者/usr/bin目录下
```
备注: abuild-meson命令也可以替换为meson命令

### 7.2 lxc-templates
源码修改：参考https://github.com/Loongson-Cloud-Community/lxc-templates/commits/loongarch64-lxc-templates-3.0.4/的git log信息“Modify alpine to support loongarch64”
构建命令：
```
./configure --build=loongarch64-alpine-linux-musl  --host=loongarch64-alpine-linux-musl --prefix=/usr --sysconfdir=/etc --mandir=/usr/share/man --localstatedir=/var
make
make install
```

