# kubernetes
## 基本信息
以 kubernetes 1.20.15 为例，进行 kubernetes on loongarch64 移植工作。
移植后的代码地址`https://github.com/Loongson-Cloud-Community/kubernetes/tree/1.20.15-loong64`

## 下载代码
下载 kubernetes 源代码至 `$GOPATH/src/k8s.io`
## 手动更新 golang.org/x/sys 和 golang.org/x/net
因为 kubernetes vendor 下 sys 和 net 版本过低，升级到高版本以支持 loong64。
```
curl -OL https://github.com/golang/sys/archive/refs/tags/v0.5.0.zip
curl -OL https://github.com/golang/net/archive/refs/tags/v0.5.0.zip

https://github.com/Loongson-Cloud-Community/kubernetes/commit/f44a834fe82a6a0399542ea76053eb858c378db0
```

## 增加 vendor 下其他 mod 包 loong64 支持
参考 `https://github.com/Loongson-Cloud-Community/kubernetes/commit/acd571fb7d45ff5ad21109f57e1ea2ec2d51ab7c`

## 为构建脚本增加 loong64 支持
参考`https://github.com/Loongson-Cloud-Community/kubernetes/commit/71abd129499fc280fed276d4929b7e35617738ff`
## 编译
1. kubernetes 需要将源码移动到 $GOPATH/src/k8s.io 目录下
2. 执行 `sudo KUBE_BUILD_PLATFORMS=linux/loong64 KUBE_GIT_TREE_STATE="clean" make release` 在 _output 目录下生成二进制
3. 执行 `sudo KUBE_BUILD_PLATFORMS=linux/loong64 KUBE_GIT_TREE_STATE="clean" KUBE_BUILD_CONFORMANCE=n KUBE_BUILD_HYPERKUBE=n make release-images` 在 _output 目录下生成镜像 tar 包
