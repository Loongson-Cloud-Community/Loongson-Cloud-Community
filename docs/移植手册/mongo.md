# mongo

## 移植环境
cpu：3a6000  
操作系统：debian

## 移植步骤
官方构建文档请点击[这里](https://github.com/mongodb/mongo/blob/r4.4.29/docs/building.md)
### 源码下载
安装git
```
apt-get update && apt-get install -y git
```
下载源码
```
git clone -b r4.4.29 --depth 1 https://github.com/mongodb/mongo.git
```
*注：如果下载失败或下载速度过慢，建议使用代理*

### 依赖下载
```
apt-get update && apt-get install -y gcc libcurl4-openssl-dev python3 python3-pip python3-dev libssl-dev libffi-dev cmake wget curl

cd mongo

python3 -m pip install -r etc/pip/compile-requirements.txt

#遇到无法安装cryptography的问题，请手动安装cryptography==36.0.2版本，然后重新执行上述命令
pip3 install cryptography-36.0.2/cryptography-36.0.2-cp311-cp311-linux_loongarch64.whl

pip3 install setuptools
```
### 架构补丁
本章仅给出需要移植哪些文件，详细的内容修改请查看[补丁](https://github.com/Loongson-Cloud-Community/mongo/commit/118efa61af436bdf37d12cabe7b7b189e8c8bf0a)
#### gpertools-2.7
需要修改的文件如下：
```
src/third_party/gperftools-2.7/dist/m4/pc_from_ucontext.m4
src/third_party/gperftools-2.7/dist/src/base/basictypes.h
src/third_party/gperftools-2.7/dist/src/base/linux_syscall_support.h
src/third_party/gperftools-2.7/dist/src/base/linuxthreads.h
src/third_party/gperftools-2.7/dist/src/malloc_hook_mmap_linux.h
src/third_party/gperftools-2.7/dist/src/stacktrace.cc
src/third_party/gperftools-2.7/dist/src/tcmalloc.cc
src/third_party/gperftools-2.7/dist/config.guess
src/third_party/gperftools-2.7/dist/config.sub
```

需要创建目录：`src/third_party/gperftools-2.7/platform/linux_loongarch64`
生成目录的方式：执行`./src/third_party/gperftools-2.7/scripts/host_config.sh`

#### mozjs-60
需要修改/添加的文件如下：
```
src/third_party/mozjs-60/extract/js/src/jit/AtomicOperations.h
src/third_party/mozjs-60/extract/js/src/jit/none/AtomicOperations-feeling-lucky.h
src/third_party/mozjs-60/gen-config.sh
src/third_party/mozjs-60/include/double-conversion/utils.h
src/third_party/mozjs-60/0001-mozilla-add-loongarch-support.patch
src/third_party/mozjs-60/get-sources.sh
```

需要创建目录：`src/third_party/mozjs-60/platform/loongarch64`
生成目录的方式：在`src/third_party/mozjs-60/`目录下执行`./get-sources.sh`,下载mozilla-release代码
mozilla-release需要修改的文件如下：
```
build/autoconf/config.guess
build/autoconf/config.sub
build/moz.configure/init.configure
modules/freetype2/builds/unix/config.guess
modules/freetype2/builds/unix/config.sub
nsprpub/build/autoconf/config.guess
nsprpub/build/autoconf/config.sub
python/mozbuild/mozbuild/configure/constants.py
toolkit/crashreporter/google-breakpad/autotools/config.guess
toolkit/crashreporter/google-breakpad/autotools/config.sub
```
修改后在`src/third_party/mozjs-60/`目录下执行`./gen-config.sh`生成上述目录
*注：由于mozilla-release代码依赖python2，所以生成目录这部分是在abi1.0 debian10镜像中执行的*

#### wiredtiger
需要修改的文件如下：
```
src/third_party/wiredtiger/SConscript
src/third_party/wiredtiger/build_posix/configure.ac.in
src/third_party/wiredtiger/cmake/configs/base.cmake
src/third_party/wiredtiger/cmake/helpers.cmake
src/third_party/wiredtiger/dist/filelist
src/third_party/wiredtiger/dist/prototypes.py
src/third_party/wiredtiger/src/docs/arch-fs-os.dox
src/third_party/wiredtiger/src/docs/spell.ok
src/third_party/wiredtiger/src/include/gcc.h
```
需要创建的目录如下：
```
src/third_party/wiredtiger/src/checksum/loongarch64
```
创建该目录后，在该目录下创建`crc32-loongarch64.c`文件，具体请参考补丁内容

#### mongo
需要修改的文件如下：
```
SConstruct
src/mongo/platform/pause.h
src/mongo/db/exec/plan_stats.h
```
### 编译
```
 python3 buildscripts/scons.py install-core --disable-warnings-as-errors
```
