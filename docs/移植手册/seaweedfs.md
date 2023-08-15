# seaweedfs
## 1.构建版本
2.85

## 2.构建环境
本次在以下两个环境中均构建：
### 2.1 loongnix-server
```
# cat /etc/os-release 
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

# uname -a
Linux localhost.localdomain 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```
```
# go version
go version go1.19 linux/loong64
```

### 2.2 Anolis OS
```
# cat /etc/os-release 
NAME="Anolis OS"
VERSION="8.8"
ID="anolis"
ID_LIKE="rhel fedora centos"
VERSION_ID="8.8"
PLATFORM_ID="platform:an8"
PRETTY_NAME="Anolis OS 8.8"
ANSI_COLOR="0;31"
HOME_URL="https://openanolis.cn/"

# uname -a
Linux bogon 4.19.190-7.6.an8.loongarch64 #1 SMP Sun Jun 25 11:36:01 CST 2023 loongarch64 loongarch64 loongarch64 GNU/Linux
```
```
# go version
go version go1.18.10 linux/loong64
```

## 3.下载vendor目录
```
cd seaweedfs
go mod tidy
go mod vendor
```

## 4.源码适配
该项目本身不需要进行源码适配，主要是依赖的vendor目录下项目与架构相关，涉及以下几个项目：
### 4.1 sys
官方最新版本已支持loong64架构，更新该项目中依赖的sys版本：
```
# go get -d golang.org/x/sys
# go mod tidy
# go mod vendor
```

### 4.2 bigfft
官方最新版本已支持loong64架构，更新该项目中依赖的bigfft版本：
```
# go get -d github.com/remyoudompheng/bigfft
# go mod tidy
# go mod vendor
```

### 4.3 memory
官方最新版本已支持loong64架构，更新该项目中依赖的memory版本：
```
# go get -d modernc.org/memory
# go mod tidy
# go mod vendor
```

### 4.4 libc
官方最新版本已支持loong64架构，更新该项目中依赖的libc版本：
```
go get -d modernc.org/libc@v1.23.0
# go mod tidy
# go mod vendor
```

### 4.5 sqlite
该项目目前官方还不支持，需要手动将架构相关代码添加到vendor/modernc.org/sqlite目录下，具体详见：https://github.com/Loongson-Cloud-Community/seaweedfs/commit/bc7ed3a2be7036e7e19c6d092b456fc62a7a5167

## 5. 源码构建
```
cd weed
make install    //执行完成后weed二进制将安装在 $GOPATH/bin 目录下
```
