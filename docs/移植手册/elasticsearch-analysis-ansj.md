# elasticsearch-analysis-ansj

## 1.项目介绍
项目源码链接：[https://github.com/Loongson-Cloud-Community/elasticsearch-analysis-ik](https://github.com/NLPchina/elasticsearch-analysis-ansj)

## 2.源码构建
构建版本： tag 8.7.0
构建工具安装：
```
yum install -y java-11-openjdk
......
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-11.0.19.0.7-11.6.0.lns8.loongarch64"
```
```
mvn package
```
编译完成后，会生成target/releases/elasticsearch-analysis-ansj-8.7.0.0-release.zip。解压该zip，查看其中并没有和架构相关的二进制。

