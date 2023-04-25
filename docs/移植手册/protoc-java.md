# protoc-java构建指导

## 1. 构建版本
3.5.1.1

## 2. 源码适配
适配源码不多，具体查看 https://github.com/Loongson-Cloud-Community/protoc-jar/tree/loongarch64-3.5.1.1 的git log信息

## 3. 构建
```
mvn clean install -DskipTests
```
构建完成后会在target目录下生成相应的jar包
