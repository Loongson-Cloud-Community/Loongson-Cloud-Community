# kubevirt单节点部署参考文档
## 部署版本
v0.35.0
## 部署环境
### 架构信息
loongarch64
### 系统
loongnix-server 8.4.0
### 内核信息
4.19.190-6.5.lns8.loongarch64
## 部署步骤
### 准备工作
[点击这里](https://github.com/Loongson-Cloud-Community/kubevirt/releases/download/v0.35.0/kubevirt-v0.35.0-loong64.tar.gz)下载本次部署用到的所有文件，下载后请解压
```
tar -zxf kubevirt-0.35.0-loong64.tar.gz
```
### 部署k8s
k8s的快速部署参考[这里](http://docs.loongnix.cn/loongnix/cloud/kubernetes/install.html)  
### 添加calico
```
kubectl apply -f calico.yaml
```
### 执行以下命令解除master的限制
```
kubectl taint nodes --all node-role.kubernetes.io/master-
```
### 部署kubevirt
#### 安装依赖
```
yum -y install qemu-kvm libvirt virt-install bridge-utils
```
#### 下载kubevirt v0.35.0镜像
```
docker pull cr.loongnix.cn/kubevirt/virt-operator:0.35.0 &&\
docker pull cr.loongnix.cn/kubevirt/virt-launcher:0.35.0 &&\
docker pull cr.loongnix.cn/kubevirt/virt-handler:0.35.0 &&\
docker pull cr.loongnix.cn/kubevirt/virt-controller:0.35.0 &&\
docker pull cr.loongnix.cn/kubevirt/virt-api:0.35.0
```
#### 离线导入镜像
所有镜像都保存在 `images`目录下，导入命令为：
```
docker load -i [tar包]
```
#### 部署
```
kubectl apply -f kubevirt-operator.yaml
kubectl apply -f kubevirt-cr.yaml
```
查看pods状态
```
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-698f8585b6-7zrh7   1/1     Running   0          3m56s
kube-system   calico-node-n478r                          1/1     Running   0          3m56s
kube-system   coredns-7cb7cc6b47-df6hb                   1/1     Running   0          6m17s
kube-system   coredns-7cb7cc6b47-qhdgx                   1/1     Running   0          6m17s
kube-system   etcd-bogon                                 1/1     Running   0          6m15s
kube-system   kube-apiserver-bogon                       1/1     Running   0          6m15s
kube-system   kube-controller-manager-bogon              1/1     Running   0          6m15s
kube-system   kube-proxy-4f468                           1/1     Running   0          6m17s
kube-system   kube-scheduler-bogon                       1/1     Running   0          6m15s
kubevirt      virt-api-58c85665f9-gtxn9                  1/1     Running   0          59s
kubevirt      virt-api-58c85665f9-t77np                  1/1     Running   0          59s
kubevirt      virt-controller-797544bbbd-7tl4c           1/1     Running   0          42s
kubevirt      virt-controller-797544bbbd-dxhmw           1/1     Running   0          42s
kubevirt      virt-handler-nfn9h                         1/1     Running   0          42s
kubevirt      virt-operator-5459ff7758-sql9t             1/1     Running   0          3m3s
kubevirt      virt-operator-5459ff7758-vg6g8             1/1     Running   0          3m3s
```
### 启动虚拟机实例
导入虚拟机镜像
```
docker load -i loongnix-server.tar
```
启动一个虚拟机实例
```
kubectl apply -f vmi.yaml
```
查看虚拟机实例状态
```
kubectl get vmis
```
```
NAME      AGE     PHASE     IP                NODENAME
testvmi   2m30s   Running   172.18.29.12/32   bogon
```
### virtctl访问虚拟机实例
virtctl静态二进制存放在`bin`目录下
```
./virtctl console testvmi
```
使用root用户直接登录
```
Successfully connected to testvmi console. The escape sequence is ^]

Loongnix-Server Linux 8
Kernel 4.19.190-6.2.4.lns8.loongarch64 on an loongarch64

testvmi login: root
Last login: Mon Feb  6 02:41:57 on tty1
[root@testvmi ~]# 
```
