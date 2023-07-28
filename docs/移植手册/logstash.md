# logstash
本文以构建龙芯平台 logstash 7.13.0 镜像为例，说明 logstash 7.13.0 在龙芯平台上的移植思路及详细过程记录。

## 移植思路
首先找到 Dockerfile
https://github.com/elastic/dockerfiles/blob/v7.13.0/logstash/Dockerfile
整个 Dockerfile 最重要的就是下载一个对应 ARCH 版本的 logstash release tar 包。
```
# Add Logstash itself.
RUN curl -Lo - https://artifacts.elastic.co/downloads/logstash/logstash-7.13.0-linux-$(arch).tar.gz | \
    tar zxf - -C /usr/share && \
    mv /usr/share/logstash-7.13.0 /usr/share/logstash && \
    chown --recursive logstash:logstash /usr/share/logstash/ && \
    chown -R logstash:root /usr/share/logstash && \
    chmod -R g=u /usr/share/logstash && \
    mkdir /licenses/ && \
    mv /usr/share/logstash/NOTICE.TXT /licenses/NOTICE.TXT && \
    mv /usr/share/logstash/LICENSE.txt /licenses/LICENSE.txt && \
    find /usr/share/logstash -type d -exec chmod g+s {} \; && \
    ln -s /usr/share/logstash /opt/logstash                                                                                                                                                                                                                                                                                                                                                                    
```                                       

这个二进制 tar 包是通过以下命令构建的
```
./gradlew assembleTarDistribution
./gradlew assembleZipDistribution
```
https://github.com/elastic/logstash/tree/v7.13.0#building-artifacts

这里并不使用从源码构建的方式直接构建 logstash。因为 logstash 是解释性语言，在构建时会下载编译好的文件，这些文件我们无法直接使用，也没有办法替换。所以，考虑 logstash 的运行原理，可以直接基于x86 版本的 logstash release tar 包，替换掉其中的架构相关的文件即可。

