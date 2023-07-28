# calico-node
## calico/node 镜像组成
- [x] calico 源码
    - felix
        - bpf 二进制
    - node
        - node 二进制
        - mounts 二进制
- [x] go-build 镜像
- [x] bird 镜像
- [x] bpftool 镜像

## 构建分析
calico 所有的构建都在 go-build 镜像中完成，go-build 默认采用 alpine 进行静态二进制的交叉编译，但是 la 架构的交叉编译支持不完整，所以采用 debian 作为基础镜像，进行本地构建。根据依赖关系，构建顺序为 `go-build` -> `bird` -> `bpftool` -> `calico/node`。

## 版本选择
- calico 3.24.1
- go-build 0.73
- bird 0.3.3
- bpftool 5.19

说明 bpftool，因为 bpftool 是由内核源码编译的，内核从 5.19 开始正式支持 loong64，故选择  5.19 版本。

## go-build 镜像
移植源码参考[https://github.com/Loongson-Cloud-Community/dockerfiles/tree/main/calico/go-build/0.73](https://github.com/Loongson-Cloud-Community/dockerfiles/tree/main/calico/go-build/0.73)，主要修改内容：
- 使用 debian 基础镜像代替 alpine
- 添加更多的软件包，例如 clang，zlib1g-dev 以支持 bpf 文件编译
- 使用 go get 代替 go install，手动编译安装
- 取消一些用于 qemu 支持的软件，不影响在 loongarch64 环境下编译

## bird 镜像
移植源码参考[https://github.com/Loongson-Cloud-Community/dockerfiles/tree/main/calico/bird/0.3.3](https://github.com/Loongson-Cloud-Community/dockerfiles/tree/main/calico/bird/0.3.3)

## bpftool 镜像
移植源码参考[https://github.com/Loongson-Cloud-Community/dockerfiles/blob/main/calico/bpftool/5.19](https://github.com/Loongson-Cloud-Community/dockerfiles/blob/main/calico/bpftool/5.19)，主要修改内容：
- 增加 Dockerfile.loong64 文件
- 微调因为内核 5.3 和 5.19 bpftool 构建之间的差异

## calico node 镜像
移植源码参考[https://github.com/Loongson-Cloud-Community/dockerfiles/tree/main/calico/node/3.24.1](https://github.com/Loongson-Cloud-Community/dockerfiles/tree/main/calico/node/3.24.1)，主要修改内容：
- 使用 clang-13 进行编译
- 增加 Dockerfile.loong64 文件
