
# hadoop+hbase伪分布部署

## 1. 部署环境    
使用1台机器  
```
hadoop@node1:/home/zhaixiaojuan/桌面$ cat /etc/os-release 
PRETTY_NAME="Loongnix GNU/Linux 20 (DaoXiangHu)"
NAME="Loongnix GNU/Linux"
VERSION_ID="20"
VERSION="20 (DaoXiangHu)"
VERSION_CODENAME=DaoXiangHu
ID=Loongnix
HOME_URL="https://www.loongnix.cn/"
SUPPORT_URL="https://www.loongnix.cn/"
BUG_REPORT_URL="http://www.loongnix.cn/"

hadoop@node1:/home/zhaixiaojuan/桌面$ uname -a
Linux node1 4.19.0-19-loongson-3 #1 SMP pkg_lnd10_4.19.190-7.6 Wed Nov 16 11:12:41 UTC 2022 loongarch64 loongarch64 loongarch64 GNU/Linux
```

## 2. hadoop部署    
### 2.1 创建hadoop用户
```
sudo useradd -m hadoop -s /bin/bash
sudo passed hadoop
sudo adduser hadoop sudo
```

### 2.2 配置无密码登陆
```
sudo apt install -y openssh-server
cd ~/.ssh   //若没有该目录，则先执行一次ssh localhost
ssh-keygen -t rsa  //提示按回车即可
cat ./id_rsa.pub >> ./authorized_keys  //加入授权
```

此时再用ssh localhost命令，便可以无需密码登陆了

### 2.3 安装java
```
apt install -y openjdk-8-jdk
```
在～/.bashrc中写入：
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64
export PATH=$JAVA_HOME/bin:$PATH
source ~/.bashrc
```

### 2.4 安装hadoop-3.3.4
```
sudo tar -zxf hadoop-3.3.4.tar.gz -C /usr/local  
cd /usr/local/
sudo mv ./hadoop-3.3.4 ./hadoop  //修改文件名
sudo chown -R hadoop ./hadoop  //修改文件权限
```
在～/.bashrc中加入以下内容：
```
export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin
```
执行： source ~/.bashrc

输入以下命令检查hadoop是否可用，成功会显示hadoop版本信息:
```
hadoop@node01:/usr/local/hadoop$ hadoop version
Hadoop 3.3.4
Source code repository https://github.com/apache/hadoop.git -r a585a73c3e02ac62350c136643a5e7f6095a3dbb
Compiled by root on 2023-02-07T03:38Z
Compiled with protoc 3.7.1
From source with checksum fb9dd8918a7b8a5b430d61af858f6ec
This command was run using /usr/local/hadoop/share/hadoop/common/hadoop-common-3.3.4.jar
```

### 2.4 修改配置文件
#### 2.4.1 hadoop-env.sh
设置JAVA_HOME参数为本地
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64
```

#### 2.4.2 core-site.xml
```
<configuration>
<property>
    <!-- 配置hadoop的临时目录 -->
        <name>hadoop.tmp.dir</name>
        <value>file:/usr/local/hadoop/tmp</value>
        <description>Abase for other temporary directories.</description>
    </property>
<property>
    <!--  指定hdfs使用本地机器的9000端口  -->
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
```

#### 2.4.3 hdfs-site.xml
```
<configuration>
<property>
    <!-- 指定HDFS副本的数量  -->
        <name>dfs.replication</name>
        <value>1</value>
    </property>
<property>
    <!-- 指定DFS名称表（名称节点）的存储位置 -->
        <name>dfs.namenode.name.dir</name>
        <value>file:/usr/local/hadoop/tmp/dfs/name</value>
    </property>
<property>
    <!-- 指定DFS数据表（数据节点）的存储位置>
        <name>dfs.datanode.data.dir</name>
        <value>file:/usr/local/hadoop/tmp/dfs/data</value>
    </property>
</configuration>
```

### 2.5 集群启动
名称节点格式化：
```
cd /usr/local/hadoop
./bin/hdfs namenode -format
``` 
出现"successfully formatted" 的提示表示成功      

启动hdfs服务：      
```
cd /usr/local/hadoop
./sbin/start-dfs.sh
```
当启动成功后，通过jps可以看到启动了三个进程：DataNode,NameNode和SecondaryNameNode:     
```
hadoop@node1:/usr/local$ jps
21441 DataNode
21348 NameNode
28564 Jps
21637 SecondaryNameNode
```

此时访问网页：http://localhost:9870    

