# telepresence
## 00x00 参考

1. [telepresence介绍](https://blog.csdn.net/a605692769/article/details/82257054)
2. [源码及镜像构建-官方未找到]()
3. [龙芯源码地址]()
4. [percona-xtrabackup-8.0.33-linux-loongarch64.tar.gz]()

## 00x01 构建环境信息

- arch

```shell
root@telepresence /w/p/telepresence# uname -a
Linux telepresence 4.19.190-2.1.lns8.loongarch64 #1 SMP Thu Sep 23 08:52:56 UTC 2021 loongarch64 loongarch64 loongarch64 GNU/Linux
```

- os

```shell
root@telepresence /w/p/percona-xtrabackup# cat /etc/os-release 
PRETTY_NAME="Loongnix GNU/Linux 20 (DaoXiangHu)"
NAME="Loongnix GNU/Linux"
VERSION_ID="20"
VERSION="20 (DaoXiangHu)"
VERSION_CODENAME=DaoXiangHu
ID=Loongnix
HOME_URL="https://www.loongnix.cn/"
SUPPORT_URL="https://www.loongnix.cn/"
BUG_REPORT_URL="http://www.loongnix.cn/"
```

## 00x02 构建依赖

# 依赖工具
```
根据Makefile文件，可知需要：
protobuf 21.9 ，protolint 0.42.0 shellcheck 0.8.0 helm3.12.0 golang 1.20 以上
因此先构建protobuf21.9 按照[文档] 
构建protolint时与源码无关，但注意需要在Makefile中屏蔽测试项目，具体修改见[]
shellcheck的作用是静态检查代码，需要使用cabal工具构建，使用haskell语言编写，因此先注释掉

```
# 代码构建依赖
在build时依赖：
```
[go-fuseftp](https://github.com/datawire/go-fuseftp.git)
该项目版本需要 0.4.2,依赖protobuf 21.5 使用21.9版本替代
依赖fuse开发包 `sudo yum install fuse-devel`
```


## 00x03 构建

- 构建命令

```
make build
```
### cgo报错
并不影响构建，忽略

```
# github.com/telepresenceio/telepresence/v2/cmd/telepresence
loadinternal: cannot find runtime/cgo

```



## 00x04 构建镜像

```shell
docker build --target tel2 --tag tel2 --tag cr.loongnix.cn/library/tel2:2.15.1 -f build-aux/docker/images/Dockerfile.traffic  .
```

# 二进制压缩包
root@xtrabackup /w/p/p/build (loong64-8.0)# file percona-xtrabackup-8.0.33-linux-loongarch64.tar.gz
percona-xtrabackup-8.0.33-linux-loongarch64.tar.gz: gzip compressed data, last modified: Fri Jul  7 09:07:15 2023, from Unix, original size 338969088


## 00×05 测试

### 1 测试telepresence二进制
#### 基本测试
```
[yzw@kubernetes-master-1 bin]$ ./telepresence -h
Telepresence can connect to a cluster and route all outbound traffic from your
workstation to that cluster so that software running locally can communicate
as if it executed remotely, inside the cluster. This is achieved using the
command:

telepresence connect

Telepresence can also intercept traffic intended for a specific service in a
cluster and redirect it to your local workstation:

telepresence intercept <name of service>

Telepresence uses background processes to manage the cluster session. One of
the processes runs with superuser privileges because it modifies the network.
Unless the daemons are already started, an attempt will be made to start them.
This will involve a call to sudo unless this command is run as root (not
recommended) which in turn may result in a password prompt.

Usage:
  telepresence [flags]
  telepresence [command]

Available Commands:
  completion         Generate a shell completion script
  config             
  connect            Connect to a cluster
  current-cluster-id Get cluster ID for your kubernetes cluster
  gather-logs        Gather logs from traffic-manager, traffic-agent, user and root daemons, and export them into a zip file.
  gather-traces      Gather Traces
  genyaml            Generate YAML for use in kubernetes manifests.
  helm               
  help               Help about any command
  intercept          Intercept a service
  leave              Remove existing intercept
  list               List current intercepts
  loglevel           Temporarily change the log-level of the traffic-manager, traffic-agent, and user and root daemons
  quit               Tell telepresence daemon to quit
  status             Show connectivity status
  test-vpn           Test VPN configuration for compatibility with telepresence
  uninstall          Uninstall telepresence agents
  upload-traces      Upload Traces
  version            Show version

Flags:
  -h, --help   help for telepresence

Global flags:
      --context string   The name of the kubeconfig context to use
      --docker           Start, or connect to, daemon in a docker container
      --no-report        Turn off anonymous crash reports and log submission on failure
      --output string    Set the output format, supported values are 'json', 'yaml',
                         and 'default' (default "default")

Use "telepresence [command] --help" for more information about a command.

For complete documentation and quick-start guides, check out our website at https://www.telepresence.io
```
#### tel2 镜像使用测试
```
yzw@loongson:~/tmp$ docker run -it cr.loongnix.cn/library/tel2:2.15.1
2023-09-25 08:22:57.7783 error   quit: failed to LoadEnv: 13 errors:
 1. invalid LogLevel (aborting): is not set
 2. invalid ServerPort (aborting): is not set
 3. invalid AgentArrivalTimeout (aborting): is not set
 4. invalid MaxReceiveSize (aborting): is not set
 5. invalid PodCIDRStrategy (aborting): is not set
 6. invalid PodIP (aborting): is not set
 7. invalid AgentRegistry (aborting): is not set
 8. invalid AgentInjectPolicy (aborting): is not set
 9. invalid AgentAppProtocolStrategy (aborting): is not set
 10. invalid AgentPort (aborting): is not set
 11. invalid AgentInjectorName (aborting): is not set
 12. invalid ClientDnsExcludeSuffixes (aborting): is not set
 13. invalid ClientConnectionTTL (aborting): is not set

```
#### telepresence镜像使用测试
```
yzw@loongson:~/tmp$ docker run -it cr.loongnix.cn/library/telepresence:2.15.1
Telepresence can connect to a cluster and route all outbound traffic from your
workstation to that cluster so that software running locally can communicate
as if it executed remotely, inside the cluster. This is achieved using the
command:

telepresence connect

Telepresence can also intercept traffic intended for a specific service in a
cluster and redirect it to your local workstation:

telepresence intercept <name of service>

Telepresence uses background processes to manage the cluster session. One of
the processes runs with superuser privileges because it modifies the network.
Unless the daemons are already started, an attempt will be made to start them.
This will involve a call to sudo unless this command is run as root (not
recommended) which in turn may result in a password prompt.

Usage:
  telepresence [flags]
  telepresence [command]

Available Commands:
  completion         Generate a shell completion script
  config             
  connect            Connect to a cluster
  current-cluster-id Get cluster ID for your kubernetes cluster
  dashboard          Open the dashboard in a web page
  gather-logs        Gather logs from traffic-manager, traffic-agent, user and root daemons, and export them into a zip file.
  gather-traces      Gather Traces
  genyaml            Generate YAML for use in kubernetes manifests.
  helm               
  help               Help about any command
  intercept          Intercept a service
  leave              Remove existing intercept
  license            Get License from Ambassador Cloud
  list               List current intercepts
  login              Authenticate to Ambassador Cloud
  loglevel           Temporarily change the log-level of the traffic-manager, traffic-agent, and user and root daemons
  logout             Logout from Ambassador Cloud
  preview            Create or remove preview domains for existing intercepts
  pro-ingress-info   Request Ingress Info from the Cloud
  quit               Tell telepresence daemon to quit
  status             Show connectivity status
  test-vpn           Test VPN configuration for compatibility with telepresence
  uninstall          Uninstall telepresence agents
  upload-traces      Upload Traces
  version            Show version

Flags:
  -h, --help   help for telepresence

Global flags:
      --context string   The name of the kubeconfig context to use
      --docker           Start, or connect to, daemon in a docker container
      --no-report        Turn off anonymous crash reports and log submission on failure
      --output string    Set the output format, supported values are 'json', 'yaml',
                         and 'default' (default "default")

Use "telepresence [command] --help" for more information about a command.

For complete documentation and quick-start guides, check out our website at https://www.telepresence.io

```

