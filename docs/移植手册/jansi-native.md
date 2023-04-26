# jansi-native 构建指导

## 1. 够将版本
1.5

## 2. 源码适配
该项目本身架构无关，但由于库的路径改变需要对其进行修改，具体查看https://github.com/Loongson-Cloud-Community/jansi-native/tree/loong64-jansi-native-1.5 的git log信息

## 3. 构建安装
```
mvn -DskipTests -Dplatform=linux64 install 
```
