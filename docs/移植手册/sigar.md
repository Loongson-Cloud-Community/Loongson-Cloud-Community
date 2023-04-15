# sigar构建指导
## 1. 构建版本
master版本， commit号：ad47dc3b494e9293d1f087aebb099bdba832de5e

## 2. 构建环境
openjdk-8     

使用的系统环境是龙芯debian-10,具体环境信息如下：
```
root@cloud-01:/home/workspace/cloud/sigar# cat /etc/os-release 
PRETTY_NAME="Loongnix GNU/Linux 20 (DaoXiangHu)"
NAME="Loongnix GNU/Linux"
VERSION_ID="20"
VERSION="20 (DaoXiangHu)"
VERSION_CODENAME=DaoXiangHu
ID=Loongnix
HOME_URL="https://www.loongnix.cn/"
SUPPORT_URL="https://www.loongnix.cn/"
BUG_REPORT_URL="http://www.loongnix.cn/"
root@cloud-01:/home/workspace/cloud/sigar# uname -a
Linux cloud-01 4.19.0-17-loongson-3 #1 SMP 4.19.190-6.1 Mon Apr 11 13:19:19 UTC 2022 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 3.源码适配
具体查看 https://github.com/Loongson-Cloud-Community/sigar/tree/loongarch64-master-ad47dc3b494e 的git log信息。

## 4. 构建命令
```
cd bindings/java
ant
```
