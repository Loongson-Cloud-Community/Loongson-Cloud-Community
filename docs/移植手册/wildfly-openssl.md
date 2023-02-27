# wildfly-openssl构建指导

## 1. 构建版本     
1.0.7

## 2. 构建环境
本次构建使用的loongnix server系统，具体系统信息如下：
```
[root@5cef9fb1156f wildfly-openssl-1.0.7]# cat /etc/os-release
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
```

```
[root@5cef9fb1156f wildfly-openssl-1.0.7]# uname -a
Linux 5cef9fb1156f 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 3.源码适配
具体查看 https://github.com/Loongson-Cloud-Community/wildfly-openssl/tree/loong64-1.0.7.Final 的git log信息。      

## 4. 构建
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0
mvn clean -DskipTests install
```
