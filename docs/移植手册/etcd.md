# etcd

## etcd 移植
移植的环境为 [cr.loongnix.cn/library/golang:1.19-alpine 镜像](https://cr.loongnix.cn/repository/library/golang?tab=tags)。

1. 拉取 [etcd 源码](https://github.com/etcd-io/etcd)并切换到 3.5.5 版本
```    
git clone https://github.com/etcd-io/etcd.git
git checkout v3.5.5
```

2. 修改脚本和源码
```
diff --git a/scripts/build-binary b/scripts/build-binary
index b819a3e57..8021192b9 100755
--- a/scripts/build-binary
+++ b/scripts/build-binary
@@ -77,6 +77,7 @@ function main {
       TARGET_ARCHS+=("arm64")
       TARGET_ARCHS+=("ppc64le")
       TARGET_ARCHS+=("s390x")
+      TARGET_ARCHS+=("loong64")
     fi
 
     if [ ${GOOS} == "darwin" ]; then
diff --git a/server/etcdmain/etcd.go b/server/etcdmain/etcd.go
index 470eb83be..9ed379b50 100644
--- a/server/etcdmain/etcd.go
+++ b/server/etcdmain/etcd.go
@@ -471,6 +471,7 @@ func checkSupportArch() {
        // to add a new platform, check https://github.com/etcd-io/website/blob/main/content/en/docs/next/op-guide/supported-platform.md
        if runtime.GOARCH == "amd64" ||
                runtime.GOARCH == "arm64" ||
+               runtime.GOARCH == "loong64" ||
                runtime.GOARCH == "ppc64le" ||
                runtime.GOARCH == "s390x" {
                return
```

3. 对 golang env 进行修改
```
go env -w GOSUMDB=off
go env -w GOPROXY=https://goproxy.cn,direct
```

4. 编译
```
cd server
go mod vendor
```
另起一个容器，配置：
```
go env -w GOPROXY=http://goproxy.loongnix.cn
```
按照同样的流程 go mod vendor，使用 vendor/golang.org/x 替换待编译容器中的 vendor/golang/x，在 vendor/go.etcd.io/bbolt/下 添加 bolt_loong64.go，在 etcdctl 以及 etcdutl 目录下也进行上述替换和添加操作。
最后在 etcd 根目录下执行：```make / make build```

5. 冒烟测试
```
./bin/etcd --version
./bin/etcdctl version
./bin/etcdutl version
```

## rpm 包制作
制作 rpm 包的环境为 [cr.loongnix.cn/loongson/loongnix-server:8.4.0 镜像](https://cr.loongnix.cn/repository/loongson/loongnix-server?tab=tags)。

1. 在 x86_64 机器上拉取同版本 rpm 包
 
2. 在 x86_64 机器上解压 rpm 包的 .sepc 文件以及源文件
```
yum install rpm-build rpmrebuild rpm cpio
rpmrebuild -e -p --notest-install etcd-3.5.5-2.fc37.x86_64.rpm
```
保存 .spec文件为 etcd.spec，提取源文件：
```
rpm2cpio etcd-3.5.5-2.fc37.x86_64.rpm | cpio -div
```
将 etcd.spec 以及源文件拷贝到制作 rpm 的环境中。

3. 构建打包文件
使用之前编译的二进制文件替换源文件中的二进制文件后创建打包目录：
```
[root@ec3237ae9ac7 rpmbuild]# tree -L 1
.
├── BUILD
├── BUILDROOT
├── RPMS
├── SOURCES
├── SPECS
└── SRPMS
```
修改 etcd.sepc 文件，更改架构名称，删除动态库的依赖，修改 release 版本。将修改后的文件移动到 SPECS 目录下，将源文件按照 etcd.sepc 中的名称命名（Name-Version-Release.BuildArch），如：etcd-3.5.5-2.loongarch64，并移动到 BUILDROOT 目录下。

4. 打包
```
rpmbuild -bb SPECS/etcd.spec
```
生成的 rpm 包在 RPMS/loongarch64/ 目录下

5. 安装
```
yum install etcd-3.5.5-2.loongarch64.rpm
```
6. 卸载
```
yum remove etcd-3.5.5-2.loongarch64.rpm
```
