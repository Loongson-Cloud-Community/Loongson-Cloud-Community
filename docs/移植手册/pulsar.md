# pulsar

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |pulsar|
|版本       |3.0.0|
|项目地址   |[https://github.com/apache/pulsar](https://github.com/apache/pulsar)|
|官方指导   |[https://github.com/apache/pulsar/tree/v3.0.0/README.md](https://github.com/apache/pulsar/tree/v3.0.0/README.md)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |4.19.190-7.6.lns8.loongarch64|


## 移植步骤

__编译环境及依赖__
1. java 17 or later
2. maven 3.5 or later
3. zip

__移植步骤__
1. 下载源码
` git clone -b v3.0.0 --depth 1 https://github.com/apache/pulsar.git`
2. 修改配置文件
具体见 [https://github.com/Loongson-Cloud-Community/pulsar/commit/9269730f5387dadc8cf0aa010dfcbec80bc13544](https://github.com/Loongson-Cloud-Community/pulsar/commit/9269730f5387dadc8cf0aa010dfcbec80bc13544)
3. 编译
#最小化编译,编译较快 
` mvn install -Pcore-modules,-main -DskipTests `
编译完成的可执行文件位于bin目录下

__测试__
```
[yzw@kubernetes-master-1 bin]$ ./pulsar standalone
2023-09-04T19:43:50,751+0800 [main] INFO  org.apache.pulsar.PulsarStandalone - Starting BK with RocksDb metadata store
2023-09-04T19:43:51,280+0800 [main] INFO  org.apache.pulsar.metadata.impl.RocksdbMetadataStore - new RocksdbMetadataStore,url=MetadataStoreConfig(sessionTimeoutMillis=30000, allowReadOnlyOperations=false, configFilePath=null, batchingEnabled=true, batchingMaxDelayMillis=5, batchingMaxOperations=1000, batchingMaxSizeKb=128, metadataStoreName=metadata-store, fsyncEnable=true, synchronizer=null),instanceId=2
2023-09-04T19:43:51,309+0800 [main] INFO  org.apache.pulsar.metadata.bookkeeper.PulsarRegistrationManager - Initializing metadata for new cluster, ledger root path: /ledgers
2023-09-04T19:43:51,324+0800 [main] ERROR org.apache.pulsar.metadata.bookkeeper.PulsarRegistrationManager - Ledger root path: /ledgers already exists
2023-09-04T19:43:51,472+0800 [main] INFO  org.apache.pulsar.metadata.bookkeeper.BKCluster - Starting new bookie on port: 37873
```
要测试其他具体的如pulsar-client或pulsar-admin 见[https://pulsar.apache.org/docs/3.1.x/getting-started-standalone/](https://pulsar.apache.org/docs/3.1.x/getting-started-standalone/)
