
## 相关链接

[直接编译二进制](http://sysdev.loongson.cn/issues/20353)

## 启动构建所使用的镜像

```
docker run -d --name etcd_rpm -v `pwd`:/root/ harbor.loongnix.org/mirrorloongsoncontainers/loongnix-server:20-beta10 bash -c "while true; do sleep 1; done"
```

## 修改镜像源

```
for file in /etc/yum.repos.d/*;do sed -i.bak "s/pkg.loongnix.cn:8080/10.130.0.6\/os/g" $file ; done
for file in /etc/yum.repos.d/*;do sed -i.bak "s/10.130.0.6\/os/10.130.0.6/g" $file ; done
```

## 安装构建工具

```
yum install -y rpm-build rpmdevtools
```

## 解压`etcd-3.2.21-2.el8.src.rpm`

```
rpm -hiv etcd-3.2.21-2.el8.src.rpm
```

## 解压并打补丁

```
rpmbuild -bp etcd.spec
```

### error: Architecture is not included: loongarch64

```
%{?go_arches:%{go_arches}}%{!?go_arches:x86_64 aarch64 ppc64le s390x loongarch64}
```
目前server自带的rpm中不存在la架构
```
rpm -E "%{go_arches}"
i386 i486 i586 i686 pentium3 pentium4 athlon geode x86_64 armv3l armv4b armv4l armv4tl armv5tl armv5tel armv5tejl armv6l armv6hl armv7l armv7hl armv7hnl aarch64 ppc64le s390x mips mipsel mipsr6 mipsr6el mips64 mips64el mips64r6 mips64r6el
```

```
%{?macro_to_text:expression}：如果macro_to_text存在，expand expression，如国不存在，则输出为空;也可以逆着用，:%{!?macro_to_text:expression}
```

Exclusivearch：指令指出只能在给定的体系结构上构建程序包。

### BuildRequires:  %{?go_compiler:compiler(go-compiler)}%{!?go_compiler:golang}


## 安装构建依赖
```
dnf install yum-utils
yum-builddep etcd.spec
```

## 修改代码

```
if runtime.GOARCH == "amd64" || runtime.GOARCH == "ppc64le" || runtime.GOARCH == "loong64" {
                return
        }

```

## -buildmode=pie not supported on linux/loong64

删除`-buildmode=pie`

## 修正构建约束 

```
Godeps/_workspace/src/github.com/coreos/bbolt/bolt_unix.go:65:15: undefined: maxMapSize
Godeps/_workspace/src/github.com/coreos/bbolt/bucket.go:128:15: undefined: brokenUnaligned
Godeps/_workspace/src/github.com/coreos/bbolt/db.go:110:13: undefined: maxMapSize
Godeps/_workspace/src/github.com/coreos/bbolt/db.go:374:12: undefined: maxMapSize
Godeps/_workspace/src/github.com/coreos/bbolt/db.go:392:10: undefined: maxMapSize
Godeps/_workspace/src/github.com/coreos/bbolt/db.go:393:8: undefined: maxMapSize
Godeps/_workspace/src/github.com/coreos/bbolt/freelist.go:244:19: undefined: maxAllocSize
Godeps/_workspace/src/github.com/coreos/bbolt/freelist.go:251:14: undefined: maxAllocSize
Godeps/_workspace/src/github.com/coreos/bbolt/freelist.go:285:17: undefined: maxAllocSize
Godeps/_workspace/src/github.com/coreos/bbolt/freelist.go:288:7: undefined: maxAllocSize
Godeps/_workspace/src/github.com/coreos/bbolt/freelist.go:288:7: too many errors

```
修正
```
cp bolt_amd64.go bolt_loong64.go
```

## Empty %files file /root/rpmbuild/BUILD/etcd-3ac81f3ae2264b21871128a170c78f8a9b2a3187/debugsourcefiles.list

```
https://blog.csdn.net/qq_41922018/article/details/103905243
```




