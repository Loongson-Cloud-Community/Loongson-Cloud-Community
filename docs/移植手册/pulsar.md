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
2023-09-05T11:24:45,203+0800 [main] INFO  org.apache.pulsar.PulsarStandalone - Starting BK with RocksDb metadata store
2023-09-05T11:24:45,646+0800 [main] INFO  org.apache.pulsar.metadata.impl.RocksdbMetadataStore - new RocksdbMetadataStore,url=MetadataStoreConfig(sessionTimeoutMillis=30000, allowReadOnlyOperations=false, configFilePath=null, batchingEnabled=true, batchingMaxDelayMillis=5, batchingMaxOperations=1000, batchingMaxSizeKb=128, metadataStoreName=metadata-store, fsyncEnable=true, synchronizer=null),instanceId=1
2023-09-05T11:24:45,665+0800 [main] INFO  org.apache.pulsar.metadata.bookkeeper.PulsarRegistrationManager - Initializing metadata for new cluster, ledger root path: /ledgers
2023-09-05T11:24:45,704+0800 [main] INFO  org.apache.pulsar.metadata.bookkeeper.PulsarRegistrationManager - Successfully initiated cluster. ledger root path: /ledgers instanceId: b41129fc-4e56-4fdf-8c99-5c6910aecb8d
2023-09-05T11:24:45,726+0800 [main] INFO  org.apache.pulsar.metadata.bookkeeper.BKCluster - Starting new bookie on port: 34027
2023-09-05T11:24:45,751+0800 [main] INFO  org.apache.bookkeeper.server.EmbeddedServer$Builder - Load lifecycle component : org.apache.bookkeeper.server.service.StatsProviderService
2023-09-05T11:24:45,765+0800 [main] INFO  org.apache.bookkeeper.meta.MetadataDrivers - BookKeeper metadata driver manager initialized
2023-09-05T11:24:45,870+0800 [main] INFO  org.apache.bookkeeper.bookie.LegacyCookieValidation - Stamping new cookies on all dirs [data/standalone/bookkeeper/current]
2023-09-05T11:24:45,984+0800 [main] INFO  org.apache.bookkeeper.bookie.BookieResources - Using ledger storage: org.apache.bookkeeper.bookie.storage.ldb.DbLedgerStorage
2023-09-05T11:24:45,990+0800 [main] INFO  org.apache.bookkeeper.bookie.storage.ldb.DbLedgerStorage - Started Db Ledger Storage

```
要测试其他具体的如pulsar-client或pulsar-admin 见[https://pulsar.apache.org/docs/3.1.x/getting-started-standalone/](https://pulsar.apache.org/docs/3.1.x/getting-started-standalone/)
