# hadoop+hbase 完全分布式部署

## 1. 环境准备
这里部署使用两台机器：
```
10.130.0.80 node01 (作为master节点)
10.130.0.91 nodeo2（作为slave节点）
```
注意：由于这里是测试，使用两台机器，在实际应用中当部署hbase，由于涉及到zookeeper，所以在进行完全分布式部署时最好使用奇数台机器。

## 2. hadoop完全分布式部署
### 2.1 创建hadoop用户    
在两台机器上都执行以下操作：      
```
sudo useradd -m hadoop -s /bin/bash  //创建hadoop用户，并用/bin/bash作为shell
sudo passwd hadoop //添加密码
sudo adduser hadoop sudo  //为hadoop用户增加管理员权限，方便部署
```
退出机器，使用hadoop用户进行登录

### 2.2 安装openjdk
在两台机器上都执行以下操作：
```
apt install -y openjdk-8-jdk
```

在～/.bashrc中添加以下内容：
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64
export JRE_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```
```
source ~/.bashrc
```
java --version  //查看是否安装成功，出现以下内容则表示安装成功
```
hadoop@node02:/usr/local/hadoop$ java -version
openjdk version "1.8.0_352"
OpenJDK Runtime Environment (Loongson 8.1.12-loongarch64-Loongnix) (build 1.8.0_352-b08)
OpenJDK 64-Bit Server VM (build 25.352-b08, mixed mode)
```

### 2.3 设置机器名称
10.130.0.80机器：执行命令“sudo vim /etc/hostname”写入node01(作为master节点)     
10.130.0.91机器：执行命令“sudo vim /etc/hostname”写入node02     
在两个机器的/etc/hosts文件中写入：      
```
10.130.0.80 node01
10.130.0.91 node02
```
分别重启两台机器，并使用hadoop用户登录      
在两个机器上都执行以下的命令，测试是否相互能ping通：     
```
ping node01 -c 3  //ping 3次自动停止
ping node02 -c 3 
```

### 2.4 ssh无密码登录
部署hadoop必须要让master节点(node01)无密码登录到各个节点上。    
首先，生成node01的公匙，因为对主机名进行了修改，所以之前若生成过，必须删除重新生成。具体命令如下：     
```
cd ~/.ssh  //若没有该目录，先执行一次ssh localhost
rm ./id_rsa* //删除之前生成的公匙（若存在）
ssh-keygen -t rsa  //执行该命令后，遇到提示信息，一直按回车即可
```

#### 2.4.1 node01节点无密码登录本机
```
cat ./id_rsa.pub  >> ./authorized_keys
ssh node01 //可能会遇到提示信息，输入yes即可
exit  // ssh无密码登录测试成功后，退回原来的终端
```

#### 2.4.2 node01节点无密码登录node02:
将node01的密钥传到node02上:
```
scp ~/.ssh/id_rsa.pub hadoop@node02:/home/hadoop/
```
在node02执行以下操作：
```
mkdir ~/.ssh //若已经存在，则忽略该命令
cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
rm ~/id_rsa.pub 
```

### 2.5 安装hadoop-3.3.4
在master节点（node01）上执行：
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
```
source ~/.bashrc
```

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

### 2.6 配置集群/分布式环境
在进行分布式部署时，需要修改/usr/local/hadoop/etc/hadoop目录下的配置文件，这里仅仅配置了正常启动所必须的设置项：workres, core-site.xml, hdfs-site.xml, mapred-site.xml, yarm-site.xml, hadoop-env.sh 6个文件。
详细的配置文件内容，可以通过官方https://hadoop.apache.org/docs/stable/index.html 最底部的Configuration部分进行学习和查看。

#### 2.6.1 主(node01)节点操作
##### workers
该文件中记录了所有作为数据节点的主机名称，默认为localhost(即把本机作为数据节点)，此时表示本机即作为名称节点也作为数据节点。在本次部署中让master(node01)充当名称节点和数据节点，node02作为数据节点，故写入的内容如下：
```
node01
node02
```
##### hadoop-env.sh
在该文件中设置JAVA_HOME参数：
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64
```
##### core-site.xml
该文件是hadoop的核心全局配置文件，可在其他配置文件中引用该文件     
```
core-site.xml
<configuration>
        <property>
<!--指定文件系统(namenode)的地址是node01，端口号 是9000-->
                <name>fs.defaultFS</name>
                <value>hdfs://node01:9000</value>
        </property>
        <property>
<!--  配置hadoop的临时目录 -->
                <name>hadoop.tmp.dir</name>
                <value>file:/usr/local/hadoop/tmp</value> 
                <description>A base for other temporary directories.</description>
        </property>
</configuration>
```
备注：
fs.defaultFS: 用来配置HDFS的主进程NameNode的运行主机（也就是hadoop集群的主节点位置）
hadoop.tmp.dir ：设置临时文件的路径

