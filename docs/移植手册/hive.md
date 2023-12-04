# hive

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

# 步骤4当前已经无需执行，使用龙芯官方maven仓库即可，使用[教程](http://docs.loongnix.cn/maven/user_guide.html)
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
2）或者从源码构建：
从官方下载源码(https://github.com/metamx/java-util.git), 执行命令“mvn install -DskipTests”

### 4.10 druid-0.12.0 jar包
1）直接下载：
下载 https://github.com/Loongson-Cloud-Community/druid/releases/download/druid-0.12.0/java-util-0.12.0.jar 存放置~/.m2/repository/io/druid/java-util/0.12.0/ 目录下；
2）或者从源码构建：
从官方下载源码(https://github.com/apache/druid.git), 执行命令“mvn clean install -pl java-util -am -DskipTests” 只构建java-util模块。

### 4.11 netty-4.1.17 jar包
1）直接下载：
下载 https://github.com/Loongson-Cloud-Community/netty/releases/download/loong64-netty-4.1.17.Final/netty-4.1.17-jar.tar.gz 从中获取netty-transport-4.1.17.Final.jar将其存放置~/.m2/repository/io/netty/netty-transport/4.1.17.Final/ 目录下。
2）或者从源码构建：
参考：
https://github.com/Loongson-Cloud-Community/netty/tree/loong64-netty-4.1.17.Final       
https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/netty.md      

### 4.12 netty-4.0.52 jar包
1）直接下载：
下载 https://github.com/Loongson-Cloud-Community/netty/releases/download/loong64-netty-4.0.52.Final/loong64-netty-4.0.52-jar.tar.gz 从中获取netty-transport-4.0.52.Final.jar将其存放置~/.m2/repository/io/netty/netty-transport/4.0.52.Final/ 目录下。
2）或者从源码构建：
参考：
https://github.com/Loongson-Cloud-Community/netty/tree/loong64-netty-4.0.52.Final           
https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/netty.md        

## 5. pom文件修改
### 5.0 对5.1的补充说明
也可以直接在maven仓库中添加仓库配置 vim $MAVEN_HOME/conf/settings.xml,配置该项后无需执行5.1
```
    <mirror>
      <id>conjars</id>
      <name>conjars</name>
      <url>https://conjars.wensel.net/repo/</url>
      <mirrorOf>conjars</mirrorOf>
    </mirror>
```
### 5.1 calcite-1.10.0.pom
在～/.m2/repository/org/apache/calcite/calcite/1.10.0/calcite-1.10.0.pom中修改pentaho-aggdesigner-algorithm的下载地址，代码如下，即用785～789行的代码替换791～801行的代码：
```
108     <pentaho-aggdesigner.version>5.1.5-jhyde</pentaho-aggdesigner.version>
......
360       <dependency>
361         <groupId>org.pentaho</groupId>
362         <artifactId>pentaho-aggdesigner-algorithm</artifactId>
363         <version>${pentaho-aggdesigner.version}</version>
364       </dependency>
......
776   <repositories>
777     <repository>
778       <id>central</id>
779       <name>Central Repository</name>
780       <url>http://repo.maven.apache.org/maven2</url>
781       <layout>default</layout>
782       <snapshots>
783         <enabled>false</enabled>
784       </snapshots>
785     </repository>
786         <repository>
787         <id>spring</id>
788         <url>https://maven.aliyun.com/repository/spring</url>
789     </repository>
790     <!--
791     <repository>
792       <releases>
793         <enabled>true</enabled>
794         <updatePolicy>always</updatePolicy>
795         <checksumPolicy>warn</checksumPolicy>
796       </releases>
797       <id>conjars</id>
798       <name>Conjars</name>
799       <url>http://conjars.org/repo</url>
800       <layout>default</layout>
801     </repository>
802     -->
803   </repositories>
```
这里之所以修改pentaho-aggdesigner-algorithm的下载地址，是因为791～801行的代码设置的下载地址已经不存在，目前下载地址已经更新为https://maven.aliyun.com/repository/spring , 
若不替换则会报以下错误：
```
[INFO] -----------------< org.apache.hive:hive-upgrade-acid >------------------
[INFO] Building Hive Upgrade Acid 3.1.2                                  [1/42]
[INFO] --------------------------------[ jar ]---------------------------------
Downloading from conjars: http://conjars.org/repo/org/pentaho/pentaho-aggdesigner-algorithm/5.1.5-jhyde/pentaho-aggdesigner-algorithm-5.1.5-jhyde.pom
......
[ERROR] Failed to execute goal on project hive-upgrade-acid: Could not resolve dependencies for project org.apache.hive:hive-upgrade-acid:jar:3.1.2: Failed to collect dependencies at org.apache.hive:hive-exec:jar:2.3.3 -> org.apache.calcite:calcite-core:jar:1.10.0 -> org.pentaho:pentaho-aggdesigner-algorithm:jar:5.1.5-jhyde: Failed to read artifact descriptor for org.pentaho:pentaho-aggdesigner-algorithm:jar:5.1.5-jhyde: Could not transfer artifact org.pentaho:pentaho-aggdesigner-algorithm:pom:5.1.5-jhyde from/to conjars (http://conjars.org/repo): Connect to conjars.org:80 [conjars.org/54.235.127.59] failed: 连接超时 (Connection timed out) -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR] 
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/DependencyResolutionException
```

### 5.2 async-http-client-2.0.37.pom
需要在～/.m2/repository/org/asynchttpclient/async-http-client/2.0.37/async-http-client-2.0.37.pom中做以下修改：     
（即将44行原本的linux-x86_64修改为linux-loongarch_64）    
```
27         <dependencies>
 28                 <dependency>
 29                         <groupId>org.asynchttpclient</groupId>
 30                         <artifactId>async-http-client-netty-utils</artifactId>
 31                         <version>${project.version}</version>
 32                 </dependency>
 33                 <dependency>
 34                         <groupId>io.netty</groupId>
 35                         <artifactId>netty-codec-http</artifactId>
 36                 </dependency>
 37                 <dependency>
 38                         <groupId>io.netty</groupId>
 39                         <artifactId>netty-handler</artifactId>
 40                 </dependency>
 41                 <dependency>
 42                         <groupId>io.netty</groupId>
 43                         <artifactId>netty-transport-native-epoll</artifactId>
 44                         <classifier>linux-loongarch_64</classifier>
 45                 </dependency>
```
这里之所以这样修改，是因为在～/.m2/repository/org/asynchttpclient/async-http-client/2.0.37/async-http-client-2.0.37.pom中设置了对netty-transport-native-epoll的架构依赖，若不修改，最后生成的 hive-druid-handler-3.1.2.jar中包含的将是x86架构的.so文件（libnetty_transport_native_epoll_x86_64.so）。


## 6. 构建指令
```
mvn clean install -Pdist -DskipTests -Dmaven.javadoc.skip=true 
```