![image](https://user-images.githubusercontent.com/67671683/220578866-ab047737-829d-498b-af90-ac0bc7ad5a91.png)


## 3. 部署hbase   
### 3.1 安装hbase
```
sudo tar -zxf hbase-2.4.16.tar.gz -C /usr/local
cd /usr/local
sudo mv ./hbase-2.4.16 ./hbase
sudo chown -R hadoop ./hbase  //修改文件权限
在～/.bashrc 中添加：
export PATH=$PATH:/usr/local/hbase/bin
```

### 3.2 修改配置文件
#### 3.2.1 hbase-env.sh
 设置JAVA_HOME:
 ```
 export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64/
 ```
 
 设置zookeeper:
 HBASE中自带zookeeper，若要单独使用hbase中内置的zookeeper，则使用：
 ```
 export HBASE_MANAGES_ZK=true  (默认为true)
 ```
若要自己单独配置zookeeper，则将该变量设置为false，这里默认使用hbase自己管理的zookeeper。

#### 3.2.2 hbase-site.xml
```
<configuration>
  <property>
    <!-- 设定部署方式为分布式部署 -->
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
  <property>
    <!-- 设置临时目录的位置  -->
    <name>hbase.tmp.dir</name>
    <value>./tmp</value>
  </property>
  <property>
    <name>hbase.unsafe.stream.capability.enforce</name>
    <value>false</value>
  </property>
  <property>
    <!-- 设置HReion服务器的位置，即数据存放的位置。这里的端口号要和hadoop的core-site.xml文件中设置的端口号保持一致 -->
    <name>hbase.rootdir</name>
    <value>hdfs://localhost:9000/hbase</value>
  </property>
</configuration>
```

备注：
hbase.cluster.distributed：用来设置hbase的运行方式。false是单机模式，true是分布式模式。若为false，Hbase和zookeeper会运行在同一个JVM里面，默认为false。
hbase.unsafe.stream.capability.enforce这个属性的设置，是为了避免出现启动错误，若没有设置为false，则在启动hbase后，有可能会出现无法找到HMaster进程的错误，启动后查看系统启动日志（/usr/local/hbase/logs/hbase-hadoop-master-ubuntu.log），会出现如下错误：
```
2020-01-25 15:04:56,916 ERROR [master/localhost:16000:becomeActiveMaster] master.HMaster: Failed to become active master
java.lang.IllegalStateException: The procedure WAL relies on the ability to hsync for proper operation during component failures, but the underlying filesystem does not support doing so. Please check the config value of 'hbase.procedure.store.wal.use.hsync' to set the desired level of robustness and ensure the config value of 'hbase.wal.dir' points to a FileSystem mount that can provide it.
```

### 3.3 集群启动
#### 3.3..1 hbase服务启动
```
hadoop@node1:/usr/local/hbase$ ./bin/start-hbase.sh 
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/local/hadoop/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/local/hbase/lib/client-facing-thirdparty/slf4j-reload4j-1.7.33.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Reload4jLoggerFactory]
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/local/hadoop/share/hadoop/common/lib/slf4j-reload4j-1.7.36.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/local/hbase/lib/client-facing-thirdparty/slf4j-reload4j-1.7.33.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Reload4jLoggerFactory]
127.0.0.1: running zookeeper, logging to /usr/local/hbase/bin/../logs/hbase-hadoop-zookeeper-node1.out
running master, logging to /usr/local/hbase/bin/../logs/hbase-hadoop-master-node1.out
: running regionserver, logging to /usr/local/hbase/bin/../logs/hbase-hadoop-regionserver-node1.out
```
当成功启动后，会增加3个进程：HMaster, HQuorumPeer, HRegionServer。
```
hadoop@node1:/usr/local/hbase$ jps
29808 Jps
21441 DataNode
21348 NameNode
29556 HRegionServer
21637 SecondaryNameNode
29365 HMaster
``` 
此时访问网页：http://localhost:16010 ：       
![image](https://user-images.githubusercontent.com/67671683/220579969-6aa92797-ce29-40f1-84c8-d41a57f1634a.png)

并且此时可以看到/hbase存储在HDFS上：      
![image](https://user-images.githubusercontent.com/67671683/220580072-69d8d312-2882-41b4-9cd8-d6beca4b1465.png)

通过命令行也可以查看到：
```
hadoop@node1:/usr/local/hbase$ hadoop fs -ls /
Found 1 items
drwxr-xr-x   - hadoop supergroup          0 2023-02-20 20:03 /hbase
```

### 3.4 集群测试
进入shell：    
```
hadoop@node1:/usr/local/hbase$ hbase shell
创建table；test123
hbase:055:0> create 'test123', 'cf'
Created table test123
Took 1.1293 seconds                                                                                                         
=> Hbase::Table - test123
```

插入数据：  
```
hbase:056:0> put 'test123', 'row1', 'cf:a', 'value100'
Took 0.0209 seconds                                                                                                         
hbase:057:0>  put 'test123', 'row2', 'cf:b', 'value200'
Took 0.0125 seconds  
```
此时可以看到/usr/local/hadoop/tmp/dfs/data/current/BP-1581270469-10.130.0.62-1676893644213/current/rbw目录下生成了文件了blk_xxxxxxxxxx，其中文件的内容便是put写入的内容。

## 4. 集群关闭
```
/usr/local/hbase/bin/stop-hbase.sh
/usr/local/hadoop/sbin/stop-dfs.sh
```

## 5. 参考
```
https://hbase.apache.org/book.html#quickstart
https://dblab.xmu.edu.cn/blog/2441/ 
https://dblab.xmu.edu.cn/blog/2442/ 
```


