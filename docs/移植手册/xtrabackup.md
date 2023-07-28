# xtrabackup
## 00x00 参考

1. [xtrabackup介绍](https://developer.huawei.com/consumer/cn/forum/topic/0202691724541050734)
2. [源码构建-官方](https://docs.percona.com/percona-xtrabackup/8.0/compile-xtrabackup.html)
3. [qpress源码地址](https://github.com/PierreLvx/qpress)
4. [龙芯源码地址](https://github.com/Loongson-Cloud-Community/percona-xtrabackup/tree/loong64-8.0)
5. [percona-xtrabackup-8.0.33-linux-loongarch64.tar.gz](https://github.com/Loongson-Cloud-Community/percona-xtrabackup/releases/download/percona-xtrabackup-8.0.33-27/percona-xtrabackup-8.0.33-linux-loongarch64.tar.gz)

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

- 构建命令

```shell
# 更新子模块
git submodule update --init --recursive

mkdir build
cd build
cmake -DWITH_BOOST=../boost_1_77_0  -DCMAKE_VERBOSE_MAKEFILE=ON -DBUILD_CONFIG=xtrabackup_release -DWITH_MAN_PAGES=OFF ..

make -j`nproc`
```

### 1 boost缺少报错

```
CMake Error at cmake/boost.cmake:108 (MESSAGE):
  You can download it with -DDOWNLOAD_BOOST=1 -DWITH_BOOST=<directory>

  This CMake script will look for boost in <directory>.  If it is not there,
  it will download and unpack it (in that directory) for you.

  You can also download boost manually, from
  https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.bz2


  If you are inside a firewall, you may need to use an https proxy:

  export https_proxy=http://example.com:80

Call Stack (most recent call first):
  cmake/boost.cmake:206 (COULD_NOT_FIND_BOOST)
  CMakeLists.txt:1556 (INCLUDE)
```

- 处理

```shell
# 在根目录下执行
wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.zip
unzip boost_1_77_0.zip
```

### 2 double-conversion error

```
[  4%] Building CXX object extra/icu/CMakeFiles/icui18n.dir/icu-release-69-1/source/i18n/double-conversion-bignum.cpp.o
cd /work/percona/percona-xtrabackup/build/extra/icu && /usr/bin/c++  -DBOOST_NO_CXX98_FUNCTION_BASE -DHAVE_CONFIG_H -DHAVE_TLSv13 -DLZ4_DISABLE_DEPRECATE_WARNINGS -DU_I18N_IMPLEMENTATION -DXTRABACKUP -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_USE_MATH_DEFINES -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/work/percona/percona-xtrabackup/build -I/work/percona/percona-xtrabackup/build/include -I/work/percona/percona-xtrabackup -I/work/percona/percona-xtrabackup/include -I/work/percona/percona-xtrabackup/extra/icu/icu-release-69-1/source/common -I/work/percona/percona-xtrabackup/extra/icu/icu-release-69-1/source/i18n -isystem /work/percona/percona-xtrabackup/extra/libedit/libedit-20210910-3.1/src/editline  -std=c++17 -fno-omit-frame-pointer -ffp-contract=off -ftls-model=initial-exec  -ffunction-sections -fdata-sections -O2 -g -DNDEBUG -g1 -fPIC   -Wno-undef -Wno-deprecated-declarations -Wno-error -Wno-unused-parameter -Wno-missing-field-initializers -Wno-sign-compare -Wno-type-limits -Wno-return-local-addr -Wno-stringop-overflow -Wno-unused-but-set-variable -Wno-misleading-indentation -Wno-maybe-uninitialized -Wno-restrict -Wno-stringop-truncation -Wno-address -o CMakeFiles/icui18n.dir/icu-release-69-1/source/i18n/double-conversion-bignum.cpp.o -c /work/percona/percona-xtrabackup/extra/icu/icu-release-69-1/source/i18n/double-conversion-bignum.cpp
In file included from /work/percona/percona-xtrabackup/extra/icu/icu-release-69-1/source/i18n/double-conversion-bignum.h:42,
                 from /work/percona/percona-xtrabackup/extra/icu/icu-release-69-1/source/i18n/double-conversion-bignum.cpp:42:
/work/percona/percona-xtrabackup/extra/icu/icu-release-69-1/source/i18n/double-conversion-utils.h:144:2: error: #error Target architecture was not detected as supported by Double-Conversion.
 #error Target architecture was not detected as supported by Double-Conversion.
  ^~~~~
make[2]: *** [extra/icu/CMakeFiles/icui18n.dir/build.make:781: extra/icu/CMakeFiles/icui18n.dir/icu-release-69-1/source/i18n/double-conversion-bignum.cpp.o] Error 1
make[2]: Leaving directory '/work/percona/percona-xtrabackup/build'
make[1]: *** [CMakeFiles/Makefile2:1092: extra/icu/CMakeFiles/icui18n.dir/all] Error 2
make[1]: Leaving directory '/work/percona/percona-xtrabackup/build'
make: *** [Makefile:155: all] Error 2

```

- 修改如下

```diff
diff --git a/extra/icu/icu-release-69-1/source/i18n/double-conversion-utils.h b/extra/icu/icu-release-69-1/source/i18n/double-conversion-utils.h
index c9374636..97f58342 100644
--- a/extra/icu/icu-release-69-1/source/i18n/double-conversion-utils.h
+++ b/extra/icu/icu-release-69-1/source/i18n/double-conversion-utils.h
@@ -118,6 +118,7 @@ int main(int argc, char** argv) {
     defined(__ARMEL__) || defined(__avr32__) || defined(_M_ARM) || defined(_M_ARM64) || \
     defined(__hppa__) || defined(__ia64__) || \
     defined(__mips__) || \
+    defined(__loongarch__) || \
     defined(__nios2__) || defined(__ghs) || \
     defined(__powerpc__) || defined(__ppc__) || defined(__ppc64__) || \
     defined(_POWER) || defined(_ARCH_PPC) || defined(_ARCH_PPC64) || \

```

## 00x04 打包

```shell
make package

# 二进制压缩包
root@xtrabackup /w/p/p/build (loong64-8.0)# file percona-xtrabackup-8.0.33-linux-loongarch64.tar.gz
percona-xtrabackup-8.0.33-linux-loongarch64.tar.gz: gzip compressed data, last modified: Fri Jul  7 09:07:15 2023, from Unix, original size 338969088
```
