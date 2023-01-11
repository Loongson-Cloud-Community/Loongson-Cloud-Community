# netty-tcnative
netty-tcnative构建指导      
构建版本：netty-tcnative-parent-2.0.26.Final

## 1. 构建环境
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

## 2. 安装软件包
```
apt install libapr1-dev libssl-dev cmake ninja-build libunwind-dev golang-1.19-go
export PATH=/usr/lib/go-1.19/bin:$PATH
```

## 3. 源码修改
### (1)boringssl-static/pom.xml
```
diff --git a/boringssl-static/pom.xml b/boringssl-static/pom.xml
index cc40c74..e91b434 100644
--- a/boringssl-static/pom.xml
+++ b/boringssl-static/pom.xml
@@ -79,7 +79,7 @@
                 <configuration>
                   <checkoutDirectory>${boringsslCheckoutDir}</checkoutDirectory>
                   <connectionType>developerConnection</connectionType>
-                  <developerConnectionUrl>scm:git:https://boringssl.googlesource.com/boringssl</developerConnectionUrl>
+                  <developerConnectionUrl>scm:git:https://github.com/Loongson-Cloud-Community/boringssl</developerConnectionUrl>
                   <scmVersion>${boringsslBranch}</scmVersion>
                   <scmVersionType>branch</scmVersionType>
                   <skipCheckoutIfExists>true</skipCheckoutIfExists>
```

### (2) pom.xml
```
diff --git a/pom.xml b/pom.xml
index 2619560..18d3d01 100644
--- a/pom.xml
+++ b/pom.xml
@@ -90,7 +90,7 @@
       <extension>
         <groupId>kr.motd.maven</groupId>
         <artifactId>os-maven-plugin</artifactId>
-        <version>1.6.2</version>
+        <version>1.7.1</version>
       </extension>
     </extensions>
 
@@ -467,8 +467,8 @@
 
                         <property name="aprTarGzFile" value="apr-${aprVersion}.tar.gz" />
                         <property name="aprTarFile" value="apr-${aprVersion}.tar" />
-                        <get src="http://archive.apache.org/dist/apr/${aprTarGzFile}" dest="${project.build.directory}/${aprTarGzFile}" verbose="on" />
-                        <checksum file="${project.build.directory}/${aprTarGzFile}" algorithm="SHA-256" property="${aprSha256}" verifyProperty="isEqual" />
+                        <get src="https://github.com/Loongson-Cloud-Community/netty-tcnative/releases/download/netty-tcnative-parent-2.0.26.Final/la64-apr-1.6.5.tar.gz" dest="${project.build.directory}/${aprTarGzFile}" verbose="on" />
+                          <!-- <checksum file="${project.build.directory}/${aprTarGzFile}" algorithm="SHA-256" property="${aprSha256}" verifyProperty="isEqual" /> -->
                         <gunzip src="${project.build.directory}/${aprTarGzFile}" dest="${project.build.directory}" />
                         <!-- Use the tar command (rather than the untar ant task) in order to preserve file permissions. -->
                         <exec executable="tar" failonerror="true" dir="${project.build.directory}/" resolveexecutable="true">
```

## 4. 构建安装
```
./mvnw install
```

## 5. 包含组件
netty-tcnative-{os-arch}：动态连接到libapr-1和openssl，要使用该组件，系统必须同事安装和配置libapr-1和openssl,该组件管理员可以自由升级openssl而无需重新编译应用。       
netty-tcnative-boringssl-static-{os-arch}: 静态链接到谷歌的boringssl，是openssl的一个分支，具有附加功能，静态链接使得在系统上使用tcnative变得更容易，该库不需要apr。
netty-tcnative-boringssl-static: 其中包含了所有受支持的netty-tcnative-boringssl-static-{os-arch}，不需要关心平台架构。
netty-tcnative-openssl-static-{os-arch}: 静态链接到libapr-1和openssl

## 6. 备注
(1)若出现以下问题类似的是由于网络原因造成的：
```
     [echo] Downloading and unpacking APR
      [get] Getting: https://github.com/Loongson-Cloud-Community/netty-tcnative/releases/download/netty-tcnative-parent-2.0.26.Final/la64-apr-1.6.5.tar.gz
      [get] To: /home/zhaixiaojuan/workspace/netty-tcnative-test/libressl-static/target/apr-1.6.5.tar.gz
      [get] Error getting https://github.com/Loongson-Cloud-Community/netty-tcnative/releases/download/netty-tcnative-parent-2.0.26.Final/la64-apr-1.6.5.tar.gz to /home/zhaixiaojuan/workspace/netty-tcnative-test/libressl-static/target/apr-1.6.5.tar.gz
```
可以手动下载apr-1.6.5.tar.gz，然后将其复制到/home/zhaixiaojuan/workspace/netty-tcnative-test/libressl-static/target/apr-1.6.5.tar.gz并对其进行解压

(2) 
 以下两个连接是适配LA架构的，可直接下载使用（即可省略上面步骤”3源码修改“的内容）
https://github.com/Loongson-Cloud-Community/netty-tcnative/tree/loong64-netty-tcnative-parent-2.0.26.Final
https://github.com/Loongson-Cloud-Community/netty-tcnative/tree/loong64-netty-tcnative-parent-2.0.29.Final
