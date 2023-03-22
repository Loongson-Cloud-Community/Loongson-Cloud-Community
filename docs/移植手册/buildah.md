# 构建指导
## 构建版本
1.29.1

## 构建环境
龙芯debian系统，具体环境信息如下：
```
root@cloud-01:/home/zhaixiaojuan/workspace/buildah-v1.29.1# cat /etc/os-release 
PRETTY_NAME="Loongnix GNU/Linux 20 (DaoXiangHu)"
NAME="Loongnix GNU/Linux"
VERSION_ID="20"
VERSION="20 (DaoXiangHu)"
VERSION_CODENAME=DaoXiangHu
ID=Loongnix
HOME_URL="https://www.loongnix.cn/"
SUPPORT_URL="https://www.loongnix.cn/"
BUG_REPORT_URL="http://www.loongnix.cn/"
root@cloud-01:/home/zhaixiaojuan/workspace/buildah-v1.29.1# uname -a
Linux cloud-01 4.19.0-17-loongson-3 #1 SMP 4.19.190-6.1 Mon Apr 11 13:19:19 UTC 2022 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 源码适配
不需要适配源码，只需将vendor目录下的bbolt更新为支持loong64的版本。       
具体构建源码：https://github.com/Loongson-Cloud-Community/buildah/tree/loong64-1.29.1 

## 安装构建依赖
(1) 软件安装
``` 
apt -y install bats btrfs-progs git libapparmor-dev libdevmapper-dev libglib2.0-dev libgpgme-dev libseccomp-dev libselinux1-dev  go-md2man golang-1.19
```
（2）设置gpgme.pc
搜索/usr目录下是否存在gpgme.pc文件，若不存在，则添加gpgme.pc，具体内容如下：
```
root@cloud-01:/home/zhaixiaojuan/workspace/buildah-v1.29.1# cat /usr/lib/loongarch64-linux-gnu/pkgconfig/gpgme.pc
prefix=/usr
exec_prefix=/usr
includedir=/usr/include
libdir=/usr/lib64
api_version=1

Name: gpgme
Description: GnuPG Made Easy to access GnuPG
Requires.private: gpg-error, libassuan
Version: 1.12.0
Cflags: -I${includedir}
Libs: -L${libdir} -lgpgme
URL: https://www.gnupg.org/software/gpgme/index.html
```

## 构建
```
make
make install
```
make构建完成后二进制会存储在bin目录下，如下：
```
zhaixiaojuan@cloud-01:~/workspace/buildah-v1.29.1/bin-dynamic$ ls
buildah  copy  imgtype  tutorial
```

```
root@cloud-01:/home/zhaixiaojuan/workspace/buildah-v1.29.1/bin# buildah --version
buildah version 1.29.1 (image-spec 1.0.2-dev, runtime-spec 1.0.2-dev)
```

## 备注
二进制获取地址：https://github.com/Loongson-Cloud-Community/buildah/releases/download/loong64-v1.29.1/loong64-debian-bin-v1.29.1.tar.gz       
该二进制用于龙芯debian10系统，在使用时需要提前安装golang-1.19(龙芯server系统上缺包，暂时无法构建)       
由于二进制构建时使用到了cgo,无法构建为静态二进制。     
