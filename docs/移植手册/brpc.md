# brpc

## 1.构建环境信息

|命令                      |结果                        |
|-------------------------|---------------------------|
|uname -m                 |loongarch64                |
|cat /etc/os-release      |22.03 LTS                  |

## 2.项目信息

|名称       |描述|
|--         |--|
|名称       |brpc|
|版本       |1.6.0|
|项目地址   |[https://github.com/apache/brpc](https://github.com/apache/brpc)|
|官方指导   |https://github.com/apache/brpc/blob/master/docs/cn/getting_started.md|

## 3.源码移植
具体查看https://github.com/Loongson-Cloud-Community/brpc/tree/loongarch64-1.6.0-abi2.0的 git log信息：    
commit 8e706a34289c2e032612a5363d9359ebc4e8433a及其之后为loongarch64移植的相关代码

## 4.构建命令
### 4.1 软件包依赖安装
```
$ yum install -y loongnix-release-ceph-nautilus.noarch && yum makecache 
$ yum install -y leveldb-devel gflags gflags-devel protobuf-devel protobuf gperftools gperftools-devel gtest gtest-devel gcc-c++ gflags gflags-devel leveldb-devel gtest gtest-devel openssl-devel
```

### 4.2 源码编译
在brpc源码路径下执行以下命令：
```
$ sh config_brpc.sh --headers="/usr/include" --libs="/usr/lib64 /usr/bin"
$ make
```
在构建完成后会生成output目录，其中包含了三个目录，具体如下：
```
$ cd output
$ ls
bin  include  lib
$ ls lib
libbrpc.a  libbrpc.so
$ ls include/
brpc  bthread  butil  bvar  idl_options.pb.h  idl_options.proto  json2pb  mcpack2pb
$ ls bin/
protoc-gen-mcpack
```

### 4.3 运行测试
```
$ cd test
$ make
$ sh run_tests.sh
```
在执行完make以后会在test目录下生成各个测试文件.cpp的二进制文件，若要单独执行某个测试，则直接执行对应的二进制文件即可，如：
```
$ ./bthread_fd_unittest
```


