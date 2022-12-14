# weave构建指导

## 项目信息
weave是weaveworks公司的核心项目，用来解决docker网络问题，weave创建的虚拟网络可以将部署在多个主机上的容器连接起来，对容器来说，weave就像一个巨大的以太网交换机，所有介入这个交换机的容器都可以直接通信。    
项目地址：git@github.com:Loongson-Cloud-Community/weave.git         
项目分支：loong64-2.1.3                
## 项目构建     
准备：提前下载镜像cr.loongnix.cn/library/alpine:3.11.11            
执行命令：            
ARCH=loong64 ALPINE_BASEIMAGE=cr.loongnix.cn/library/alpine:3.11.11 make

## 构建结果
make执行成功后，会生成以下镜像：
```
cr.loongnix.cn/weaveworks/weavebuild:2.1.3
cr.loongnix.cn/weaveworks/weave-npc:2.1.3                                   
cr.loongnix.cn/weaveworks/weave-kube:2.1.3                                     
cr.loongnix.cn/weaveworks/weaveexec:2.1.3                                
cr.loongnix.cn/weaveworks/weave:2.1.3  
cr.loongnix.cn/weaveworks/weavedb:2.1.3  
```
### weavebuild
生成该镜像使用的dockerfile是build/Dockerfile，该镜像是后面其他几个镜像的基础镜像，主要配置了构建环境包括安装必要的软件、go的依赖项目及库文件（libpacp）等。   
项目源码的构建也都是在该镜像中执行的，包括二进制：prog/weaver/weave、prog/weaveutil/weaveutile、prog/sigproxy/sigproxy、prog/weavewait/weavewait, prog/weavewait/weavewait_noop, prog/weavewait/weavewait_nomcast, prog/kube-peers/kube-peers, prog/weave-npc/weave-npc        
### weave
该镜像使用的dockerfile是prog/weaver/Dockerfile.weaveworks是主程序，负责建立weave网络，收发数据，提供DNS服务。其中主要包含了二进制prog/weaver/weaver, prog/weaveutil/weaveutil和shell脚本prog/weaver/weave。                        
weave: 用户态的shell脚本，用于安装weave,将container连接到weave虚拟网络，并为他们分配IP。      
weaver: 运行于container内，每个weave网络内的主机都要运行，是使用go语言实现的虚拟网络路由器。不同主机之间的网络通信依赖于weaver路由。
参考：https://cloud.tencent.com/developer/article/1027318                
### weaveexec      
使用的dockerfile是prog/weaveexec/Dockerfile.weaveworks。该镜像是libnetwork CNM driver,实现docker网络。其中主要包含了二进制prog/sigproxy/sigproxy,prog/weavewait/weavewait,prog/weavewait/weavewait_noop, prog/weavewait/weavewait_nomcast。             
参考：https://www.feiyiblog.com/2020/04/06/Docker%E5%AE%B9%E5%99%A8%E7%BD%91%E7%BB%9C-weave/       
### weave-kube
该镜像主要包含了二进制prog/kube-peers/kube-peers。在weavenet可以自动为容器分配IP地址，并基于VxLAN协议为容器提供跨主机通信能力。在weavenet中，每台主机都运行着一个weave peer，每个peer都有一个名称，重启保持不变，它们之间通过TCP连接彼此，建立后交换拓扑信息。      
weave net可以在具有编号拓扑部分连接的网络中路由数据包。如在下图中，peer1直接连接2和3,但是如果1需要发送数据包到4和5,则必须先将其发送到peer3。     
参考：https://blog.csdn.net/lfs666666/article/details/111821138      
https://blog.51cto.com/u_13045706/3834774     
### weave-npc
该镜像主要包含了二进制weave-npc, weave-npc使用iptables来生效network policy，控制接入输出。     
参考：https://juejin.cn/post/6935333405810753543      
### weavedb
使用的dockerfile是prog/weavedb/Dockefile,是一个空镜像。    
## 源码修改
详细的源码修改可通过以下命令查看：
```
git show ae49ea3dafacb457e2c0d3aeec300796ec662b05
git show 2140d55f11135df4628ee6a93d7b89fb70da563a
```

