## 一、配置

### 1.1 maven 配置

- `/etc/maven/settings.xml`文件，下面的配置文件中需要将`proxy`部分替换为自己的`IP+PORT`：

```xml
<?xml version="1.0" encoding="UTF-8"?>

<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <pluginGroups>
  </pluginGroups>

  <proxies>
    <proxy>
      <id>xxx</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>x.x.x.x</host>
      <port>xxx</port>
      <nonProxyHosts>*.loongnix.cn|*.aliyun.com</nonProxyHosts>
    </proxy>
  </proxies>

  <servers>
  </servers>

  <mirrors>
      <mirror>
          <id>ali</id>
          <mirrorOf>central</mirrorOf>
          <name>Nexus ali</name>
          <url>http://maven.aliyun.com/nexus/content/groups/public</url>
      </mirror>
  </mirrors>

  <profiles>
    <profile>
    <id>loongson</id>
    <repositories>
    <repository>
        <id>loongson</id>
        <name>Loongson Maven</name>
        <url>https://maven.loongnix.cn/loongarchabi1/maven/</url>
        <releases><enabled>true</enabled></releases>
        <snapshots><enabled>true</enabled></snapshots>
    </repository>
    </repositories>
    <pluginRepositories>
    <pluginRepository>
        <id>loongson</id>
        <name>Loongson Maven</name>
        <url>https://maven.loongnix.cn/loongarchabi1/maven/</url>
        <releases><enabled>true</enabled></releases>
        <snapshots><enabled>true</enabled></snapshots>
    </pluginRepository>
    </pluginRepositories>
    </profile>
    <!-- ali -->
    <profile>
    <id>ali</id>
    <repositories>
    <repository>
        <id>ali</id>
        <name>ali Maven</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public</url>
        <releases><enabled>true</enabled></releases>
        <snapshots><enabled>true</enabled></snapshots>
    </repository>
    </repositories>
    <pluginRepositories>
    <pluginRepository>
        <id>ali</id>
        <name>ali Maven</name>
        <url>http://maven.aliyun.com/nexus/content/groups/public</url>
        <releases><enabled>true</enabled></releases>
        <snapshots><enabled>true</enabled></snapshots>
    </pluginRepository>
    </pluginRepositories>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>loongson</activeProfile>
    <!-- 
    <activeProfile>ali</activeProfile>
    -->
  </activeProfiles>
</settings>
```

## 二、构建

```
## 启动docker构建环境
docker run -d --name spark --hostname spark --network host cr.loongnix.cn/loongson/loongnix-server:8.4 bash -c "while true; do sleep 1;done"

## 安装相关软件，需要手动开启PowerTools和epel仓库
dnf install /usr/bin/mvn git vim java-1.8.0-openjdk-devel.loongarch64 wget python3 R libgomp libgfortran gcc

## 代码下载
git clone --branch loong64-v3.1.1 --depth=3 https://github.com/Loongson-Cloud-Community/spark.git

## 拉去龙芯maven源架构相关包(前提是已经配置过maven仓库)
mvn dependency:tree

## 构建过程中需要使用https://github.com/Loongson-Cloud-Community/zinc/releases/download/v0.3.15/zinc-0.3.15.tgz来覆盖build下的zinc

## 构建命令
./dev/make-distribution.sh --name spark-v3.1.1 --pip  --tgz -Psparkr -Phive -Phive-thriftserver -Pmesos -Pyarn -Dmaven.test.skip=true -Denforcer.skip=true
```