##### hdfs-site.xml
该文件用于设置HDFS的NameNode和DataNode
```
<configuration>
<!-- 指定secondary namenode的http服务器的地址和端口-->
        <property>
                <name>dfs.namenode.secondary.http-address</name>
                <value>node01:50090</value>
        </property>
<!-- 指定HDFS副本的数量-->
        <property>
                <name>dfs.replication</name>
                <value>2</value>
        </property>
<!-- 指定DFS名称表（名称节点）的存储位置-->
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:/usr/local/hadoop/tmp/dfs/name</value>
        </property>
<!-- 指定DFS数据表（数据节点）的存储位置-->
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:/usr/local/hadoop/tmp/dfs/data</value>
        </property>
</configuration>
```
备注：
dfs: 确定DFS名称节点应在本地文件系统上的哪个位置存储名称表。如果是以逗号分隔的目录列表，则名称表将复制到所有目录中，以实现副本。

##### mapred-site.xml
该文件是MapReduce的核心配置文件，用于指定MapReduce运行时框架
```
<configuration>
<!-- 指定MapReduce的运行时框架-->
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
        </property>
<!-- 指定服务器IPC的主机：端口号-->
        <property>
                <name>mapreduce.jobhistory.address</name>
                <value>node01:10020</value>
        </property>
<!-- 指定服务器Web UI的主机：端口号-->
        <property>
                <name>mapreduce.jobhistory.webapp.address</name>
                <value>node01:19888</value>
        </property>
        <property>
                <name>yarn.app.mapreduce.am.env</name>
                <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        </property>
        <property>
                <name>mapreduce.map.env</name>
                <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        </property>
        <property>
                <name>mapreduce.reduce.env</name>
                <value>HADOOP_MAPRED_HOME=/usr/local/hadoop</value>
        </property> 
</configuration>
```
备注：
mapreduce.framework.name：用来指定MapReduce的运行时框架，有local,yarn和classic三种模式。
yarn.app.mapreduce.am.env: 用户为MapReduce APP master进程添加的环境变量

##### yarn-site.xml
本文件是yarn框架的核心配置文件，需要指定yarn集群的管理者
```
<configuration>
<!-- 指定yarn集群管理者的地址-->
        <property>
                <name>yarn.resourcemanager.hostname</name>
                <value>node01</value>
        </property>
        <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
</configuration>
```
备注：上述配置文件中，配置了yarn的主进程ResourceManager运行主机为node01，同时配置了NodeManager运行时的附属服务，需要配置为mapreduce_shuffle才能正常运行MapReduce的默认程序。


#### 2.6.2 从（node02）节点操作
上面6个配置文件完成后，需要把主节点上的/usr/local/hadoop文件夹复制到各个节点上。在node02上执行以下操作：
```
sudo chown -R hadoop /usr/local/hadoop
```

