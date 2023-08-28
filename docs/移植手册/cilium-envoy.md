# cilium-envoy

## 项目信息

|名称       |描述|
|--         |--|
|名称       |proxy|
|版本       |cilium-1.11.0|
|项目地址   |[https://github.com/cilium/proxy](https://github.com/cilium/proxy/tree/9b1701da9cc035a1696f3e492ee2526101262e56)|


## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |debian 10 容器|

## 移植说明
cilium-envoy所在的项目`cilium/proxy`并没有`tag`,本文通过`commit`来区分版本，本次移植的版本为`9b1701da9cc035a1696f3e492ee2526101262e56`；  
另外，如果您在移植时遇到类似
```
link: warning: package "github.com/golang/protobuf/ptypes/any" is provided by more than one rule:
    @com_github_golang_protobuf//ptypes/any:go_default_library
    @io_bazel_rules_go//proto/wkt:any_go_proto
...
...
This will be an error in the future.
external/go_sdk/pkg/tool/linux_loong64/link: fingerprint mismatch: github.com/golang/protobuf/ptypes/duration has 529553fed0b6f344, import from github.com/envoyproxy/protoc-gen-validate/validate expecting df483964545e7b77
link: error running subcommand: exit status 2
```
的问题，说明您移植的版本中，envoy依赖的golang低于1.15版本，目前还没有找到该问题的解决方法，建议您升版本；  
最后，本次移植在proxy项目中没有做修改，所有的修改都是在bazel的cache目录中．

## 移植步骤

__编译环境和依赖__  

```
#  建议在docker容器中构建
docker run -it --name cilium-envoy cr.loongnix.cn/library/debian:buster /bin/bash

#  安装编译工具
apt-get update && apt-get install \
   libtool \
   cmake \
   automake \
   autoconf \
   make \
   ninja-build \
   curl \
   unzip \
   g++ \
   git \
   virtualenv

#  安装JDK
cd /usr/local
curl -OL http://ftp.loongnix.cn/Java/openjdk11/loongson11.4.0-fx-jdk11.0.18_10-linux-loongarch64.tar.gz
tar -zxf loongson11.4.0-fx-jdk11.0.18_10-linux-loongarch64.tar.gz
export JAVA_HOME=/usr/local/jdk-11.0.18
export PATH=$JAVA_HOME/bin:$PATH

#  安装golang
curl -OL http://ftp.loongnix.cn/toolchain/golang/go-1.19/go1.19.linux-loong64.tar.gz
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH

#  安装bazel
curl -o /usr/local/bin/bazel -L https://github.com/Loongson-Cloud-Community/bazel/releases/download/3.7.2/bazel_nojdk-3.7.2-linux-loongarch64
chmod +x /usr/local/bin/bazel
```

__下载源码__  

```
git clone https://github.com/cilium/proxy.git
cd proxy
git checkout 9b1701da9c
```

__移植__  
移植时需要修改bazel的cache目录，所以先执行编译命令，让bazel生成cache目录并下载依赖文件．  
```
#  在proxy目录下编译
make cilium-envoy
```
等到报错后，进入`/root/.cache/bazel/_bazel_root/bcca255f98078ff781f83f621a84105c/external`
目录开始移植．如果移植过程中未找到下述哪个文件，可以执行一次编译命令，可能是bazel还未执行到下载该文件
就已经出现错误．
```
#  在 platforms/cpu/BUILD 文件中添加cpu信息
constraint_value(
    name = "loongarch64",
    constraint_setting = ":cpu",
)

#  修改 io_bazel_rules_go/go/private/platforms.bzl
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

#  修改 io_bazel_rules_go/go/private/sdk.bzl
res = ctx.execute(["uname", "-m"])
        if res.return_code == 0:
            uname = res.stdout.strip()
            if uname == "aarch64":
                goarch = "arm64"
            elif uname == "armv6l":
                goarch = "arm"
            elif uname == "armv7l":
                goarch = "arm"
            elif uname == "ppc64le":
                goarch = "ppc64le"
            elif uname == "loongarch64":
                goarch = "loong64"

#  修改 envoy/bazel/dependency_imports.bzl
def envoy_dependency_imports(go_version = GO_VERSION):
    rules_foreign_cc_dependencies()
    go_rules_dependencies()
    go_register_toolchains(go_version="host")
    rbe_toolchains_config()
    gazelle_dependencies()
    apple_rules_dependencies()

#  修改 envoy/bazel/repository_locations.bzl
    bazel_gazelle = dict(
        project_name = "Gazelle",
        project_desc = "Bazel BUILD file generator for Go projects",
        project_url = "https://github.com/bazelbuild/bazel-gazelle",
        version = "0.24.0",
        sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
        urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/v{version}/bazel-gazelle-v{version}.tar.gz"],
        release_date = "2021-10-11",
        use_category = ["build"],

...

    com_github_gperftools_gperftools = dict(
        project_name = "gperftools",
        project_desc = "tcmalloc and profiling libraries",
        project_url = "https://github.com/gperftools/gperftools",
        version = "2.10",
        sha256 = "83e3bfdd28b8bcf53222c3798d4d395d52dadbbae59e8730c4a6d31a9c3732d8",
        strip_prefix = "gperftools-{version}",
        urls = ["https://github.com/gperftools/gperftools/releases/download/gperftools-{version}/gperftools-{version}.tar.gz"],
        release_date = "2022-05-31",
        use_category = ["dataplane_core", "controlplane"],
        cpe = "cpe:2.3:a:gperftools_project:gperftools:*",
    ),

...

    com_github_luajit_luajit = dict(
        project_name = "LuaJIT",
        project_desc = "Just-In-Time compiler for Lua",
        project_url = "https://luajit.org",
        # The last release version, 2.1.0-beta3 has a number of CVEs filed
        # against it. These may not impact correct non-malicious Lua code, but for prudence we bump.
        version = "83b6dffcf4ffea376298f3fac3452841eabd0606",
        sha256 = "a5d211370a1112615a0bb20613ad97e7bcd32902b413a6a53bf23382c3061102",
        strip_prefix = "LuaJIT-{version}",
        urls = ["https://github.com/loongson/LuaJIT/archive/{version}.tar.gz"],
        release_date = "2020-10-12",
        use_category = ["dataplane_ext"],
        extensions = ["envoy.filters.http.lua"],
        cpe = "cpe:2.3:a:luajit:luajit:*",
    ),

#  修改 envoy/bazel/envoy_internal.bzl
def envoy_copts(repository, test = False):
    posix_options = [
        "-Wall",
        "-Wextra",
#        "-Werror",
        "-Wnon-virtual-dtor",
        "-Woverloaded-virtual",
        "-Wold-style-cast",
        "-Wformat",
        "-Wformat-security",
        "-Wvla",
        "-Wno-deprecated-declarations",
        "-Wreturn-type",
    ]

#  修改　envoy/bazel/BUILD
config_setting(
    name = "linux_s390x",
    values = {"cpu": "s390x"},
)

config_setting(
    name = "linux_loongarch64",
    values = {"cpu": "loongarch64"},
)

...

selects.config_setting_group(
    name = "linux",
    match_any = [
        ":linux_aarch64",
        ":linux_mips64",
        ":linux_ppc",
        ":linux_s390x",
        ":linux_x86_64",
        ":linux_loongarch64",
    ],
)

#  修改 boringssl/src/include/openssl/base.h
#elif defined(__MIPSEL__) && defined(__LP64__)
#define OPENSSL_64_BIT
#define OPENSSL_MIPS64
#elif defined(__loongarch64)
#define OPENSSL_64_BIT
#define OPENSSL_LOONGARCH64
#elif defined(__pnacl__)
#define OPENSSL_32_BIT
#define OPENSSL_PNACL

#  修改 boringssl/src/CMakeLists.txt
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "loongarch64")
  set(ARCH "generic")

#  修改 boringssl/src/util/generate_build_files.py
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "loongarch64")
  set(ARCH "generic")

#  修改 com_googlesource_googleurl/build/build_config.h
#elif defined(__aarch64__) || defined(_M_ARM64)
#define ARCH_CPU_ARM_FAMILY 1
#define ARCH_CPU_ARM64 1
#define ARCH_CPU_64_BITS 1
#define ARCH_CPU_LITTLE_ENDIAN 1
#elif defined(__loongarch64)
#define ARCH_CPU_LOONG_FAMILY 1
#define ARCH_CPU_LOONG64 1
#define ARCH_CPU_64_BITS 1
#define ARCH_CPU_LITTLE_ENDIAN 1

```
至于升级gazelle到0.24.0的原因是之前的gazelle版本在使用golang 1.16+版本时会出现以下问题，导致go.mod中的依赖无法正常下载．
```
DEBUG: /tmp/tmp.g1skLo1cY4/external/bazel_gazelle/internal/go_repository.bzl:189:18: com_github_lyft_protoc_gen_star: gazelle: finding module path for import github.com/stretchr/testify/assert: exit status 1: go: malformed module path "gazelle_remote_cache__\\n": invalid char '\\'
gazelle: finding module path for import github.com/stretchr/testify/require: exit status 1: go: malformed module path "gazelle_remote_cache__\\n": invalid char '\\'
```
解决方法来自官方的Pr：[#20394](https://github.com/envoyproxy/envoy/pull/20394)

__编译__  
上文已经提到了，在确保网络通畅的情况下执行：
```
make cilium-envoy
```
之后就是等待，建议使用16/32核的机器进行编译，否则等待的时间较长．
