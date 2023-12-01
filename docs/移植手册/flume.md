## 一、配置

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

```shell

## 启动构建环境
docker run -d --name flume --hostname flume --network host cr.loongnix.cn/openanolis/anolisos:8.8 bash -c "while true; do sleep 1;done"

## 安装相关软件
dnf install /usr/bin/mvn git vim java-1.8.0-openjdk-devel.loongarch64 -y

## 将maven配置文件替换为上述的配置文件

## 拉取适配了龙芯架构的源码信息
git clone --branch loong64-1.11.0 https://github.com/Loongson-Cloud-Community/flume.git

## 构建
mvn clean install -DskipTests -Dspotbugs.skip=true
```
