# grpc

<!-- note -->

???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决

<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |grpc|
|版本       |1.30.0|
|项目地址   |[https://github.com/grpc/grpc](https://github.com/grpc/grpc)|
|官方指导   |[https://github.com/grpc/grpc/blob/v1.30.0/BUILDING.md](https://github.com/grpc/grpc/blob/v1.30.0/BUILDING.md)|


## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |anilos 8.8 容器|


## 移植说明

* grpc 高版本架构无关，无需移植便可以在 LoongArch64 平台上编译运行
* grpc 低版本本身架构无关，但是引入了第三方架构相关的依赖 boringssl，abseil-cpp 
导致在 LoongArch64 平台上无法顺利编译需要移植
* grpc 对于第三方依赖有两种编译模式，一种是依赖操作系统预安装的软件包
另一种是从源码编译,因为低版本的 grpc 对系统包要求版本较低，和当前龙芯
操作系统不兼容，所以在龙芯平台上编译 grpc 对于第三方库选择从源码编译

## 移植步骤

__编译环境和依赖__

``` shell
docker run -it --rm cr.loongnix.cn/openanolis/anolis:8.8 
yum install -y vim git cmake gcc gcc-c++ openssl-devel
```

__下载源码__

``` shell
git clone -b v1.30.0 --depth=1 https://github.com/grpc/grpc.git
cd grpc
git submodule update --init
```
__移植__

grpc 本身无需移植，但需要对 `third_part` 下的第三方依赖进行移植。

* `abseil-cpp` - 参考 [https://github.com/abseil/abseil-cpp/pull/1110/files](https://github.com/abseil/abseil-cpp/pull/1110/files)
* `boringssl-with-bazel` - 参考 [https://github.com/Loongson-Cloud-Community/boringssl/commit/97c4cc76c8f63af242023484fec27615e3691aec](https://github.com/Loongson-Cloud-Community/boringssl/commit/97c4cc76c8f63af242023484fec27615e3691aec)

其中 boringssl-with-bazel 是 boringssl 的一个特殊分支，boringssl-with-bazel
在 boringssl 源码的基础上封装了一层 bazel 构建，将 boringssl 源码
置于 `src` 目录下，所以进行代码移植时注意目录关系。特别的，还需要对根目录下
`CMakeList.txt` 进行移植。

__编译__

``` shell
mkdir build
pushd build
cmake -DgRPC_INSTALL=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON ..
make -j`nproc`
make install
popd
```

grpc 及相关依赖将被安装到 `/usr/lib` 或 `/usr/lib64` 目录下。

__测试__

选择 `examples/cpp/helloworld` 进行测试，在测试之前需要保证系统配置正确。

``` shell
$ echo $PKG_CONFIG_PATH
/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig

$ cat /etc/ld.so.conf
...
/usr/local/lib/
/usr/local/lib64/
```


``` shell
pushd test/cpp/helloworld
make

# terminal 1
$ ./greeter_server
Server listening on 0.0.0.0:50051

# terminal 2
$ ./greeter_client 
Greeter received: Hello world
```
