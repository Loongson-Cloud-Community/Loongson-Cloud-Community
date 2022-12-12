# onlyoffice documentserver
## 快速部署
[点击这里](https://github.com/Loongson-Cloud-Community/DocumentServer/releases/download/v7.1.1/onlyoffice-documentserver_0.0.0-0_mips64el.deb)下载 mips64 架构 onlyoffice documentsever 7.1.1 `deb` 包。

[点击这里](https://github.com/Loongson-Cloud-Community/onlyoffice-documentserver/tree/v7.1.1-mips)查看或下载已经适配 mips64 架构的脚本。
## 移植架构
mips64el
## 移植版本
本文移植的 onlyoffice documentserver 为 `7.1.1` 版本。
## 环境要求
### 硬件
磁盘空间 >=40G   
内存 >=2G  
CPU >=2，>=2GHz  
SWAP >=4G
### 软件
python  
git  
ninja-build  
nodejs 14.16.1  
npm 8.19.2  
jdk8  

**注：本文的移植步骤仅在debian:bullseye下进行过验证，以上环境要求参考[官方文档](https://helpcenter.onlyoffice.com/installation/docs-community-compile.aspx)。**
## 移植步骤
### 软件适配
#### 安装依赖软件
安装 git python 以及 ninja：  
```
sudo apt install -y git python python3 ninja-build
```  
debian 官方源提供的 nodejs 和 npm 版本过低，选择从龙芯mips源中下载和安装 nodejs，通过 yarnpkg 安装高版本 npm：  
```
apt install -y yarnpkg && yarnpkg add npm -g
```  
从 http://ftp.loongnix.cn 中下载 mips jdk8 的 tar 包，解压后将其安装在 `/usr/local` 下，并设置以下环境变量：  
```
export JAVA_HOME=/usr/local/openjdk &&\
export PATH=$JAVA_HOME/bin:$PATH
```
#### 下载源码
新建目录 onlyoffice，将其视为本次软件移植的根目录：  
```
mkdir onlyoffice && cd onlyoffice
```
下载 onlyoffice documentserver 官方构建工具 [build_tools](https://github.com/ONLYOFFICE/build_tools)，使用 git 切换版本至 `v7.1.1.76`（如果读者需要适配其他版本的源码，请确保 build_tools 中的 `version` 与 documentserver 源码的版本一致）:  
```
git clone -b v7.1.1.76 https://github.com/ONLYOFFICE/build_tools.git
```
![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/3.1.png)

下载 [onlyoffice documentserver](https://github.com/ONLYOFFICE/DocumentServer) 官方源码，使用 git 切换版本至 `v7.1.1`，同时下载 documentserver 中链接的子项目，下载完成后将 documentserver 的组件移动到上层目录：  
```
git clone --recursive -b v7.1.1 https://github.com/ONLYOFFICE/DocumentServer.git &&\ 
mv ./DocumentServer/core ./DocumentServer/core-fonts ./DocumentServer/dictionaries ./DocumentServer/sdkjs ./DocumentServer/sdkjs-plugins ./DocumentServer/server ./DocumentServer/web-apps .
```
下载 [onlyoffice document-templates](https://github.com/ONLYOFFICE/document-templates) 官方源码，使用 git 切换版本至 `v7.1.1.76`：
```
git clone -b v7.1.1.76 https://github.com/ONLYOFFICE/document-templates.git
```
下载 [onlyoffice document-server-integration](https://github.com/ONLYOFFICE/document-server-integration) 官方源码，使用 git 切换版本至 `v7.1.1.76`，同时下载 documentserver 中链接的子项目:
```
git clone --recursive -b v7.1.1.76 https://github.com/ONLYOFFICE/document-server-integration.git
```
下载 [onlyoffice sdkjs-forms](https://github.com/ONLYOFFICE/sdkjs-forms) 官方源码，使用 git 切换版本至 `v7.1.1.76`：
```
git clone -b v7.1.1.76 https://github.com/ONLYOFFICE/sdkjs-forms.git
```
下载 [onlyoffice ducumentbuilder](https://github.com/ONLYOFFICE/DocumentBuilder) 官方源码，使用 git 切换版本至 `v7.1.1.76`，同时下载 documentbuilder 中链接的子项目：
```
git clone --recursive -b v7.1.1.76 https://github.com/ONLYOFFICE/DocumentBuilder.git
```
#### 设置环境变量
```
export GCLIENT_PY3=0  
export USE_PYTHON3=0
export DEPOT_TOOLS_UPDATE=0
export DEPOT_TOOLS_BOOTSTRAP_PYTHON3=0
export SKIP_GCE_AUTH_FOR_GIT=1
export KERNEL_BITS=64
```
#### 修改脚本和源码
注释 `./build_tools/make.py` 中更新 onlyoffice 组件的代码，确保版本始终为 `v7.1.1`:
```
diff --git a/make.py b/make.py
index 7635f70..a22a30e 100755
--- a/make.py
+++ b/make.py
@@ -52,9 +52,9 @@ config.parse_defaults()
 base.check_build_version(base_dir)
 
 # update
-if ("1" == config.option("update")):
-  repositories = base.get_repositories()
-  base.update_repositories(repositories)
+#if ("1" == config.option("update")):
+#  repositories = base.get_repositories()
+#  base.update_repositories(repositories)
 
 base.configure_common_apps()
```
修改 `./build_tools/scripts/core_common/modules/openssl.py`：
```
diff --git a/scripts/core_common/modules/openssl.py b/scripts/core_common/module
index 2a5cdbd..ebff355 100644
--- a/scripts/core_common/modules/openssl.py
+++ b/scripts/core_common/modules/openssl.py
@@ -79,12 +79,12 @@ def make():
     return
 
   if (-1 != config.option("platform").find("linux")) and not base.is_dir("../bu
-    base.cmd("./config", ["no-shared", "no-asm", "--prefix=" + old_cur_dir + "/
+    base.cmd("./Configure", ["linux64-mips64", "no-shared", "no-asm", "--prefix
     base.replaceInFile("./Makefile", "CFLAGS=-Wall -O3", "CFLAGS=-Wall -O3 -fvi
     base.replaceInFile("./Makefile", "CXXFLAGS=-Wall -O3", "CXXFLAGS=-Wall -O3 
     base.cmd("make")
     base.cmd("make", ["install"])
-    # TODO: support x86
+    # TODO: support mips64
```
修改 `./build_tools/scripts/base.py`：
```
diff --git a/scripts/base.py b/scripts/base.py
index fc8a377..3f92ccf 100644
--- a/scripts/base.py
+++ b/scripts/base.py
@@ -598,6 +598,8 @@ def qt_config(platform):
     config_param += " linux_arm64"
   if config.check_option("platform", "linux_arm64"):
     config_param += " v8_version_89"
+  if config.check_option("platform", "linux_64"):
+    config_param += " v8_version_89"
   return config_param
 
 def qt_major_version():
@@ -1243,7 +1245,7 @@ def copy_v8_files(core_dir, deploy_dir, platform, is_xp=Fa
   if (config.option("vs-version") == "2019"):
     directory_v8 += "/v8_89/v8/out.gn/"
   else:
-    directory_v8 += "/v8/v8/out.gn/"
+    directory_v8 += "/v8_89/v8/out.gn/"
 
   if is_xp:
     copy_files(directory_v8 + platform + "/release/icudt*.dll", deploy_dir + "/
```
修改 `./build_tools/scripts/core_common/modules/v8.py`：
```
diff --git a/scripts/core_common/modules/v8.py b/scripts/core_common/modules/v8.
index 98008a2..dbf2b9d 100644
--- a/scripts/core_common/modules/v8.py
+++ b/scripts/core_common/modules/v8.py
@@ -71,7 +71,8 @@ def make():
   if ("mac" == base.host_platform()) and (-1 == config.option("config").find("u
     return
 
-  use_v8_89 = False
+#  use_v8_89 = False
+  use_v8_89 = True
   if (-1 != config.option("config").lower().find("v8_version_89")):
     use_v8_89 = True
   if ("windows" == base.host_platform()) and (config.option("vs-version") == "2
```
修改 `./build_tools/scripts/core_common/modules/v8_89.py`：
```
diff --git a/scripts/core_common/modules/v8_89.py b/scripts/core_common/modules/
index 7529882..b089ae4 100644
--- a/scripts/core_common/modules/v8_89.py
+++ b/scripts/core_common/modules/v8_89.py
@@ -13,8 +13,8 @@ def make_args(args, platform, is_64=True, is_debug=False):
     args_copy.append("target_cpu=\\\"x64\\\"") 
     args_copy.append("v8_target_cpu=\\\"x64\\\"")
   else:
-    args_copy.append("target_cpu=\\\"x86\\\"") 
-    args_copy.append("v8_target_cpu=\\\"x86\\\"")
+    args_copy.append("target_cpu=\\\"mips64el\\\"") 
+    args_copy.append("v8_target_cpu=\\\"mips64el\\\"")
 
   if (platform == "linux_arm64"):
     args_copy = args[:]
@@ -28,7 +28,7 @@ def make_args(args, platform, is_64=True, is_debug=False):
     args_copy.append("is_debug=false")
   
   if (platform == "linux"):
-    args_copy.append("is_clang=true")
+    args_copy.append("is_clang=false")
     args_copy.append("use_sysroot=false")
   if (platform == "windows"):
     args_copy.append("is_clang=false")    
@@ -76,7 +76,6 @@ def make():
       os.chdir("../")
     base.cmd("./depot_tools/gclient", ["sync", "-r", "remotes/branch-heads/8.9"
     base.cmd("gclient", ["sync", "--force"], True)
-
   if ("windows" == base.host_platform()):
     base.replaceInFile("v8/build/config/win/BUILD.gn", ":static_crt", ":dynamic
 
@@ -93,7 +92,7 @@ def make():
              "treat_warnings_as_errors=false"]
 
   if config.check_option("platform", "linux_64"):
-    base.cmd2("gn", ["gen", "out.gn/linux_64", make_args(gn_args, "linux")])
+    base.cmd2("gn", ["gen", "out.gn/linux_64", make_args(gn_args, "linux", Fals
     base.cmd("ninja", ["-C", "out.gn/linux_64"])
 
   if config.check_option("platform", "linux_32"):
```
在 `./build_tools/tools/linux/automate.py` 中，在 `qt` 编译前加上断点：
```
diff --git a/tools/linux/automate.py b/tools/linux/automate.py
index 70ed8b3..6db14dc 100755
--- a/tools/linux/automate.py
+++ b/tools/linux/automate.py
@@ -24,7 +24,7 @@ def install_qt():
 
   if not base.is_dir("./qt-everywhere-opensource-src-5.9.9"):
     base.cmd("tar", ["-xf", "./qt_source_5.9.9.tar.xz"])
-
+    sys.exit(0)
   qt_params = ["-opensource",
                "-confirm-license",
                "-release",
```
在 `./build_tools/tools/linux/` 下，运行 `./automate.py` 脚本（下文将不再赘述 automate.py 脚本的路径）:
```
./automate server
```
当脚本在断点退出后，修改 `./build_tools/tools/linux/qt-everywhere-opensource-src-5.9.9/qtdeclarative/src/qml/jsruntime/qv4global_p.h`，修改后删除断点：
```
diff --git a/qv4global_p.h b/qv4global_p.h
@@ -107,7 +107,8 @@ inline double trunc(double d) {return d > 0 ? floor(d) : ceil(d); }
#  if defined(Q_OS_LINUX) || defined(Q_OS_QNX)
#    define V4_ENABLE_JIT
#  endif
-#elif defined(Q_PROCESSOR_MIPS_32) && defined(Q_OS_LINUX)
+//#elif defined(Q_PROCESSOR_MIPS_32) && defined(Q_OS_LINUX)
+#elif defined(Q_PROCESSOR_MIPS_32) && 0
#  define V4_ENABLE_JIT
#endif
```
修改 `./core/Common/3dParty/v8/v8.pri`：
```
diff --git a/Common/3dParty/v8/v8.pri b/Common/3dParty/v8/v8.pri
@@ -4,9 +4,9 @@ v8_version_89 {
CONFIG += use_v8_monolith
    DEFINES += V8_VERSION_89_PLUS
-   core_win_32:CONFIG += build_platform_32
-   core_linux_32:CONFIG += build_platform_32
-   !build_platform_32:DEFINES += V8_COMPRESS_POINTERS
+   core_win_64:CONFIG += build_platform_64
+   core_linux_64:CONFIG += build_platform_64
+   !build_platform_64:DEFINES += V8_COMPRESS_POINTERS

    CORE_V8_PATH_OVERRIDE = $$PWD/../v8_89
}
```
修改 `./core/Common/base.pri`：
```
diff --git a/Common/base.pri b/Common/base.pri
@@ -110,6 +110,11 @@ linux-g++:contains(QMAKE_HOST.arch, aarch64): {
    CONFIG += core_linux_64
    CONFIG += core_linux_host_arm64
}
+linux-g++:contains(QMAKE_HOST.arch, mips64): {
+   message("linux-64")
+   CONFIG += core_linux_64
+   CONFIG += core_linux_host_mips64
+}
 !core_linux64: {
    message("linux-32")
    CONFIG += core_linux_32
@@ -199,6 +204,8 @@ core_windows {
}

core_linux {
+   QMAKE_CFLAGS += -mxgot
+   QMAKE_CXXFLAGS += -mxgot
    equals(TEMPLATE, app) {
        QMAKE_LFLAGS += "-Wl,-rpath,\'\$$ORIGIN\'"
        QMAKE_LFLAGS += "-Wl,-rpath,\'\$$ORIGIN/system\'"
```
在此次工作目录外重新拉取官方的 bulid_tools 源码，在 `build_tools/scripts/core_common/modules/v8_89.py` 中加入断点：
```
@@ -76,7 +76,7 @@ def make():
       os.chdir("../")
     base.cmd("./depot_tools/gclient", ["sync", "-r", "remotes/branch-heads/8.9"
     base.cmd("gclient", ["sync", "--force"], True)
-
+    sys.exit(0)
   if ("windows" == base.host_platform()):
     base.replaceInFile("v8/build/config/win/BUILD.gn", ":static_crt", ":dynamic
```
运行 `automate.py` 脚本至断点处，修改 `./core/Common/3dParty/v8_89/depot_tools/ninja`：
```
diff --git a/ninja b/ninja
@@ -24,6 +24,8 @@ case "$OS" in
    case "$MACHINE" in
      x86_64)
        exec "${THIS_DIR}/ninja-linux64" "$@";;
+     mips64 | mips64el)
+       exec "/usr/bin/ninja" "$@";;
      *)
        echo Unsupported architecture \($MACHINE\) -- unable to run ninja.
        print_help
```
修改 `./core/Common/3dParty/v8_89/v8/src/codegen/mips64/assembler-mips64.h`：
```
diff --git a/assember-mips64.h b/assember-mips64.h
@@ -65,11 +65,16 @@ class Operand {
      : rm_(no_reg), rmode_(rmode) {
    value_.immediate = immediate;
  }
+/*  V8_INLINE explicit Operand(int32_t immediate,
+                            RelocInfo::Mode rmode = RelocInfo::NONE)
+     : rm_(no_reg), rmode_(rmode) {
+   value_.immediate = static_cast<int64_t>(immediate);
+ }*/
  V8_INLINE explicit Operand(const ExternalReference& f)
      : rm_(no_reg), rmode_(RelocInfo::EXTERNAL_REFERENCE) {
    value_.immediate = static_cast<int64_t>(f.address());
  }
- V8_INLINE explicit Operand(const char* s);
+ //V8_INLINE explicit Operand(const char* s);
  explicit Operand(Handle<HeapObject> handle);
  V8_INLINE explicit Operand(Smi value) : rm_(no_reg), rmode_(RelocInfo::NONE) {
    value_.immediate = static_cast<intptr_t>(value.ptr());
```
修改 `./core/Common/3dParty/v8_89/v8/src/objects/managed.h`：
```
diff --git a/managed.h b/managed.h
@@ -93,8 +93,8 @@ class Managed : public Foregin {
static Handle<Managed<CppType>> FromSharedPtr(
      Isolate* isolate, size_t estimated_size,
      std::shared_ptr<CppType> shared_ptr) {
-    reinterpret_cast<v8::Isolate*>(isolate)
-       ->AdjustAmountOfExternalAllocatedMemory(estimated_size);
+    reinterpret_cast<v8::Isolate*>(isolate)
+       ->AdjustAmountOfExternalAllocatedMemory(static_cast<int64_t>(estimated_size));   
    auto destructor = new ManagedPtrDestructor(
        estimated_size, new std::shared_ptr<CppType>{std::move(shared_ptr)},
        Destructor);
```
修改 `./core/Common/3dParty/v8_89/v8/test/cctest/cctest-utils.h`：
```
diff --git a/cctest-utils.h b/cctest-utils.h
@@ -29,7 +29,7 @@ namespace internal {
  __asm__ __volatile__("sw $sp, %0" : "=g"(sp_addr))
#elif V8_HOST_ARCH_MIPS64
#define GET_STACK_POINTER_TO(sp_addr) \
- __asm__ __volatile__("sd $sp, %0" : "=g"(sp_addr))
+ __asm__ __volatile__("sd $sp, %0" : "=m"(sp_addr))
#elif defined(__s390x__) || defined(_ARCH_S390X)
#define GET_STACK_POINTER_TO(sp_addr) \
  __asm__ __volatile__("stg %%r15, %0" : "=m"(sp_addr))
```
修改完成后，删除官方 `build_tools/scripts/core_common/modules/v8_89.py` 中的断点，把官方 `core/Common/3dParty/v8_89` 目录移动到本次移植的目录下.由于 onlyoffice documentserver 官方脚本下载的 depot_tools 中没有 mips 架构的 gn 二进制，所以需要读者下载 gn 源码进行编译安装（gn 源码支持 mips 架构，无需进行适配）。将编译好的 `gn` 放在 `./core/Common/3dParty/v8_89/v8/buildtools/linux64/` 目录下。  
运行 automate.py，正常情况下，由于 pkg 官方提供的 nodejs 不支持 mips 架构，脚本会在执行到 pkg 打包 nodejs 项目时报错：
```
> pkg@5.8.0
> Fetching base Node.js binaries to PKG_CACHE_PATH
  fetched-v14.20.0-linux-mips64el      [                    ] 0%
> Error! 404: Not Found
> Not found in remote cache:
  {"tag":"v3.4","name":"node-v14.20.0-linux-mips64el"}
> Building base binary from source:
  built-v14.20.0-linux-mips64el
> Error! Unknown arch 'mips64el'. Specify x64, x86, armv7, arm64, ppc64, s390x
```
此时需要读者先下载 node 官方的 nodejs [14.20.0版本源码](https://github.com/nodejs/node/tree/v14.20.0)，并下载 [node.v14.20.0.cpp.patch](https://github.com/vercel/pkg-fetch/tree/main/patches), 将该补丁合入到 node14.20.0 的官方代码中，最后执行 `make && make install` 进行编译和安装。将编译的 node 重命名为 `fetched-v14.20.0-linux-mips64el`，拷贝到 `~/.pkg-cache/v3.4/` 路径下。最后在 `/usr/local/lib/node_modules/pkg/node_modules/pkg-fetch/lib-es5/index.js` 中取消 pkg 的校验：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/3.18.png)
### deb 包制作
下载 onlyoffice document-server-package [官方源码](https://github.com/ONLYOFFICE/document-server-package)，使用 git 切换版本至 `v7.1.1.76`：
```
git clone -b v7.1.1.76 https://github.com/ONLYOFFICE/document-server-package.git
```
修改 `./document-server-package/Makefile`:
```
diff --git a/Makefile b/Makefile
@@ -29,6 +29,11 @@ ifeq ($(UNAME_M),x86_64)
        DEB_ARCH := amd64
        TAR_ARCH := x86_64
 endif
+ifeq ($(UNAME_M),mips64)
+       RPM_ARCH := mips64el
+       DEB_ARCH := mips64el
+       TAR_ARCH := mips64el
+endif
 ifneq ($(filter aarch%,$(UNAME_M)),)
        RPM_ARCH := aarch64
        DEB_ARCH := arm64
@@ -158,6 +163,9 @@ else
        ifeq ($(UNAME_M),x86_64)
                ARCHITECTURE := 64
        endif
+       ifeq ($(UNAME_M),mips64)
+               ARCHITECTURE := 64
+       endif
        ifneq ($(filter %86,$(UNAME_M)),)
                ARCHITECTURE := 32
        endif
```
在 `./document-server-package/` 下执行 `make deb` 命令：
```
cd ./document-server-package && make deb
```
生成的 deb 包在 `./document-server-package/deb/` 路径下：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/3.20.png)
### Docker 镜像制作
下载 [onlyoffice docker-documentserver](https://github.com/ONLYOFFICE/Docker-DocumentServer) 官方源码，使用 git 切换版本至 `v7.1.1.76`：
```
git clone -b v7.1.1.76 https://github.com/ONLYOFFICE/Docker-DocumentServer.git
```
新建目录 `deb`，在 `deb` 目录下[下载](http://httpredir.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.8_all.deb) `ttf-mscorefonts-installer_3.8_all.deb` 并将 `onlyoffice-documentserver_0.0.0-0_mips64el.deb` 拷贝到该目录下：
```
cd ./Docker-DocumentServer && \
mkdir deb && \
cd deb && \
wget http://httpredir.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.8_all.deb &&\
cp ./document-server-package/deb/onlyoffice-documentserver_0.0.0-0_mips64el.deb .
```
Docker-DocumentServer 完整的目录结构如下：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/3.21.png)

修改 Dockerfile，制作 `cr.loongnix.cn/mips/onlyoffice-documentserver:7.1.1.76`：
```
cd ./Docker-DocumentServer && docker build -t cr.loongnix.cn/mips/onlyoffice-documentserver:7.1.1.76 .
```
## 功能测试
测试时使用官方提供的 `example`，本文仅针对关键功能进行测试：容器能否正常启动、是否存在素材丢失，相关文件的新建、修改、保存以及文件的上传、下载功能是否正常。
### 启动镜像
参照官方文档，执行命令：
```
docker run -i -t -d -p 8086:80 cr.loongnix.cn/mips/onlyoffice-documentserver:7.1.1.76
```
在浏览器中输入本机 `ip:映射的端口号` 进入 `welcome` 页面：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/4.1.png)

在终端输入：
```
sudo docker exec f46a8772db8c sudo supervisorctl start ds:example
sudo docker exec f46a8772db8c sudo sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf
```
点击 `GO TO TEST EXAMPLE` 按钮组件，进入官方提供的 `example`。
### 素材检查
对比同版本官方提供的 x86 架构 onlyoffice documentserver 镜像中的素材，本文构建的镜像包含的素材与其一致。
### 新建文件
新建 `new.docx` 文件，修改后保存，再次打开，文件内容正常显示：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/4.2.png)

新建 `new.xlsx` 文件，修改后保存，再次打开，文件内容正常显示：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/4.3.png)

新建 `new.pptx` 文件，修改后保存，再次打开，文件内容正常显示：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/4.4.png)

新建 `new.docxf` 文件，修改后保存，再次打开，文件内容正常显示：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/4.5.png)
### 传输文件
上传 `test.docx` 文件：

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/4.6.png)

下载 'new.docx' 文件： 

![](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/images/onlyoffice/4.7.png)
## 特殊问题归纳
如果读者按照本文的步骤和方法进行适配，容器应该能够正常启动。如果读者在适配过程中出现了其他问题，希望以下内容能够帮助到读者：

问题1：容器图片素材缺失  
解决方法：重新运行 `build_js.make()` 以及之后的脚本。

问题2：容器中 `themes.js` 缺失  
解决方法：与问题1一致。

问题3：文档无法保存  
解决方法：重新验证 onlyoffice documentserver 各个组件的版本，确保组件的版本一致且 build_tools 的版本支持 onlyoffice documentserver 源码（可通过查看 build_tools 下的 version 文件）。

问题4：在 `build.make()` 过程中提示缺少库文件，如：`/usr/bin/ld: cannot find -lVbaFormatLib`  
解决方法：与问题3一致。

问题5：pkg 打包 node 校验失败  
解决方法：在 `/usr/local/lib/node_modules/pkg/node_modules/pkg-fetch/lib-es5/index.js` 中取消 pkg 的校验。
