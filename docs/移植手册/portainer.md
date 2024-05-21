# portainer
## 1. 项目介绍
portainer是一款对单节点  多节点集群下的容器、镜像资源进行管理的可视化web工具
源码：https://github.com/portainer/portainer
1.x版本镜像名为portainer
2.x版本为portainer-ce

## 2. 构建版本
2.11.1

## 3. 构建步骤
（1）loong64架构构建
官方未给出构建方法，查看项目文件，可知通过build/binary_portainer.sh文件进行构建二进制：

需要先在api文件夹下获取vendor`go mod vendor`
可能出现由于bbolt项目未适配导致的报错，可以将bbolt的引用改为bolt，更改具体详情见https://github.com/Loongson-Cloud-Community/docker-library/portainer/portainer/2.11.1/的patch信息
```
bash build/binary_portainer.sh linux loong64
```
编译完成后，二进制存储在dist路径下。


### 4. 备注
- 构建容器可能报错情况：
```
not found docker-compose binary
```
需要将docker-compose docker helm kubectl kcompose等二进制拉取到dist文件夹下再构建镜像

- 情况二：
运行容器访问页面404not found
因为镜像内没有前端资源，可以从官方镜像获取
获取方法：
```
docker pull --platform portainer/portainer-ce:2.11.1
docker run -d --name portainer -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
docker export portainer > portainer.tar.gz 
mkdir tmp && cd tmp && tar xf ../portainer.tar.gz
```
解压tar包得到的public和storybook即为前端资源，COPY到镜像内即可