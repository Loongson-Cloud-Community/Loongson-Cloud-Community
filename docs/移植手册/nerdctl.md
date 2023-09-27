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

## 4. 使用依赖
若要使用nerdctl需要满足以下2个条件：        
1）使用高版本的CNI网络插件：           
下载https://github.com/Loongson-Cloud-Community/plugins/releases/download/v1.3.0/loongarch64-v1.3.0-bin.tar.gz，         
解压后重命名为bin,将其存放在/opt/cni/ 目录下      
备注： plugins源码构建指导：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/plugins.md     
2）卸载docker-ce         
3) 使用示例     
```
[root@kubernetes-master-1 plugins]# nerdctl pull cr.loongnix.cn/library/alpine:3.11
cr.loongnix.cn/library/alpine:3.11:                                               resolved       |++++++++++++++++++++++++++++++++++++++| 
manifest-sha256:9730184ded621302981066363fad2a8157ff071565dc3478c3e8c4fce9c08adc: done           |++++++++++++++++++++++++++++++++++++++| 
config-sha256:530dc3f1f2ceb4bea7af5aa073e25108e98e2520049193b37e28bb1d0ae51c62:   done           |++++++++++++++++++++++++++++++++++++++| 
elapsed: 0.5 s                                                                    total:  528.0  (1.0 KiB/s)                                       
[root@kubernetes-master-1 plugins]# nerdctl run -it cr.loongnix.cn/library/alpine:3.11
/ # 
```


