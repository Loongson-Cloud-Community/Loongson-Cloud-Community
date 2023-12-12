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

### 1.2 npm 配置

- `~/.npmrc`

```
registry=https://registry.loongnix.cn:4873
```

## 二、构建

``` bash
## 启动构建环境
docker run -d --name alluxio --hostname alluxio --network host cr.loongnix.cn/loongson/loongnix-server:8.4 bash -c "while true; do sleep 1;done"

## 安装相关软件
dnf install /usr/bin/mvn git vim java-1.8.0-openjdk-devel.loongarch64 wget /usr/bin/g++ /usr/bin/node make /usr/bin/python2 /usr/bin/protoc fuse-devel -y

## 安装protobuf相关组件
dnf install /usr/bin/protoc
wget https://github.com/Loongson-Cloud-Community/nacos/releases/download/2.0.3/protoc-gen-grpc-java-la64-server.tar.gz
tar xzvf protoc-gen-grpc-java-la64-server.tar.gz
mv protoc-gen-grpc-java /usr/bin/

## 下载源码
git clone --branch loong64-v2.5.0 --depth=3 https://github.com/Loongson-Cloud-Community/alluxio.git

## 构建
mvn clean install -DskipTests -Dspotbugs.skip=true
```
