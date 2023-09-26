# nerdctl   

## 1. 项目信息
|名称       |描述|
|--         |--|
|名称       |nerdctl|
|版本       |1.5.0|
|项目地址   |[https://github.com/containerd/nerdctl](https://github.com/containerd/nerdctl)|

nerdctl是containerd的命令行工具。与ctr不同，nerdctl的目标是用户友好并和docker兼容，比ctr覆盖更全面。     
从基本用法的角度来看，与ctr相比，nerdctl支持：    
构建镜像；
容器网络管理；
docker compose与nerdctl compose up

## 2. 源码适配
与架构相关的代码较少，具体见：https://github.com/Loongson-Cloud-Community/nerdctl/tree/v1.5.0-loong64 的git log信息。

## 3. 构建
### 3.1 二进制编译
执行命令：make nerdctl         
编译完成后会在_output目录下生成nerdctl二进制

### 3.2 二进制安装
执行命令： make install      
默认安装在/usr/local/bin目录下

### 3.3 官方release包构建
执行命令： make artifacts   
该命令将构建所有平台，所有架构的tar包