下面是针对一些修改添加的解释   
### Makefile
（1）在Makefile中注释了关于qemu相关的内容，通过查看注释qemu主要是在x86上交叉构建别的架构，所以这里注释。
```
diff --git a/Makefile b/Makefile
index ece9c260..ef1a32c6 100644
--- a/Makefile
+++ b/Makefile
@@ -249,7 +251,7 @@ endif
 # It also makes sure the multiarch hooks are reqistered in the kernel so the QEMU emulation works
 $(BUILD_UPTODATE): build/*
        $(SUDO) docker build -t $(BUILD_IMAGE) build/
-       $(SUDO) docker run --rm --privileged multiarch/qemu-user-static:register --reset
+#      $(SUDO) docker run --rm --privileged multiarch/qemu-user-static:register --reset
        touch $@

@@ -265,8 +267,8 @@ ifeq ($(ARCH),amd64)
 else
 # When cross-building, only the placeholder "CROSS_BUILD_" should be removed
 # Register /usr/bin/qemu-ARCH-static as the handler for ARM and ppc64le binaries in the kernel
-       curl -sSL https://github.com/multiarch/qemu-user-static/releases/download/$(QEMU_VERSION)/x86_64_qemu-$(QEMUARCH)-static.tar.gz | tar -xz -C $(shell dirname $@)
-       cd $(shell dirname $@) && sha256sum -c $(shell pwd)/build/shasums/qemu-$(QEMUARCH)-static.sha256sum
+       #curl -sSL https://github.com/multiarch/qemu-user-static/releases/download/$(QEMU_VERSION)/x86_64_qemu-$(QEMUARCH)-static.tar.gz | tar -xz -C $(shell dirname $@)
+       #cd $(shell dirname $@) && sha256sum -c $(shell pwd)/build/shasums/qemu-$(QEMUARCH)-static.sha256sum
```

