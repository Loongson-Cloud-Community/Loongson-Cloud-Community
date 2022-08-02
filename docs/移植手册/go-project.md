# go 项目通用移植参考

本文章介绍使用 go mod 模式管理 的 go 语言项目的通用移植方法。

## 环境准备
- loongarch64 机器
- golang loongarch64 编译器

## 移植步骤
### 1. 设置环境变量
将 goproxy 设置为龙芯源，从这里下载的架构相关依赖是适配过的；关闭 GOSUMDB 和 删除项目里的 go.sum 文件是保证不使用 SUM 校验，
```
export GOPROXY=http://goproxy.loongnix.cn
export GOSUMDB=off
rm  -f go.sum
```
### 2. 构建
```
go build $TARGET
```

## 可能出现的问题
1. 构建方式不同 

和上边的例子不同，大部分项目使用 Makefile 进行构建，并在 Makefile 中编写构建命令，所以需要修改对应 Makefile 中的构建命令以适应龙芯架构
  
2. GOPATH 已经存在旧的依赖导致编译出错

如果在设置 GOPROXY 为龙芯源之前 GOPATH 里已经有架构相关的依赖包，则可能导致编译时使用旧的依赖包，所以可以先清空 GOPATH

## 问题反馈
如果您发现有龙芯未集成的架构相关的依赖包，可以反馈给我们[issues](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/issues)
