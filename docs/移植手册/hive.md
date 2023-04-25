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

### 4.1 protoc-jar-3.5.1.1
下载protoc-jar-3.5.1.1.jar (https://github.com/Loongson-Cloud-Community/protoc-jar/releases/download/loongarch64-v3.5.1.1/protoc-jar-3.5.1.1.jar)存放置～/.m2/repository/com/github/os72/protoc-jar/3.5.1.1/目录下。       
具体构建方法查看：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/protoc-java.md

### 4.2 protoc-jar-maven-plugin-3.5.1.1

该项目是对4.1中protoc-jar-3.5.1.1的封装，所以在


构建指令
```
mvn clean install -Pdist -DskipTests -Dmaven.javadoc.skip=true 
```



