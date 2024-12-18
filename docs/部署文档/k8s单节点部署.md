# k8s单节点部署.md

## 相关资源地址

1. [containerd-1.7.13下载地址](https://github.com/Loongson-Cloud-Community/containerd/releases/download/v1.7.13/containerd-1.7.13-static-abi2.0-bin.tar.gz)
2. [k8s-1.29相关资源地址](http://cloud.loongnix.cn/releases/loongarch64/kubernetes/kubernetes/v1.29.0/)

## 部署环境准备

1. 关闭swap分区：`swapoff -a`
2. 关闭selinux： `setenforce 0`
3. 检查内核模块
```sh
modprobe overlay
modprobe br_netfilter
```
4. 设置k8s内核配置选项
```sh
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```
  执行`sysctl -p /etc/sysctl.d/99-kubernetes-cri.conf` 使其生效

## 安装containerd

1. 下载安装containerd二进制
```
wget https://github.com/Loongson-Cloud-Community/containerd/releases/download/v1.7.13/containerd-1.7.13-static-abi2.0-bin.tar.gz
tar -xf containerd-1.7.13-static-abi2.0-bin.tar.gz
mv containerd-1.7.13-static-abi2.0-bin/* /usr/local/bin/
```

2. 生成containerd默认配置文件
```sh
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
```