## 哪些是架构相关
根据 logstash 结构，logstash 是由 jruby 驱动，jruby 由 java 驱动。除此之外，jruby 使用了 jnr 技术调用 c 库以直接调用一些系统功能。我们能判断出至少 jruby 和 jnr 部分是需要移植的，其关系图如下。基于这个关系图，我们应该`从下往上`依次编译移植。其中 jnr 只是一个概念，不是一个具体的项目。                                                                               
![Untitled Diagram (1).jpg](https://upload-images.jianshu.io/upload_images/22834193-aba60918285c3214.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 版本信息
logstash https://github.com/elastic/logstash/blob/v7.13.0/versions.yml#L15
jruby https://github.com/jruby/jruby/blob/9.2.16.0/core/pom.rb#L46
https://github.com/jruby/jruby/blob/master/pom.xml#L116
根据以上信息，确认需要移植的组件版本，然后移植各个组件
- jffi 1.3.1
- jnr-ffi 2.2.1
- jnr-constants 0.10.1
- jnr-posix 3.1.4
- jruby 9.2.16.0

## jffi 
https://github.com/jnr/jffi/tree/jffi-1.3.1
下载源码
`git clone -b jffi-1.3.1 --depth=1 https://github.com/jnr/jffi.git`

jffi 是以 libffi 为基础封装的，所以首先需要替换龙芯适配的 libffi。然后再做一些小的修改即可。
具体参考 https://gitee.com/merore/jffi/commit/9987e94ce56612acd8cfeb0c3cec5adefb905c1c

准备编译环境
```
yum install  ant ant-junit java gcc gcc-c++ make diffutils rpmdevtools automake texinfo maven
```

运行测试，保证全部通过
```
ant test
```

编译安装（maven组织形式）
```
ant jar
ant archive-platform-jar
mvn pacakge
mvn install
```

## jnr-constant
jnr-constant 多架构（包括LoongArch64）补丁已合入上游。在此演示针对某一版本进行移植。
下载 0.10.1 版本的源码，该版本尚不支持LoongArch。
```
git clone -b jnr-constants-0.10.1 --depth=1 https://github.com/jnr/jnr-constants.git
```
首先根据这个补丁，修改 Rakefile 文件，使其支持生成当前平台补丁的功能。
https://github.com/jnr/jnr-constants/pull/98/commits/39bae9852bc1dbb6a9024d35a2474b5e5a932be5

然后执行命令生成本地
```
yum install ruby ruby-devel rake libffi-devel
gem install ffi
rake generate:lplatform
```
然后编译安装即可
```
mvn package
mvn install
```

## jnr-ffi
下载对应版本的源码
```
git clone -b jnr-ffi-2.2.1 --depth=1 https://github.com/jnr/jnr-ffi.git
```
参照该补丁移植
https://gitee.com/merore/jnr-ffi/commit/12d471b09bb8b99e62c1ea23d0a3b58a18f28d7c

运行测试，保证全部通过
```
./mvnw test
```
编译安装（保证前边的已经编译安装完成）
```
./mvnw package
./mvnw install
```

## jnr-posix
下载源码
```
git clone -b jnr-posix-3.1.4 --depth=1 https://github.com/jnr/jnr-posix.git
```
参照该补丁移植
https://gitee.com/merore/jnr-posix/commit/64ae42bfff1105843ac18e0ddac5506ef3b390ca

执行测试
这里测试不能过，一般情况下仅有这6个测试不通过。
```
mvn test

Results :

Failed tests: 
  FileTest.accessTest:509 access /tmp/jnr-posix-access-test4690482981282283296tmp for write:  expected:<-1> but was:<0>
  IOTest.testSendRecvMsg_WithControl:204 null
  LinuxPOSIXTest.testMessageHdrMultipleControl:139 Error with sendmsg: Invalid argument
  ProcessTest.testGetRLimit:49 Bad soft limit for number of processes
  ProcessTest.testGetRLimitPointer:83 Bad soft limit for number of processes
  ProcessTest.testGetRLimitPreallocatedRlimit:66 Bad soft limit for number of processes

Tests run: 100, Failures: 6, Errors: 0, Skipped: 0
```
以跳过测试的方式打包安装
```
mvn package -DskipTests=true
mvn install -DskipTests=true
```
至此，jnr 系列已全部移植并安装完成。

## jruby
下载源码
```
git clone -b 9.2.16.0 --depth=1 https://github.com/jruby/jruby.git
```
参照该补丁进行移植
https://gitee.com/merore/jruby/commit/3442e306e9e594ee39a98669912cda7854a49ce3

编译打包
```
./mvnw
./mvnw -Pdist
./mvnw -Pcomplete
```
其中编译出后续需要的文件`maven/jruby-dist/target/jruby-dist-9.2.16.0-bin.tar.gz`，`maven/jruby-complete/target/jruby-complete-9.2.16.0.jar`

## 替换 logstash 中的 jruby
x86 logstash release 包中需要替换三处，`jdk`,`vendor/jruby`，`logstash-core/lib/jars/jruby-complete-9.2.16.0.jar`， 

其中 `vendor/jruby` 使用 jruby-dist 解压替换。jdk 使用龙芯 jdk 替换即可。


## java版本选择
tar 包中包含了一个 x86 版本的jdk。查看这个 jdk 的信息，是 java 11 版本。目前我拿不到 java11。但我们并不一定也需要对应的版本，因为 class 文件是虚拟机解释执行，只需要 class 文件版本和java虚拟机版本能兼容即可。
```
wget https://artifacts.elastic.co/downloads/logstash/logstash-7.13.0-linux-x86_64.tar.gz

[root@9aa709805e36 logstash-7.13.0]# ls
bin  config  CONTRIBUTORS  data  Gemfile  Gemfile.lock	jdk  lib  LICENSE.txt  logstash-core  logstash-core-plugin-api	modules  NOTICE.TXT  tools  vendor  x-pack

[root@9aa709805e36 jdk]# cat release 
IMPLEMENTOR="AdoptOpenJDK"
IMPLEMENTOR_VERSION="AdoptOpenJDK"
JAVA_VERSION="11.0.10"
JAVA_VERSION_DATE="2021-01-19"
MODULES="java.base java.compiler java.datatransfer java.xml java.prefs java.desktop java.instrument java.logging java.management java.security.sasl java.naming java.rmi java.management.rmi java.net.http java.scripting java.security.jgss java.transaction.xa java.sql java.sql.rowset java.xml.crypto java.se java.smartcardio jdk.accessibility jdk.internal.vm.ci jdk.management jdk.unsupported jdk.internal.vm.compiler jdk.aot jdk.internal.jvmstat jdk.attach jdk.charsets jdk.compiler jdk.crypto.ec jdk.crypto.cryptoki jdk.dynalink jdk.internal.ed jdk.editpad jdk.hotspot.agent jdk.httpserver jdk.internal.le jdk.internal.opt jdk.internal.vm.compiler.management jdk.jartool jdk.javadoc jdk.jcmd jdk.management.agent jdk.jconsole jdk.jdeps jdk.jdwp.agent jdk.jdi jdk.jfr jdk.jlink jdk.jshell jdk.jsobject jdk.jstatd jdk.localedata jdk.management.jfr jdk.naming.dns jdk.naming.ldap jdk.naming.rmi jdk.net jdk.pack jdk.rmic jdk.scripting.nashorn jdk.scripting.nashorn.shell jdk.sctp jdk.security.auth jdk.security.jgss jdk.unsupported.desktop jdk.xml.dom jdk.zipfs"
OS_ARCH="x86_64"
OS_NAME="Linux"
SOURCE=".:git:f16a065dd6d5"
BUILD_SOURCE="git:10223734"
FULL_VERSION="11.0.10+9"
SEMANTIC_VERSION="11.0.10+9"
BUILD_INFO="OS: Linux Version: 4.15.0-1103-azure"
JVM_VARIANT="Hotspot"
JVM_VERSION="11.0.10+9"
IMAGE_TYPE="JDK"
```
解压一个 logstash tar 包中原来的 jar 包。比如 `logstash-core/lib/jars/jruby-complete-9.2.16.0.jar`。使用 javap 查看编译的目标版本，52 对应的就是 java8。也就是说我们可以使用至少 java8 来运行这个 jar 包，也当然可以运行这个项目。在此就选择 java8 进行 jdk 的替换。
```
jar -xf jruby-complete-9.2.16.0.jar
[root@9aa709805e36 tmp]# javap -verbose org/jruby/Ruby\$1.class | grep major
  major version: 52
```

## 测试和打包
先打包替换完成的 logstash 二进制包，遵守命令规范。
```
tar -zcvf logstash-7.13.0-linux-loongarch64.tar.gz logstash-7.13.0
```
然后执行测试，因为执行测试后会在目录生成一些使用信息，所以先执行了打包做备份。
执行命令后按回车键，输出信息即可。
```
bin/logstash -e 'input { stdin{} } output { stdout{} }'


[root@9aa709805e36 logstash-7.13.0]#  bin/logstash -e 'input { stdin{} } output { stdout{} }'
Using bundled JDK: /root/logstash-7.13.0/jdk
OpenJDK 64-Bit Server VM warning: You have loaded library /tmp/jffi3206126205232206230.so which might have disabled stack guard. The VM will try to fix the stack guard now.
It's highly recommended that you fix the library with 'execstack -c <libfile>', or link it with '-z noexecstack'.
 Sending Logstash logs to /root/logstash-7.13.0/logs which is now configured via log4j2.properties
[2021-10-28T07:03:59,244][INFO ][logstash.runner          ] Log4j configuration path used is: /root/logstash-7.13.0/config/log4j2.properties
[2021-10-28T07:03:59,268][INFO ][logstash.runner          ] Starting Logstash {"logstash.version"=>"7.13.0", "jruby.version"=>"jruby 9.2.16.0 (2.5.7) 2021-10-26 0ff666f71a OpenJDK 64-Bit Server VM 25.302-b08 on 1.8.0_302-b08 +indy +jit [linux-loongarch64]"}
[2021-10-28T07:03:59,305][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.queue", :path=>"/root/logstash-7.13.0/data/queue"}
[2021-10-28T07:03:59,324][INFO ][logstash.setting.writabledirectory] Creating directory {:setting=>"path.dead_letter_queue", :path=>"/root/logstash-7.13.0/data/dead_letter_queue"}
[2021-10-28T07:03:59,811][WARN ][logstash.config.source.multilocal] Ignoring the 'pipelines.yml' file because modules or command line options are specified
[2021-10-28T07:03:59,861][INFO ][logstash.agent           ] No persistent UUID file found. Generating new UUID {:uuid=>"869bb54b-3538-414c-9d01-7a0284077576", :path=>"/root/logstash-7.13.0/data/uuid"}
[2021-10-28T07:04:01,181][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
[2021-10-28T07:04:01,584][INFO ][org.reflections.Reflections] Reflections took 73 ms to scan 1 urls, producing 24 keys and 48 values 
[2021-10-28T07:04:04,615][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>"main", "pipeline.workers"=>4, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>50, "pipeline.max_inflight"=>500, "pipeline.sources"=>["config string"], :thread=>"#<Thread:0x54f267cd run>"}
[2021-10-28T07:04:05,873][INFO ][logstash.javapipeline    ][main] Pipeline Java execution initialization time {"seconds"=>1.25}
[2021-10-28T07:04:05,941][INFO ][logstash.javapipeline    ][main] Pipeline started {"pipeline.id"=>"main"}
The stdin plugin is now waiting for input:
[2021-10-28T07:04:06,018][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}

{
    "@timestamp" => 2021-10-28T07:06:22.560Z,
       "message" => " ",
      "@version" => "1",
          "host" => "9aa709805e36"
}

```
