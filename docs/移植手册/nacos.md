
- 版本：2.1.0

## 01 项目介绍

Nacos /nɑ:kəʊs/ 是 Dynamic Naming and Configuration Service的首字母简称，一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。

Nacos 致力于发现、配置和管理微服务。Nacos 提供了一组简单易用的特性集，帮助您快速实现动态服务发现、服务配置、服务元数据及流量管理。

Nacos 帮助您更敏捷和容易地构建、交付和管理微服务平台。 Nacos 是构建以“服务”为中心的现代应用架构 (例如微服务范式、云原生范式) 的服务基础设施。

## 02 构建环境

```shell
# 系统信息
root@nacos_server /w/d/nacos# cat /etc/os-release 
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

# 内核信息
root@nacos_server /w/d/nacos# uname -r
4.19.190-2.1.lns8.loongarch64
```

## 03 依赖分析

对于官方的“nacos-server.jar”的架构相关扫描结果如下：
```
root@nacos_server /w/t/n/tmp# for file in (find ./ -name "*.jar"); jar tf $file | grep "\.so\$" && echo $file; end
librocksdbjni-linux32.so
librocksdbjni-linux64.so
librocksdbjni-linux-ppc64le.so
librocksdbjni-linux-aarch64.so
./BOOT-INF/lib/rocksdbjni-5.18.4.jar
META-INF/native/libnetty_transport_native_epoll_aarch_64.so
META-INF/native/libnetty_transport_native_epoll_x86_64.so
./BOOT-INF/lib/netty-all-4.1.59.Final.jar
META-INF/native/libio_grpc_netty_shaded_netty_tcnative_linux_x86_64.so
META-INF/native/libio_grpc_netty_shaded_netty_transport_native_epoll_x86_64.so
./BOOT-INF/lib/nacos-client-2.1.0.jar
META-INF/native/libio_grpc_netty_shaded_netty_tcnative_linux_x86_64.so
META-INF/native/libio_grpc_netty_shaded_netty_transport_native_epoll_x86_64.so
./BOOT-INF/lib/grpc-netty-shaded-1.26.0.jar
com/sun/jna/linux-x86/libjnidispatch.so
com/sun/jna/linux-x86-64/libjnidispatch.so
com/sun/jna/linux-arm/libjnidispatch.so
com/sun/jna/linux-armel/libjnidispatch.so
com/sun/jna/linux-aarch64/libjnidispatch.so
com/sun/jna/linux-ppc/libjnidispatch.so
com/sun/jna/linux-ppc64le/libjnidispatch.so
com/sun/jna/linux-mips64el/libjnidispatch.so
com/sun/jna/linux-s390x/libjnidispatch.so
com/sun/jna/sunos-x86/libjnidispatch.so
com/sun/jna/sunos-x86-64/libjnidispatch.so
com/sun/jna/sunos-sparc/libjnidispatch.so
com/sun/jna/sunos-sparcv9/libjnidispatch.so
com/sun/jna/freebsd-x86/libjnidispatch.so
com/sun/jna/freebsd-x86-64/libjnidispatch.so
com/sun/jna/openbsd-x86/libjnidispatch.so
com/sun/jna/openbsd-x86-64/libjnidispatch.so
./BOOT-INF/lib/jna-4.5.2.jar
```
从直接扫描的结果来看，主要存在“rocksdbjni-5.18.4.jar”， “netty-all-4.1.59.Final.jar”， “nacos-client-2.1.0.jar”， “grpc-netty-shaded-1.26.0.jar”， “jna-4.5.2.jar”这几个架构相关的包, 进一步分析上述jar包所涉及的项目，可以得到nacos-server的架构相关依赖关系如下：
```
nacos-2.1.0/
├── grpc-netty-shaded-1.26.0
│   └── netty-4.1.42.Final
│       └── netty-tcnative-parent-2.0.26.Final
├── jna-4.5.2
├── nacos-client-2.1.0
├── netty-all-4.1.59.Final
│   └── netty-tcnative-parent-2.0.36.Final
└── rocksdbjni-5.18.4
```

## 04 构建过程

## 05 测试

- db
- 端口


