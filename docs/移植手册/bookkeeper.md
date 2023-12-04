# bookkeeper

## 项目信息

|名称       |描述|
|--         |--|
|名称       |bookkeeper|
|版本       |4.14.1|
|项目地址   |[https://github.com/apache/bookkeeper](https://github.com/apache/bookkeeper)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |loongnix server 8.4|

__说明__
bookkeeper项目主要适配的部分：
	1. 跳过loongarch不支持的sse4.2向量加速指令集
	2. 添加loongarch编译配置文件src/loongarch64_aol.properties
	3. 排除打包过程中重复的依赖文件

__下载源码__  
从apache/bookkeeper仓库的中下载未移植的源码：[https://github.com/apache/bookkeeper](https://github.com/apache/bookkeeper)  
从Loongson-Cloud-Community/bazel仓库的release中下载已经移植过的源码包：[https://github.com/Loongson-Cloud-Community/bookkeeper](https://github.com/Loongson-Cloud-Community/bookkeeper)  
如果您下载了已经移植过的源码包，您可以跳过下文的`移植`章节

__移植__  
关于移植过程中需要修改的文件以及如何修改可以参考[dbad884](https://github.com/Loongson-Cloud-Community/bookkeeper/commit/dbad884b18bf5baf45410cdb551451b13e927d05)

```

__编译__  
在确保网络通畅的情况下执行：
```
mvn clean package -P loongarch64-linux-nar-aol -DskipTests
```