### 2.7 集群启动
#### 2.7.1 主(node01)节点操作
(1)在主节点上执行执行名称节点的格式化，只需要执行一次，后面再启动hadoop时，不需要再次格式化名称节点（若需要重新进行格式化，则删除tmp和log目录）。
执行命令：
```
hdfs namenode -format
```
当出现以下内容时表示格式化成功：
```
2023-02-09 11:45:44,384 INFO namenode.FSImage: Allocated new BlockPoolId: BP-2007561254-10.130.0.80-1675914344373
2023-02-09 11:45:44,400 INFO common.Storage: Storage directory /usr/local/hadoop/tmp/dfs/name has been successfully formatted.
2023-02-09 11:45:44,436 INFO namenode.FSImageFormatProtobuf: Saving image file /usr/local/hadoop/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 using no compression
2023-02-09 11:45:44,592 INFO namenode.FSImageFormatProtobuf: Image file /usr/local/hadoop/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 of size 401 bytes saved in 0 seconds .
2023-02-09 11:45:44,611 INFO namenode.NNStorageRetentionManager: Going to retain 1 images with txid >= 0
2023-02-09 11:45:44,647 INFO namenode.FSNamesystem: Stopping services started for active state
2023-02-09 11:45:44,648 INFO namenode.FSNamesystem: Stopping services started for standby state
2023-02-09 11:45:44,652 INFO namenode.FSImage: FSImageSaver clean checkpoint: txid=0 when meet shutdown.
2023-02-09 11:45:44,652 INFO namenode.NameNode: SHUTDOWN_MSG:
/************************************************************
SHUTDOWN_MSG: Shutting down NameNode at node01/10.130.0.80
************************************************************/
```

(2)启动hadoop
```
start-dfs.sh   //	启动HDFS集群
start-yarn.sh  //启动yarn集群
mr-jobhistory-daemon.sh start historyserver
```

(3)查看启动的进程
若正确启动，在主节点上可以看到以下几个进程：
```
hadoop@node01:/usr/local/hadoop$ jps
18449 ResourceManager
19723 JobHistoryServer
19803 Jps
18061 DataNode
18541 NodeManager
18238 SecondaryNameNode
17967 NameNode
```

(4)查看启动的数据节点
```
hadoop@node01:/usr/local/hadoop$ hdfs dfsadmin -report
......
Live datanodes (2):

Name: 10.130.0.80:9866 (node01)
Hostname: node01
Decommission Status : Normal
Configured Capacity: 44310081536 (41.27 GB)
DFS Used: 8192 (8 KB)
Non DFS Used: 12885385216 (12.00 GB)
DFS Remaining: 31424688128 (29.27 GB)
DFS Used%: 0.00%
DFS Remaining%: 70.92%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
Last contact: Thu Feb 09 20:22:37 CST 2023
Last Block Report: Thu Feb 09 18:49:10 CST 2023
Num of Blocks: 0


Name: 10.130.0.91:9866 (node02)
Hostname: node02
Decommission Status : Normal
Configured Capacity: 44310081536 (41.27 GB)
DFS Used: 8192 (8 KB)
Non DFS Used: 10843045888 (10.10 GB)
DFS Remaining: 33467027456 (31.17 GB)
DFS Used%: 0.00%
DFS Remaining%: 75.53%
Configured Cache Capacity: 0 (0 B)
Cache Used: 0 (0 B)
Cache Remaining: 0 (0 B)
Cache Used%: 100.00%
Cache Remaining%: 0.00%
Xceivers: 0
```
可以看到启动的数据节点有2个，node01和node02，与前面在配置文件hdfs-site.xml中的设置一致。

#### 2.7.2 从(node02)节点操作
在主节点启动服务后，在从节点上可以看到启动了两个进程DataNode和NodeManager。
```
hadoop@node02:/usr/local/hadoop$ jps
11349 DataNode
11467 NodeManager
11819 Jps
```

