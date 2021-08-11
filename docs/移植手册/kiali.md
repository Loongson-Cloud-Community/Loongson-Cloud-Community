# kiali

## 环境准备
- loongson loongarch64架构系统
- 软件依赖
golang(>=1.14), git, docker,NPM, make

## 项目分析
kiali是一款istio服务网格可视化工具，提供了服务拓扑图、全链路跟踪、指标要测、配置校验、健康检查等功能。kiali源码与架构无关。

##版本信息
- v1.26.0
-其他版本移植参考这里的修改即可

##编译准备
```
export GOPATH=/source/kiali/kiali 
mkdir -p $GOPATH
cd $GOPATH
mkdir -p src/github.com/kiali
cd src/github.com/kiali
git clone git@github.com:kiali/kiali
git clone git@github.com:kiali/kiali-operator kiali/operator
git clone git@github.com:kiali/helm-charts kiali/helm-charts
export PATH=${PATH}:${GOPATH}/bin
```

## 移植步骤
共修改三个文件：go.sum, Makefile,deploy/docker/Dockerfile-ubi8-minimal。
（1）删除 go.sum文件
（2）Makefile修改
```
--- a/Makefile
+++ b/Makefile
@@ -40,7 +40,8 @@ CONTAINER_VERSION ?= dev
 
 # These two vars allow Jenkins to override values.
 QUAY_NAME ?= quay.io/${CONTAINER_NAME}
-QUAY_TAG = ${QUAY_NAME}:${CONTAINER_VERSION}
+#QUAY_TAG = ${QUAY_NAME}:${CONTAINER_VERSION}
+QUAY_TAG = harbor.loongnix.cn/cncf-oa/kiali:v1.26.0 
```
（3）deploy/docker/Dockerfile-ubi8-minimal修改
```
--- a/deploy/docker/Dockerfile-ubi8-minimal
+++ b/deploy/docker/Dockerfile-ubi8-minimal
@@ -1,4 +1,4 @@
-FROM registry.access.redhat.com/ubi8-minimal
+FROM harbor.loongnix.cn/mirrorloongsoncontainers/loongnix-server:20-beta11
 
 LABEL maintainer="kiali-dev@googlegroups.com"
 
@@ -7,8 +7,8 @@ ENV KIALI_HOME=/opt/kiali \
 
 WORKDIR $KIALI_HOME
 
-RUN microdnf install -y shadow-utils && \
-    microdnf clean all && \
+RUN dnf install -y shadow-utils && \
+    dnf clean all && \
     rm -rf /var/cache/yum && \
     adduser --uid 1000 kiali
```

##编译
```
export GOPROXY=http://goproxy.loongson.cn:3000
go env -w GOSUMDB=off
cd ${GOPATH}/src/github.com/kiali/kiali
make build
```
##镜像制作
```
cd ${GOPATH} /src/github.com/kiali/kiali 
make container-build
```
