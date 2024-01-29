# deepflow
## 1. 源码移植
参考https://github.com/Loongson-Cloud-Community/deepflow/tree/loongarch64-v6.1.4 的commit信息       

## 2. server组件编译
### 2.1 环境准备
在编译server组件时依赖gogo/protobuf中的一些二进制，下载二进制https://github.com/Loongson-Cloud-Community/gogo-protobuf/releases/download/v1.3.2/gogo-protobuf-1.3.2-bin.tar.gz ，对其进行解压，并将其添加到PATH路径当中。      
### 2.2 软件安装
```
apt install -y golang-1.20 libpython3.7-dev libpython3.7-stdlib
pip3 install ujson
```
### 2.3 server组件编译
```
cd server
make
```
编译完成以后会生成bin/deepflow-server
