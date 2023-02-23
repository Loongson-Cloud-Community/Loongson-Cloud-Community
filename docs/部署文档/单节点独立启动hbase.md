# 单节点独立启动hbase

本文将展示如何通过`hbase shell`进行表的创建、插入、遍历等操作以及如何开启和停止hbase。文中hbase的版本为`2.4.16`。

## 部署环境
```
NAME="Loongnix-Server Linux"
VERSION="8"
ID="loongnix-server"
ID_LIKE="rhel fedora centos"
VERSION_ID="8"
PLATFORM_ID="platform:lns8"
PRETTY_NAME="Loongnix-Server Linux 8"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:loongnix-server:loongnix-server:8"
HOME_URL="http://www.loongnix.cn/"
BUG_REPORT_URL="http://bugs.loongnix.cn/"
CENTOS_MANTISBT_PROJECT="Loongnix-server-8"
CENTOS_MANTISBT_PROJECT_VERSION="8"
```
```
Linux 8f02d1b43d7b 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```
## 安装JDK
jdk版本为`jdk 8`，更多支持hbase的java jdk信息请点击[这里](https://hbase.apache.org/book.html#java)。安装后设置`JAVA_HOME`环境变量。

## 开始
```
tar -zxf hbase-2.4.16-bin.tar.gz &&\
cd hbase-2.4.16
```
请确认设置了`JAVA_HOME`，否则无法启动hbase。执行`bin/start-hbase.sh`脚本启动hbase，启动后在浏览器中访问[http://localhost:16010](http://localhost:16010/)可以看到hbase前端的UI。
### 连接hbase
使用`hbase shell`命令连接到hbase的运行实例，该命令在`bin/`目录下：
```
$ ./bin/hbase shell
HBase Shell
Use "help" to get list of supported commands.
Use "exit" to quit this interactive shell.
For Reference, please visit: http://hbase.apache.org/2.0/book.html#shell
Version 2.4.16, rUnknown, Tue Feb 21 12:51:44 UTC 2023
Took 0.0079 seconds                                                                          
hbase:001:0> 
```
### 打印帮助信息
在`hbase shell`中输入`help`。
### 创建一张表
使用`create`命令创建一个新表,必须指定表名和列族(ColumnFamily)名称:
```
hbase:002:0> create 'test', 'cf'
Created table test
Took 2.1679 seconds                                                                          
=> Hbase::Table - test
```
### 确认表是否存在
使用`list`命令确认表是否存在：
```
hbase:003:0> list 'test'
TABLE                                                                                        
test                                                                                         
1 row(s)
Took 0.0707 seconds                                                                          
=> ["test"]
```
### 查看表的详细信息
使用`describe`命令查看表的详细信息，包括默认的配置：
```
hbase:004:0> describe 'test'
Table test is ENABLED                                                                        
test                                                                                         
COLUMN FAMILIES DESCRIPTION                                                                  
{NAME => 'cf', BLOOMFILTER => 'ROW', IN_MEMORY => 'false', VERSIONS => '1', KEEP_DELETED_CELL
S => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', COMPRESSION => 'NONE', TTL => 'FOREVER', MIN_VER
SIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}          

1 row(s)
Quota is disabled
Took 0.3040 seconds
```
### 插入数据
使用`put`命令向表中插入数据：
```
hbase:002:0> put 'test', 'row1', 'cf:a', 'value1'
Took 0.3951 seconds                                                                          
hbase:003:0> put 'test', 'row2', 'cf:b', 'value2'
Took 0.0211 seconds                                                                          
hbase:004:0> put 'test', 'row3', 'cf:c', 'value3'
Took 0.0317 seconds
```
### 遍历表中数据
使用`scan`命令遍历且打印表中数据：
```
hbase:005:0> scan 'test'
ROW                      COLUMN+CELL                                                         
 row1                    column=cf:a, timestamp=2023-02-23T07:09:38.540, value=value1        
 row2                    column=cf:b, timestamp=2023-02-23T07:09:45.685, value=value2        
 row3                    column=cf:c, timestamp=2023-02-23T07:09:54.162, value=value3        
3 row(s)
Took 0.1601 seconds
```
### 获取一行数据
使用`get`命令一次获取一行数据：
```
hbase:006:0> get 'test', 'row1'
COLUMN                   CELL                                                                
 cf:a                    timestamp=2023-02-23T07:09:38.540, value=value1                     
1 row(s)
Took 0.1136 seconds
```
### 禁用表
当需要对表进行删除、修改设置等情况时，需要先禁用表，使用`disable`命令禁用表，使用'enable'命令对已禁用的表重新使能：
```
hbase:009:0> disable 'test'
Took 0.3501 seconds                                                                          
hbase:010:0> enable 'test'
Took 0.6473 seconds
```
### 删除表
使用`drop`命令删除表：
```
hbase:011:0> disable 'test'
Took 0.3521 seconds                                                                          
hbase:012:0> drop 'test'
Took 0.3895 seconds
```
### 退出hbase shell
使用`quit`命令退出hbase shell，hbase仍会运行在后台。
## 停止hbase
运行`bin/stop-hbase.sh`脚本停止hbase。
```
$ ./bin/stop-hbase.sh
stopping hbase....................
```
