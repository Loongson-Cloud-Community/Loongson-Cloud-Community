# grpc-java
grpc-java构建指导      

## 1. 构建版本
```
grpc-java:1.26.0
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

## 2. 安装软件包
```
apt install apt install openjdk-11-jdk，libprotoc-dev
```

## 3. 组件准备    
由于grpc 1.26.0在构建时依赖其他架构相关的项目：        
### 3.1 protobuf 3.11.0     
下载：https://github.com/Loongson-Cloud-Community/protobuf/releases/download/v3.11.0/protobuf-3.11.0-loongarch64.tar.gz      
解压protobuf的压缩包，将protoc二进制拷贝到/usr/bin/目录下，并根据下面的命令查看protoc库的查找路径，将库文件拷贝到对应的目录下（根据下面的结构，这里将库文件拷贝到/lib/loongarch64-linux-gnu目录下）。         
```
ldd /usr/bin/protoc 
	linux-vdso.so.1 (0x000000ffffc70000)
	libprotobuf.so.22 => /lib/loongarch64-linux-gnu/libprotobuf.so.22 (0x000000fff65f4000)
	libprotoc.so.22 => /lib/loongarch64-linux-gnu/libprotoc.so.22 (0x000000fff632c000)
	libz.so.1 => /lib/loongarch64-linux-gnu/libz.so.1 (0x000000fff6304000)
	libstdc++.so.6 => /lib/loongarch64-linux-gnu/libstdc++.so.6 (0x000000fff6128000)
	libm.so.6 => /lib/loongarch64-linux-gnu/libm.so.6 (0x000000fff605c000)
	libgcc_s.so.1 => /lib/loongarch64-linux-gnu/libgcc_s.so.1 (0x000000fff5ff8000)
	libpthread.so.0 => /lib/loongarch64-linux-gnu/libpthread.so.0 (0x000000fff5fc4000)
	libc.so.6 => /lib/loongarch64-linux-gnu/libc.so.6 (0x000000fff5e20000)
	/lib64/ld.so.1 (0x000000fff693ac68)
```

### 3.2 .gradle目录
在使用gradle构建时，依赖库的存放路径～/.gradle，其中包含了loongarch64架构相关的代码
下载gradle压缩包：https://github.com/Loongson-Cloud-Community/grpc-java/releases/download/loong64-v1.26.0/loong64-grpc-java-1.26.0-gradle.tar.gz，       
将其解压到～/目录下。    

### 3.3 .m2目录
maven在构建时，会将依赖默认下载到～/.m2的路径下，其中包含了loongarch64架构相关的代码。
下载m2压缩包：https://github.com/Loongson-Cloud-Community/grpc-java/releases/download/loong64-v1.26.0/loong64-grpc-java-1.26.0-m2.tar.gz，       
将其解压到～/目录下。     

## 4.  源码适配
### 4.1 源码修改
```
diff --git a/build.gradle b/build.gradle
index db7be15f4..023b47b22 100644
--- a/build.gradle
+++ b/build.gradle
@@ -27,6 +27,7 @@ subprojects {
     }
 
     tasks.withType(JavaCompile) {
+        it.options.errorprone.disableAllChecks=true
         it.options.compilerArgs += [
             "-Xlint:all",
             "-Xlint:-options",
diff --git a/compiler/build.gradle b/compiler/build.gradle
index 098f48c30..8799da3f9 100644
--- a/compiler/build.gradle
+++ b/compiler/build.gradle
@@ -56,6 +56,7 @@ model {
                 linker.executable = 'aarch64-linux-gnu-g++'
             }
             target("s390_64")
+            target("loongarch_64")
         }
         clang(Clang) {
         }
@@ -67,6 +68,7 @@ model {
         ppcle_64 { architecture "ppcle_64" }
         aarch_64 { architecture "aarch_64" }
         s390_64 { architecture "s390_64" }
+        loongarch_64 { architecture "loongarch_64" }
     }
 
     components {
@@ -76,7 +78,8 @@ model {
                 'x86_64',
                 'ppcle_64',
                 'aarch_64',
-                's390_64'
+                's390_64',
+                'loongarch_64'
             ]) {
                 // If arch is not within the defined platforms, we do not specify the
                 // targetPlatform so that Gradle will choose what is appropriate.
```

### 4.2 添加配置文件     
在grpc-java的根目录下创建文件gradle.properties，并写入以下内容用于指定使用本地的protoc，而不会再去google仓库中下载。     
```
cat gradle.properties 
protoc=/usr/bin/protoc
```

## 5. 构建
编译命令：      
```
./gradlew  build -x test  
```
备注： ”-x test“表示忽略测试
构建成功后在./compiler/build/exe/java_plugin/目录下生成二进制protoc-gen-grpc-java，并在每个子目录下生成对应的jar包。

## 6. 说明
### 6.1 .gradle目录      
~/.gradle目录下存储了与架构相关的依赖项，包含适配loongarch64的jar包：     
需要在os-maven-plugin 1.7.-0中添加LA架构适配，编译生成jar包并将其拷贝到”～/.gradle/caches/modules-2/files-2.1/kr.motd.maven/os-maven-plugin/1.7.0/c50a6b3cb49e24d96b1252619a3c600c08796193“路径下。      

### 6.2 .m2目录
.m2路径存储了两个和架构相关的jar包：     
1）netty-tcnative 2.0.26      
下载其源码并进行编译安装，具体构建方法见：
https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/netty-tcnative.md      

2）netty 4.1.42
下载其源码并进行编译安装，具体构建方法见：    
https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/netty.md     

## 7 备注
步骤6主要是对.m2和.gradle中适配LA架构的项目进行了一个解释，按照步骤3中拷贝 .gradle和.m2的目录后，步骤6可完全忽略。      









