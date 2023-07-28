# metrics-server

## 1. 构建版本
v0.5.0

## 2. 构建环境
使用龙芯debian-10系统，安装golang-1.19
```
root@cloud-01:/home/workspace/github-loongCloud/metrics-server-0.5.0# cat /etc/os-release 
PRETTY_NAME="Loongnix GNU/Linux 20 (DaoXiangHu)"
NAME="Loongnix GNU/Linux"
VERSION_ID="20"
VERSION="20 (DaoXiangHu)"
VERSION_CODENAME=DaoXiangHu
ID=Loongnix
HOME_URL="https://www.loongnix.cn/"
SUPPORT_URL="https://www.loongnix.cn/"
BUG_REPORT_URL="http://www.loongnix.cn/"
```
```
root@cloud-01:/home/workspace/github-loongCloud/metrics-server-0.5.0# uname -a
Linux cloud-01 4.19.0-17-loongson-3 #1 SMP 4.19.190-6.1 Mon Apr 11 13:19:19 UTC 2022 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 3. 源码适配
（1）使用下面的命令更新sys去支持loong64
```
go get  -d golang.org/x/sys@bc2c85ada10aa9b6aa9607e9ac9ad0761b95cf1d  //更新sys去支持loong64
```
（2）源码中与架构相关的代码仅在Makefile和Dockerfile中，适配较为简单，具体查看https://github.com/Loongson-Cloud-Community/metrics-server/tree/v0.5.0-loongarch64 的git log信息。      

## 4. 构建
```
go mod vendor   //使用vendor构建
make metrics-server  //构建二进制
make container  //构建镜像
```
