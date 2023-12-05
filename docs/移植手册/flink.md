# flink

# 1.构建版本
release-1.14.6    

# 2.源码修改
见补丁: https://github.com/Loongson-Cloud-Community/flink/releases/download/release-1.14.6/loongarch64-1.14.6.patch

# 3.修改maven源
将maven源修改为龙芯源。
在文件/etc/maven/settings.xml 和 ~/.m2/settings.xml 中添加以下内容：      
```
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
```
```
  <activeProfiles>
        <activeProfile>loongson</activeProfile>
  </activeProfiles>
```

# 4.构建
```
mvn clean package -DskipTests
```
