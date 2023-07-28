# zdtd-jni
## 构建文档
### 1. 构建版本
v1.4.9-1     
### 2. 构建环境
```
[root@5cef9fb1156f zstd-jni-1.4.9-1]# uname -a
Linux 5cef9fb1156f 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux

[root@5cef9fb1156f zstd-jni-1.4.9-1]# cat /etc/os-release 
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
### 3. 源码修改
具体查看：https://github.com/Loongson-Cloud-Community/zstd-jni/tree/loong64-1.4.9-1      

### 4. 编译
```
./sbt compile test package
```

### 5. 备注
在源码中修改了以下内容，是因为源码中写的原始的sbt-jni的下载路径已经不存在，而且目前官方只存储了0.2.2b版本，所以这里修改了下载路径和下载版本。       
```
diff --git a/project/plugins.sbt b/project/plugins.sbt
index ef64a00..4629b83 100644
--- a/project/plugins.sbt
+++ b/project/plugins.sbt
@@ -1,5 +1,5 @@
 resolvers += Resolver.url("joprice-sbt-plugins", url("https://dl.bintray.com/content/joprice/sbt-plugins"))(Resolver.ivyStylePatterns)
 
-addSbtPlugin("com.github.joprice" % "sbt-jni" % "0.2.1")
+addSbtPlugin("io.github.joprice" % "sbt-jni" % "0.2.2")
 addSbtPlugin("com.typesafe.sbt" % "sbt-osgi" % "0.9.4")
 addSbtPlugin("com.github.sbt" % "sbt-jacoco" % "3.1.0")
```
