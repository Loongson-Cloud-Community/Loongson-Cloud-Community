# elasticsearch

## 版本选择
龙芯移植版本选择 `elasticsearch 7.13.0`。主要是出于 ELK 兼容性考虑。

## 项目分析
elasticsearch 本身是 java 项目，可以在 JVM 的基础上跨架构运行，但是由于其使用了 JNA 技术，所以 `jna` 和其一个 c 语言模块 `ml-cpp` 需要在龙芯架构上进行代码移植和编译。通过我们的分析，其 java 调用 ml-cpp 部分的 java 代码也需要在增加相应的架构代码，所以需要适配的部分一共有三处。
- ml-cpp java 部分
- ml-cpp c 部分
- jna

下面按照 jna，ml-cpp c 部分，ml-cpp java 部分 的顺序分步说明。

## jna
根据 elasticsearch 7.13.0 [版本依赖](https://github.com/elastic/elasticsearch/blob/v7.13.0/buildSrc/version.properties) 确定 jna 版本 [5.7.0-1](https://github.com/java-native-access/jna/tree/5.7.0)

jna 技术属于 java 调用 c 的外部函数调用，和 jnr，jni 等一样，其核心依然是 libffi。所以第一步将 `native/libffi` 替换为龙芯适配后的 libffi 源码。
第二步，在 jna 源码中增加 loongarch64 逻辑。
```
[root@916b602ffe1d jna-5.7.0]# git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   build.xml
	modified:   src/com/sun/jna/Native.java
	modified:   src/com/sun/jna/NativeLibrary.java
	modified:   src/com/sun/jna/Platform.java

```
然后编译 jna 即可
```
ant native
ant -Drelease=true -Dmaven-release=true clean dist 
```
生成 `dist/jna.jar` 保存。


## ml-cpp c 语言部分
ml-cpp 版本和 elasticsearch 版本保持一致，选择 [7.13.0](https://github.com/elastic/ml-cpp/tree/v7.13.0)。

ml-cpp 官方[构建方法](https://github.com/elastic/ml-cpp/blob/v7.13.0/build-setup/linux.md)

在官方的构建中，一共需要编译并安装
- gcc 7.5
- binutils 2.34
- git 1.8.3+
- libxml2 2.9.4
- boost 1.71.0
- patchelf 0.9
- valgrind 3.15.0

经过分析，gcc，binutils，git，patchelf，valgrind 不需要编译，可以用安装源代替。需要编译的只是 libxml2 和 boost。

### 准备工作
```
# 安装系统依赖
yum install bzip2 gcc-c++ texinfo tzdata unzip zlib-devel java-1.8.0-openjdk autoconf libtool patchelf diffutils

# 创建默认目录
mkdir -p /usr/local/gcc75

# 配置环境变量
export LD_LIBRARY_PATH=/usr/local/gcc75/lib64:/usr/local/gcc75/lib:/usr/lib:/lib
export PATH=$JAVA_HOME/bin:/usr/local/gcc75/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/vagrant/bin

# 这里按照你 ml-cpp 下载的路径存放
export CPP_SRC_HOME=$HOME/ml-cpp
```
### 构建 libxml2
```
git clone -b v2.9.4 https://gitlab.gnome.org/GNOME/libxml2.git
./autogen.sh
./configure --prefix=/usr/local/gcc75 --without-python --without-readline
make -j 4
make install 
```

### 构建 boost
下载龙芯适配的源码
```
# 参照官网步骤编译即可
./bootstrap.sh --without-libraries=context --without-libraries=coroutine --without-libraries=graph_parallel --without-libraries=mpi --without-libraries=python --without-icu

[root@916b602ffe1d boost]# git diff
diff --git a/boost/math/tools/config.hpp b/boost/math/tools/config.hpp
index 47fdea65c..12e4b52a8 100644
--- a/boost/math/tools/config.hpp
+++ b/boost/math/tools/config.hpp
@@ -377,7 +377,7 @@ struct is_integer_for_rounding
 #  endif
 #endif
 
-#if ((defined(__linux__) && !defined(__UCLIBC__) && !defined(BOOST_MATH_HAVE_FIXED_GLIBC)) || defined(__QNX__) || defined(__IBMCPP__)) && !defined(BOOST_NO_FENV_H)
+#if ((!defined(BOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS) && defined(__linux__) && !defined(__UCLIBC__) && !defined(BOOST_MATH_HAVE_FIXED_GLIBC)) || defined(__QNX__) || defined(__IBMCPP__)) && !defined(BOOST_NO_FENV_H)
 //
 // This code was introduced in response to this glibc bug: http://sourceware.org/bugzilla/show_bug.cgi?id=2445
 // Basically powl and expl can return garbage when the result is small and certain exception flags are set
diff --git a/boost/unordered/detail/implementation.hpp b/boost/unordered/detail/implementation.hpp
index 9dffde159..7c653fee6 100644
--- a/boost/unordered/detail/implementation.hpp
+++ b/boost/unordered/detail/implementation.hpp
@@ -284,7 +284,7 @@ namespace boost {
 
 // clang-format off
 #define BOOST_UNORDERED_PRIMES \
-    (17ul)(29ul)(37ul)(53ul)(67ul)(79ul) \
+    (3ul)(17ul)(29ul)(37ul)(53ul)(67ul)(79ul) \
     (97ul)(131ul)(193ul)(257ul)(389ul)(521ul)(769ul) \
     (1031ul)(1543ul)(2053ul)(3079ul)(6151ul)(12289ul)(24593ul) \
     (49157ul)(98317ul)(196613ul)(393241ul)(786433ul) \


./b2 -j6 --layout=versioned --disable-icu pch=off optimization=speed inlining=full define=BOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS define=BOOST_LOG_WITHOUT_DEBUG_OUTPUT define=BOOST_LOG_WITHOUT_EVENT_LOG define=BOOST_LOG_WITHOUT_SYSLOG define=BOOST_LOG_WITHOUT_IPC define=_FORTIFY_SOURCE=2 cxxflags=-std=gnu++14 cxxflags=-fstack-protector linkflags=-Wl,-z,relro linkflags=-Wl,-z,now

env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./b2 install --prefix=/usr/local/gcc75 --layout=versioned --disable-icu pch=off optimization=speed inlining=full define=BOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS define=BOOST_LOG_WITHOUT_DEBUG_OUTPUT define=BOOST_LOG_WITHOUT_EVENT_LOG define=BOOST_LOG_WITHOUT_SYSLOG define=BOOST_LOG_WITHOUT_IPC define=_FORTIFY_SOURCE=2 cxxflags=-std=gnu++14 cxxflags=-fstack-protector linkflags=-Wl,-z,relro linkflags=-Wl,-z,now
```

## 正式构建 ml-cpp
首先下载 ml-cpp 7.13.0 的源码，然后在 `3rd_party.sh` 中执行 `bash pull-eigen.sh` 命令
可选操作，下载完 eigen 后，在 ml-cpp 初始化 git 仓库，以便后续

```
# 因为我们没有手动编译 gcc ，所以需要把需要的文件拷贝到 /usr/local/gcc75 对应的目录下
mkdir -pv /usr/local/gcc75/lib64
cp /lib64/libgcc_s.so.1 /usr/local/gcc75/lib64/
cp /lib64/libstdc++.so.6 /usr/local/gcc75/lib64/

# 因为我们编译出来的 boost 库不包含后缀，所以需要修改脚本
sed -i 's/$(BOOSTARCH)-//g' mk/linux.mk
```

修改一些编译源码和配置
```
[root@916b602ffe1d ml-cpp]# git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   3rd_party/3rd_party.sh
	modified:   3rd_party/rapidjson/include/rapidjson/rapidjson.h
	modified:   3rd_party/rapidjson/include/rapidjson/writer.h
	modified:   lib/core/CCrashHandler_Linux.cc
	modified:   lib/seccomp/CSystemCallFilter_Linux.cc
	modified:   mk/linux.mk
	modified:   mk/macosx.mk

```

生成的二进制在 `build/distribution/platform`

## ml-cpp java 部分编译
因为 java 跨平台的特性且龙芯当前 java 版本不够，所以修改好代码后在 x86 下编译也是一样的。
```
[root@916b602ffe1d elasticsearch-7.13.0]# git diff --cached
diff --git a/x-pack/plugin/ml/src/main/java/org/elasticsearch/xpack/ml/MachineLearningFeatureSet.java b/x-pack/plugin/ml/src/main/java/org/elasticsearch/xpack/ml/MachineLearningFeatureSet.java
index 1c81dfe5..3a36e5e2 100644
--- a/x-pack/plugin/ml/src/main/java/org/elasticsearch/xpack/ml/MachineLearningFeatureSet.java
+++ b/x-pack/plugin/ml/src/main/java/org/elasticsearch/xpack/ml/MachineLearningFeatureSet.java
@@ -76,7 +76,7 @@ public class MachineLearningFeatureSet implements XPackFeatureSet {
      * List of platforms for which the native processes are available
      */
     private static final List<String> mlPlatforms = Collections.unmodifiableList(
-            Arrays.asList("darwin-x86_64", "linux-aarch64", "linux-x86_64", "windows-x86_64"));
+            Arrays.asList("darwin-x86_64", "linux-aarch64", "linux-x86_64", "windows-x86_64","linux-loongarch64"));
 
     private final boolean enabled;
     private final XPackLicenseState licenseState;
```

## 最后整合
将在龙芯移植后的 jna.jar, linux-loongarch64 (ml-cpp), ml-cpp.jar 和 jdk 替换掉 x86 下编译生成的 tar 包即可。
