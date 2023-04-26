# hive构建指导

## 1. 构建版本
rel/release-3.1.2

## 2. 构建环境
本次构建使用龙芯debian系统，需要先安装java-8:
```
apt install -y openjdk-8-jdk
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64
export JRE_HOME=$JAVA_HOME/jre
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
```

## 3. 源码适配
该项目本身架构无关，无需适配

## 4. 依赖项准备
hive在构建时，会依赖一些架构相关的jar包，需要提前构建loongarch64架构的jar包，具体如下：

### 4.1 protoc-jar-3.5.1.1 jar包
1）直接下载:
将protoc-jar-3.5.1.1.jar (https://github.com/Loongson-Cloud-Community/protoc-jar/releases/download/loongarch64-v3.5.1.1/protoc-jar-3.5.1.1.jar)存放置～/.m2/repository/com/github/os72/protoc-jar/3.5.1.1/目录下。       
2）或者从源码构建安装：
https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/protoc-java.md

### 4.2 protoc-jar-maven-plugin-3.5.1.1 jar包
1）直接下载：
将protoc-jar-maven-plugin-3.5.1.1.jar(https://github.com/Loongson-Cloud-Community/protoc-jar-maven-plugin/releases/download/v3.5.1.1/protoc-jar-maven-plugin-3.5.1.1.jar)存放置
～/.m2/repository/com/github/os72/protoc-jar-maven-plugin/3.5.1.1/ 目录下。
2）或者从源码构建安装：
该项目是对4.1中protoc-jar-3.5.1.1的封装，所以在构建时需要先对其进行安装；
在protoc-jar-maven-plugin项目中执行：mvn clean install -DskipTests。

### 4.3 protoc-2.5.0 二进制
1) 直接下载：
 下载protoc二进制(https://github.com/Loongson-Cloud-Community/protobuf/releases/download/v2.5.0/protoc), 将其重命名为protoc-2.5.0-linux-loongarch_64.exe, 将其拷贝到～/.m2/repository/com/google/protobuf/protoc/2.5.0/ 目录下；
2) 或者从源码构建：
具体构建方法查看：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/protobuf.md 

### 4.4 lz4-java-1.3.0 jar包
1）直接下载：
将lz4-java-1.3.0-jar.tar.gz(https://github.com/Loongson-Cloud-Community/lz4-java/releases/download/1.3.0/lz4-java-1.3.0-jar.tar.gz)存放置～/.m2/repository/net/jpountz/lz4/lz4/1.3.0/ 目录下；
2）或者从源码构建安装
具体查看：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/lz4-java.md

### 4.5 snappy-java-1.1.4 jar包
1）直接下载：
将snappy-java-1.1.4.jar(https://github.com/Loongson-Cloud-Community/snappy-java/releases/download/loongarch64-v1.1.4/snappy-java-1.1.4.jar)存放置~/.m2/repository/org/xerial/snappy/snappy-java/1.1.4/ 目录下;
2) 或者从源码构建安装：
该项目架构无关，从官方下载源码(https://github.com/xerial/snappy-java)，执行make即可。

### 4.6 jansi-native-1.5 jar包
1）直接下载：
将jansi-linux64-1.5.jar(解压https://github.com/Loongson-Cloud-Community/jansi-native/releases/download/loong64-jansi-native-v1.5/loongarch64-jansi-native-1.5-jar.tar.gz ， 获取其中的ansi-linux64-1.5.jar)存放置~/.m2/repository/org/fusesource/jansi/jansi-native/1.5 目录下；     
2）或者从源码构建安装：
具体查看：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/jansi-native.md 

### 4.7 jansi-1.11 jar包
1）直接下载：
下载https://github.com/Loongson-Cloud-Community/jansi/releases/download/jansi-project-1.11/jansi-1.11-jar.tar.gz 从中获取jansi-1.11.jar包，将其存放到～/.m2/repository/org/fusesource/jansi/jansi/1.11；     
2）或者从源码构建安装：
从官方下载源码(https://github.com/fusesource/jansi), 执行命令“mvn install -DskipTests”

### 4.8 sigar-dist-1.6.5.132.zip 
1）直接下载：
获取https://github.com/Loongson-Cloud-Community/sigar/releases/download/loongarch64-master-ad47dc3b494e/sigar-dist-1.6.5.132.zip ， 将其拷贝到～/.m2/repository/org/hyperic/sigar-dist/1.6.5.132目录下；     
2）或者从源码构建：
查看：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/sigar.md 

### 4.9 java-util-1.3.2 jar包
1）直接下载：
下载 https://github.com/Loongson-Cloud-Community/java-util/releases/download/java-util-1.3.2/java-util-1.3.2.jar  存放置~/.m2/repository/com/metamx/java-util/1.3.2/ 目录下；


构建指令
```
mvn clean install -Pdist -DskipTests -Dmaven.javadoc.skip=true 
```



