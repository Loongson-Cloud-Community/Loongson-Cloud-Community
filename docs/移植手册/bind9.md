## 构建环境信息

|命令                      |结果                        |
|-------------------------|---------------------------|
|uname -m                 |loongarch64                |
|cat /etc/os-release      |Anolis OS 8.8              |

## 项目以及依赖项信息

|名称                     |地址                                                        |版本                 |
|-------------------------|-----------------------------------------------------------|--------------------|
|bind9                    |https://github.com/Loongson-Cloud-Community/bind9.git      |loong64-v9.9.4      |
|openssl                  |https://github.com/Loongson-Cloud-Community/openssl.git    |OpenSSL_1_0_2-stable|

## 构建openssl

> 这里一定要使用`OpenSSL_1_0_2-stable`版本

```shell
mkdir -p /usr/local/openssl
./config --prefix=/usr/local/openssl
make
make install
```

查看结果：

```shell
$ ls /usr/local/openssl/
bin/  include/  lib/  ssl/
```

## 构建bind9

预先安装

```shell
dnf install diffutils
```

构建

```shell
mkdir -p /usr/local/bind9
./configure --prefix=/usr/local/bind9 --with-openssl=/usr/local/openssl
make
make install
```

查看结果：

```
$ ls /usr/local/bind9/
bin/  etc/  include/  lib/  sbin/  share/  var/
```

二进制主要在`bin`和`sbin`下
