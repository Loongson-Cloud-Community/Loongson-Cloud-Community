# elasticsearch-analysis-ik

## 1. 项目介绍
项目源码链接：https://github.com/Loongson-Cloud-Community/elasticsearch-analysis-ik      
从elasticsearch-analysis-ik官方中下载 elasticsearch-analysis-ik-8.7.0.zip ，查看该zip是架构无关的，所以不需要进行移植，直接从官方链接下载即可。
若要进行从源码构建，则可参考下面的“2. 源码修改”和“3. 项目构建”。

## 2. 源码修改
构建版本：tag 8.7.0     
在构建源码时，需要修改pom.xml中elasticsearch的版本修改与tag的版本一致(这里为8.7.0)，才能和tag对应版本的elasticsearch(这里为8.7.0)配套使用。
```
[root@kubernetes-master-1 elasticsearch-analysis-ik]# git diff pom.xml
diff --git a/pom.xml b/pom.xml
index 6206bd6..e1cca8c 100755
--- a/pom.xml
+++ b/pom.xml
@@ -12,7 +12,7 @@
     <inceptionYear>2011</inceptionYear>
 
     <properties>
-        <elasticsearch.version>8.4.1</elasticsearch.version>
+        <elasticsearch.version>8.7.0</elasticsearch.version>
         <maven.compiler.target>1.8</maven.compiler.target>
         <elasticsearch.assembly.descriptor>${project.basedir}/src/main/assemblies/plugin.xml</elasticsearch.assembly.descriptor>
         <elasticsearch.plugin.name>analysis-ik</elasticsearch.plugin.name>
```
备注：pom.xml中设定的elasticsearch版本和源码的tag 版本不一致，在elasticsearch-analysis-ik的官方有相关的issue，可查看：
```
https://github.com/medcl/elasticsearch-analysis-ik/issues/839
https://github.com/medcl/elasticsearch-analysis-ik/issues/857
```

## 3. 项目构建
构建命令： 
```
mvn clean
mvn compile
mvn package
```
当构建完成后，zip文件存储在target/release 目录下
