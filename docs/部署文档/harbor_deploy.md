## 部署环境

|命令                     |结果                       |
|-------------------------|---------------------------|
|uname -m                 |loongarch64                |
|cat /etc/os-release      |loongnix-server:8          |

## 准备工作

从[harbor下载页面](https://github.com/goharbor/harbor/releases?q=tag%3Av2.1.1&expanded=true)下载harbor-2.1.1的在线[部署工具](https://github.com/goharbor/harbor/releases/download/v2.1.1/harbor-online-installer-v2.1.1.tgz) 

```bash 
wget https://github.com/goharbor/harbor/releases/download/v2.1.1/harbor-online-installer-v2.1.1.tgz
```

对于`harbor-online-installer-v2.1.1.tgz`解压可以得到如下文件：

```text
common.sh  harbor.yml.tmpl  install.sh*  LICENSE  prepare*
```

首先对于`harbor.yml`做如下修改

```diff
diff --git a/harbor.yml b/harbor.yml
index efe1749..186e314 100644
--- a/harbor.yml
+++ b/harbor.yml
@@ -2,7 +2,7 @@
 
 # The IP address or hostname to access admin UI and registry service.
 # DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
-hostname: reg.mydomain.com
+hostname: 10.130.200.238
 
 # http related config
 http:
@@ -10,12 +10,12 @@ http:
   port: 80
 
 # https related config
-https:
+#https:
   # https port for harbor, default is 443
-  port: 443
+  #port: 443
   # The path of cert and key files for nginx
-  certificate: /your/certificate/path
-  private_key: /your/private/key/path
+  #certificate: /your/certificate/path
+  #private_key: /your/private/key/path
 
 # # Uncomment following will enable tls communication between all harbor components
 # internal_tls:
@@ -44,7 +44,7 @@ database:
   max_open_conns: 1000
 
 # The default data volume
-data_volume: /data
+data_volume: /harbord
```

1. hostname修改为本机也就是部署机器的域名或者`ip`
2. 注释掉`https`部分，我们这里只是用http
3. 修改`data_volume`的路径到`/harbord`，这里尽量将`data_volume`修改到独立的目录，因为harbor后续的配置文件或者数据文件都会存到`data_volume`之下

然后对于`prepare`脚本进行修改，这个脚本主要是用来生成配置文件的

```diff
diff --git a/prepare b/prepare
index d4226a8..27e03f5 100755
--- a/prepare
+++ b/prepare
@@ -57,7 +57,7 @@ docker run --rm -v $input_dir:/input \
                     -v $config_dir:/config \
                     -v /:/hostfs \
                     --privileged \
-                    goharbor/prepare:v2.1.1 prepare $@
+                    cr.loongnix.cn/harbor/prepare:2.1.1 prepare $@
```

然后执行`install.sh`生成配置文件并启动`harbor`服务，当然这里会部署失败，因为默认使用的是x86的镜像，但是会帮我们生成三个部分的文件：

1. 工作目录下的`docker-compose.yml`文件
2. 工作目录下的`common`文件夹
3. `/harbord`也就是`data_volume`下相关的数据文件

然后我们可以看一下`docker-compose.yml`文件的一部分：

```yml
services:
  log:
    image: goharbor/harbor-log:v2.2.1-rc2
    container_name: harbor-log
    restart: always
    dns_search: .
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
    volumes:
      - /var/log/harbor/:/var/log/docker/:z
      - type: bind
        source: ./common/config/log/logrotate.conf
        target: /etc/logrotate.d/logrotate.conf
      - type: bind
        source: ./common/config/log/rsyslog_docker.conf
        target: /etc/rsyslog.d/rsyslog_docker.conf
    ports:
      - 127.0.0.1:1514:10514
    networks:
      - harbor
```

可以发现这里的镜像名称和`cr.loongnix.cn`里面的是不符合的，需要修改，修改如下：

```diff
diff --git a/docker-compose.yml b/docker-compose.yml
index f896996..2f56810 100644
--- a/docker-compose.yml
+++ b/docker-compose.yml
@@ -1,7 +1,7 @@
 version: '2.3'
 services:
   log:
-    image: goharbor/harbor-log:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/harbor-log:2.2.1
     container_name: harbor-log
     restart: always
     dns_search: .
@@ -25,7 +25,7 @@ services:
     networks:
       - harbor
   registry:
-    image: goharbor/registry-photon:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/registry-photon:2.2.1
     container_name: registry
     restart: always
     cap_drop:
@@ -54,7 +54,7 @@ services:
         syslog-address: "tcp://127.0.0.1:1514"
         tag: "registry"
   registryctl:
-    image: goharbor/harbor-registryctl:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/harbor-registryctl:2.2.1
     container_name: registryctl
     env_file:
       - ./common/config/registryctl/env
@@ -85,7 +85,7 @@ services:
         syslog-address: "tcp://127.0.0.1:1514"
         tag: "registryctl"
   postgresql:
-    image: goharbor/harbor-db:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/harbor-db:2.2.1
     container_name: harbor-db
     restart: always
     cap_drop:
@@ -110,7 +110,7 @@ services:
         syslog-address: "tcp://127.0.0.1:1514"
         tag: "postgresql"
   core:
-    image: goharbor/harbor-core:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/harbor-core:2.2.1
     container_name: harbor-core
     env_file:
       - ./common/config/core/env
@@ -150,7 +150,7 @@ services:
         syslog-address: "tcp://127.0.0.1:1514"
         tag: "core"
   portal:
-    image: goharbor/harbor-portal:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/harbor-portal:2.2.1
     container_name: harbor-portal
     restart: always
     cap_drop:
@@ -176,7 +176,7 @@ services:
         tag: "portal"
 
   jobservice:
-    image: goharbor/harbor-jobservice:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/harbor-jobservice:2.2.1
     container_name: harbor-jobservice
     env_file:
       - ./common/config/jobservice/env
@@ -206,7 +206,7 @@ services:
         syslog-address: "tcp://127.0.0.1:1514"
         tag: "jobservice"
   redis:
-    image: goharbor/redis-photon:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/redis-photon:2.2.1
     container_name: redis
     restart: always
     cap_drop:
@@ -228,7 +228,7 @@ services:
         syslog-address: "tcp://127.0.0.1:1514"
         tag: "redis"
   proxy:
-    image: goharbor/nginx-photon:v2.2.1-rc2
+    image: cr.loongnix.cn/harbor/nginx-photon:2.2.1
     container_name: nginx
     restart: always
     cap_drop:
```

## 启动

使用`docker-compose up`命令启动harbor, 然后访问`http://{your_ip}`,比如我的ip是`10.130.200.238`,那么主页地址就是`http://10.130.200.238`
