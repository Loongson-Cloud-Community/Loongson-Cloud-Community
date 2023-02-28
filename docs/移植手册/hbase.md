# hbase
## 快速开始
[点击这里](https://github.com/Loongson-Cloud-Community/hbase/releases/download/rel%2F2.4.16/hbase-2.4.16-bin.tar.gz)下载Apache HBase 2.4.16。
## hbase构建
### 版本
2.4.16
### 环境依赖
#### 移植环境
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
```
Linux b79f3dc579f0 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```
#### 软件依赖
```
yum install -y maven wget diffutils
```
除了上述直接通过yum安装的软件外，还需要安装`protobuf-3.21.12`以及`protobuf-2.5.0`：  
[点击这里](https://github.com/Loongson-Cloud-Community/protobuf/releases/download/v3.21.12/protobuf-3.21.12-linux-loong64.tar.gz)下载`protobuf-3.21.12`源码。  
[点击这里](https://github.com/Loongson-Cloud-Community/protobuf/releases/download/v2.5.0/protobuf-2.5.0-linux-loong64.tar.gz)下载`protobuf-2.5.0`源码。  
安装步骤如下：
```
yum install -y autoconf automake libtool curl make gcc-c++ unzip
tar -zxf protobuf-2.5.0-linux-loong64.tar.gz
tar -zxf protobuf-3.21.12-linux-loong64.tar.gz
cd protobuf-3.21.12
./autogen.sh
./configure --prefix=/usr --libdir=/usr/lib64
make
make install
cd ../protobuf-2.5.0
./autogen.sh
./configure --libdir=/usr/local/lib64
make
make install
mv /usr/local/bin/protoc /usr/local/bin/protoc-2.5.0
```
测试是否安装成功：
```
protoc --version
>> libprotoc 3.21.12
protoc-2.5.0 --version
>> libprotoc 2.5.0
```
#### 环境变量
```
export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.312.b07-8.1.10.lns8.loongarch64"
export M2_HOME="/usr/share/maven"
export PATH=$PATH:$JAVA_HOME/bin:$M2_HOME/bin:$JAVA_HOME/jre/bin
```
注意openjdk的版本。
### 快速构建
#### maven本地仓库
在`/usr/share/maven/conf/settings.xml`文件中设置maven本地仓库目录：
```
<localRepository>/data/local_repo</localRepository>
```
[点击这里](https://github.com/Loongson-Cloud-Community/hbase/releases/download/rel%2F2.4.16/local_repo.tar.gz)下载maven本地仓库，解压至`/data`目录下。
#### hbase源码
[点击这里](https://github.com/Loongson-Cloud-Community/hbase/releases/download/rel%2F2.4.16/hbase-2.4.16-src.tar.gz)下载hbase源码。
#### 编译
```
mvn -Dhadoop.profile=3.0 -Dhadoop-three.version=3.3.4 clean package -DskipTests assembly:single
```
编译信息的含义参考[这里](https://hbase.apache.org/book.html#build)。
### 详细构建
[点击这里](https://dlcdn.apache.org/hbase/2.4.16/hbase-2.4.16-src.tar.gz)下载hbase 2.4.16官方源码。  
参考软件依赖章节完成多版本`protoc`的安装。maven本地仓库路径的修改与否不会影响到后续的构建。
#### hbase源码修改
对`hbase-2.4.16`目录下的`pom.xml`以及`hbase-protocol-shaded/pom.xml`文件进行修改：
```
diff --git a/pom.xml b/pom.xml
index 11680c4..18a26f1 100755
--- a/pom.xml
+++ b/pom.xml
@@ -1697,7 +1697,7 @@
           <artifactId>protobuf-maven-plugin</artifactId>
           <version>${protobuf.plugin.version}</version>
           <configuration>
-            <protocArtifact>${external.protobuf.groupid}:protoc:${external.protoc.version}:exe:${os.detected.classifier}</protocArtifact>
+            <protocExecutable>/usr/local/bin/protoc-2.5.0</protocExecutable>      
             <protoSourceRoot>${basedir}/src/main/protobuf/</protoSourceRoot>
             <clearOutputDirectory>false</clearOutputDirectory>
             <checkStaleness>true</checkStaleness>

diff --git a/hbase-protocol-shaded/pom.xml b/hbase-protocol-shaded/pom.xml
index be67445..30ca69c 100644
--- a/hbase-protocol-shaded/pom.xml
+++ b/hbase-protocol-shaded/pom.xml
@@ -95,8 +95,8 @@
               <goal>compile</goal>
             </goals>
             <phase>generate-sources</phase>
             <configuration>
-              <protocArtifact>com.google.protobuf:protoc:${internal.protobuf.version}:exe:${os.detected.classifier}</protocArtifact>
+              <protocExecutable>/usr/bin/protoc</protocExecutable>
               <checkStaleness>true</checkStaleness>
             </configuration>
           </execution>
```
xml文件的修改，参考[这里](https://www.xolstice.org/protobuf-maven-plugin/compile-custom-mojo.html)。  
#### 寻找架构相关的jar包
关于架构相关jar包的寻找有两个方案：  
方案一，直接下载其他架构的`hbase-2.4.16-bin.tar.gz`文件，解压后在`lib`目录下查找含有`.so`文件的jar包，逐个适配；方案二，直接编译，遇到阻塞的jar包进行适配，编译完成后在maven本地仓库中查找含有`.so`文件的jar包，逐个适配。  
方案一适用于`lib`目录下架构相关的jar包来源于独立的项目与本项目无关，如只包含`jna.jar`。  
方案二适用于`lib`目录下架构相关的jar包是本项目生成的，无论其中的`.so`文件来源与项目自身编译产生的或是解压第三方jar包得到的，如本项目`hbase-2.4.16/lib`目录下的`shaded-clients/hbase-shaded-mapreduce-2.4.16.jar`等。  
采用方案二统计出需要适配的jar包有：
```
os-maven-plugin 1.5.0.final.jar
snappy-java-1.1.8.2.jar
jruby-complete-9.2.13.0.jar
hbase-shaded-netty-4.1.4.jar
commons-crypto-1.0.0.jar
leveldbjni-all-1.8.jar
jline-2.11.jar
jffi-1.2.16-native.jar
jna-5.2.0.jar
```
其中，`os-maven-plugin 1.5.0.final.jar`是hbase编译时需要的jar包，从`1.7.1`版本开始支持loongarch。
#### 适配os-maven-plugin 1.5.0.final.jar
[点击这里](https://github.com/trustin/os-maven-plugin/tree/os-maven-plugin-1.5.0.Final)跳转到`os-maven-plugin`项目。  
[点击这里](https://github.com/trustin/os-maven-plugin/pull/63/files)查看修改。  
修改后执行:
```
mvn clean package
mvn install
```
#### 适配snappy-java-1.1.8.2.jar
[点击这里](https://github.com/xerial/snappy-java/tree/1.1.8.2)跳转到`snappy-java`项目。  
[点击这里](https://github.com/xerial/snappy-java/blob/master/BUILD.md)查看如何编译。
#### 适配jruby-complete-9.2.13.0.jar
在适配`jruby-complete-9.2.13.0.jar`之前需要先适配以下项目，否则hbase在调用该jar包时会出错：
```
jffi 1.2.23
jnr-ffi 2.1.12
jnr-constants 0.9.15
jnr-posix 3.0.54
```
##### jffi
[点击这里](https://github.com/jnr/jffi/tree/jffi-1.2.23)跳转到`jffi`项目。  
[点击这里](https://github.com/Loongson-Cloud-Community/jffi/commit/9f4e5ea308acce52fb5e04fb6884741ae41b0fa4)查看修改。  
[点击这里](https://github.com/jnr/jffi/blob/jffi-1.2.23/README.md)查看如何编译。  
##### jnr-ffi
[点击这里](https://github.com/jnr/jnr-ffi/tree/jnr-ffi-2.1.12)跳转到`jnr-ffi`项目。  
[点击这里](https://github.com/Loongson-Cloud-Community/jnr-ffi/commit/2c2623da57abfaca16a2b9af1d6bad5ac15045c2)查看修改。  
修改后执行：
```
./mvnw install -DskipTests=true
```
#### jnr-constants
[点击这里](https://github.com/jnr/jnr-constants/tree/jnr-constants-0.9.15)跳转到`jnr-constants`项目。  
[点击这里](https://github.com/jnr/jnr-constants/pull/98/commits/39bae9852bc1dbb6a9024d35a2474b5e5a932be5)查看修改。  
[点击这里](https://github.com/jnr/jnr-constants/blob/jnr-constants-0.9.15/README.md)查看如何编译。  
#### jnr-posix
[点击这里](https://github.com/jnr/jnr-posix/tree/jnr-posix-3.0.54)跳转到`jnr-posix`项目。  
[点击这里](https://github.com/Loongson-Cloud-Community/jnr-posix/commit/e15e556eb16c3f96b73d239c25ebaa35c7e351a1)查看修改。  
修改后执行：
```
mvn package -DskipTests=true
mvn install -DskipTests=true
```
以上4个项目编译完成后，开始构建`jruby`：  
[点击这里](https://github.com/jruby/jruby/tree/9.2.13.0)跳转到`jruby`项目。  
[点击这里](https://github.com/Loongson-Cloud-Community/jruby/commit/db7fd99339bd91240117485ce20d6ffca61c3ce9)查看修改。  
[点击这里](https://github.com/jruby/jruby/blob/9.2.13.0/BUILDING.md)查看如何编译。  

#### hbase-shaded-netty-4.1.4.jar
`hbase-shaded-netty-4.1.4.jar`中的`.so`文件来源于`netty-transport-native-epoll-4.1.87.Final-linux-loongarch.jar`。而在编译`netty-transport-native-epoll-4.1.87.Final-linux-loongarch.jar`前需要先编译`netty-tcnative-linux-loongarch_64-2.0.56.Final.jar`。
##### netty-tcnative-linux-loongarch_64-2.0.56.Final.jar
参考[netty-tcnative移植手册](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/netty-tcnative.md)。  
##### netty-transport-native-epoll-4.1.87.Final-linux-loongarch.jar
参考[netty移植手册](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/netty.md)。  
安装上述两个jar包后开始编译`hbase-shaded-netty-4.1.4.jar`。[点击这里](https://github.com/apache/hbase-thirdparty/tree/rel/4.1.4)跳转到`hbase-thirdparty`项目。  
执行：
```
mvn clean install
```

#### commons-crypto-1.0.0.jar
[点击这里](https://github.com/apache/commons-crypto/tree/CRYPTO-1.0.0)跳转到`commons-crypto`项目。  
卸载高版本的openssl-devel，安装1.0.2版本openssl-devel:
```
yum install compat-openssl10-devel
```
安装后执行：
```
mvn clean package
mvn install
```
#### leveldbjni-all-1.8.jar
[点击这里](https://github.com/fusesource/leveldbjni/tree/leveldbjni-1.8)跳转到`leveldbjni`项目。  
[点击这里](https://github.com/fusesource/leveldbjni/pull/117/files)查看修改。  
[点击这里](https://github.com/fusesource/leveldbjni/blob/leveldbjni-1.8/readme.md#building)查看如何编译。  
#### jline-2.11.jar
[点击这里](https://github.com/jline/jline2/tree/jline-2.11)跳转到`jline2`项目。  
架构相关的`.so`文件来源于maven仓库中的`jansi-1.11.jar`。而`jansi-1.11.jar`中的`.so`文件来源于`jansi-native-1.5-linux64.jar`。  
##### jansi-native-1.5-linux64.jar
[点击这里](https://github.com/fusesource/jansi-native/tree/jansi-native-1.5)跳转到`jansi-native`项目。  
执行：
```
mvn clean package
```
一般会出现autotools相关的问题，如果出现：
```
config.status: error: cannot find input file: `Makefile.in'
```
进入报错的`configure.ac`文件所在的位置，执行：
```
aclocal
autoconf
autoheader
automake --add-missing
```
生成`Makefile.in`后重新在根目录执行命令:
```
mvn clean package
mvn install
```
##### jansi-1.11.jar
[点击这里](https://github.com/fusesource/jansi/tree/jansi-project-1.11)跳转到`jansi`项目。  
在`jansi/jansi`目录下执行：
```
mvn clean package
mvn install
```
上述的jar包安装到本地仓库后，在jline2根目录下执行：
```
mvn clean package
mvn install
```
#### jffi-1.2.16-native.jar
参考上文jffi项目。
#### jna-5.2.0.jar
参考[jna移植手册](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/jna.md)。
#### hbase编译
```
mvn -Dhadoop.profile=3.0 -Dhadoop-three.version=3.3.4 clean package -DskipTests assembly:single
```



