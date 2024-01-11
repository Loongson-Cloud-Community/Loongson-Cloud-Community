# ambari

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |ambari|
|版本       |2.7.0|
|项目地址   |[https://github.com/apache/ambari](https://github.com/apache/ambari)|
|官方指导   |[https://github.com/apache/ambari/tree/release-2.7.6/README.md](https://github.com/apache/ambari/tree/release-2.7.6/README.md)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |4.19.190-7.6.lns8.loongarch64|


## 移植步骤

__编译环境及依赖__
1. java 8
2. maven 3.3.9 及以下版本
3. python 2.7 and later
4. loongnix maven configure [龙芯maven仓库配置](http://docs.loongnix.cn/maven/user_guide.html)
5. mysql-connector-java gcc python-devel  python2-devel.loongarch64

__移植步骤__
1. 下载源码
   ` git clone -b release-2.7.0 --depth 1 https://github.com/apache/pulsar.git`
2. 也可以直接下载适配代码
   ` git clone -b loong64-2.7.0 --depth 1 [https://github.com/apache/pulsar.git](https://github.com/Loongson-Cloud-Community/pulsar.git)`
3. 修改配置文件
   ### 修改所有项目的pom文件
      - 项目由于对node依赖较高(4.x 0.x 8.x)，需要使用node编译前端界面及资源，而loongarch的node版本只有12.0+可以使用，实际编译发现无法替代，且需要node系列组件phantomjs虽然存在但无法使用，因此需要对ambari-admin ambari-web ambari-logsearch/ambari-logsearch-web ambari-views四个子项目的pom文件中node编译部分进行修改，由于前端资源与架构无关，因此将x86编译得到的相关资源进行下载解压并替代,更改node部分逻辑，关闭本地编译部分，增加下载解压部分
      - 对pom文件中部分maven插件版本 jar依赖版本 以及失效的依赖下载地址进行更新
      - pom文件中使用rpm-maven-plugin对项目进行rpm打包，而本身2.1.4不支持loongarch，需要修改版本为2.2.0,且修改<needarch>字段由noarch x86_64 到 loongarch
      - ambari-metrics/pom.xml 中下载了hbase hadoop grafana phoenix，进行替换
     注意：
	(1) 如果是使用patch进行构建编译的用户，最好将上述四个项目的url进行替换，更改为在目标平台构建好的版本
	(2) ambari原码对grafana版本依赖是2.6.0,但由于目前缺少2.6.0的构建依赖，使用现有版本6.4.0代替，后续如有问题及时反馈
   - 所有项目的pom文件中版本由<version>2.0.0.0-SNAPSHOT</version> 改为 <version>2.7.0.0.0</version>

   ### 修改.py的python使用声明
   - 暂未排出原因，需要将#!/usr/bin/env python 更改为 #!/usr/bin/env python2
   - 同样的 #!/usr/bin/python 到 #!/usr/bin/python2，注意项目中存在直接声明#!/usr/bin/python2.6的无需更改

   ### 修改源码
   - ambari-metrics/ambari-metrics-timelineservice/src/test/java/org/apache/ambari/metrics/core/timeline/AbstractMiniHBaseClusterTest.java部分修改
         tearDownMiniCluster();方法需要参数,修改为tearDownMiniCluster(1);
   - ambari-common/src/main/python/ambari_commons/libs目录下只有ppcl64及x86,在编译时需要添加loongarch部分，其中__init__.py部分相同，所需的 "posixsubprocess.so" 需要手动编译替换（怎么替换？）
   - ambari-common 部分os_check.py需要适配，该部分影响rpm编译完成安装后的使用，可能会报错：
	```
	ERROR: Unexpected error Ambari repo file path not set for current OS.
	ERROR: Exiting with exit code 1.
	REASON: Failed to create user. Exiting.
	```
        具体原因是由于在该文件对不同os的/etc/{os}-release进行了判断，分为redhat fedora centos等，而anlios loongnix server 同属于centos系，需要进行适配
   - 修改ambari-server 和 ambari-agent 的dependencies.properties，删除对python的依赖以及rpm-python的依赖

4. 编译
   由于项目需要下载较多依赖耗时较长，可以首先在本地将依赖下载并更改下载地址到本地，假设存储地址为/opt/compile-ambari

   下载hbase hadoop grafana phoenix  solr 以及 x86编译好的前端资源包
   infra项目还需要lucene 和 commons-fileupload-1.3.3.jar 也下载到/opt
/compile-ambari，接着将下载到本地的依赖在pom文件进行替换
   在主目录执行编译命令，可以先不进行rpm包打包(删掉以下指令的rpm部分)，节省时间
   ```
   mvn -B clean install package rpm:rpm -Drat.skip=true -DnewVersion=2.7.0.0.0 -DbuildNumber=631319b00937a8d04667d93714241d2a0cb17275 -DskipTests -Dpython.ver="python >= 2.6"
   ```
   添加-Drat.skip=true是为了跳过许可证过期的问题
   编译到ambari-metrics部分可能会出现编译中断，需要进入ambari-metrics部分进行编译
   ```
   mvn clean package install -Dbuild-rpm -DskipTests

   ```
   编译到ambari-logsearch部分可能会出现编译中断，需要进入ambari-logsearch部分编译，
   ```
   cd ambari-logsearch && mvn versions:set -DnewVersion=2.7.0.0.0 && mvn clean install package -P native,rpm -DskipTest
   ```
   编译结束后退出，对infra进行编译
   ```
   cd ambari-infra && mvn versions:set -DnewVersion=2.7.0.0.0 &&mvn clean package install -P rpm -DskipTest -Drat.skip=true
   ```
   编译完成的rpm包位于target/rpm/..目录下，jar包位于本地maven仓库
   ```
    find . -name "*.rpm" -exec cp {} path/to/ \; 将rpm包存放到指定位置
   ```
