# mahout

## 1.构建版本
trunk分支，commit id: 343fc71f5338a627a6949a812b7ca76573981fef
对应的版本是14.2

## 2. 源码修改
不需要进行修改

## 3. 配置龙芯maven源
将maven源修改为龙芯源。 在文件/etc/maven/settings.xml 和 ~/.m2/settings.xml 中添加以下内容：    
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

## 4. 构建
```
mvn clean package -DskipTests
```
