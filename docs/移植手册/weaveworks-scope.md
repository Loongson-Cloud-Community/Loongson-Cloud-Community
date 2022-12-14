## weaveworks/scope

## 项目信息        
scope帮助你能够直观的了解、监视和控制容器化、基于微服务的应用程序。可以监控k8s集群的一系列资源的状态、资源使用情况、应用拓扑还可以直接通过UI界面进行调试、查看日志等操作以实时了解docker容器，类似与zabbix等监控服务。    
项目地址：https://github.com/Loongson-Cloud-Community/scope/tree/loong64-1.13.0        
项目分支：loong64-1.13.0     

## 源码修改
具体修改通过以下命令查看
```
git show e67356a970495fac20ac168c874b366d2fb51f93
git show abe42d11d984df193e25b2ae3ced171da53ac96e
git show 9f297fb798bcbf31094e15c3fb840d65d15e7e36
git show 428a8de5c67cb781c9e5abd8a647d90cb23eeed6
```

## 项目构建
提前下载镜像:     
```
cr.loongnix.cn/library/golang:1.15     
cr.loongnix.cn/library/node:10.24.1-debian      
```
执行命令：
```
make
```
## 构建结果
make执行成功后，会生成4个镜像    
```
cr.loongnix.cn/weaveworks/scope-ui-build:1.13.0     
cr.loongnix.cn/weaveworks/scope-backend-build:1.13.0     
cr.loongnix.cn/weaveworks/cloud-agent:1.13.0     
cr.loongnix.cn/weaveworks/scope:1.13.0    
```

### scope-backend-build
生成该镜像使用的dockerfile是backend/Dockerfile，该镜像是根镜像，主要配置了构建环境包括安装必要的软件、go的依赖项目及库文件（libpacp）等。      
项目源码的构建也都是在该镜像中执行的：    
包括文件：prog/staticui/staticui.go, prog/externalui/externalui.go //这两个文件中没有main，所以构建完后不会生成二进制也没有生成库文件，这里构建仅仅是用例检测这两个文件是否有语法等错误。    
构建二进制：：   
编译scope源码生成prog/scope二进制     
编译vendor/github.com/peterbourgon/runsvinit生成二进制vendor/github.com/peterbourgon/runsvinit/runsvinit     
### cloud-agent
该镜像使用的dockerfile是docker/Dockerfile.cloud-agent。该镜像中主要存储了scope二进制，并启动该二进制。
### scope-ui-build
该镜像使用的dockerfile是client/Dockerfile，该镜像用来设置了一些环境变量。
### scope
使用的dockerfile是docker/Dockerfile.scope。该镜像中存储了：    
脚本weave：用来下载镜像weaveexec, weave, weavedb    
二进制runsvinit    
脚本run-app：执行scope时传入参数scope-app     
脚本run-probe：在执行scope时传入参数scope-probe     

## 部署测试
```
wget https://github.com/Loongson-Cloud-Community/scope/blob/loong64-1.13.0/scope     
mv scope /usr/local/bin/scope
chmod a+x /usr/local/bin/scope
//部署安装scope,设定用户myuser, 密码mypassword
sudo scope launch -app.basicAuth -app.basicAuth.password mypassword -app.basicAuth.username myuser -probe.basicAuth -probe.basicAuth.password mypassword -probe.basicAuth.username myuser
```
此时在机器上会启动一个scope的容器：
```
root@node1:/home/workspace/scope-test# docker ps
CONTAINER ID   IMAGE    COMMAND   CREATED  STATUS   PORTS    NAMES
fe3f9aa32121   cr.loongnix.cn/weaveworks/scope:1.13.0   "/home/weave/entrypo…"   16 minutes ago   Up 16 minutes    weavescope
```
在浏览器中输入本机ip地址：4040端口，并输入用户名和密码（myuser mypassword）
