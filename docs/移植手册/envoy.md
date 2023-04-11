# envoy

由于 envoy 的构建依赖 bazel，目前 bazel for loongarch64 稳定版本为 3.1.0。根据 envoy 官方依赖关系，选择 envoy 1.15.0  作为目标版本进行移植。

官方构建手册

[https://github.com/envoyproxy/envoy/blob/v1.15.0/bazel/README.md](https://github.com/envoyproxy/envoy/blob/v1.15.0/bazel/README.md "https://github.com/envoyproxy/envoy/blob/v1.15.0/bazel/README.md")

## 环境准备

```bash
# 在 debian:buster 中构建
docker run -it cr.loongnix.cn/library/debian:buster bash

# 安装编译工具
apt-get install \
   libtool \
   cmake \
   automake \
   autoconf \
   make \
   ninja-build \
   curl \
   unzip \
   g++ \
   virtualenv
 
# 因为系统差异，额外创建一个 python 软链接
ln -sf /usr/bin/python3 /usr/bin/python3

# 下载并安装 jdk for loongarch64
curl -OL http://ftp.loongnix.cn/Java/openjdk11/loongson11.4.0-fx-jdk11.0.18_10-linux-loongarch64.tar.gz
export JAVA_HOME=/usr/local/jdk
export PATH=$JAVA_HOME/bin:$PATH

# 下载并安装 golang for loongarch64
curl -OL http://ftp.loongnix.cn/toolchain/golang/go-1.19/go1.19.linux-loong64.tar.gz
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH

# 下载并安装 bazel for loongarch64
curl -o /usr/bin/bazel -L https://github.com/Loongson-Cloud-Community/bazel/releases/download/3.1.0/bazel-3.1.0-linux-loongarch64
chmod +x /usr/bin/bazel

```

## 源码移植

-   下载源码并获取依赖关系

```bash
# 下载源码
git clone -b v1.15.0 --depth=1 https://github.com/envoyproxy/envoy.git

# 解析并获取依赖项
root@1c0331621040:~/envoy# bazel fetch //source/exe:envoy-static
INFO: All external dependencies fetched successfully.
Loading: 661 packages loaded

```

-   修改 bazel cache platforms（bazel cache 位于 \~/.cache/bazel）

```bash
# platforms/cpu/BUILD
constraint_value(
    name = "loongarch64",
    constraint_setting = ":cpu",
)
```

-   修改 bazel cache io\_bazel\_rules\_go

```bash
# go/private/platforms.bzl
BAZEL_GOARCH_CONSTRAINTS = {
    "386": "@platforms//cpu:x86_32",
    "amd64": "@platforms//cpu:x86_64",
    "arm": "@platforms//cpu:arm",
    "arm64": "@platforms//cpu:aarch64",
    "ppc64le": "@platforms//cpu:ppc",
    "s390x": "@platforms//cpu:s390x",
    "loong64": "@platforms//cpu:loongarch64",
}


GOOS_GOARCH = (
    ...
    ("linux", "386"),
    ("linux", "amd64"),
    ("linux", "arm"),
    ("linux", "arm64"),
    ("linux", "mips"),
    ("linux", "mips64"),
    ("linux", "mips64le"),
    ("linux", "mipsle"),
    ("linux", "ppc64"),
    ("linux", "ppc64le"),
    ("linux", "riscv64"),
    ("linux", "loong64"),
    ...
)

# go/private/sdk.bzl
def _detect_host_platform(ctx):
...
        # uname -p is not working on Aarch64 boards
        # or for ppc64le on some distros
        res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "aarch64":
                host = "linux_arm64"
            elif uname == "armv6l":
                host = "linux_arm"
            elif uname == "armv7l":
                host = "linux_arm"
            elif uname == "ppc64le":
                host = "linux_ppc64le"
            elif uname == "loongarch64":
                host = "linux_loong64"
...
```

-   修改 bazel cache boringsll

这个修改参照 mips 进行，使用通用加解密算法

```bash
# src/include/openssl/base.h
#elif defined(__loongarch64) 
#define OPENSSL_64_BIT
#define OPENSSL_LOONGARCH64

# src/CMakeLists.txt
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "loongarch64")
  set(ARCH "generic")

# src/util/generate_build_files.py
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "loongarch64")
  set(ARCH "generic")

```

-   修改源码，使用本地golang

```bash
diff --git a/bazel/dependency_imports.bzl b/bazel/dependency_imports.bzl
index 1bcc3a8..66b23d0 100644
--- a/bazel/dependency_imports.bzl
+++ b/bazel/dependency_imports.bzl
@@ -13,7 +13,7 @@ GO_VERSION = "1.14.4"
 def envoy_dependency_imports(go_version = GO_VERSION):
     rules_foreign_cc_dependencies()
     go_rules_dependencies()
-    go_register_toolchains(go_version)
+    go_register_toolchains(go_version="host")
     rbe_toolchains_config()
     gazelle_dependencies()
     apple_rules_dependencies()
```

-   修改源码，调整 luajit 和 gperftools 下载位置，以增加 loongarch64 支持

```bash
diff --git a/bazel/repository_locations.bzl b/bazel/repository_locations.bzl
index b2501ec..a4ea4cc 100644
--- a/bazel/repository_locations.bzl
+++ b/bazel/repository_locations.bzl
@@ -171,9 +171,9 @@ DEPENDENCY_REPOSITORIES = dict(
         # TODO(cmluciano): Bump to release 2.8
         # The currently used version is specifically chosen to fix ppc64le builds that require inclusion
         # of asm/ptrace.h, and also s390x builds that require special handling of mmap syscall.
-        sha256 = "97f0bc2b389c29305f5d1d8cc4d95e9212c33b55827ae65476fc761d78e3ec5d",
-        strip_prefix = "gperftools-gperftools-2.7.90",
-        urls = ["https://github.com/gperftools/gperftools/archive/gperftools-2.7.90.tar.gz"],
+        sha256 = "b0dcfe3aca1a8355955f4b415ede43530e3bb91953b6ffdd75c45891070fe0f1",
+        strip_prefix = "gperftools-gperftools-2.10",
+        urls = ["https://github.com/gperftools/gperftools/archive/gperftools-2.10.tar.gz"],
         use_category = ["test"],
     ),
     com_github_grpc_grpc = dict(
@@ -187,9 +187,9 @@ DEPENDENCY_REPOSITORIES = dict(
         cpe = "cpe:2.3:a:grpc:grpc:*",
     ),
     com_github_luajit_luajit = dict(
-        sha256 = "409f7fe570d3c16558e594421c47bdd130238323c9d6fd6c83dedd2aaeb082a8",
-        strip_prefix = "LuaJIT-2.1.0-beta3",
-        urls = ["https://github.com/LuaJIT/LuaJIT/archive/v2.1.0-beta3.tar.gz"],
+        sha256 = "a5d211370a1112615a0bb20613ad97e7bcd32902b413a6a53bf23382c3061102",
+        strip_prefix = "LuaJIT-83b6dffcf4ffea376298f3fac3452841eabd0606",
+        urls = ["https://github.com/loongson/LuaJIT/archive/83b6dffcf4ffea376298f3fac3452841eabd0606.tar.gz"],
         use_category = ["dataplane"],
         cpe = "N/A",
     ),
```

-   修改源码，修改 luajit patch 以适应版本差异

```bash
diff --git a/bazel/foreign_cc/luajit.patch b/bazel/foreign_cc/luajit.patch
index 296d66c..94cc66b 100644
--- a/bazel/foreign_cc/luajit.patch
+++ b/bazel/foreign_cc/luajit.patch
@@ -33,15 +33,6 @@ index f56465d..5d91fa7 100644
  #
  # Disable the JIT compiler, i.e. turn LuaJIT into a pure interpreter.
  #XCFLAGS+= -DLUAJIT_DISABLE_JIT
-@@ -111,7 +111,7 @@ XCFLAGS=
- #XCFLAGS+= -DLUAJIT_NUMMODE=2
- #
- # Enable GC64 mode for x64.
--#XCFLAGS+= -DLUAJIT_ENABLE_GC64
-+XCFLAGS+= -DLUAJIT_ENABLE_GC64
- #
- ##############################################################################
-

```

-   修改源码，关闭 Werror 编译选项以跳过编译警告

```bash
diff --git a/bazel/envoy_internal.bzl b/bazel/envoy_internal.bzl
index 6c9d125..8be256a 100644
--- a/bazel/envoy_internal.bzl
+++ b/bazel/envoy_internal.bzl
@@ -7,7 +7,6 @@ def envoy_copts(repository, test = False):
     posix_options = [
         "-Wall",
         "-Wextra",
-        "-Werror",
         "-Wnon-virtual-dtor",
         "-Woverloaded-virtual",
         "-Wold-style-cast",
```



## 编译

```bash
bazel build -c opt //source/exe:envoy-static

```