#### 2.7.3 通过UI界面查看hadoop运行状态
在浏览器中输入http://10.130.0.80:9870 查看HDFS集群状态。
![image](https://user-images.githubusercontent.com/67671683/220589853-836bb0e3-2f96-46e6-94f9-fae97e2a9b06.png)

在浏览器中输入http://10.130.0.80:8088，查看yarn集群状态：
![image](https://user-images.githubusercontent.com/67671683/220589919-5463d403-23ea-496d-a955-f119e5cd0ab4.png)

### 2.8 集群测试
#### 2.8.1 命令行操作（主节点node01）
（1）创建HDFS用户实例
```
hdfs dfs -mkdir -p /user/hadoop
```
此时在Browse the file system中可以看到创建的用户目录：

![image](https://user-images.githubusercontent.com/67671683/220593396-d315d372-636e-4258-af74-67fb5e3bdc05.png)
![image](https://user-images.githubusercontent.com/67671683/220593453-d8c4253a-37c7-4a54-b6c1-ae5cd832597d.png)
![image](https://user-images.githubusercontent.com/67671683/220593475-6f4135fa-368f-4af8-9618-2b92db2a1f05.png)

通过hdfs dfs -ls / 可以查看到hdfs的根目录下存储的文件：
```
hadoop@node01:/usr/local/hadoop$ hdfs dfs -ls /
Found 2 items
drwxrwx---   - hadoop supergroup          0 2023-02-20 09:31 /tmp
drwxr-xr-x   - hadoop supergroup          0 2023-02-20 09:35 /user
```

（2）在HDFS中创建input目录，将要操作的文件保存在该目录下
```
hdfs dfs -mkdir input
hdfs dfs -put /usr/local/hadoop/etc/hadoop/*.xml input
```
（3）运行MapReduce作业
```
cd  /usr/local/hadoop/share/hadoop/mapreduce
hadoop@node01:/usr/local/hadoop/share/hadoop/mapreduce$ hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar grep input output 'dfs[a-z.]+'
2023-02-09 20:42:05,830 INFO client.DefaultNoHARMFailoverProxyProvider: Connecting to ResourceManager at node01/10.130.0.80:8032
2023-02-09 20:42:06,461 INFO mapreduce.JobResourceUploader: Disabling Erasure Coding for path: /tmp/hadoop-yarn/staging/hadoop/.staging/job_1675933900726_0001
2023-02-09 20:42:07,603 INFO input.FileInputFormat: Total input files to process : 0
2023-02-09 20:42:07,671 INFO mapreduce.JobSubmitter: number of splits:0
2023-02-09 20:42:07,845 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1675933900726_0001
2023-02-09 20:42:07,845 INFO mapreduce.JobSubmitter: Executing with tokens: []
```
备注：
hadoop jar xxx表示执行一个hadoop的jar包程序，grep表示执行jar包程序中的搜索功能呢个，input表示搜索的HDFS文件路径，out表示搜索完成后输出HDFS的结果路径。


在【Utilities】→【Browse the file system】→【usr】→【hadoop】下可以看到生成了output目录：
![image](https://user-images.githubusercontent.com/67671683/220593750-a04602c9-4d8f-453e-b28b-866a4989df25.png)
![image](https://user-images.githubusercontent.com/67671683/220593792-5d55bf92-82b3-4a5e-a512-49ee000edf4f.png)

在【output】下可以看到有两个文件，_SUCCESS表示此次任务执行成功，part-r-0000中存储了grep的结果。单击part-r-0000可以将文件下载到本地，查看其中的内容如下：
```
1	dfsadmin
1	dfs.replication
1	dfs.namenode.secondary.http
1	dfs.namenode.name.dir
1	dfs.datanode.data.dir
```

#### 2.8.2 网页端上传文件
点击下图中的上传按钮，上传文件：

![image](https://user-images.githubusercontent.com/67671683/220593934-b370e76c-30a7-4601-9415-769c552c8245.png)

注意：
打开浏览器的机器上需要添加以下配置：
/etc/hosts:
```
10.130.0.80 node01
10.130.0.91 node02
```
备注：要关闭代理服务器，否则会导致访问失败。

#### 2.8.3 网页端查看文件
![image](https://user-images.githubusercontent.com/67671683/220595335-dc0249b3-6ba0-4347-b66a-88f9491dda4c.png)

点击下图中的Download便可以下载文件，Head/Tail the file可以查看文件:
![image](https://user-images.githubusercontent.com/67671683/220595394-251c3c9d-8b10-4ff5-a98a-b94f5c6822a7.png)

备注：
1）hdfs存放文件的位置位于节点的datanode路径下，本次部署存放文件的具体目录是：    
```
“/usr/local/hadoop/tmp/dfs/data/current/BP-1730813420-10.130.0.137-1676856486892/current/finalized/subdir0/subdir0”。
```
因为hdfs存放文件是按照块存储的，所以存储文件的名称与实际文件的名称并不一致，如上图中上传的文件“解决冲突”，实际文件名称是：blk_1073741826, vim该文件可以查看到具体的存储内容。       
2）因为本次部署使用了2个数据备份，所以在node01和node02上都存在块文件blk_1073741826。    

## 3.hbase完全分布式部署
### 3.1 安装hbase-2.4.16
在master(node01)节点上执行:
```
sudo tar -xf hbase-2.4.16-bin.tar.gz
sudo mv hbase-2.4.16 hbase
sudo chown -R hadoop  ./hbase
```
在～/.bashrc中添加：
```
export HBASE_HOME=/usr/local/hbase
export PATH=$PATH:$HBASE_HOME/bin
```

### 3.2 修改配置文件
#### 3.2.1 主节点（node01）操作
##### 3.2.1.1 hbase-env.sh
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-loongarch64
export HBASE_MANAGES_ZK=true   #表示使用hbase自带的zookeeper,若要使用自己单独部署的zookeeper集群，则将true设置为false
```
##### 3.2.1.2 hbase-site.xml
```
<configuration>
 <!-- 指定hbase在hdfs上存储数据的文件夹，端口要和hadoop的core-site.xml文件中设置的端口号一致-->
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://node01:9000/hbase</value>
  </property>
<!-- 指定hbase的master主机名和端口 -->
  <property>
    <name>hbase.master</name>
    <value>node01:60000</value>
  </property>
  <!-- 指定hbase的部署方式 -->
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
 <!-- 指定hbase的临时目录 -->
  <property>
    <name>hbase.tmp.dir</name>
    <value>/usr/local/hbase/tmp</value>
  </property>
  <property>
    <name>hbase.unsafe.stream.capability.enforce</name>
    <value>false</value>
  </property>
  <!-- 指定zookeeper集群的主机名 -->
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>node01,node02</value>
  </property>
</configuration>
```

##### 3.2.1.3 regionserver
配置所有作为数据节点的主机名，在本次部署中主节点也作为数据节点，所以配置如下：
```
node01
node02
```

#### 3.2.2 从节点(node02)操作
将主节点上配置好的hbase传到从节点上：
```
scp -r hbase hadoop@node01:/usr/local
sudo chown -R hadoop ./hbase
```

在～/.bashrc中设置：
```
export HBASE_HOME=/usr/local/hbase
export PATH=$PATH:$HBASE_HOME/bin
```
```
source ~/.bashrc
```
### 3.3 集群启动
#### 3.3.1 主节点(node01)操作
```
hadoop@node01:/usr/local/hbase$ bin/start-hbase.sh 
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
node02: running zookeeper, logging to /usr/local/hbase/bin/../logs/hbase-hadoop-zookeeper-node02.out
node01: running zookeeper, logging to /usr/local/hbase/bin/../logs/hbase-hadoop-zookeeper-node01.out
running master, logging to /usr/local/hbase/logs/hbase-hadoop-master-node01.out
node01: running regionserver, logging to /usr/local/hbase/bin/../logs/hbase-hadoop-regionserver-node01.out
node02: running regionserver, logging to /usr/local/hbase/bin/../logs/hbase-hadoop-regionserver-node02.out
```
通过jps查看启动的进程:
```
hadoop@node01:/usr/local/hbase$ jps
10034 HMaster
26565 NodeManager
25975 NameNode
26072 DataNode
9928 HQuorumPeer
26473 ResourceManager
27001 JobHistoryServer
26252 SecondaryNameNode
10590 Jps
10239 HRegionServer
```
若成功启动此时可以发现新增加了3个进程：HMaster(hbase master进程), HQuorumPeer（zookeeper进程）, HRegionServer（hbase region server进程）。

同时，可以看到hbase目录已经挂载到hdfs的根目录下:
```
hadoop@node01:/usr/local/hbase$ hdfs dfs -ls /
Found 5 items
drwxr-xr-x   - hadoop supergroup          0 2023-02-22 14:28 /hbase
drwxrwx---   - hadoop supergroup          0 2023-02-20 09:31 /tmp
drwxr-xr-x   - hadoop supergroup          0 2023-02-20 09:35 /user
-rw-r--r--   2 dr.who supergroup       3441 2023-02-20 09:40 /解决冲突
```
此时，在hadoop的集群中也能看到hbase文件夹。

![image](https://user-images.githubusercontent.com/67671683/220596088-19fa056f-c4e8-4ce6-b16f-72e82b9294e9.png)

#### 3.3.2 从节点(node02)操作
```
hadoop@node02:/usr/local/hbase$ jps
15457 NodeManager
20930 HQuorumPeer
21063 HRegionServer
15785 DataNode
21593 Jps
```
可以发现新增加了2个进程：HQuorumPeer和HRegionServer

#### 3.3.3 通过UI界面查看hbase运行状态
在浏览器中输入http://10.130.0.80:16010 或者输入 http://node01:16010 可以进行查看。
![image](https://user-images.githubusercontent.com/67671683/220596234-a42bc628-958f-4a5f-9c87-d30d6504732e.png)

### 3.4 集群测试
进入shell:   
```
hadoop@node1:/usr/local/hbase$ hbase shell
创建table；test123
hbase:055:0> create 'test123', 'cf'
Created table test123
Took 1.1293 seconds                                                                                                         
=> Hbase::Table - test123
```

插入数据
```
hbase:056:0> put 'test123', 'row1', 'cf:a', 'value100'
Took 0.0209 seconds                                                                                                         
hbase:057:0>  put 'test123', 'row2', 'cf:b', 'value200'
Took 0.0125 seconds  
```
此时可以看到/usr/local/hadoop/tmp/dfs/data/current/BP-1581270469-10.130.0.62-1676893644213/current/rbw目录下生成了文件了blk_xxxxxxxxxx，其中文件的内容便是put写入的内容。     
hadoop@node02:/usr/local/hadoop/tmp/dfs/data/current/BP-1730813420-10.130.0.137-1676856486892$ grep -rn value200       
匹配到二进制文件 current/rbw/blk_1073741851     
## 4. 集群关闭
```
/usr/local/hbase/bin/stop-hbase.sh
/usr/local/hadoop/sbin/stop-dfs.sh
/usr/local/hadoop/sbin/stop-yarn.sh
```

## 5. 问题记录
hadoop上传文件错误
在上传文件时，出现下图中的Couldn’t upload the file xxx。
![image](https://user-images.githubusercontent.com/67671683/220596595-43efdedc-7b89-4188-8d26-95120eb4282a.png)

F12, 查看浏览器错误信息，如下。通过下面的信息是访问权限的问题。
![image](https://user-images.githubusercontent.com/67671683/220596645-c6c0dc08-2553-4e23-9eb8-7ead6074a1d1.png)

解决方法：
   在主节点node01执行命令“hdfs dfs -chmod 777 / ”，此时再重新上传便可以上传成功。
   ![image](https://user-images.githubusercontent.com/67671683/220596688-ed0767f6-c210-4173-ae55-ffb1ddb8e153.png)

## 6. 参考
```
https://book.itheima.net/course/1269935677353533441/1269937996044476418/1269939156776165379 
https://dblab.xmu.edu.cn/blog/2775/ 
https://dblab.xmu.edu.cn/blog/2441/ 
https://blog.csdn.net/qq_42886289/article/details/90682592 
```

## 7. 附录
HDFS体系主要由namenode和datanode组成。
namenode: 整个文件系统的管理节点，它维护着整个文件系统的文件目录树，文件/目录的元信息和每个文件对应的数据块列表，接收用户的操作请求。
namenode包含的文件有：
1）fsimage文件：元数据镜像。存储某一个时间namenode内存元数据信息，记录文件分块存储在哪几个数据节点上。
2）edits文件：操作日志文件。
3）fstime文件：保存最近一次checkpoint的时间

secondarynamenode: 
1）是HA的一个解决方案。但不支持热备份，配置即可。
2）执行过程：从namenode上下载元数据信息(fsimage,edits)，然后把二者合并，生成新的fsimage，在本地保存，并将其推送到namenode，同时重置namenode的edits。
3）默认安装在namenode节点上。

datanode提供真实文件数据的存储服务，主要包括：
1）文件块：最基本的存储单元。对于文件内容而言，一个文件的长度大小是size,则从文件的0偏移开始，按照固定的大小，顺序对文件进行划分并编号，划分好的每一个块称一个block;
2）不同于普通文件系统的是，hdfs中，如果一个文件小于一个数据块的大小，并不占用整个数据块的存储空间，而是占用实际大小的存储空间。
3）Replication:多副本，默认是3个。