（2）修改了vendor中内容，所以在构建时，不再进行子模块更新
```
diff --git a/Makefile b/Makefile
index ece9c260..ef1a32c6 100644
--- a/Makefile
+++ b/Makefile
@@ -196,9 +198,9 @@ ifeq ($(BUILD_IN_CONTAINER),true)
 # This make target compiles all binaries inside of the weaveworks/build container
 # It bind-mounts the source into the container and passes all important variables
 exes $(EXES) tests lint: $(BUILD_UPTODATE)
-       git submodule update --init
+       #git submodule update --init
 # Containernetworking has another copy of vishvananda/netlink which leads to duplicate definitions
-       -@rm -r vendor/github.com/containernetworking/cni/vendor
+       #-@rm -r vendor/github.com/containernetworking/cni/vendor
```
### build/Dockerfile
（1）在目前龙芯debian系统中没有工具shfmt, 该工具是用来格式化shell程序的，非关键作用，所以这里删除   
```
@@ -43,25 +41,29 @@ RUN apt-get update \
                flex \
                bison
 
-RUN curl -fsSLo shfmt https://github.com/mvdan/sh/releases/download/v1.3.0/shfmt_v1.3.0_linux_amd64 && \
-       echo "b1925c2c405458811f0c227266402cf1868b4de529f114722c2e3a5af4ac7bb2  shfmt" | sha256sum -c && \
-       chmod +x shfmt && \
-       mv shfmt /usr/bin
```
（2）删除交叉编译工具部分
```
 # Temporarily add the Debian repositories, because we're going to install gcc cross-compilers from there
 # Install the build-essential and crossbuild-essential-ARCH packages
-RUN echo "deb http://emdebian.org/tools/debian/ jessie main" > /etc/apt/sources.list.d/cgocrosscompiling.list \
-  && curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add - \
```
（3）在golang中LA架构不支持-race特性，所以删除
```
 RUN go clean -i net \
-       && go install -tags netgo std \
-       && go install -race -tags netgo std
+       && go install -tags netgo std
```
（4）下载的libpcap代码中的config.sub和config.guess不支持LA架构，获取支持LA架构的文件，并进行替换
```
@@ -76,6 +78,8 @@ RUN chmod -R a+w /usr/local/go
 ENV LIBPCAP_CROSS_VERSION=1.6.2
 RUN curl -sSL http://www.tcpdump.org/release/libpcap-${LIBPCAP_CROSS_VERSION}.tar.gz | tar -xz \
        && cd libpcap-${LIBPCAP_CROSS_VERSION} \
+       && wget -O ./config.sub "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" \
+       && wget -O ./config.guess "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" \
        && for crosscompiler in ${GCC_CROSSCOMPILERS}; do \
                CC=${crosscompiler}-gcc ac_cv_linux_vers=2 ./configure --host=${crosscompiler} --with-pcap=linux \
```
（5）go mod 模式下下载
```
 # Install common Go tools
-RUN go get \
-       github.com/golang/lint/golint \
-       github.com/fzipp/gocyclo \
-       github.com/fatih/hclfmt \
-       github.com/client9/misspell/cmd/misspell
+
+ENV https_proxy=http://10.130.0.16:7890
+RUN go env -w GO111MODULE=on \
+       && go env -w GOSUMDB=off \
+       && go get \
+       golang.org/x/lint/golint \
+       github.com/fzipp/gocyclo@v0.3.0 \
+       github.com/fatih/hclfmt \
+       github.com/client9/misspell/cmd/misspell \
+       && go env -w GO111MODULE=""
```
在下载go依赖项目时，使用go module模式下载。这是因为在GOPATH模式下下载时报错：
1）hclfmt
```
 root@93d6ee8c5f2a:/go# go get github.com/fatih/hclfmt
package io/fs: unrecognized import path "io/fs": import path does not begin with hostname
cannot find package "github.com/hashicorp/hcl/hcl/printer" in any of:
    /usr/local/go/src/github.com/hashicorp/hcl/hcl/printer (from $GOROOT)
    /go/src/github.com/hashicorp/hcl/hcl/printer (from $GOPATH)

root@f721141043a1:/go/src/github.com/fatih/hclfmt# grep -rn printer
main.go:14:    "github.com/hashicorp/hcl/hcl/printer" 
main.go:116:    res, err := printer.Format(src)
```
  此时GOPATH下已经下载了/go/src/github.com/hashicorp/hcl，该源码的版本是最新版本v2.15.0，不存在hcl/printer,故报错，在go mod模式下，会自动查找在哪个版本的hashicorp/hcl中存在目录hcl/printer,并下载对应的版本。
