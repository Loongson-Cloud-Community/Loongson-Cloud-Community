## cri-tools构建指导

### 构建版本
v1.20.0

### 构建环境
本次使用loongnix server
```
[root@5ab3688f7f77 cri-tools]# cat /etc/os-release 
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
```
[root@5ab3688f7f77 cri-tools]# uname -a
Linux 5ab3688f7f77 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```

golang使用1.15.6版本
```
[root@5ab3688f7f77 cri-tools]# go version
go version go1.15.6 linux/loong64
```

### 源码适配
架构无关

### 构建
```
rm -rf ~/go   //清楚本地缓存
export GOPROXY="http://goproxy.loongnix.cn:3000"
export GOSUMDB=off
rm -rf go.sum
go mod vendor //更新vendor目录
```
```
make   //执行构建
```
构建成功后会在_output目录下生成crictl critest两个二进制

### 备注
二进制获取地址：https://github.com/Loongson-Cloud-Community/cri-tools/releases/download/loong64-v1.20.0/loong64-v1.20.0-bin.tar.gz      
源码分支：https://github.com/Loongson-Cloud-Community/cri-tools/tree/loong64-1.20.0   

