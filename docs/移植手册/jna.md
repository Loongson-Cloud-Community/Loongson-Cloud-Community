# jna

## 构建版本
5.2.0

## 构建环境
本次构建使用龙芯debian系统，具体系统信息如下：
```
root@cloud-01:/home/zhaixiaojuan/workspace/cloud/jna-5.2.0# cat /etc/os-release 
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
root@cloud-01:/home/zhaixiaojuan/workspace/cloud/jna-5.2.0# uname -a
Linux cloud-01 4.19.0-17-loongson-3 #1 SMP 4.19.190-6.1 Mon Apr 11 13:19:19 UTC 2022 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 源码修改
查看 https://github.com/Loongson-Cloud-Community/jna/tree/loong64-5.2.0  的git log信息
移植后可能会出现的问题:
```
/usr/local/jdk-11.0.19/bin/java: symbol lookup error: /home/yzw/.cache/JNA/temp/jna2144651195920714260.tmp: undefined symbol: ALIGN
/usr/local/jdk-11.0.19/bin/java: symbol lookup error: /home/yzw/.cache/JNA/temp/jna2144651195920714260.tmp: undefined symbol: ffi_prep_cif_machdep_var
```
问题原因：
libffi库没有完全适配
解决方案：
从loongson/jna库中获取相应版本或相近版本的libffi库，重新编译(注意libffi库中的autogen.sh脚本需要从jna源码库中获取)

## 构建
```
ant dist
```
构建其他参数，参考：https://github.com/java-native-access/jna/blob/master/www/ReleasingJNA.md
