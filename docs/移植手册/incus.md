# incus
## 1.构建环境 
```
a. 使用系统：loongnix-server 8.4 
b. 安装 go 1.20 //不同的版本依赖的go版本可能不同，按照报错提示设置对应的go即可
c. 设置PKG_CONFIG_PATH=lxc.pc所在的路径
需要提前安装lxc，该版本的incus要求lxc版本>=3.1.0， 这个通过使用lxc源码编译3.1.0版本并安装，安装完成后lxc.pc位于路径/usr/local/lib/pkgconfig/lxc.pc，故这里设置:
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
```
## 2. 依赖检查
```
make deps
```
在执行完该命令后，会生成$GOPATH/deps路径下生成文件夹cowsql和raft。
并按照提示设置以下环境变量：
```
export CGO_CFLAGS="-I/root/go/deps/raft/include/ -I/root/go/deps/cowsql/include/" 
export CGO_LDFLAGS="-L/root/go/deps/raft/.libs -L/root/go/deps/cowsql/.libs/" 
export LD_LIBRARY_PATH="/root/go/deps/raft/.libs/:/root/go/deps/cowsql/.libs/" 
export CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)"
```

## 3. 编译
```
make
```
直接使用make编译，调用cgo的代码编译出来的二进制默认是动态链接，二进制安装在$GOPATH/bin路径下。     

通过“make -n”查看执行的编译命令：      
```
[root@kubernetes-master-1 incus]# make -n
CC="cc" CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)" go install -v -tags "libsqlite3"  ./...
CGO_ENABLED=0 go install -v -tags netgo ./cmd/incus-migrate
CGO_ENABLED=0 go install -v -tags agent,netgo ./cmd/incus-agent
cd cmd/lxd-to-incus && CC="cc" CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)" go install -v ./
echo "Incus built successfully"
```
CGO_ENABLED=0的情况下默认是静态编译，故只需要设置第一个构建命令为静态编译即可，添加静态编译参数：“-ldflags '-extldflags "-static -fpic"' ”：
```
CC="cc" CGO_LDFLAGS_ALLOW="(-Wl,-wrap,pthread_create)|(-Wl,-z,now)" go install -ldflags '-extldflags "-static -fpic"' -v -tags "libsqlite3"  ./...
```
但是由于系统上缺少udev,acl,sqlite3,cap静态库，导致以下二进制无法编译成静态二进制：     
```
fuidshift  incusd lxc-to-incus lxd-to-incus
```



