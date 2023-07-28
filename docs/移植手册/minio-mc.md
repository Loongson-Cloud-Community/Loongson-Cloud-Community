# minio-mc

# Loongarch64
## 构建版本
2020-12-18T10-53-53Z 

## 源码适配
该项目与架构无关，不需要适配

## 编译
g使用go版本：1.19   
编译命令：
```
go build \
   -mod=vendor \
   -buildmode=pie \
   -trimpath -tags kqueue \
   -ldflags="-s -w -X github.com/minio/mc/cmd.Version=2020-12-18T10-53-53Z \
        -X github.com/minio/mc/cmd.ReleaseTag=2020-12-18T10-53-53Z" \
   -o bin/minio-client
   ```

## rpm包制作
使用spec见src.rpm
```
https://github.com/Loongson-Cloud-Community/mc/releases/download/untagged-c79ae86bb2c97de123bc/minio-client-20201218T105353Z-1.1.src.rpm
```

执行rpm包构建命令：
```
rpmbuild -ba --nodebuginfo  minio-client.spec
```
