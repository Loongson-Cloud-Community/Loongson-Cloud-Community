# powerdns

## 环境准备
- loongson loongarch64架构系统
- 软件依赖（以下软件是在debian系统的软件，若在其他系统上替换为相应的软件即可）
g++  libboost-all-dev libtool make pkg-config  libssl-dev autoconf automake bison flex lua5.3 liblua5.3-dev libmariadb-dev-compat libmariadb-dev

## 项目分析
powerdns是一个域名解析服务器，在powerdns源码中主要分为三种：auth,recursor和dnsdist

##版本信息
-auth-4.1.11
-其他版本移植参考这里的修改即可

## 移植步骤
共修改两个文件：m4/pdns_check_os.m4，pdns/dns.hh

m4/pdns_check_os.m4修改：
```
diff --git a/m4/pdns_check_os.m4 b/m4/pdns_check_os.m4
index 860f9aa0e..d2ec0b092 100644
--- a/m4/pdns_check_os.m4
+++ b/m4/pdns_check_os.m4
@@ -36,7 +36,7 @@ AC_DEFUN([PDNS_CHECK_OS],[
   AM_CONDITIONAL([HAVE_SOLARIS], [test "x$have_solaris" = "xyes"])
 
   case "$host" in
-  mips* | powerpc-* )
+  mips* | powerpc-* | loongarch64*)
     AC_MSG_CHECKING([whether the linker accepts -latomic])
     LDFLAGS="-latomic $LDFLAGS"
     AC_LINK_IFELSE([m4_default([],[AC_LANG_PROGRAM()])],
```

pdns/dns.hh 修改：
```
diff --git a/pdns/dns.hh b/pdns/dns.hh
index 88a658c5a..11abc3e64 100644
--- a/pdns/dns.hh
+++ b/pdns/dns.hh
@@ -142,7 +142,7 @@ static_assert(sizeof(EDNS0Record) == 4, "EDNS0Record size must be 4");
 # define PDP_ENDIAN     3412 /* LSB first in word, MSW first in long (pdp) */
 
 #if defined(vax) || defined(ns32000) || defined(sun386) || defined(i386) || \
-        defined(__i386) || defined(__ia64) || defined(__amd64) || \
+  defined(__i386) || defined(__ia64) || defined(__amd64) || defined(__loongarch64) || \
         defined(MIPSEL) || defined(_MIPSEL) || defined(BIT_ZERO_ON_RIGHT) || \
         defined(__alpha__) || defined(__alpha) || \
         (defined(__Lynx__) && defined(__x86__))
```

##编译
###pdns-auth编译
（1）生成configure文件：
```
./bootstrap 
```

（2）生成makefile文件：
```
./configure --with-module = "bind gmysql" --sysconfdir=/etc/powerdns --with-unixodbc-lib=/usr/lib/loongarch64-linux-gnu
```

（3）生成二进制
```
make -C ext && make -C modules && make -C pdns &&
make -C  pdns install && make -C modules install
```
###pdns-recurs编译
（1）进入 pdns/pdns/recursordist
（2）生成configure文件：
```
autoreconf -vi
```
（3）生成makefile文件：
```
./configure
```
（4）生成二进制：
```
make
```
  备注：具体可查看 pdns/pdns/recursordist/README.md 文件
###pdns-dnsdist编译
（1）进入pdns/pdns/dnsdistdist

步骤（2）～（4）同pdns-recurs编译中一致

##镜像制作
由于pdns-auth镜像较为常用，所以这里只介绍该镜像的制作方法，pdns-recur和pdns-dnsdist的制作参考pdns-auth即可
###Dockerfile-auth制作
由于该版本源码中没有dockerfile，所以需要手动编写dockerfile，主要参考auth-4.5.0和auth-4.3.0版本的dockerfile编写，
具体dockerfile见:https://github.com/Loongson-Cloud-Community/pdns/blob/auth-4.1.11/Dockerfile-auth 
###镜像编译
docker build -t pdns-auth:4.1.11 -f Dockerfile-auth .

