# bazel

## 项目信息

|名称       |描述|
|--         |--|
|名称       |bazel|
|版本       |3.7.2|
|项目地址   |[https://github.com/bazelbuild/bazel](https://github.com/bazelbuild/bazel)|
|官方指导   |[Compiling Bazel from source](https://docs.bazel.build/versions/3.7.0/install-compile-source.html)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |debian 10 容器|

## 移植说明
bazel的构建方式有两种：
1. 通过已有的bazel构建
2. 从零开始  
下文的移植步骤针对当前没有bazel二进制，从零开始构建bazel二进制

## 移植步骤

__编译环境和依赖__  
1. Bash
2. zip,unzip
3. C++ 工具链 
4. JDK8 或 JDK11
5. Python2 或 Python3
```
sudo apt-get install build-essential openjdk-11-jdk python3 zip unzip
```

__下载源码__  
从bazelbuild/build仓库的release中下载未移植的源码包：[bazel-3.7.2-dist.zip](https://github.com/bazelbuild/bazel/releases/download/3.7.2/bazel-3.7.2-dist.zip)
从Loongson-Cloud-Community/bazel仓库的release中下载已经移植过的源码包：[bazel-3.7.2-dist.zip](https://github.com/Loongson-Cloud-Community/bazel/releases/download/3.7.2/bazel-3.7.2-dist.zip)
如果您下载了已经移植过的源码包，您可以跳过下文的`移植`章节

__移植__  
关于移植过程中需要修改的文件以及如何修改可以参考[217ac55](https://github.com/Loongson-Cloud-Community/bazel/commit/217ac5503e5f57b770f30b8a335e46785d3d720f)以及[8617b8c](https://github.com/Loongson-Cloud-Community/bazel/commit/8617b8cdff6510850ea4d24621bbeec1204236bf)这两次提交
另外，您需要在`platforms/cpu/BUILD`文件末尾添加以下内容：
```
constraint_value(
    name = "loongarch64",
    constraint_setting = ":cpu",
)

```

__编译__  
在确保网络通畅的情况下执行：
```
env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
```
编译结束后的二进制存放在`output`目录下，编译的bazel不包含JDK
