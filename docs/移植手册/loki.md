# loki

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |loki|
|版本       |2.9.2|
|项目地址   |[https://github.com/grafana/loki](https://github.com/grafana/loki)|
|官方指导   |[https://github.com/grafana/loki/tree/2.9.2/README.md](https://github.com/grafana/grafana/tree/2.9.2/README.md)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A6000|
|OS         |Anolis 23
|系统       |5.10.190-7.6.lns8.loongarch64|


## 移植说明
该项目的编译结果为二进制

  
## 移植步骤

__编译环境和依赖__
需要将项目放置到$GOPATH/src/github.com/grafana/下

__适配__
编译时可能会报错：pkg/storage/stores/shipper/index/table.go:113:20: cannot use db.Stats().TxStats.Write (value of type int64) as int value in assignment
修改./pkg/storage/stores/shipper/index/table.go 第113行： int(db.Stats().TxStats.Write)

__编译__

`go build ./cmd/loki`
'./loki -config.file=./cmd/loki/loki-local/config.yaml'
###
在编译时，如果要启动Linux的journal日志服务，需要添加promatil头
` go build --tags=promtail_journal_enabled ./clients/cmd/promtail `


