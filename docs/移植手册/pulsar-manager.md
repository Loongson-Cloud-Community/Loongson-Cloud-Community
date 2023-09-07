# pulsar-manager

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |pulsar-manager|
|版本       |v0.4.0|
|项目地址   |[https://github.com/apache/pulsar-manager](https://github.com/apache/pulsar-manager)|
|官方指导   |[https://github.com/apache/pulsar-manager/tree/v0.4.0/README.md](https://github.com/apache/pulsar-manager/tree/v0.4.0/README.md)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |4.19.190-7.6.lns8.loongarch64|


## 移植步骤

__编译环境及依赖__
1. java 8 及以上
2. node 16 及以上
3. npm 9.8 及以上
//node及npm相应版本配置在front-end下的build.gradle中修改

__移植步骤__
1. 下载源码
   - ` git clone -b v0.4.0 --depth 1 https://github.com/apache/pulsar-manager.git`
如果需要0.4.0版本可以直接下载[https://github.com/Loongson-Cloud-Community/pulsar-manager/tree/loong64-0.4.0](https://github.com/Loongson-Cloud-Community/pulsar-manager/tree/loong64-0.4.0)
   - ` git clone -b loong64-0.4.0 --depth 1 https://github.com/Loongson-Cloud-Community/pulsar-manager.git`
   下载后可以忽略第二步
   - 需要二进制包可以从[https://github.com/Loongson-Cloud-Community/pulsar-manager/releases/tag/0.4.0](https://github.com/Loongson-Cloud-Community/pulsar-manager/releases/tag/0.4.0)获取.

2. 修改配置文件
   具体见 [https://github.com/Loongson-Cloud-Community/pulsar-manager/commit/68203f667d1591efc7cd0426afafeeebd0577314](https://github.com/Loongson-Cloud-Community/pulsar-manager/commit/68203f667d1591efc7cd0426afafeeebd0577314)
3. 编译
   添加`-x test`跳过测试
   ` ./gradlew build -x test `
   - 编译过程中可能会出现在front-end子任务下npm install失败,执行:
   ```
   cd front-end && npm install --ignore-scripts && npm run build:prod
   ```
   编译成功的制品位于./build/distribution/目录下

__测试__

```
[yzw@kubernetes-master-1 bin]$ ./pulsar-manager
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/home/yzw/git-release/pulsar-manager/pulsar-manager/lib/logback-classic-1.2.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/home/yzw/git-release/pulsar-manager/pulsar-manager/lib/slf4j-log4j12-1.7.25.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/home/yzw/git-release/pulsar-manager/pulsar-manager/lib/log4j-slf4j-impl-2.17.1.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [ch.qos.logback.classic.util.ContextSelectorStaticBinder]
2023-09-06 09:17:40.928  INFO 23982 --- [           main] s.c.a.AnnotationConfigApplicationContext : Refreshing org.springframework.context.annotation.AnnotationConfigApplicationContext@77128536: startup date [Wed Sep 06 09:17:40 CST 2023]; root of context hierarchy
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.springframework.cglib.core.ReflectUtils$1 (file:/home/yzw/git-release/pulsar-manager/pulsar-manager/lib/spring-core-5.0.6.RELEASE.jar) to method java.lang.ClassLoader.defineClass(java.lang.String,byte[],int,int,java.security.ProtectionDomain)
WARNING: Please consider reporting this to the maintainers of org.springframework.cglib.core.ReflectUtils$1
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
2023-09-06 09:17:41.244  WARN 23982 --- [kground-preinit] o.s.h.c.j.Jackson2ObjectMapperBuilder    : For Jackson Kotlin classes support please add "com.fasterxml.jackson.module:jackson-module-kotlin" to the classpath
2023-09-06 09:17:41.291  INFO 23982 --- [           main] f.a.AutowiredAnnotationBeanPostProcessor : JSR-330 'javax.inject.Inject' annotation found and supported for autowiring
2023-09-06 09:17:41.373  INFO 23982 --- [           main] trationDelegate$BeanPostProcessorChecker : Bean 'configurationPropertiesRebinderAutoConfiguration' of type [org.springframework.cloud.autoconfigure.ConfigurationPropertiesRebinderAutoConfiguration$$EnhancerBySpringCGLIB$$b23dda4a] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.0.2.RELEASE)

```
