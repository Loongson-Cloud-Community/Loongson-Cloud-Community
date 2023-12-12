# buildx使用手册

## 0. 简介
Buildx是Docker官方提供的一种构建工具，优势:
	(1) 可以在不同平台上构建多架构的Docker镜像，支持Dockerfile和OCI镜像格式;
	(2) 支持hcl语法，批量构建镜像
	(3) 还可以使用多种构建器，如BuildKit、Docker-CLI、Buildah等。
Buildx的主要优势在于可以将不同架构的Docker镜像打包到同一个镜像中，从而支持多平台部署，提高了Docker镜像的可移植性和兼容性。
 

## 1. 部署环境    

```
[yzw@bogon ~]$ cat /etc/os-release 
NAME="Anolis OS"
VERSION="23"
ID="anolis"
VERSION_ID="23"
PLATFORM_ID="platform:an23"
PRETTY_NAME="Anolis OS 23"
ANSI_COLOR="0;31"
HOME_URL="https://openanolis.cn/"
BUG_REPORT_URL="https://bugzilla.openanolis.cn/"

[yzw@bogon ~]$ uname -a
Linux bogon 5.10.134-15.1.an23.loongarch64 #1 SMP Thu Sep 7 02:30:41 UTC 2023 loongarch64 GNU/Linux

``` 

## 2. 安装
### 下载并创建目录
```
wget http://cloud.loongnix.xa/docker/buildx%2F0.12.0/docker-buildx-0.12.0-rc1_Linux_Loong64.tar.gz

mkdir -p ~/.docker/cli-plugins/
```

### 安装
```
install docker-buildx ~/.docker/cli-plugins/
chmod a+x ~/.docker/cli-plugins/docker-buildx
+docker buildx install //使用docker builder 代替docker buildx  执行docker buildx uninstall取消

由于需要开启实验模式才可以使用buildx,两种设置方法
vi ~/.docker/config.json 或　vi /etc/docker/daemon.json
"experimental": "enabled"
或
设置环境变量　DOCKER_CLI_EXPERIMENTAL=enabled

重启docker使配置生效
systemctl daemon-reload
systemctl restart docker

测试: docker buildx  -h 
      docker builder -h
```
## 3. 基本使用命令
### 基本操作语句

#### 创建实例命令及对应参数  此处及之后的命令均使用builder 使用buildx效果相同
```
docker builder create [参数] [内容|]
docker builder create --name loongson　--driver=docker --driver-opt=moby/buildkit:v0.11.3 
//创建名字为loongson的实例,指定构建器驱动程序为docker,指定驱动程序为buildkit，版本可选
构建器类型
+++++++++++++++++++++++++++++++++++
docker docker绑定+ 默认的buildkit +
docker-container + buildkit 　　　+
kubernetes       + k8s集群下专用　+
remote           + 手动连接       +
+++++++++++++++++++++++++++++++++++

主要使用前两个
```

