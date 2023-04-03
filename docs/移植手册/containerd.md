# containerd 构建指导
## 1. 构建版本
v1.7.0

## 2. 构建环境
本次构建使用龙芯server系统，具体环境信息如下：
```
[root@localhost containerd]# cat /etc/os-release 
NAME="Loongnix-Server Linux"
VERSION="8"
ID="loongnix-server"
ID_LIKE="rhel fedora centos"
VERSION_ID="8"
PLATFORM_ID="platform:lns8"
PRETTY_NAME="Loongnix-Server Linux 8"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:loongnix-server:loongnix-server:8"
HOME_URL="http://www.loongnix.cn/"
BUG_REPORT_URL="http://bugs.loongnix.cn/"
CENTOS_MANTISBT_PROJECT="Loongnix-server-8"
CENTOS_MANTISBT_PROJECT_VERSION="8"
```
## 3. 构建依赖
在编译containerd之前需要先安装protobuf 3.x，golang>=1.19.x      
```
yum install -y protobuf golang-1.19
```

## 4. 源码适配
该项目本身不需要适配，只需要适配一下vendor目录下的ebpf，只有两行代码，适配简单，具体查看 https://github.com/Loongson-Cloud-Community/containerd/tree/loong64-v1.7.0 的git log信息。     

## 5. 构建
构建动态二进制：
```
make
```
构建静态二进制：
```
make STATIC=1
```
