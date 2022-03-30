# minio

## 环境要求
- loongson 3A5000
- golang1.15

## 项目分析
`minio` 是一个 `go` 语言项目，虽然带了一个前端页面，但是这部分并不需要编译，所以 `minio` 可以看作一个纯 `go` 语言项目;

其次 `minio` 采用 `go mod` 进行依赖管理，龙芯也提供了匹配的 `goproxy` 源方便移植;

当前 `loongarch64` 仅支持 `go-1.15.6`，所以我们选择对应版本的 `minio:RELEASE.2021-02-24T18-44-45Z`

## 移植步骤

删除 `go.sum` 文件
```
rm go.sum
```

设置龙芯 `GOPROXY` 代理，设置关闭 `GOSUMDB` 校验
```
export GOPROXY=http://goproxy.loongnix.cn
export GOSUMDB=off
```

执行 `make build`，会报错以下错误，结合错误提示以及 Makefile 的编译流程，我们可以找到
```
root@pugu:/tmp/minio-RELEASE.2021-02-24T18-44-45Z# make build
Error generating git commit-id:  exit status 128
exit status 1
Checking dependencies
Arch 'loongarch64' is not supported. Supported Arch: [x86_64, amd64, aarch64, ppc64le, arm*, s390x]
make: *** [Makefile:15: checks] Error 1
```

结合错误提示以及 Makefile 的编译流程，我们可以找到在 `buildscripts/checkdeps.sh` 中有下列代码，需要加上 loongarch64 架构的支持
```
# 修改前
assert_is_supported_arch() {
    case "${ARCH}" in
        x86_64 | amd64 | aarch64 | ppc64le | arm* | s390x )
            return
            ;;
        *)
            echo "Arch '${ARCH}' is not supported. Supported Arch: [x86_64, amd64, aarch64, ppc64le, arm*, s390x]"
            exit 1
    esac
}

# 修改后
assert_is_supported_arch() {
    case "${ARCH}" in
        x86_64 | amd64 | aarch64 | ppc64le | arm* | s390x | loongarch64 )
            return
            ;;
        *)
            echo "Arch '${ARCH}' is not supported. Supported Arch: [x86_64, amd64, aarch64, ppc64le, arm*, s390x, loongarch64]"
            exit 1
    esac
}
```

最后执行 `make build`，即可成功编译出 `minio` 可执行文件

## 制作镜像
