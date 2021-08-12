# 龙芯 maven 源

## 使用方法

在 ~/.m2/settings.xml 中增加龙芯 maven 源
```
  <mirrors>
          <mirror>
                  <id>nexus</id>
                  <mirrorOf>*</mirrorOf>
                  <name>Public Repository Mirror</name>
                  <url>http://maven.loongnix.cn/repository/maven-public/</url>
          </mirror>
  </mirrors>

```

## 软件收录清单

### com.github.jnr - jffi
- 1.2.23
### com.github.jnr - jnr-ffi
- 2.1.12
### com.github.jnr - jnr-constants
- 0.9.15
### com.github.jnr - jnr-posix
- 3.0.54
