# kibana移植文档
kibana二进制本身与架构无关，只是tar包中依赖的node是特定于架构的，所以这里是下载x86的kibana的tar包，然后替换其中node为loongarch64架构即可。

## 1. 移植版本
7.10.2

## 2. 移植步骤 
### （1）下载7.10.2 x86 kibana版本：   
```
curl -OL https://artifacts.elastic.co/downloads/kibana/kibana-7.10.2-linux-x86_64.tar.gz
``` 
下载完后解压     
### （2）下载10.24.1nodejs      
查看kibana 7.10.2源码，使用的是node 10.23.1版本，在loongarch64架构上没有该版本，故下载10.24.1版本node: 
http://ftp.loongnix.cn/nodejs/LoongArch/dist/v10.24.1/node-v10.24.1-linux-loong64.tar.gz   并解压       
### （3）替换node        
将（2）中解压的node-v10.24.1-linux-loong64 重命名为 node，并替换kibana-7.10.2-linux-x86_64 中的 node 目录。
### （4）修改package.json
将该文件中node的版本10.23.1修改为10.24.1 
### （5） 修改re2.node二进制
该二进制是架构相关的，编译LA架构的re2.node二进制，替换/node_modules/re2/build/Release/re2.node。
re2.node编译方法见：https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/node-re2.md
### （6）压缩tar包
修改kibana-7.10.2-linux-x86_64为kibana-7.10.2-linux-loongarch64，并压缩tar包
