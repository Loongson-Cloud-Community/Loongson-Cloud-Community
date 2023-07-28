# tikv
## 构建指导   

### 1.环境准备
#### (1)构建环境      
这里使用server:8.4镜像作为构建环境    
#### (2)安装软件包
> yum install -y loongnix-release-epel && yum clean all && yum makecache   
> yum install -y scl-utils rpmdevtools gcc gcc-c++ protobuf-compiler  clang-libs clang-devel  perl cmake3 make && yum clean all   
#### (3)安装rust工具链
> export RUSTUP_DIST_SERVER=https://rust-lang.loongnix.cn    
> export RUSTUP_UPDATE_ROOT=https://rust-lang.loongnix.cn/rustup     
> curl --proto '=https' --tlsv1.2 -sSf https://rust-lang.loongnix.cn/rustup-init.sh | sh     
> rustup toolchain install nightly-2021-10-18       
> rustup default nightly-2021-10-18-loongarch64-unknown-linux-gnu    
#### (4)验证工具链是否安装成功   
> rustc 1.58.0-nightly   
> binary: rustc   
> commit-hash: unknown   
> commit-date: unknown   
> host: loongarch64-unknown-linux-gnu   
> release: 1.58.0-nightly   
> LLVM version: 13.0.1   

> cargo 1.57.0-nightly   
> release: 1.57.0   
> host: loongarch64-unknown-linux-gnu   
> libgit2: 1.3.0 (sys:0.13.23 vendored)   
> libcurl: 7.64.0 (sys:0.4.49+curl-7.79.1 system ssl:OpenSSL/1.1.1d)   
> os: Linux 20 (DaoXiangHu) [64-bit]   

####备注
若网络不好，则下载https://github.com/zhaixiaojuan/tikv/releases/Loongarch64-file.tar.gz, 使用Loongarch64-file/nightly-2021-10-18-loongarch64-unknown-linux-gnu, 并将其添加到PATH路径下,此时不再需要步骤（3）。

### 2. 源码修改
下在源码，切到loongarch64-5.4.3，通过下面的命令查看具体修改
> git show ded2c0422b6d86d3cfa3b0a22799145ed73c2331   
> git show 992ba3648956f23072a41f292b1a85d4911499bd   
> git show 0ffc1de1351de938fac7b9b25faf0a171b38aeca   
> git show 811b3da87293fe31b1fbb726cbafdd0eda15fb91   

### 3. 二进制构建   
> make build_dist_release   

### 4. 镜像构建
> make docker 
