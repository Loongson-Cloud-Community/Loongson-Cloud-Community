# lxc 指导手册
## 1.源码移植
具体见https://github.com/Loongson-Cloud-Community/lxc/tree/loongarch64-lxc-5.0.2 的git log信息。       

## 2. 构建
```
meson setup build
ninja -C build
ninja -C build install
```
若要指定配置选项，可在meson命令后添加相关的设置，如：
```
meson setup build/ -Dio-uring-event-loop=false -Dtests=true -Dpam-cgroup=true -Dprefix=/usr/ -Dsysconfdir=/etc/ -Dlocalstatedir=/var/
```

## 3. 测试
### 3.1 上游测试
lxc上游测试流程是：
1）启动一个arm的虚拟机
2）下载lxc源码，执行编译安装
3）下载lxc-ci源码，使用其中的脚本文件lxc-exercise来执行测试
详细的ci测试流程见https://jenkins.linuxcontainers.org/job/lxc-github-pull-test/4813/arch=arm64,async=epoll,compiler=gcc,restrict=vm/consoleFull

### 3.2 本地测试     
（1）环境准备    
arm机器    
debian/ubuntu系统    

(2)源码准备
lxc：
```
mkdir -p /build/source
git clone https://github.com/lxc/lxc -b main /build/source
git fetch https://github.com/lxc/lxc +refs/pull/*:refs/remotes/origin/pr/*
git checkout 4d08dac9c02a7ad40010129916f5e105ea1a67c3
WANT_IO_URING=-Dio-uring-event-loop=false && meson setup build/ -Dio-uring-event-loop=false -Dtests=true -Dpam-cgroup=true -Dprefix=/usr/ -Dsysconfdir=/etc/ -Dlocalstatedir=/var/
```

lxc-ci：
```
git clone https://github.com/lxc/lxc-ci.git
cd lxc-ci
cp ./deps/lxc-exercise /build/
```
（3）lxc源码编译
```
ninja -C build
ninja -C build install
// 下面的命令为测试做准备
netplan generate
netplan apply
sed -i s/lxd-/incus-/g /lib/apparmor/rc.apparmor.functions
systemctl restart apparmor
mount -t tmpfs tmpfs /home
mkdir -p /var/lib/lxc
mount -t tmpfs tmpfs /var/lib/lxc
```
(4)执行测试
```
/build/lxc-exercise
```
