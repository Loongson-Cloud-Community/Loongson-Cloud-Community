# k8s单节点部署.md

## 相关资源地址

1. [containerd-1.7.13下载地址](https://github.com/Loongson-Cloud-Community/containerd/releases/download/v1.7.13/containerd-1.7.13-static-abi2.0-bin.tar.gz)
2. [k8s-1.29相关资源地址](http://cloud.loongnix.cn/releases/loongarch64/kubernetes/kubernetes/v1.29.0/)
3. [runc-1.1.12下载地址](https://github.com/Loongson-Cloud-Community/runc/releases/download/v1.1.12/runc-seccomp-1.1.12-abi2.0-bin.tar.gz)

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

5. 关闭防火墙
```sh
systemctl stop firewalld
```

6. 修改hosts文件

```sh
10.130.0.193 lab1
```

## 安装runc

```sh
wget https://github.com/Loongson-Cloud-Community/runc/releases/download/v1.1.12/runc-seccomp-1.1.12-abi2.0-bin.tar.gz
tar -xf runc-seccomp-1.1.12-abi2.0-bin.tar.gz
mv runc-seccomp-1.1.12-abi2.0-bin/runc-static /usr/local/bin/runc
```

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

3. 修改 /etc/containerd/config.toml， 将systemd 作为容器的cgroup driver:

```toml
 [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
   ...
   [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
     SystemdCgroup = true
```

4. 修改 /etc/containerd/config.toml， 指定的pause容器部分:

```toml
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "lcr.loongnix.cn/kubernetes/pause:3.9"
```

5. 为了通过 systemd 启动 containerd ，请还需要从 https://raw.githubusercontent.com/containerd/containerd/main/containerd.service 下载 containerd.service 单元文件，并将其放置在 /etc/systemd/system/containerd.service 中

```sh
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /etc/systemd/system/containerd.service
```

6. 启动containerd

```sh
systemctl daemon-reload
systemctl start containerd
```

## k8s安装

```sh
mkdir -p /tmp/rpms
cd /tmp/rpms
wget http://cloud.loongnix.cn/releases/loongarch64/kubernetes/kubernetes/v1.29.0/cri-tools-1.29.0-0.loongarch64.rpm
wget http://cloud.loongnix.cn/releases/loongarch64/kubernetes/kubernetes/v1.29.0/kubeadm-1.29.0-0.loongarch64.rpm
wget http://cloud.loongnix.cn/releases/loongarch64/kubernetes/kubernetes/v1.29.0/kubectl-1.29.0-0.loongarch64.rpm
wget http://cloud.loongnix.cn/releases/loongarch64/kubernetes/kubernetes/v1.29.0/kubelet-1.29.0-0.loongarch64.rpm
wget http://cloud.loongnix.cn/releases/loongarch64/kubernetes/kubernetes/v1.29.0/kubernetes-cni-1.3.0-0.loongarch64.rpm
yum install -y ./*.rpm
```

## 配置crictl

```sh
 ## 配置runtime-endpoint
 crictl config runtime-endpoint unix:///run/containerd/containerd.sock
 ## 配置image-endpoint
 crictl config image-endpoint unix:///run/containerd/containerd.sock
```

## 创建k8s集群

```sh
kubeadm init \
--image-repository lcr.loongnix.cn/kubernetes \
--kubernetes-version v1.29.0 \
--cri-socket=/run/containerd/containerd.sock \
--pod-network-cidr=10.244.0.0/16 -v=5
```

出现类似如下日志，代表启动成功

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.130.0.193:6443 --token dpl4ij.njlpwjg3bzg8up0k \
	--discovery-token-ca-cert-hash sha256:7990c6a4850f6c4e1f1a45855e76fb0852e8113f63ff0b8ddfa252f3da2d5d10 
```


