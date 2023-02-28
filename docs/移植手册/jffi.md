# jffi
## 移植版本
jffi-1.2.23
## 移植环境
```
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
内核版本
```
4.19.190-2.1.lns8.loongarch64
```
## 环境依赖
软件依赖
```
yum -y ant maven texinfo gcc
```
环境变量
```
export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.312.b07-8.1.10.lns8.loongarch64"
export M2_HOME="/usr/share/maven"
export PATH=$PATH:$JAVA_HOME/bin:$M2_HOME/bin:$JAVA_HOME/jre/bin
```
注意JDK版本
## 源码修改
[点击这里](https://github.com/Loongson-Cloud-Community/jffi/commit/9f4e5ea308acce52fb5e04fb6884741ae41b0fa4)查看修改。
另外，用龙芯适配的libffi替换源文件中的libffi。
## 编译
```
ant jar && ant archive-platform-jar && mvn package
```
