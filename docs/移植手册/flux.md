# flux

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称|描述|
|--|--|
|官方地址|https://github.com/influxdata/flux|
|版本|v0.161.0|

## 构建环境

|名称|描述|
|--|--|
|机器|loongarch64|
|系统|loongnix-server|

## 移植步骤

__软件预装__

```shell
dnf install golang-1.20 make git cargo
```

__下载源码__

```shell
git clone --depth=1 --branch v0.161.0 https://github.com/influxdata/flux.git
```

__安装golang二进制依赖__

```shell
go install github.com/influxdata/pkg-config@latest
# 安装完成后将GOPATH/bin加入环境变量
```

__查看pkg-config__

```shell
root@influxdb-doc /# which -a pkg-config 
/root/go/bin/pkg-config
/usr/bin/pkg-config
/bin/pkg-config
```

## 构建rust相关依赖

```shell
cd libflux/
# 需要配置loongson cargo仓库： http://docs.loongnix.cn/rust/rust.html
# 删除原来的Cargo.lock
rm -rf Cargo.lock
cargo build
```

__依赖相关报错__

```
error: package `log v0.4.19` cannot be built because it requires rustc 1.60.0 or newer, while the currently active rustc version is 1.58.1
```

修改如下：

```diff
diff --git a/libflux/flux-core/Cargo.toml b/libflux/flux-core/Cargo.toml
index 6a5aa98..43598e2 100644
--- a/libflux/flux-core/Cargo.toml
+++ b/libflux/flux-core/Cargo.toml
@@ -49,7 +49,7 @@ maplit = "1.0.2"
 flatbuffers = "2.0.0"
 derivative = "2.1.1"
 walkdir = "2.2.9"
-log = "0.4"
+log = "=0.4.8"
 lsp-types = { version = "0.92", optional = true }
 pulldown-cmark = { version = "0.8", default-features = false }
 structopt = "0.3"
```
---

__所有依赖项修改如下__

```diff
diff --git a/libflux/flux-core/Cargo.toml b/libflux/flux-core/Cargo.toml
index 6a5aa98..096296b 100644
--- a/libflux/flux-core/Cargo.toml
+++ b/libflux/flux-core/Cargo.toml
@@ -26,6 +26,7 @@ lsp = ["lsp-types"]
 doc = ["rayon"]
 
 [dependencies]
+bumpalo = "=3.12.0"
 anyhow = "1"
 ena = "0.14"
 env_logger = "0.9"
@@ -42,22 +43,22 @@ serde = { version = "^1.0.59", features = ["rc"] }
 serde_derive = "^1.0.59"
 serde_json = "1.0"
 serde-aux = "0.6.1"
-wasm-bindgen = { version = "0.2.62", features = ["serde-serialize"] }
+wasm-bindgen = { version = "=0.2.62", features = ["serde-serialize"] }
 chrono = { version = "0.4", features = ["serde"] }
 regex = "1"
 maplit = "1.0.2"
 flatbuffers = "2.0.0"
 derivative = "2.1.1"
 walkdir = "2.2.9"
-log = "0.4"
+log = "=0.4.8"
 lsp-types = { version = "0.92", optional = true }
 pulldown-cmark = { version = "0.8", default-features = false }
 structopt = "0.3"
-libflate = "1"
+libflate = "=1.2.0"
 once_cell = "1"
-csv = "1.1"
+csv = "=1.1.0"
 pad = "0.1.6"
-tempfile = "3"
+tempfile = "=3.1.0"
 
 [dev-dependencies]
 env_logger = "0.9"
```

> 这里`=`表示使用绝对的版本号

## 构建golang项目

```shell
# 进入根目录
go get golang.org/x/net@6960703597adf5b8919a13c3c0ce585a274fd405
go get golang.org/x/sys@00d8004a14487f8c7b7fdfe44b95e9f6c4590f5f
go mod tidy

go build ./cmd/flux
```