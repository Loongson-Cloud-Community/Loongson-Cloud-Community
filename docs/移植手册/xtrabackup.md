## 00x00 参考

1. [xtrabackup介绍](https://developer.huawei.com/consumer/cn/forum/topic/0202691724541050734)
2. [源码构建-官方](https://docs.percona.com/percona-xtrabackup/8.0/compile-xtrabackup.html)
3. [qpress源码地址](https://github.com/PierreLvx/qpress)
4. [龙芯源码地址]()

## 00x01 构建环境信息

- arch

```shell
root@xtrabackup /w/p/percona-xtrabackup# uname -a
Linux xtrabackup 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```

- os

```shell
root@xtrabackup /w/p/percona-xtrabackup# cat /etc/os-release 
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

## 00x02 构建依赖

```shell
# 文档构建依赖
apt install python3-sphinx

# 代码构建依赖
apt install bison pkg-config cmake devscripts debconf \
debhelper automake bison ca-certificates libprocps-dev \
libcurl4-openssl-dev cmake debhelper libaio-dev \
libncurses-dev libssl-dev libtool zlib1g-dev libgcrypt20-dev libev-dev libprocps-dev \
lsb-release build-essential rsync libdbd-mysql-perl \
libnuma1 socat librtmp-dev libtinfo5 vim-common \
liblz4-tool liblz4-1 liblz4-dev zstd python-docutils 
```

## 00x03 构建

- cmake 命令

```shell
mkdir build
cd build
cmake -DWITH_BOOST=../boost_1_77_0  -DCMAKE_VERBOSE_MAKEFILE=ON -DBUILD_CONFIG=xtrabackup_release -DWITH_MAN_PAGES=OFF -B ..

make -j`nproc`
```

### 1 boost

```shell
# 在根目录下执行
wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.zip
unzip boost_1_77_0.zip
```

