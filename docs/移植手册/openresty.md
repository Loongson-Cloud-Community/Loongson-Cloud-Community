# openresty
## 官方 dockerfile
openresty 的基础镜像可以使用 debian，centos，alpine 等，但只有 alpine 是从源码构建，在此我们选择 alpine/Dockerfile。
```
https://github.com/openresty/docker-openresty
```

## openresty pre-release
从源码构建时，Dockerfile 会下载一个 openresty 的预构建的源码包，该源码包由 `openresty/util/mirror-tarballs` 生成，具体修改参考。
```
https://github.com/Loongson-Cloud-Community/openresty/commit/d5475b0b7278bba597ef6bd26a1b87846014cdf4
```

## 镜像构建
openresty 移植参考如下链接，主要做了以下修改
```
https://github.com/Loongson-Cloud-Community/dockerfiles/commit/4554d8e134a8d0c8188e2440e0ab372535989c9f
```
1. 修改 openresty pre-release 下载位置，以使源码支持龙芯架构
2. 禁用 pcre jit 特性
