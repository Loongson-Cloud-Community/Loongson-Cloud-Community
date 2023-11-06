# binfmt

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |binfmt|
|版本       |latest|
|项目地址   |[https://github.com/tonistiigi/binfmt/tree/master](https://github.com/tonistiigi/binfmt/tree/master)|
|官方指导   |[https://github.com/tonistiigi/binfmt/tree/master/README.md](https://github.com/tonistiigi/binfmt/tree/master/README.md)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A6000|
|系统       |5.10 kernel|


## 移植步骤

__编译环境及依赖__
1. docker 20.0 +
2. buildx
3. 基础镜像 debian alpine golang busybox
4. tonistiigi/xx 对应两个镜像 xx bats-assert 详见[tonistiigi-xx.md]()
5. buildkit 部分内容 （binfmt的vendor目录中包含vendor/github.com/moby/buildkit/util/archutil）
6. qemu源码及补丁

__移植步骤__

主要修改 Dockerfile ，添加 start.sh next.sh crossarch.sh docker-bake.hcl 
以及configure_qemu.sh 中qemu的编译参数配置

更新go.mod 
`go mod vendor`

最终编译命令 docker buildx/builder bake -f docker-bake.hcl

__测试__

1. 安装全部qemu，分别测试不同架构在loongarch上的运行情况(如riscv64)
```
[yzw@bogon ~]$ docker run -it riscv64/busybox
WARNING: The requested image's platform (linux/riscv64) does not match the detected host platform (linux/loong64) and no specific platform was requested
/ # uname -a
Linux a9596bef3a4f 5.10.134-15.1.an23.loongarch64 #1 SMP Thu Sep 7 02:30:41 UTC 2023 riscv64 GNU/Linux


```

2. 测试跨架构批量构建情况
```
hello.go

package main
import (
	"fmt"
	"runtime"
)

func main(){
	fmt/Printf("Hello, %s/%s! \n",runtime.GOOS,runtime.GOARCH)
}

go.mod 

module hello

go 1.21

Dockerfile

FROM golang:1.20-alpine AS builder 
WORKDIR /app
ADD . .
RUN go build hello -o .

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello .
CMD ["./hello"]

docker-bake.hcl
target "default" {
    args={
        HTTPS_PROXY= "http://10.130.0.20:7890" ,
    }
    dockerfile="Dockerfile"
    tags = ["lcr.loongnix.cn/library/buildx:hello-go"]
    cache-to = ["type=inline"]
}

target "all" {
    inherits = ["default"]
    platforms = [
        "linux/amd64",
        "linux/arm64",
        "linux/arm/v7",
        "linux/arm/v6",
        "linux/arm/v5",
        "linux/riscv64"
    ]
}
```

执行命令
``` docker buildx bake -f docker-bake.hcl```
上述命令可能不成功，使用默认构建器时最多可同时构建一个跨机构镜像，如
``` docker buildx build --platform linux/arm64 . ```

