## 简介

cAdvisor（Container Advisor）让容器用户了解他们正在运行的容器的资源使用情况和性能特征。它是一个正在运行的守护进程，用于收集、聚合、处理和导出有关正在运行的容器的信息。具体来说，对于每个容器，它保存了资源隔离参数、历史资源使用情况、完整的历史资源使用情况直方图和网络统计信息。该数据由容器和机器导出

## 二进制构建参考

1. [官方构建文档](https://github.com/google/cadvisor/blob/master/docs/development/build.md)

## 容器构建

dockerfile位置

- deploy/Dockerfile

- deploy/canary/Dockerfile

使用这两个dockerfile都可以直接进行构建(目前龙芯平台暂不支持直接构建)

## 龙芯平台当前使用

```
docker pull harbor.loongnix.cn/mirrorloongsoncontainers/cadvisor:v0.40.0
```
