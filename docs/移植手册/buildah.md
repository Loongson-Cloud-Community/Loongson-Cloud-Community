# 构建指导
## 1.构建版本
1.29.1

## 2.构建环境
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

# 3.源码适配
不需要适配源码，只需将vendor目录下的bbolt更新为支持loong64的版本。       
具体构建源码：https://github.com/Loongson-Cloud-Community/buildah/tree/loong64-1.29.1 

## 4.安装构建依赖
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

## 5.构建
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

## 6. 二进制获取
二进制获取地址：https://github.com/Loongson-Cloud-Community/buildah/releases/download/loong64-v1.29.1/loong64-debian-bin-v1.29.1.tar.gz  
解压该tar包，并将其添加到PATH目录下。      
注意：由于二进制构建时使用到了cgo,无法构建为静态二进制。   

## 7. 使用方法
该buildah在使用时还依赖golang,runc,cni,具体使用步骤如下：
（1）按照上面的3～5的步骤(或者步骤6)将buildah安装到本地环境上
（2）安装golang-1.19
 (3) runc安装：    
 下载二进制：https://github.com/Loongson-Cloud-Community/runc/releases/download/commit-d5be3e26050c-loongarch64/loong64-bin-main-d5be3e26050c.tar.gz  ，并将其解压到本地/usr/bin/目录下。    
 buildah对runc有版本要求，当前系统自带的runc版本较低，与buildah不配套
 （4）cni构建
 ```
 git clone https://github.com/containernetworking/plugins    
 cd ./plugins
 ./build_linux.sh           //构建完成后会在bin目录下生成二进制
 ```
 ```
 mkdir -p /opt/cni/bin
 install -v ./bin/*  /opt/cni/bin/          //将其安装到/opt/cin/bin目录下
 ```
 （5）配置文件
 在本地机器上创建/etc/containers目录，并在其中加入以下文件：

 /etc/containers/policy.json：
 ```
 {
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports":
        {
            "docker-daemon":
                {
                    "": [{"type":"insecureAcceptAnything"}]
                }
        }
}
 ```
 
 
 /etc/containers/registries.conf：
 ```
 # This is a system-wide configuration file used to
# keep track of registries for various container backends.
# It adheres to TOML format and does not support recursive
# lists of registries.

# The default location for this configuration file is /etc/containers/registries.conf.

# The only valid categories are: 'registries.search', 'registries.insecure',
# and 'registries.block'.

[registries.search]
registries = ['docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.access.redhat.com', 'registry.centos.org']

# If you need to access insecure registries, add the registry's fully-qualified name.
# An insecure registry is one that does not have a valid SSL certificate or only does HTTP.
[registries.insecure]
registries = []


# If you need to block pull access from a registry, uncomment the section below
# and add the registries fully-qualified name.
#
# Docker only
[registries.block]
registries = []
 ```
  
 此时buildah二进制便可以正常工作
  


