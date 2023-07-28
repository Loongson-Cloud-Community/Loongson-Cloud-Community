# protobuf

## 1. 构建版本
```
2.5.0
```

## 2. 构建环境
```
[root@5cef9fb1156f protobuf-2.5.0]# cat /etc/os-release 
NAME="Loongnix-Server Linux"
VERSION="8"
ID="loongnix-server"
ID_LIKE="rhel fedora centos"
VERSION_ID="8"
PLATFORM_ID="platform:lns8"
PRETTY_NAME="Loongnix-Server Linux 8"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:loongnix-server:loongnix-server:8"
HOME_URL="http://www.loongnix.cn/"
BUG_REPORT_URL="http://bugs.loongnix.cn/"
CENTOS_MANTISBT_PROJECT="Loongnix-server-8"
CENTOS_MANTISBT_PROJECT_VERSION="8"
[root@5cef9fb1156f protobuf-2.5.0]# uname -a
Linux 5cef9fb1156f 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 3.源码适配
具体查看：https://github.com/Loongson-Cloud-Community/protobuf/tree/loong64-v2.5.0   的git log信息

## 4. 构建
编译有两种方式静态编译和动态编译，源码默认的编译方式动态编译
```
./autogen.sh  
./configure （静态编译：./configure --enable-shared=no）
make （全部静态编译 make LDFLAGS=-all-static）
```
```
make check 
```
若make check失败，仍然可以安装，但是库的某些功能可能无法正常工作。
安装：
```
sudo make install
sudo ldconfig //刷新共享库的缓存
```
默认情况下，该软件包将安装到/usr/local。但是，在一些平台上，/usr/local/lib都不是LD_LIBRARY_PATH的一部分。此时可使用以下两种方式解决：
```
a.export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
b../configure --prefix=/usr  //使用该命令将protobuf安装到/usr路径下
```
备注：更详细的内容可参考官方文档：https://github.com/protocolbuffers/protobuf/blob/master/src/README.md。

## 5. 常见问题
protoc执行报错：
```
./protoc: error while loading shared libraries: libprotobuf.so.18:
cannot open shared object file: No such file or directory
```
这是由于使用官方源码默认生成的二进制是动态的。
解决：使用时需要将src/.libs中的lib开头的库文件复制到本地的/lib目录下,此时protoc二进制便可以运行。
或者设置export LD_LIBRARY_PATH=xxx/protobuf/src/.libs:$LD_LIBRARY_PATH
