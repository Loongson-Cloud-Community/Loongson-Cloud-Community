# harbor-operator构建指导

## 1. 构建环境     
使用龙芯debian-10系统，具体环境参数如下：
```
root@cloud-01:/homeworkspace/cloud/harbor-operator-project/harbor-operator/bin# cat /etc/os-release 
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
root@cloud-01:/home/workspace/cloud/harbor-operator-project/harbor-operator/bin# uname -a
Linux cloud-01 4.19.0-17-loongson-3 #1 SMP 4.19.190-6.1 Mon Apr 11 13:19:19 UTC 2022 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 2. 软件安装
安装golang-1.19   

## 3. 源码适配
该项目本身与架构无关，只需更新一下依赖的sys库和stringer版本，具体修改查看https://github.com/Loongson-Cloud-Community/harbor-operator/tree/loong64-release-1.2.0 的git log信息。         

## 4. 构建
### 4.1 二进制构建
```
make all
```
备注： 已完成构建的二进制下载地址：https://github.com/Loongson-Cloud-Community/harbor-operator/releases/download/loong64-release-v1.2.0/loong64-bin-release-1.2.0.tar.gz 

### 4.2 镜像构建
```
make docker-build
```
