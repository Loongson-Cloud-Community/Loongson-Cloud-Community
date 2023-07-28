# hadoop

## 1.构建版本
hadoop-3.3.4

## 2. 快速下载
https://github.com/Loongson-Cloud-Community/hadoop/releases/download/untagged-d8735871897e8e2f1b0c/hadoop-3.3.4.tar.gz

## 3. 构建环境
本次构建使用龙芯server系统，具体信息如下：
```
[root@5cef9fb1156f /]# cat /etc/os-release 
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
[root@5cef9fb1156f /]# uname -a
Linux 5cef9fb1156f 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 4. 软件安装
```
yum install -y maven autoconf automake libtool cmake zlib-devel  lzo-devel svn ncurses-devel openssl-devel make cmake  protobuf cyrus-sasl-lib cyrus-sasl-devel fuse-devel git
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel java-1.8.0-openjdk-javadoc
yum install -y libstdc++ libstdc++-devel libstdc++-static gcc gcc-c++ 
yum install -y devtoolset-10-gcc devtoolset-10-gcc-c++ devtoolset-10-libgcc devtoolset-10-libstdc++
```
```
export PATH=/opt/rh/devtoolset-10/root/bin:$PATH
```

## 5. 构建准备
```
在构建hadoop-3.3.4之前需要先构建安装protobuf3.7，从github官方获取源码，构建步骤如下：
./autogen.sh  
./configure （静态编译：./configure --enable-static）
make （静态编译 make LDFLAGS=-all-static）
sudo make install
```

## 6. 源码修改
具体查看https://github.com/Loongson-Cloud-Community/hadoop/tree/loong64-3.3.4 的git log信息。

## 7. 构建命令
获取.m2压缩包（https://github.com/Loongson-Cloud-Community/hadoop/releases/download/untagged-d8735871897e8e2f1b0c/hadoop-m2-3.3.4.tar.gz） ，将其拷贝到～/目录下，并进行解压。
在源码中执行构建命令：
```
mvn package -Pdist,native -DskipTests -Dtar
```
构建成功后会在hadoop-dist/target目录下生成tar包hadoop-3.3.4.tar.gz

## 8. 备注
.m2路径中包含了以下与架构相关的包：

### node-v12.19.1     
在.m2中的具体路径：~/.m2/repository/com/github/eirslett/node/12.19.1/node-v12.19.1-linux-loongarch64.tar.gz            
该tar包的下载地址：http://ftp.loongnix.cn/nodejs/LoongArch/dist/

### grpc-java-1.26.0     
在.m2中的具体路径：~/.m2/repository/io/grpc/protoc-gen-grpc-java/1.26.0/protoc-gen-grpc-java-1.26.0-linux-loongarch_64.exe      
具体构建方法参考：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/grpc-java.md

### protobuf-3.7.1
在.m2中的具体路径：~/.m2/repository/com/google/protobuf/protoc/3.7.1/protoc-3.7.1-linux-loongarch_64.exe       
具体构建方法查看上面的“5.构建准备”。

### protobuf-2.5.0
在.m2中具体位置：~/.m2/repository/com/google/protobuf/protoc/2.5.0/protoc-2.5.0-linux-loongarch_64.exe        
具体构建方法参考：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/protobuf.md 

### netty-4.1.77
在.m2中的具体路径：~/.m2/repository/io/netty/netty-transport-native-epoll/4.1.77.Final/netty-transport-native-epoll-4.1.77.Final-linux-loongarch64.jar           
具体构建方法参考：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/netty.md     

### zstd-jni-1.4.9-1
在.m2中的具体路径：~/.m2/repository/com/github/luben/zstd-jni/1.4.9-1/zstd-jni-1.4.9-1.jar         
具体构建方法参考：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/zstd-jni.md    

### snappy-java-1.1.8.2
在.m2中的具体路径：~/.m2/repository/org/xerial/snappy/snappy-java/1.1.8.2/snappy-java-1.1.8.2.jar        
具体构建方法参考官方：https://github.com/xerial/snappy-java/blob/master/BUILD.md

### lz4-java-1.7.1
在.m2中的具体路径：~/.m2/repository/org/lz4/lz4-java/1.7.1/lz4-java-1.7.1.jar       
具体构建方法参考官方：https://github.com/lz4/lz4-java

### wildfly-openssl-1.0.7
在.m2中的具体路径：~/.m2/repository/org/wildfly/openssl/wildfly-openssl/1.0.7.Final/wildfly-openssl-1.0.7.Final.jar               
具体构建方法参考：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/wildfly-openssl.md 

### jna-5.2.0
在.m2中的路径：~/.m2/repository/net/java/dev/jna/jna/5.2.0/jna-5.2.0.jar    
具体构建方法参考：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/jna.md

### leveldbjni-all
在.m2中的路径：~/.m2/repository/org/fusesource/leveldbjni/leveldbjni-all/1.8/leveldbjni-all-1.8.jar              
具体构建方法参考官方：https://github.com/fusesource/leveldbjni/blob/leveldbjni-1.8/readme.md#building 

### netty-all
在netty-all文件netty-all-4.1.77.Final.pom中添加了LA架构，具体添加内容如下：      
~/.m2/repository/io/netty/netty-all/4.1.77.Final/netty-all-4.1.77.Final.pom：       
```
861     <dependency>
 862       <groupId>io.netty</groupId>
 863       <artifactId>netty-transport-native-epoll</artifactId>
 864       <version>4.1.77.Final</version>
 865       <classifier>linux-loongarch64</classifier>
 866       <scope>runtime</scope>
 867       <exclusions>
 868         <exclusion>
 869           <groupId>io.netty</groupId>
 870           <artifactId>netty-common</artifactId>
 871         </exclusion>
 872         <exclusion>
 873           <groupId>io.netty</groupId>
 874           <artifactId>netty-buffer</artifactId>
 875         </exclusion>
 876         <exclusion>
 877           <groupId>io.netty</groupId>
 878           <artifactId>netty-transport</artifactId>
 879         </exclusion>
 880         <exclusion>
 881           <groupId>io.netty</groupId>
 882           <artifactId>netty-transport-native-unix-common</artifactId>
 883         </exclusion>
 884         <exclusion>
 885           <groupId>io.netty</groupId>
 886           <artifactId>netty-transport-classes-epoll</artifactId>
 887         </exclusion>
 888       </exclusions>
 889       <optional>false</optional>
 890     </dependency>
```
