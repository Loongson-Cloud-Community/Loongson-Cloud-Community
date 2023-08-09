# kapacitor

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |kapacitor|
|版本       |1.6.6|
|项目地址   |[https://github.com/influxdata/kapacitor](hhttps://github.com/influxdata/kapacitor)|
|官方指导   |[https://github.com/influxdata/kapacitor/blob/v1.6.6/README.md](https://github.com/influxdata/kapacitor/blob/v1.6.6/README.md)|


## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |Loongnix-Server Linux 8|


## 移植说明
kapacitor作为influx项目下
移植1.6.6对应flux版本为0.171
修改flux中的libflux/flux-core/Cargo.toml文件要和rust1.58版本对应
bumpalo = "=3.12.0"
log = "=0.4.8"
libflate = "=1.2.0"
csv = "=1.1.0"
tempfile = "=3.1.0"

## 移植步骤

__编译环境和依赖__
- 需要的软件：``` golang-1.19 make rust cmake clang catgo git ```
- 需要的lib库(yum源中没有的) ``` libflux ``` 

__下载源码__
- 下载flux源码 [https://github.com/influxdata/flux](https://github.com/influxdata/flux)
```git clone --depth=1 --branch v0.171.0 https://github.com/influxdata/flux.git```
- 下载kapacitor源码
```git clone --depth=1 --branch v1.6.6 https://github.com/influxdata/kapacitor.git```

__安装golang二进制依赖并配置__
```go install github.com/influxdata/pkg-config@latest```
# 安装完成后将GOPATH/bin加入环境变量
```export PATH=${GOPATH}/bin:${PATH}```

查看pkg-config
```
yzw@kube /# which -a pkg-config 
/root/go/bin/pkg-config
/usr/bin/pkg-config
/bin/pkg-config
```
__构建libflux动态库__
``` 
cd libflux/
# 必须配置loongsonrust源的cargo： http://docs.loongnix.cn/rust/rust.html
# 删除原有Cargo.lock
rm -rf Cargo.lock
```
# 修改Cargo.toml文件
将原有libflux/flux-core/Cargo.toml备份并删除，替换为如下内容的Cargo.toml
mv Cargo.toml Cargo.toml.bak
vim Cargo.toml
```
version = "0.154.0"
authors = ["Flux Team <flux-developers@influxdata.com>"]
edition = "2021"

[lib]
name = "fluxcore"
crate-type = ["rlib"]

[[bin]]
name = "fluxdoc"
test = false
bench = false
required-features = ["doc"]

[[bin]]
name = "fluxc"
test = false
bench = false

[features]
default = ["strict"]
strict = []
lsp = ["lsp-types"]
doc = ["rayon"]

[dependencies]
bumpalo = "=3.12.0"
anyhow = "1"
ena = "0.14"
env_logger = "0.9"
thiserror = "1"
codespan-reporting = "0.11"
comrak = "0.10.1"
fnv = "1.0.7"
derive_more = { version = "0.99.17", default-features = false, features = [
    "display",
    "from"
] }
pretty = "0.11.2"
rayon = { version = "1", optional = true }
serde = { version = "^1.0.59", features = ["rc"] }
serde_derive = "^1.0.59"
serde_json = "1.0"
serde-aux = "0.6.1"
wasm-bindgen = { version = "=0.2.62", features = ["serde-serialize"] }
chrono = { version = "0.4", features = ["serde"] }
regex = "1"
maplit = "1.0.2"
flatbuffers = "2.0.0"
derivative = "2.1.1"
walkdir = "2.2.9"
log = "=0.4.8"
lsp-types = { version = "0.92", optional = true }
pulldown-cmark = { version = "0.8", default-features = false }
structopt = "0.3"
libflate = "=1.2.0"
once_cell = "1"
csv = "=1.1.0"
pad = "0.1.6"
tempfile = "=3.1.0"

[dev-dependencies]
env_logger = "0.9"
colored = "1.8"
pretty_assertions = "1"
criterion = "0.3.3"
expect-test = "1.1.0"

[[bench]]
name = "scanner"
harness = false
```
# 执行build命令
```
make libflux
```
# 生成对应的二进制flux
``` 
make
```
# 配置对应flux可执行文件和libflux.so配置到/usr目录下
```
配置export LD_LIBRARY_PATH=/usr/local/lib
cp flux /usr/local/bin
cp libflux.so /usr/local/lib/
```
- 可能报错1：
[yzw@kubernetes-master-1 flux]$ sudo go build ./cmd/flux/
pkg-config --cflags -- flux
Package flux was not found in the pkg-config search path.
Perhaps you should add the directory containing `flux.pc'
to the PKG_CONFIG_PATH environment variable
Package 'flux', required by 'virtual:world', not found
pkg-config: exit status 1
按照如下步骤解决
``` 
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"
查看当前pkg-config
[yzw@kubernetes-master-1 kapacitor]$ pkg-config --variable pc_path pkg-config
/usr/lib64/pkgconfig:/usr/share/pkgconfig```
# 手动创建flux.pc
sudo vim /usrlib/pkgconfig/flux.pc
prefix=/usr/local/
exec_prefix=${prefix}
libdir=${prefix}/lib
includedir=${prefix}/include

Name: flux
Description: A description of flux
Version: 0.171.0
Libs: -L${libdir} -lflux
Cflags: -I${includedir}

:wq保存退出
```
- 可能报错2：
```
找不到flux.h头文件
cd ~/flux/
find -name flux.h
export CGO_CFLAGS="-I/path/flux/libflux/include"
export CGO_LDFLAGS="-L/usr/local/lib/libflux.so"
export LD_LIBRARY_PATH="/usr/local/lib/"
```

__编译__
进入kapacitor目录
依次执行
```
cd kapacitor
go build ./cmd/kapacitor/main.go
mv main kapacitor
go build ./cmd/kapacitord/main.go
mv main kapacitord
go build ./tick/cmd/tickfmt/main.go
mv main tickfmt
```

__测试__
./kapacirtord &
[yzw@kubernetes-master-1 kapacitor]$ ./kapacitord  | head -n 20

2023/08/04 16:10:34 No configuration provided, using default settings
'##:::'##::::'###::::'########:::::'###:::::'######::'####:'########::'#######::'########::
 ##::'##::::'## ##::: ##.... ##:::'## ##:::'##... ##:. ##::... ##..::'##.... ##: ##.... ##:
 ##:'##::::'##:. ##:: ##:::: ##::'##:. ##:: ##:::..::: ##::::: ##:::: ##:::: ##: ##:::: ##:
 #####::::'##:::. ##: ########::'##:::. ##: ##:::::::: ##::::: ##:::: ##:::: ##: ########::
 ##. ##::: #########: ##.....::: #########: ##:::::::: ##::::: ##:::: ##:::: ##: ##.. ##:::
 ##:. ##:: ##.... ##: ##:::::::: ##.... ##: ##::: ##:: ##::::: ##:::: ##:::: ##: ##::. ##::
 ##::. ##: ##:::: ##: ##:::::::: ##:::: ##:. ######::'####:::: ##::::. #######:: ##:::. ##:
..::::..::..:::::..::..:::::::::..:::::..:::......:::....:::::..::::::.......:::..:::::..::

ts=2023-08-04T16:10:34.384+08:00 lvl=info msg="kapacitor starting" service=run version= branch=unknown commit=unknown
ts=2023-08-04T16:10:34.384+08:00 lvl=info msg="go version" service=run version=go1.19.7
ts=2023-08-04T16:10:34.418+08:00 lvl=info msg="listing Kapacitor hostname" source=srv hostname=localhost
ts=2023-08-04T16:10:34.418+08:00 lvl=info msg="listing ClusterID and ServerID" source=srv cluster_id=3c588d2e-8e42-493b-8f35-8080e8fb6c53 server_id=b37b6d2b-9cdb-43f6-8087-309104bb848b
ts=2023-08-04T16:10:34.418+08:00 lvl=info msg="opened task master" service=kapacitor task_master=main

__打rpm包以及制作镜像__
- 主要关注kapacitor/Dockerfile_build_ubuntu64、build.py、build.sh以及scripts文件夹下的post-install.sh文件
- 源基础镜像来自https://quay.io/repository/influxdb/cross-builder?tab=tags
- 参考https://quay.io/repository/influxdb/cross-builder/manifest/sha256:0c8131d50d527501580ae1e1c22f80f7645dd29bc444b34f6346ed7392b97b1c制作
- 根据对应的镜像可知制作该基础镜像的步骤，成功构建的龙芯cross-build镜像和源镜像区别：未配置mingw64 musl osxcross gotestsum
（没有影响）
- 安装protoc-python 
  protobuf需要整体打包为protobuf-3.  .tar.gz  并且在打包前需要构建与镜像同版本的protoc，必须是动态编译 默认
  ./autogen.sh 
  ./configure
  make 
  make install得到so库文件
  打包到git后在kapacitor文件夹的Docker文件中进行修改
    ```
    diff --git a/Dockerfile_build_ubuntu64 b/Dockerfile_build_ubuntu64
    index 35eba67..30868a6 100644
    --- a/Dockerfile_build_ubuntu64
    +++ b/Dockerfile_build_ubuntu64
    @@ -1,9 +1,10 @@
    -FROM quay.io/influxdb/cross-builder:go1.19.4-cb1343dd74ecba8ec07fe810195530a0b9055aa9
    -
    +#FROM quay.io/influxdb/cross-builder:go1.19.4-cb1343dd74ecba8ec07fe810195530a0b9055aa9
    +FROM cr.loongnix.cn/influxdb/cross-builder:go1.19.7-main
    +#FROM cr.loongnix.cn/library/golang
     # This dockerfile is capabable of performing all
     # build/test/package/deploy actions needed for Kapacitor.
     
    -MAINTAINER support@influxdb.com
    +MAINTAINER yangzewei@loongson.cn
     
     RUN apt-get -qq update && apt-get -qq install -y \
         software-properties-common \
    @@ -24,25 +25,56 @@ RUN apt-get -qq update && apt-get -qq install -y \
         libtool
     
     RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
    -
    +#RUN apt-get install golang-1.19
     RUN gem install fpm
    +ENV GOPROXY="https://goproxy.cn,direct"
    +ENV GOPATH /go
    +ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
    +#RUN go install github.com/influxdata/pkg-config@latest
    +#RUN go install github.com/influxdata/flux@v0.171.0
     
     # Install protobuf3 python library
     # NOTE: PROTO_VERSION env var is inherited from the cross-builder image.
    -RUN wget -q https://github.com/google/protobuf/releases/download/v${PROTO_VERSION}/protobuf-python-${PROTO_VERSION}.tar.gz \
    -    && tar -xf protobuf-python-${PROTO_VERSION}.tar.gz \
    -    && cd protobuf-${PROTO_VERSION}/python \
    +# PROTOBUF_VERSION 3.17.3
    +# RUN wget -q https://github.com/google/protobuf/releases/download/v${PROTO_VERSION}/protobuf-python-${PROTO_VERSION}.tar.gz \
    +ENV http_proxy=http://10.130.0.20:7890
    +ENV https_proxy=http://10.130.0.20:7890
    +
    +RUN wget -q https://github.com/yzewei/protobuf/releases/download/v3.17.3/protobuf-3.17.3.tar.gz \
    +    && tar -xf protobuf-3.17.3.tar.gz \
    +    && cd protobuf/python \
         && python2 setup.py install \
         && python3 setup.py install \
         && cd ../../ \
    -    && rm -rf /protobuf-${PROTO_VERSION} protobuf-python-${PROTO_VERSION}.tar.gz
    +    && rm -rf /protobuf protobuf-3.17.3.tar.gz
    +
    +ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig/"
    +ENV CGO_CFLAGS="-I/go/pkg/mod/github.com/influxdata/flux@v0.171.0/libflux/include"
    +ENV CGO_LDFLAGS="-L/usr/local/lib/libflux.so"
    +ENV LD_LIBRARY_PATH="/usr/local/lib/"
    +RUN which -a pkg-config
    +RUN unset http_proxy
    +RUN unset https_proxy
     
     ENV PROJECT_DIR /kapacitor
     RUN mkdir -p $PROJECT_DIR
     WORKDIR $PROJECT_DIR
     
    +
     # Configure local git
     RUN git config --global user.email "support@influxdb.com"
     RUN git config --global user.Name "Docker Builder"
    -
    +ENV PATH=/usr/lib/go-1.19/bin:$PATH
     ENTRYPOINT [ "/kapacitor/build.py" ]
    ```
其中应该注意到go的路径设置以kapacitor构建时机器的go路径为准

- 接下来修改build.py、build.sh相关内容，由于需要添加依赖的so库、在post-install.sh文件中配置识别so库的环境变量

build.py修改如下：
    ```
    diff --git a/build.py b/build.py
    index 50019d1..7ff3a39 100755
    --- a/build.py
    +++ b/build.py
    @@ -26,6 +26,10 @@ INSTALL_ROOT_DIR = "/usr/bin"
     LOG_DIR = "/var/log/kapacitor"
     DATA_DIR = "/var/lib/kapacitor"
     SCRIPT_DIR = "/usr/lib/kapacitor/scripts"
    +LIB_DIR="/usr/local/lib"
    +LIB64_DIR="/usr/local/lib64"
    +DEF_LIB_DIR="/usr/lib"
    +FLUX_DIR="/usr/local/bin"
     
     INIT_SCRIPT = "scripts/init.sh"
     SYSTEMD_SCRIPT = "scripts/kapacitor.service"
    @@ -78,6 +82,10 @@ fpm_common_args = "-f -s dir --log error \
                              LOG_DIR[1:],
                              DATA_DIR[1:],
                              SCRIPT_DIR[1:],
    +                         LIB_DIR[1:],
    +                         LIB64_DIR[1:],
    +                         DEF_LIB_DIR[1:],
    +                         os.path.dirname(DEF_LIB_DIR[1:]),
                              os.path.dirname(SCRIPT_DIR[1:]),
                              os.path.dirname(DEFAULT_CONFIG),
                         ]),
    @@ -93,7 +101,7 @@ targets = {
     
     supported_builds = {
         'darwin': [ "amd64" ],
    -    'linux': [ "arm64", "amd64" ],
    +    'linux': [ "arm64", "amd64","loongarch64" ],
         'windows': [ "amd64" ]
     }
     
    @@ -132,6 +140,10 @@ def create_package_fs(build_root):
         os.makedirs(os.path.join(build_root, LOG_DIR[1:]))
         os.makedirs(os.path.join(build_root, DATA_DIR[1:]))
         os.makedirs(os.path.join(build_root, SCRIPT_DIR[1:]))
    +    os.makedirs(os.path.join(build_root, FLUX_DIR[1:]))
    +    #os.makedirs(os.path.join(build_root, DEF_LIB_DIR[1:]))
    +    os.makedirs(os.path.join(build_root, LIB_DIR[1:]))
    +    os.makedirs(os.path.join(build_root, LIB64_DIR[1:]))
         os.makedirs(os.path.join(build_root, os.path.dirname(DEFAULT_CONFIG)))
         os.makedirs(os.path.join(build_root, os.path.dirname(LOGROTATE_CONFIG)))
         os.makedirs(os.path.join(build_root, os.path.dirname(BASH_COMPLETION_SH)))
    @@ -377,6 +389,8 @@ def get_system_arch():
             arch = "amd64"
         elif arch == "aarch64":
             arch = "arm64"
    +    elif arch == "loongarch64":
    +        arch = "loongarch64"
         elif 'arm' in arch:
             # Prevent uname from reporting full ARM arch (eg 'armv7l')
             arch = "arm64"
    @@ -488,70 +502,70 @@ def build(version=None,
             logging.info("Using build tags: {}".format(','.join(tags)))
     
         logging.info("Sending build output to: {}".format(outdir))
    -    if not os.path.exists(outdir):
    -        os.makedirs(outdir)
    -    elif clean and outdir != '/' and outdir != ".":
    -        logging.info("Cleaning build directory '{}' before building.".format(outdir))
    -        shutil.rmtree(outdir)
    -        os.makedirs(outdir)
    +    #if not os.path.exists(outdir):
    +    #    os.makedirs(outdir)
    +    #elif clean and outdir != '/' and outdir != ".":
    +    #    logging.info("Cleaning build directory '{}' before building.".format(outdir))
    +    #    shutil.rmtree(outdir)
    +    #    os.makedirs(outdir)
     
         logging.info("Using version '{}' for build.".format(version))
     
    -    tmp_build_dir = create_temp_dir()
    -    for target, path in targets.items():
    -        logging.info("Building target: {}".format(target))
    -        build_command = ". /root/.cargo/env && "
    +    #tmp_build_dir = create_temp_dir()
    +    #for target, path in targets.items():
    +    #logging.info("Building target: {}".format(target))
    +    #    build_command = ". /root/.cargo/env && "
     
    -        build_command += "CGO_ENABLED=1 "
    +    #    build_command += "CGO_ENABLED=1 "
     
             # Handle variations in architecture output
    -        fullarch = arch
    -        if  arch == "aarch64" or arch == "arm64":
    -            arch = "arm64"
    -
    -        if platform == "linux":
    -            if arch == "amd64":
    -                tags += ["netgo", "osusergo", "static_build"]
    -            if arch == "arm64":
    -                cc = "/musl/aarch64/bin/musl-gcc"
    -                tags += ["netgo", "osusergo", "static_build", "noasm"]
    -        elif platform == "darwin" and arch == "amd64":
    -            cc = "x86_64-apple-darwin18-clang"
    -            tags += [ "netgo", "osusergo"]
    -        elif  platform == "windows" and arch == "amd64":
    -            cc = "x86_64-w64-mingw32-gcc"
    -        build_command += "CC={} GOOS={} GOARCH={} ".format(cc, platform, arch)
    -
    -        if "arm" in fullarch:
    -            if  fullarch != "arm64":
    -                logging.error("Invalid ARM architecture specified: {} only arm64 is supported".format(arch))
    -                return False
    -        if platform == 'windows':
    -            target = target + '.exe'
    -            build_command += "go build -buildmode=exe -o {} ".format(os.path.join(outdir, target))
    -        else:
    -            build_command += "go build -o {} ".format(os.path.join(outdir, target))
    -        if race:
    -            build_command += "-race "
    -        if len(tags) > 0:
    -            build_command += "-tags \"{}\" ".format(' '.join(tags))
    +    #    fullarch = arch
    +    #    if  arch == "aarch64" or arch == "arm64":
    +    #        arch = "arm64"
    +    #    elif arch == "loongarch64":
    +    #        arch = "loong64" 
    +    #    if platform == "linux":
    +    #        if arch == "amd64":
    +    #            tags += ["netgo", "osusergo", "static_build"]
    +    #        if arch == "arm64":
    +    #            cc = "/musl/aarch64/bin/musl-gcc"
    +    #            tags += ["netgo", "osusergo", "static_build", "noasm"]
    +    #    elif platform == "darwin" and arch == "amd64":
    +    #        cc = "x86_64-apple-darwin18-clang"
    +    #        tags += [ "netgo", "osusergo"]
    +    #    elif  platform == "windows" and arch == "amd64":
    +    #        cc = "x86_64-w64-mingw32-gcc"
    +    #    build_command += "CC={} GOOS={} GOARCH={} ".format(cc, platform, arch)
    +#
    +    #    if "arm" in fullarch:
    +    #        if  fullarch != "arm64":
    +    #            logging.error("Invalid ARM architecture specified: {} only arm64 is supported".format(arch))
    +    #           return False
    +    #   if platform == 'windows':
    +    #        target = target + '.exe'
    +    #       build_command += "go build -buildmode=exe -o {} ".format(os.path.join(outdir, target))
    +    #    else:
    +    #        build_command += "go build -o {} ".format(os.path.join(outdir, target))
    +    #    if race:
    +    #        build_command += "-race "
    +    #    if len(tags) > 0:
    +    #        build_command += "-tags \"{}\" ".format(' '.join(tags))
     
                 # Starting with Go 1.5, the linker flag arguments changed to 'name=value' from 'name value'
    -        build_command += "-ldflags=\""
    -        if static:
    -            build_command +="-s "
    -        if platform == "linux":
    -            build_command += r'-extldflags \"-fno-PIC -Wl,-z,stack-size=8388608\"  '
    -        build_command += '-X main.version={} -X main.branch={} -X main.commit={} -X main.platform=OSS" '.format(version,
    -                                                                                                            get_current_branch(),
    -                                                                                                            get_current_commit())
    -        if static:
    -            build_command += "-a -installsuffix cgo "
    -        build_command += path
    -        start_time = datetime.utcnow()
    -        run(build_command, shell=True)
    -        end_time = datetime.utcnow()
    -        logging.info("Time taken: {}s".format((end_time - start_time).total_seconds()))
    +    #   build_command += "-ldflags=\""
    +    #   if static:
    +    #        build_command +="-s "
    +    #    if platform == "linux":
    +    #        build_command += r'-extldflags \"-fno-PIC -Wl,-z,stack-size=8388608\"  '
    +    #    build_command += '-X main.version={} -X main.branch={} -X main.commit={} -X main.platform=OSS" '.format(version,
    +    #get_current_branch(),get_current_commit())
    +    #    if static:
    +    #        build_command += "-a -installsuffix cgo "
    +    #    build_command += path
    +    start_time = datetime.utcnow()
    +    #    run(build_command, shell=True)
    +    end_time = datetime.utcnow()
    +    logging.info("Time taken: {}s".format((end_time - start_time).total_seconds()))
         return True
     
     def generate_sha256_from_file(path):
    @@ -583,23 +597,26 @@ def package(build_output, pkg_name, version, nightly=False, iteration=1, static=
         outfiles = []
         tmp_build_dir = create_temp_dir()
         logging.debug("Packaging for build output: {}".format(build_output))
         logging.info("Using temporary directory: {}".format(tmp_build_dir))
         try:
             for platform in build_output:
                 # Create top-level folder displaying which platform (linux, etc)
                 os.makedirs(os.path.join(tmp_build_dir, platform))
                 for arch in build_output[platform]:
                     logging.info("Creating packages for {}/{}".format(platform, arch))
                     # Create second-level directory displaying the architecture (amd64, etc)
                     current_location = build_output[platform][arch]
                     # Create directory tree to mimic file system of package
                     build_root = os.path.join(tmp_build_dir,
                                               platform,
                                               arch,
                                               '{}-{}-{}'.format(PACKAGE_NAME, version, iteration))
                     os.makedirs(build_root)
                     # Copy packaging scripts to build directory
                     if platform == "windows" or static or "static_" in arch:
                         # For windows and static builds, just copy
    @@ -609,7 +626,7 @@ def package(build_output, pkg_name, version, nightly=False, iteration=1, static=
                     else:
                         create_package_fs(build_root)
                         package_scripts(build_root)
    -
    +                
                     for binary in targets:
                         # Copy newly-built binaries to packaging directory
                         if platform == 'windows':
    @@ -624,7 +641,26 @@ def package(build_output, pkg_name, version, nightly=False, iteration=1, static=
                             fr = os.path.join(current_location, binary)
                             # Where the binary should go in the package filesystem
                             to = os.path.join(build_root, INSTALL_ROOT_DIR[1:], binary)
    +                        logging.info("fr={} to= {}".format(fr,to))
                         shutil.copy(fr, to)
    +                #将依赖软件fluxc的二进制复制
    +                #fr = os.path.join("/",FLUX_DIR[1:], "fluxc")
    +                #to = os.path.join(build_root, FLUX_DIR[1:], "fluxc")
    +                #logging.info("fr={},to= {}".format(fr,to))
    +                #shutil.copy(fr, to)
    +                #将依赖库文件libflux.so复制
    +                fr = os.path.join("/",LIB_DIR[1:], "libflux.so")
    +                to = os.path.join(build_root, DEF_LIB_DIR[1:], "libflux.so")
    +                #to = os.path.join(build_root, LIB_DIR[1:], "libflux.so")
    +                logging.info("fr={},to= {}".format(fr,to))
    +                shutil.copy(fr, to)
    +                
    +                to = os.path.join(build_root, LIB_DIR[1:], "libflux.so")
    +                logging.info("fr={},to= {}".format(fr,to))
    +                shutil.copy(fr, to)
    +                
    +                to = os.path.join(build_root, LIB64_DIR[1:], "libflux.so")
    +                shutil.copy(fr, to)
     
                     for package_type in supported_packages[platform]:
                         # Package the directory structure for each package type for the platform
    @@ -672,6 +708,7 @@ def package(build_output, pkg_name, version, nightly=False, iteration=1, static=
                                                                 platform,
                                                                 package_arch)
                             current_location = os.path.join(os.getcwd(), current_location)
                             if package_type == 'tar':
                                 tar_command = "cd {} && tar -cvzf {}.tar.gz --owner=root --group=root ./*".format(package_build_root, name)
                                 run(tar_command, shell=True)
    @@ -697,7 +734,8 @@ def package(build_output, pkg_name, version, nightly=False, iteration=1, static=
                                 package_build_root,
                                 current_location)
                             if package_type == "rpm":
    -                            fpm_command += "--depends coreutils --depends shadow-utils --rpm-posttrans {}".format(POSTINST_SCRIPT)
    +                            fpm_command += " --depends coreutils --depends shadow-utils --rpm-posttrans {}".format(POSTINST_SCRIPT)
                             out = run(fpm_command, shell=True)
                             matches = re.search(':path=>"(.*)"', out)
                             outfile = None
    @@ -720,7 +758,7 @@ def package(build_output, pkg_name, version, nightly=False, iteration=1, static=
     
     def main(args):
         global PACKAGE_NAME
         if args.release and args.nightly:
             logging.error("Cannot be both a nightly and a release.")
             return 1
    @@ -785,13 +823,14 @@ def main(args):
     
         for platform in platforms:
             build_output.update( { platform : {} } )
             archs = []
             if args.arch == "all":
                 single_build = False
                 archs = supported_builds.get(platform)
             else:
                 archs = [args.arch]
             for arch in archs:
                 od = args.outdir
                 if not single_build:
    @@ -807,12 +846,15 @@ def main(args):
                              static=args.static):
                     return 1
                 build_output.get(platform).update( { arch : od } )
    -
         # Build packages
         if args.package:
             if not check_path_for("fpm"):
                 logging.error("FPM ruby gem required for packaging. Stopping.")
                 return 1
             packages = package(build_output,
                                args.name,
                                args.version,
    @@ -820,7 +862,7 @@ def main(args):
                                iteration=args.iteration,
                                static=args.static,
                                release=args.release)
             if args.package_udfs:
                 packages += package_udfs(args.version, args.outdir)
     
    @@ -869,7 +911,7 @@ if __name__ == '__main__':
         log_format = '[%(levelname)s] %(funcName)s: %(message)s'
         logging.basicConfig(level=LOG_LEVEL,
                             format=log_format)
         parser = argparse.ArgumentParser(description='InfluxDB build and packaging script.')
         parser.add_argument('--verbose','-v','--debug',
                             action='store_true',
    @@ -885,15 +927,17 @@ if __name__ == '__main__':
                             type=str,
                             help='Name to use for package name (when package is specified)')
         parser.add_argument('--arch',
    -                        metavar='<amd64|arm64|all>',
    +                        metavar='<amd64|arm64|loongarch64|all>',
                             type=str,
                             default=get_system_arch(),
                             help='Target architecture for build output')
         parser.add_argument('--platform',
                             metavar='<linux|darwin|windows|all>',
                             type=str,
                             default=get_system_platform(),
                             help='Target platform for build output')
         parser.add_argument('--branch',
                             metavar='<branch>',
                             type=str,
    @@ -988,4 +1032,5 @@ if __name__ == '__main__':
                             help='Timeout for tests before failing')
         args = parser.parse_args()
         print_banner()
    +    #package("",pkg_name="kapacitor-1.6.6", version="1.6.6")
         sys.exit(main(args))
    
    
    ```
build.sh修改如下:
    ```
    diff --git a/build.sh b/build.sh
    index bb5e012..66b6f8a 100755
    --- a/build.sh
    +++ b/build.sh
    @@ -1,7 +1,7 @@
     #!/bin/bash
     # Run the build utility via Docker
     
    -set -e
    +set -eux
     
     # Make sure our working dir is the dir of the script
     DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
    @@ -22,7 +22,9 @@ echo "Running build.py"
     docker run \
         --rm \
         -v "$DIR:/kapacitor" \
    -    -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    -    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    -    $imagename \
    -    "$@"
    +     $imagename \
    +     "$@"
    +    #-e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    +    #-e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    +    # $imagename \
    +    # "$@"
    
    ```
scripts/post-install.sh修改如下：
    ```
    diff --git a/scripts/post-install.sh b/scripts/post-install.sh
    index 6d0bd15..a2228d4 100644
    --- a/scripts/post-install.sh
    +++ b/scripts/post-install.sh
    @@ -4,6 +4,9 @@ BIN_DIR=/usr/bin
     DATA_DIR=/var/lib/kapacitor
     LOG_DIR=/var/log/kapacitor
     SCRIPT_DIR=/usr/lib/kapacitor/scripts
    +echo "export LD_LIBRARY_PATH=/usr/lib" >> /etc/profile
    +source /etc/profile
    +
     
     function install_init {
         cp -f $SCRIPT_DIR/init.sh /etc/init.d/kapacitor
    ```
在进行修改后，执行build的shell脚本```./build.sh --package``` 进行自动打包及镜像构建，需等待较长时间

## 测试
更换主机，部署打包好的deb包和rpm包
``` sudo rpm -ivh --force kapacitor-1.6.6~7989708-0.loongarch64.rpm```
    ``` 
    [wwj@node01 tmp]$ kapacitord
    
    '##:::'##::::'###::::'########:::::'###:::::'######::'####:'########::'#######::'########::
     ##::'##::::'## ##::: ##.... ##:::'## ##:::'##... ##:. ##::... ##..::'##.... ##: ##.... ##:
     ##:'##::::'##:. ##:: ##:::: ##::'##:. ##:: ##:::..::: ##::::: ##:::: ##:::: ##: ##:::: ##:
     #####::::'##:::. ##: ########::'##:::. ##: ##:::::::: ##::::: ##:::: ##:::: ##: ########::
     ##. ##::: #########: ##.....::: #########: ##:::::::: ##::::: ##:::: ##:::: ##: ##.. ##:::
     ##:. ##:: ##.... ##: ##:::::::: ##.... ##: ##::: ##:: ##::::: ##:::: ##:::: ##: ##::. ##::
     ##::. ##: ##:::: ##: ##:::::::: ##:::: ##:. ######::'####:::: ##::::. #######:: ##:::. ##:
    ..::::..::..:::::..::..:::::::::..:::::..:::......:::....:::::..::::::.......:::..:::::..::
    
    2023/08/08 14:37:16 Using configuration at: /etc/kapacitor/kapacitor.conf
    ```

``` sudo dpkg -i  kapacitor_1.6.6~7989708-0_loongarch64.deb```
    ```
    [wwj@node01 tmp]$ kapacitord
    
    '##:::'##::::'###::::'########:::::'###:::::'######::'####:'########::'#######::'########::
     ##::'##::::'## ##::: ##.... ##:::'## ##:::'##... ##:. ##::... ##..::'##.... ##: ##.... ##:
     ##:'##::::'##:. ##:: ##:::: ##::'##:. ##:: ##:::..::: ##::::: ##:::: ##:::: ##: ##:::: ##:
     #####::::'##:::. ##: ########::'##:::. ##: ##:::::::: ##::::: ##:::: ##:::: ##: ########::
     ##. ##::: #########: ##.....::: #########: ##:::::::: ##::::: ##:::: ##:::: ##: ##.. ##:::
     ##:. ##:: ##.... ##: ##:::::::: ##.... ##: ##::: ##:: ##::::: ##:::: ##:::: ##: ##::. ##::
     ##::. ##: ##:::: ##: ##:::::::: ##:::: ##:. ######::'####:::: ##::::. #######:: ##:::. ##:
    ..::::..::..:::::..::..:::::::::..:::::..:::......:::....:::::..::::::.......:::..:::::..::
    
    2023/08/08 14:27:28 Using configuration at: /etc/kapacitor/kapacitor.conf

    ``` 

## 附录
剩余go.mod和go.sum部分变更如下：
    ```
    diff --git a/go.mod b/go.mod
    index e1a6e79..f5ded55 100644
    --- a/go.mod
    +++ b/go.mod
    @@ -21,6 +21,7 @@ require (
            github.com/google/go-cmp v0.5.7
            github.com/google/uuid v1.3.0
            github.com/gorhill/cronexpr v0.0.0-20180427100037-88b0669f7d75
    +       github.com/h2non/gock v1.2.0
            github.com/influxdata/cron v0.0.0-20201006132531-4bb0a200dcbe
            github.com/influxdata/flux v0.171.0
            github.com/influxdata/httprouter v1.3.1-0.20191122104820-ee83e2772f69
    @@ -45,12 +46,12 @@ require (
            github.com/serenize/snaker v0.0.0-20161123064335-543781d2b79b
            github.com/shurcooL/markdownfmt v0.0.0-20170214213350-10aae0a270ab
            github.com/spaolacci/murmur3 v0.0.0-20180118202830-f09979ecbc72
    -       github.com/stretchr/testify v1.7.0
    +       github.com/stretchr/testify v1.8.1
            github.com/uber/jaeger-client-go v2.28.0+incompatible
            github.com/urfave/cli/v2 v2.3.0
            github.com/xdg/scram v0.0.0-20180814205039-7eeb5667e42c
            github.com/zeebo/mwc v0.0.4
    -       go.etcd.io/bbolt v1.3.5
    +       go.etcd.io/bbolt v1.3.7
            go.uber.org/zap v1.16.0
            golang.org/x/crypto v0.0.0-20220214200702-86341886e292
            golang.org/x/tools v0.1.11-0.20220513221640-090b14e8501f
    @@ -143,7 +144,6 @@ require (
            github.com/googleapis/gax-go/v2 v2.0.5 // indirect
            github.com/googleapis/gnostic v0.4.1 // indirect
            github.com/gophercloud/gophercloud v0.17.0 // indirect
    -       github.com/h2non/gock v1.2.0 // indirect
            github.com/h2non/parth v0.0.0-20190131123155-b4df798d6542 // indirect
            github.com/hashicorp/consul/api v1.8.1 // indirect
            github.com/hashicorp/errwrap v1.0.0 // indirect
    @@ -232,7 +232,7 @@ require (
            golang.org/x/net v0.0.0-20220520000938-2e3eb7b945c2 // indirect
            golang.org/x/oauth2 v0.0.0-20210514164344-f6687ab2804c // indirect
            golang.org/x/sync v0.0.0-20210220032951-036812b2e83c // indirect
    -       golang.org/x/sys v0.0.0-20211216021012-1d35b9e2eb4e // indirect
    +       golang.org/x/sys v0.10.0 // indirect
            golang.org/x/term v0.0.0-20210927222741-03fcf44c2211 // indirect
            golang.org/x/text v0.3.7 // indirect
            golang.org/x/time v0.0.0-20210220033141-f8bda1e9f3ba // indirect
    diff --git a/go.sum b/go.sum
    index eb605ef..281944e 100644
    --- a/go.sum
    +++ b/go.sum
    @@ -1038,6 +1038,7 @@ github.com/nats-io/nkeys v0.1.3/go.mod h1:xpnFELMwJABBLVhffcfd1MZx6VsNRFpEugbxzi
     github.com/nats-io/nuid v1.0.0/go.mod h1:19wcPz3Ph3q0Jbyiqsd0kePYG7A95tJPxeL+1OSON2c=
     github.com/nats-io/nuid v1.0.1 h1:5iA8DT8V7q8WK2EScv2padNa/rTESc1KdnPw4TC2paw=
     github.com/nats-io/nuid v1.0.1/go.mod h1:19wcPz3Ph3q0Jbyiqsd0kePYG7A95tJPxeL+1OSON2c=
    +github.com/nbio/st v0.0.0-20140626010706-e9e8d9816f32 h1:W6apQkHrMkS0Muv8G/TipAy/FJl/rCYT0+EuS8+Z0z4=
     github.com/nbio/st v0.0.0-20140626010706-e9e8d9816f32/go.mod h1:9wM+0iRr9ahx58uYLpLIr5fm8diHn0JbqRycJi6w0Ms=
     github.com/niemeyer/pretty v0.0.0-20200227124842-a10e7caefd8e/go.mod h1:zD1mROLANZcx1PVRCS0qkT7pwLkGfwJo4zjcN/Tysno=
     github.com/nxadm/tail v1.4.4 h1:DQuhQpB1tVlglWS2hLQ5OV6B5r8aGxSrPc5Qo6uTN78=
    @@ -1261,8 +1262,10 @@ github.com/streadway/amqp v0.0.0-20190827072141-edfb9018d271/go.mod h1:AZpEONHx3
     github.com/streadway/handy v0.0.0-20190108123426-d5acb3125c2a/go.mod h1:qNTQ5P5JnDBl6z3cMAg/SywNDC5ABu5ApDIw6lUbRmI=
     github.com/stretchr/objx v0.1.0/go.mod h1:HFkY916IF+rwdDfMAkV7OtwuqBVzrE8GR6GFx+wExME=
     github.com/stretchr/objx v0.1.1/go.mod h1:HFkY916IF+rwdDfMAkV7OtwuqBVzrE8GR6GFx+wExME=
    -github.com/stretchr/objx v0.2.0 h1:Hbg2NidpLE8veEBkEZTL3CvlkUIVzuU9jDplZO54c48=
     github.com/stretchr/objx v0.2.0/go.mod h1:qt09Ya8vawLte6SNmTgCsAVtYtaKzEcn8ATUoHMkEqE=
    +github.com/stretchr/objx v0.4.0/go.mod h1:YvHI0jy2hoMjB+UWwv71VJQ9isScKT/TqJzVSSt89Yw=
    +github.com/stretchr/objx v0.5.0 h1:1zr/of2m5FGMsad5YfcqgdqdWrIhu+EBEJRhR1U7z/c=
    +github.com/stretchr/objx v0.5.0/go.mod h1:Yh+to48EsGEfYuaHDzXPcE3xhTkx73EhmCGUpEOglKo=
     github.com/stretchr/testify v1.2.0/go.mod h1:a8OnRcib4nhh0OaRAV+Yts87kKdq0PP7pXfy6kDkUVs=
     github.com/stretchr/testify v1.2.1/go.mod h1:a8OnRcib4nhh0OaRAV+Yts87kKdq0PP7pXfy6kDkUVs=
     github.com/stretchr/testify v1.2.2/go.mod h1:a8OnRcib4nhh0OaRAV+Yts87kKdq0PP7pXfy6kDkUVs=
    @@ -1270,8 +1273,11 @@ github.com/stretchr/testify v1.3.0/go.mod h1:M5WIy9Dh21IEIfnGCwXGc5bZfKNJtfHm1UV
     github.com/stretchr/testify v1.4.0/go.mod h1:j7eGeouHqKxXV5pUuKE4zz7dFj8WfuZ+81PSLYec5m4=
     github.com/stretchr/testify v1.5.1/go.mod h1:5W2xD1RspED5o8YsWQXVCued0rvSQ+mT+I5cxcmMvtA=
     github.com/stretchr/testify v1.6.1/go.mod h1:6Fq8oRcR53rry900zMqJjRRixrwX3KX962/h/Wwjteg=
    -github.com/stretchr/testify v1.7.0 h1:nwc3DEeHmmLAfoZucVR881uASk0Mfjw8xYJ99tb5CcY=
     github.com/stretchr/testify v1.7.0/go.mod h1:6Fq8oRcR53rry900zMqJjRRixrwX3KX962/h/Wwjteg=
    +github.com/stretchr/testify v1.7.1/go.mod h1:6Fq8oRcR53rry900zMqJjRRixrwX3KX962/h/Wwjteg=
    +github.com/stretchr/testify v1.8.0/go.mod h1:yNjHg4UonilssWZ8iaSj1OCr/vHnekPRkoO+kdMU+MU=
    +github.com/stretchr/testify v1.8.1 h1:w7B6lhMri9wdJUVmEZPGGhZzrYTPvgJArz7wNPgYKsk=
    +github.com/stretchr/testify v1.8.1/go.mod h1:w2LPCIKwWwSfY2zedu0+kehJoqGctiVI29o6fzry7u4=
     github.com/subosito/gotenv v1.2.0 h1:Slr1R9HxAlEKefgq5jn9U+DnETlIUa6HfgEzj0g5d7s=
     github.com/subosito/gotenv v1.2.0/go.mod h1:N0PQaV/YGNqwC0u51sEeR/aUtSLEXKX9iv69rRypqCw=
     github.com/tcnksm/go-input v0.0.0-20180404061846-548a7d7a8ee8/go.mod h1:IlWNj9v/13q7xFbaK4mbyzMNwrZLaWSHx/aibKIZuIg=
    @@ -1348,8 +1354,9 @@ github.com/zeebo/mwc v0.0.4/go.mod h1:qNHfgp/ZCpQNcJHwKcO5EP3VgaBrW6DPohsK4Qfyxx
     github.com/zeebo/xxh3 v0.13.0/go.mod h1:AQY73TOrhF3jNsdiM9zZOb8MThrYbZONHj7ryDBaLpg=
     go.etcd.io/bbolt v1.3.2/go.mod h1:IbVyRI1SCnLcuJnV2u8VeU0CEYM7e686BmAb1XKL+uU=
     go.etcd.io/bbolt v1.3.3/go.mod h1:IbVyRI1SCnLcuJnV2u8VeU0CEYM7e686BmAb1XKL+uU=
    -go.etcd.io/bbolt v1.3.5 h1:XAzx9gjCb0Rxj7EoqcClPD1d5ZBxZJk0jbuoPHenBt0=
     go.etcd.io/bbolt v1.3.5/go.mod h1:G5EMThwa9y8QZGBClrRx5EY+Yw9kAhnjy3bSjsnlVTQ=
    +go.etcd.io/bbolt v1.3.7 h1:j+zJOnnEjF/kyHlDDgGnVL/AIqIJPq8UoB2GSNfkUfQ=
    +go.etcd.io/bbolt v1.3.7/go.mod h1:N9Mkw9X8x5fupy0IKsmuqVtoGDyxsaDlbk4Rd05IAQw=
     go.etcd.io/etcd v0.0.0-20191023171146-3cf2f69b5738/go.mod h1:dnLIgRNXwCJa5e+c6mIZCrds/GIG4ncV9HhK5PX7jPg=
     go.mongodb.org/mongo-driver v1.0.3/go.mod h1:u7ryQJ+DOzQmeO7zB6MHyr8jkEQvC8vH7qLUO4lqsUM=
     go.mongodb.org/mongo-driver v1.1.1/go.mod h1:u7ryQJ+DOzQmeO7zB6MHyr8jkEQvC8vH7qLUO4lqsUM=
    @@ -1679,8 +1686,9 @@ golang.org/x/sys v0.0.0-20210616045830-e2b7044e8c71/go.mod h1:oPkhp1MJrh7nUepCBc
     golang.org/x/sys v0.0.0-20210630005230-0f9fa26af87c/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
     golang.org/x/sys v0.0.0-20211025201205-69cdffdb9359/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
     golang.org/x/sys v0.0.0-20211117180635-dee7805ff2e1/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
    -golang.org/x/sys v0.0.0-20211216021012-1d35b9e2eb4e h1:fLOSk5Q00efkSvAm+4xcoXD+RRmLmmulPn5I3Y9F2EM=
     golang.org/x/sys v0.0.0-20211216021012-1d35b9e2eb4e/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
    +golang.org/x/sys v0.10.0 h1:SqMFp9UcQJZa+pmYuAKjd9xq1f0j5rLcDIk0mj4qAsA=
    +golang.org/x/sys v0.10.0/go.mod h1:oPkhp1MJrh7nUepCBck5+mAzfO9JrbApNNgaTdGDITg=
     golang.org/x/term v0.0.0-20201117132131-f5c789dd3221/go.mod h1:Nr5EML6q2oocZ2LXRh80K7BxOlk5/8JxuGnuhpl+muw=
     golang.org/x/term v0.0.0-20201126162022-7de9c90e9dd1/go.mod h1:bj7SfCRtBDWHUb9snDiAeCFNEtKQo2Wmx5Cou7ajbmo=
     golang.org/x/term v0.0.0-20210927222741-03fcf44c2211 h1:JGgROgKl9N8DuW20oFS5gxc+lE67/N3FcwmBPMe7ArY=
    ```