2）gocyclo
```
root@93d6ee8c5f2a:/go# go get  github.com/fzipp/gocyclo       
package io/fs: unrecognized import path "io/fs": import path does not begin with hostname
```
当前使用的是go1.15.6, io/fs这个模块在go1.16版本才有，故降低gocyclo的版本,要指定版本下载，必须在go mod模式下:
```
root@93d6ee8c5f2a:/go# go env -w GO111MODULE="on" 
root@93d6ee8c5f2a:/go# go get  github.com/fzipp/gocyclo@v0.3.0
go: downloading github.com/fzipp/gocyclo v0.3.0
```
注意：在使用go mod模式下载完成后又通过go env -w GO111MODULE=””设置为GOPATH模式，这是因为后面的镜像在使用该镜像时，使用的是项目里自带的vendor构建，虽然在go mod模式下也可以使用vendor构建，但是此时会出现类似下面的问题，出现的问题较多。      
```
go: found golang.org/x/sys/unix in golang.org/x/sys v0.2.0
go: found github.com/docker/libnetwork/ipams/remote/api in github.com/docker/libnetwork v0.5.6
go: found golang.org/x/crypto/hkdf in golang.org/x/crypto v0.3.0
go: github.com/weaveworks/weave/prog/weaver imports
	github.com/weaveworks/weave/common imports
	github.com/Sirupsen/logrus: github.com/Sirupsen/logrus@v1.9.0: parsing go.mod:
	module declares its path as: github.com/sirupsen/logrus
	        but was required as: github.com/Sirupsen/logrus
```
而且在go mod模式下还会报如下的错误：
```
go build -i -ldflags "-linkmode external -extldflags -static -X main.version=git-f670be431546" -tags netgo -o prog/weaver/weaver ./prog/weaver
vendor/github.com/docker/docker/api/types/container/config.go:7:2: cannot find package "." in:
	/go/src/github.com/weaveworks/weave/vendor/github.com/docker/go-connections/nat
vendor/github.com/docker/docker/pkg/plugins/client.go:14:2: cannot find package "." in:
	/go/src/github.com/weaveworks/weave/vendor/github.com/docker/go-connections/sockets
vendor/github.com/docker/docker/pkg/plugins/client.go:15:2: cannot find package "." in:
	/go/src/github.com/weaveworks/weave/vendor/github.com/docker/go-connections/tlsconfig
vendor/github.com/aws/aws-sdk-go/aws/credentials/shared_credentials_provider.go:8:2: cannot find package "." in:
	/go/src/github.com/weaveworks/weave/vendor/github.com/go-ini/ini
vendor/github.com/aws/aws-sdk-go/aws/awsutil/path_value.go:9:2: cannot find package "." in:
	/go/src/github.com/weaveworks/weave/vendor/github.com/jmespath/go-jmespath
make: *** [Makefile:219: prog/weaver/weaver] Error 1
```
其实在docker/docker/vendor下面包含了依赖项目，但是go mod模式下并没有在docker/docker/vendor查找docker/docker的依赖，而是去docker的同级目录下查找依赖，从而导致报错。在GOPATH模式下则会接使用docker/docker/vendor下面的依赖进行构建。
### vendor
（1）替换gopacket的代码
```
root@9fcb61dbde31:/go/src/github.com/weaveworks/weave# go build -i -ldflags "-linkmode external -extldflags -static -X main.version=git-f670be431546" -tags netgo -o prog/weaver/weaver ./prog/weaver
# github.com/weaveworks/weave/vendor/github.com/google/gopacket/pcap
vendor/github.com/google/gopacket/pcap/pcap.go:199:7: identifier "_Ctype_struct_bpf_program" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:476:13: identifier "_Ctype_struct_pcap_stat" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:521:49: identifier "_Ctype_struct_bpf_program" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:544:10: identifier "_Ctype_struct_bpf_program" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:577:41: identifier "_Ctype_struct_bpf_insn" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:649:66: identifier "_Ctype_struct_bpf_program" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:662:19: identifier "_Ctype_struct_bpf_insn" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:789:34: identifier "_Ctype_struct_pcap_addr" may conflict with identifiers generated by cgo
vendor/github.com/google/gopacket/pcap/pcap.go:792:56: identifier "_Ctype_struct_pcap_addr" may conflict with identifiers generated by cgo
```
通过查看 https://github.com/google/gopacket/issues/656， 是gopacket本身代码的问题，从commit 0c245453667e53d789b6dc8e74134345437f3312解决了这个问题。目前是下载了gopacket的最新版本，替换vendor下面版本。

（2）containernetworking/cni    
将该项目下vendor路径下的sys替换为适配LA的库     
（3）boltdb/bolt    
增加LA架构的支持     
```
root@cloud-01:/home/zhaixiaojuan/workspace/github-loongCloud/weave-bak/vendor/github.com/boltdb/bolt# grep -rn loong
bolt_loong64.go:1:// +build loong64
```
