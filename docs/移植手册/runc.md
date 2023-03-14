# runc

本次移植 `runc 1.0.0` 版本，编译环境为 `loognix-server:8.3` 容器，golang 采用系统自带的 `golang 1.15.6`。

## 环境
- runc 1.0.0 [源码](https://github.com/opencontainers/runc)
- loongnix-server 8.3 [容器](https://cr.loongnix.cn/repository/loongson/loongnix-server)
- golang 1.15.6

## 编译移植

### 1. 安装编译必要软件
```
yum install libseccomp-devel golang make git vim -y
```

### 2. 切换到需要移植的分支
`git checkout -b v1.0.0-loongarch64 v1.0.0`

### 3. 参考以下 patch 进行源码修改
[patch to loongarch64](https://github.com/Loongson-Cloud-Community/runc/commit/f3e4c85f7906564c9356ab0400b46f3b9616a7e4)

### 4. 更新 vendor 下的 golang/sys golang/net 库
```
export GOPROXY=http://goproxy.loongnix.cn
export GOSUMDB=off
rm -f go.sum
go mod vendor
```

### 5. 编译
动态编译：  `make runc`       
静态编译：  `make static`
