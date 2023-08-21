# telegraf

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |telegraf|
|版本       |1.27.3|
|项目地址   |[https://github.com/influxdata/telegraf](https://github.com/influxdata/telegraf)|
|官方指导   |[https://github.com/influxdata/telegraf/blob/v1.27.3/README.md](https://github.com/influxdata/telegraf/blob/v1.27.3/README.md)|


## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |4.19.190-7.6.lns8.loongarch64|


## 移植说明

  
## 移植步骤

__编译环境和依赖__
1. Linux kernel version 2.6.23 or later
2. go 1.20.0 以上版本
  龙芯go下载地址: [http://ftp.loongnix.cn/toolchain/golang/](http://ftp.loongnix.cn/toolchain/golang/)

__下载源码__
```
git clone -b v1.27.3 --depth 1 git@github.com:influxdata/telegraf.git
```

__移植__

- 检查架构相关
	修改Makefile中的架构声明，该项目在打包过程中与架构挂钩
```
diff --git a/Makefile b/Makefile
index 7d3c391..0f229e5 100644
--- a/Makefile
+++ b/Makefile
@@ -122,14 +122,14 @@ embed_readme_%:
 .PHONY: config
 config:
        @echo "generating default config"
-       go run ./cmd/telegraf config > etc/telegraf.conf
+       go run -v ./cmd/telegraf config > etc/telegraf.conf
 
 .PHONY: docs
 docs: build_tools embed_readme_inputs embed_readme_outputs embed_readme_processors embed_readme_aggregators embed_readme_secretstores
 
 .PHONY: build
 build:
-       CGO_ENABLED=0 go build -tags "$(BUILDTAGS)" -ldflags "$(LDFLAGS)" ./cmd/telegraf
+       CGO_ENABLED=0 go build -v -tags "$(BUILDTAGS)" -ldflags "$(LDFLAGS)" ./cmd/telegraf
 
 .PHONY: telegraf
 telegraf: build
@@ -137,7 +137,7 @@ telegraf: build
 # Used by dockerfile builds
 .PHONY: go-install
 go-install:
-       go install -mod=mod -ldflags "-w -s $(LDFLAGS)" ./cmd/telegraf
+       go install -mod=vendor -ldflags "-w -s $(LDFLAGS)" ./cmd/telegraf
 
 .PHONY: test
 test:
@@ -242,15 +242,15 @@ clean:
 
 .PHONY: docker-image
 docker-image:
-       docker build -f scripts/buster.docker -t "telegraf:$(commit)" .
+       docker build -f scripts/buster.docker -t "telegraf:$(tag)" .
 
 plugins/parsers/influx/machine.go: plugins/parsers/influx/machine.go.rl
        ragel -Z -G2 $^ -o $@
 
 .PHONY: ci
 ci:
-       docker build -t quay.io/influxdb/telegraf-ci:1.20.5 - < scripts/ci.docker
-       docker push quay.io/influxdb/telegraf-ci:1.20.5
+       docker build -t cr.loongnix.cn/influxdb/telegraf-ci:1.20.2 - < scripts/ci.docker
+       #docker push cr.loongnix.cn/influxdb/telegraf-ci:1.20.2
 
 .PHONY: install
 install: $(buildbin)
@@ -274,7 +274,7 @@ install: $(buildbin)
 $(buildbin):
        echo $(GOOS)
        @mkdir -pv $(dir $@)
-       CGO_ENABLED=0 go build -o $(dir $@) -ldflags "$(LDFLAGS)" ./cmd/telegraf
+       CGO_ENABLED=0 go build -v -o $(dir $@) -ldflags "$(LDFLAGS)" ./cmd/telegraf
 
 # Define packages Telegraf supports, organized by architecture with a rule to echo the list to limit include_packages
 # e.g. make package include_packages="$(make amd64)"
@@ -287,6 +287,12 @@ mipsel += mipsel.deb linux_mipsel.tar.gz
 mipsel:
        @ echo $(mipsel)
 arm64 += linux_arm64.tar.gz arm64.deb aarch64.rpm
+
+loongarch64 += linux_loongarch64.tar.gz loongarch64.deb loongarch64.rpm
+.PHONY: loongarch64
+loongarch64:
+       @ echo $(loongarch64)
+
 .PHONY: arm64
 arm64:
        @ echo $(arm64)
@@ -332,7 +338,7 @@ darwin-arm64 += darwin_arm64.tar.gz
 darwin-arm64:
        @ echo $(darwin-arm64)
 
-include_packages := $(mips) $(mipsel) $(arm64) $(amd64) $(armel) $(armhf) $(riscv64) $(s390x) $(ppc64le) $(i386) $(windows) $(darwin-amd64) $(darwin-arm64)
+include_packages := $(mips) $(mipsel) $(loongarch64) $(arm64) $(amd64) $(armel) $(armhf) $(riscv64) $(s390x) $(ppc64le) $(i386) $(windows) $(darwin-amd64) $(darwin-arm64)
 
 .PHONY: package
 package: docs config $(include_packages)
@@ -425,6 +431,9 @@ mips.deb linux_mips.tar.gz: export GOARCH := mips
 mipsel.deb linux_mipsel.tar.gz: export GOOS := linux
 mipsel.deb linux_mipsel.tar.gz: export GOARCH := mipsle
 
+loongarch64.deb linux_loongarch64.tar.gz: export GOOS := linux
+loongarch64.deb linux_loongarch64.tar.gz: export GOARCH := loong64
+
 riscv64.deb riscv64.rpm linux_riscv64.tar.gz: export GOOS := linux
 riscv64.deb riscv64.rpm linux_riscv64.tar.gz: export GOARCH := riscv64
```
- 编译过程中发现需要fpm打包工具，安装步骤如下
```
sudo yum install rubygems ruby
gem sources --add http://mirrors.aliyun.com/rubygems/ #更换为阿里源
gem sources --remove https://rubygems.org/
sudo gem install fpm

```

__编译__
1. 编译telegraf二进制文件
```
go mod tidy
go mod vendor #依赖下载到当前项目，方便处理
make build 
```
2. 打包loongarch架构下的telegraf rpm、deb包
``` 
make config
make loongarch64.deb
make linux_loongarch64.tar.gz
make loongarch64.rpm
```
3. 构建镜像
增加docker文件 buster.docker  docker-entrypoint.sh
buster.docker文件内容：
```
FROM cr.loongnix.cn/library/golang:1.20-buster as builder
WORKDIR /go/src/github.com/influxdata/telegraf

COPY . /go/src/github.com/influxdata/telegraf
RUN make go-install

FROM cr.loongnix.cn/library/buildpack-deps:buster-curl
#FROM buildpack-deps:buster-curl
COPY --from=builder /go/bin/* /usr/bin/
COPY etc/telegraf.conf /etc/telegraf/telegraf.conf

EXPOSE 8125/udp 8092/udp 8094

COPY scripts/docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf"]
```
docker-entrypoint.sh文件内容
```
#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- telegraf "$@"
fi

exec "$@"
```
最终执行：
```
make docker-images
```
构建镜像时发现server机器的网络遇到问题，更换到本机进行编译，通过
__测试__
1. 测试telegraf二进制
```
./telegraf --help
yzw@yzw-pc:~/git/telegraf$ telegraf --version
2023/08/21 10:56:22 github.com/josharian/native: unrecognized arch loong64 (LittleEndian), please file an issue
Telegraf 1.27.3 (git: HEAD@afcf0133)
```
发现提示信息，不影响使用，也可自行到文件进行修改
2. 测试deb包和rpm包
```
使用另一台机器或者启动镜像，将生成的安装包复制
sudo dpkg -i telegraf_1.27.3-1_loongarch64.deb
```
3. 测试镜像
```
经过和x86机器对比，镜像无误
```

