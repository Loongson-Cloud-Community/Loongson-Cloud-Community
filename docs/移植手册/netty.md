# netty
netty构建指导      

## 1. 构建版本
```
tag: netty-4.1.42.Final
```

## 2. 构建环境
```
cat /etc/os-release
PRETTY_NAME="Loongnix GNU/Linux 20 (DaoXiangHu)"
NAME="Loongnix GNU/Linux"
VERSION_ID="20"
VERSION="20 (DaoXiangHu)"
VERSION_CODENAME=DaoXiangHu
ID=Loongnix
HOME_URL="https://www.loongnix.cn/"
SUPPORT_URL="https://www.loongnix.cn/"
BUG_REPORT_URL="http://www.loongnix.cn/"

```

```
uname -a
Linux node1 4.19.0-19-loongson-3 #1 SMP pkg_lnd10_4.19.190-7.6 Wed Nov 16 11:12:41 UTC 2022 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 3. 源码修改
```
diff --git a/common/src/main/java/io/netty/util/internal/PlatformDependent.java b/common/src/main/java/io/netty/util/internal/PlatformDependent.java
index b7ce81484f..463426c12f 100644
--- a/common/src/main/java/io/netty/util/internal/PlatformDependent.java
+++ b/common/src/main/java/io/netty/util/internal/PlatformDependent.java
@@ -1398,6 +1398,9 @@ public final class PlatformDependent {
         if ("s390x".equals(value)) {
             return "s390_64";
         }
+        if ("loongarch64".equals(value)) {
+            return "loongarch_64";
+        }
 
         return "unknown";
     }
diff --git a/pom.xml b/pom.xml
index 4737b3e3e5..be3de04ef1 100644
--- a/pom.xml
+++ b/pom.xml
@@ -311,7 +311,7 @@
     <argLine.javaProperties>-D_</argLine.javaProperties>
     <!-- Configure the os-maven-plugin extension to expand the classifier on                  -->
     <!-- Fedora-"like" systems. This is currently only used for the netty-tcnative dependency -->
-    <osmaven.version>1.6.2</osmaven.version>
+    <osmaven.version>1.7.1</osmaven.version>
     <!-- keep in sync with PlatformDependent#ALLOWED_LINUX_OS_CLASSIFIERS -->
     <os.detection.classifierWithLikes>fedora,suse,arch</os.detection.classifierWithLikes>
     <tcnative.artifactId>netty-tcnative</tcnative.artifactId>
@@ -768,10 +768,10 @@
                 </requireMavenVersion>
                 <requireProperty>
                   <regexMessage>
-                    x86_64/AARCH64/PPCLE64 JDK must be used.
+                    x86_64/AARCH64/PPCLE64/loongarch64 JDK must be used.
                   </regexMessage>
                   <property>os.detected.arch</property>
-                  <regex>^(x86_64|aarch_64|ppcle_64)$</regex>
+                  <regex>^(x86_64|aarch_64|ppcle_64|loongarch_64)$</regex>
                 </requireProperty>
               </rules>
             </configuration>
diff --git a/testsuite-shading/pom.xml b/testsuite-shading/pom.xml
index e4064cfe9b..0301616136 100644
--- a/testsuite-shading/pom.xml
+++ b/testsuite-shading/pom.xml
@@ -46,7 +46,7 @@
       <extension>
         <groupId>kr.motd.maven</groupId>
         <artifactId>os-maven-plugin</artifactId>
-        <version>1.6.0</version>
+        <version>1.7.1</version>
       </extension>
     </extensions>
     <plugins>
```

## 4. 构建命令
```
./mvnw  install -DskipTests
```
