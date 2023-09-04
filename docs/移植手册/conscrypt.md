# conscrypt

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |conscrypt|
|版本       |2.5.2|
|项目地址   |[https://github.com/google/conscrypt](https://github.com/google/conscrypt)|
|官方指导   |[https://github.com/google/conscrypttree/2.5.2/README.md](https://github.com/google/conscrypttree/2.5.2/README.md)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |4.19.190-7.6.lns8.loongarch64|


## 移植说明
该项目的编译结果为jar包

  
## 移植步骤

__编译环境和依赖__
1. boringssl 
loongarch移植的项目地址[https://github.com/Panxuefeng-loongson/boringssl/tree/LoongArch64](https://github.com/Panxuefeng-loongson/boringssl/tree/LoongArch64)
无需编译,配置环境变量:`export boringsslHome=path/to/boringsslHome`

__适配__
具体修改情况见 [https://github.com/Loongson-Cloud-Community/conscrypt/commit/a4a0b0285deff910e6cd65223530ffce928720e7](https://github.com/Loongson-Cloud-Community/conscrypt/commit/a4a0b0285deff910e6cd65223530ffce928720e7)
由于在loongarch平台无法生成constants子项目中的Native.java代码,需要在x86平台生成代码,接着放到相同目录下的consycrypt-constants/src/java/main目录下
[https://github.com/Loongson-Cloud-Community/conscrypt/releases/download/v2.5.2/NativeConstants.tar.gz](https://github.com/Loongson-Cloud-Community/conscrypt/releases/download/v2.5.2/NativeConstants.tar.gz)

__编译__

`./gradlew conscrypt-openjdk:assemble `
`./gradlew conscrypt-openjdk-uber:assemble `



