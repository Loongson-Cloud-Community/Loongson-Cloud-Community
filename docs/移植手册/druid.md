# druid

## 1. 构建版本
0.12.0

## 2. 依赖项sigar
项目本身无架构相关代码，但依赖sigar-dist-1.6.5.132，      
其下载地址：https://github.com/Loongson-Cloud-Community/sigar/releases/download/loongarch64-master-ad47dc3b494e/sigar-dist-1.6.5.132.zip        
具体构建方法，查看： https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/sigar.md        

## 3. 构建
```
mvn clean install -pl java-util -am -DskipTests    //只构建java-util模块
```

若要构建所有模块，则执行以下命令：
```
mvn clean install -DskipTests
```