#### 查询　删除　切换驱动器
```
docker builder ls 
docker builder rm <name>

docker builder use <name>
docker builder inspect --bootstrap <name>
//暂时存在问题，因为目前没有支持loongarch的镜像manufast

docker builder 

docker builder 
```
具体命令手册见(https://github.com/docker/buildx/blob/master/docs/reference/buildx_create.md)[https://github.com/docker/buildx/blob/master/docs/reference/buildx_create.md]

#### 构建镜像
##### buildx主要依赖bake命令来构建镜像，可以识别*json 文件、*.yaml 文件以及*.hcl文件来构建镜像，具体可识别的文件名字如下：
- docker-bake.override.hcl
- docker-bake.hcl
- docker-bake.override.json
- docker-bake.json
- docker-compose.yaml
- docker-compose.yml

##### 具体构建命令如下：
```
docker builder bake --file=../docker/bake.hcl
```

##### hcl文件的配置解析
##### Bake 文件支持以下属性类型：
- target: 构建目标
- group: 构建目标的集合
- variable: 构建时的参数及值
- function: 自定义函数
不同属性类型下可以定义的属性如下：
Name	        	Type	描述			
args	        	Map	构建参数  --build-arg
attest	        	List	安全特性设置
cache-from		List	指定构建时的缓存源
cache-to		List	指定构建时存储的缓存目标
context	        	String	指定构建上下文位置 代替.
contexts	        Map	Additional build contexts
dockerfile-inline	String  内联Dockerfile
dockerfile		String	--file
inherits		List	声明inherits可以从其他标签继承属性，当从多个目标继承属性并且存在冲突时，继承列表中最后出现的目标优先
labels			Map	声明构建镜像的标签
matrix			Map	使用矩阵在一个target下同时声明多个待构建镜像
name			String	Override the target name when using a matrix.
no-cache-filter		List	Disable build cache for specific stages
no-cache		Boolean	Disable build cache completely
output			List	Output destinations
platforms		List	镜像对应的目标架构
pull			Boolean	Always pull images
secret			List	Secrets to expose to the build
ssh			List	SSH agent sockets or keys to expose to the build
tags			List	-tags
target			String	Target build stage

##### 下面给出bake文件的常用样例:
1. 您可以在 Bake 文件中分层定义属性，并可以给属性分配1至多个值，可以将冗长的docker build命令写入文件进行构建。
例子: 
```
docker build \
  --build-arg HTTP_PROXY=http://10.20.30.2:1234 \
  --build-arg GO_VERSION=1.20.1 \
  --file=Dockerfile.hello \
  --tag=lcr.loongnix.cn/library/hello:latest \
  https://github.com/hello
```
```
target "hello" {
  args={
	HTTP_PROXY=http://10.20.30.2:1234
	GO_VERSION=1.20.1
  }
  dockerfile = "Dockerfile.hello"
  tags = ["lcr.loongnix.cn/library/hello:latest"]
  context = "https://github.com/hello"
}
```

2. 下面给出一个简单的 Bake 文件。其中定义了三个属性：变量、组和目标。
```
variable "TAG" {
  default = "latest"
}

group "default" {
  targets = ["hello"]
}

target "hello" {
  dockerfile = "Dockerfile"
  tags = ["cr.loongnix.cn/library/hello:${TAG}"]
}
```

3. 多阶段构建
```
# docker-bake.hcl
target "base" {
    dockerfile = "baseapp.Dockerfile"
}
target "app" {
    contexts = {
        baseapp = "target:base"
    }
}
```

4. 函数
```
# docker-bake.hcl
function "increment" {
  params = [number]
  result = number + 1
}

target "webapp-dev" {
  dockerfile = "webtest.Dockerfile"
  tags = ["lcr.loongnix.cn/library/webapp:latest"]
  args = {
    buildno = "${increment(123)}"
  }
}
```
更具体的参数及样例见[https://docs.docker.com/build/bake/reference/](https://docs.docker.com/build/bake/reference/)

## 4. 跨平台镜像批量构建功能
#### 选用平台
##### x86/loongarch64 (使用的镜像不同)
###### 使用默认构建器
一次只能构建一个架构的镜像，无法将多个架构镜像同时存储在同一个manifest中
```
$ docker buildx build --platform linux/arm64 
```
###### 使用buildkit
```
$ docker builder create --name loongson　--driver=docker --driver-opt=moby/buildkit:v0.11.3
$ docker buildx build --push --platform linux/arm64,linux/loongarch64 -t cr.loongnix.cn/library/test:latest -f Dockerfile .
注意：构建单一架构(single arch)下镜像时使用--load --platform linux/arm64 组合
而多架构只能使用--push --platform linux/arm64,linux/loongarch64
--load 表示构建到本地
--push则直接push到dockerhub
```
构建完毕后，查看构建的多架构镜像信息：
``` 
docker buildx imagetools inspect jianghushinian/hello-go
```

交叉编译可以使用的参数
　　变量	说明
TARGETPLATFORM	构建镜像的目标平台，如：linux/amd64，linux/arm/v7，windows/amd64。
TARGETOS	TARGETPLATFORM 的操作系统，如：linux、windows。
TARGETARCH	TARGETPLATFORM 的架构类型，如：amd64、arm。
TARGETVARIANT	TARGETPLATFORM 的变体，如：v7。
BUILDPLATFORM	执行构建所在的节点平台。
BUILDOS	　　　　BUILDPLATFORM 的操作系统。
BUILDARCH	BUILDPLATFORM 的架构类型。
BUILDVARIANT	BUILDPLATFORM 的变体。

如希望在x86下编译loongarch:
```
Dockerfile
FROM --platform=$BUILDPLATFORM golang:1.20-alpine AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /app
ADD . .
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o hello .

FROM lcr.loongnix.cn/library/alpine:v3.18.4-base
WORKDIR /app
COPY --from=builder /app/hello .
CMD ["./hello"]

docker-bake.hcl
variable "TARGETPLATFORM" {
  default = "loong64"
}
variable "BUILDPLATFORM" {
  default = "amd64"
}
variable "TARGETOS" {
  default = "linux"
}
variable "TARGETARCH" {
  default = "loong64"
}
```
上述代码中目标平台若为loongarch，则需要调用lcr龙芯官方镜像源的基础镜像

