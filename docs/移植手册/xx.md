# xx

本次移植 `xx 1.3.0` 版本，编译环境为新世界 `openeuler:22.03` ，golang 采用 `golang 1.21.0`。

## 环境
- xx 1.3.0 [源码](https://github.com/binfmt/xx)
- openeuler:22.03 [OS](https://www.openeuler.org/zh/download/archive/detail/?version=openEuler%2022.03%20LTS)
- golang 1.21.0

## 编译移植

### 1. 安装编译必要软件
```
yum install docker libseccomp-devel golang make git vim -y
```
如果docker版本低于20.10 参考其他文档/buildx.md 编译buildx并按文档内容加入buildx

### 2. 切换到需要移植的分支
`git checkout -b v1.3.0-loongarch64 v1.3.0`

### 3. 参考以下 patch 进行源码修改
[patch to loongarch64](https://github.com/tonistiigi/xx/pull/130)

### 4. 构建镜像
```
cd src && docker buildx bake -f docker-bake.dev.hcl

cd src/util/bats-assert &&  docker buildx bake -f docker-bake.hcl
```

