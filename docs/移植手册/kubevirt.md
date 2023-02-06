# kubevirt
## 移植版本
```
v0.35.0
```
## 移植环境
### 系统信息
```
ID="loongnix-server"
ID_LIKE="rhel fedora centos"
VERSION_ID="8"
PLATFORM_ID="platform:lns8"
PRETTY_NAME="Loongnix-Server Linux 8"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:loongnix-server:loongnix-server:8"
HOME_URL="http://www.loongnix.cn/"
BUG_REPORT_URL="http://bugs.loongnix.cn/"
CENTOS_MANTISBT_PROJECT="Loongnix-server-8"
CENTOS_MANTISBT_PROJECT_VERSION="8"
```
### 内核信息
```
4.19.190-2.1.lns8.loongarch64
```
### 编译器
```
go version 1.19
gcc version 8.3.0
```
## 移植步骤
### 安装依赖项
```
yum install -y make golang-1.19 git glibc-static libvirt-devel rsync
```
### 源码适配
kubevirt源码中包含的组件和工具较多，本次适配以制作kubevirt部分容器镜像为目的，具体为`virt-api`，`virt-operator`，`virt-handler`，`virt-controller`，`virt-launcher`，所以目前适配后的代码不一定能构建所有的组件和工具。
```
diff --git a/pkg/virt-config/virt-config.go b/pkg/virt-config/virt-config.go
index ef241d4df..74dfa1ac3 100644
--- a/pkg/virt-config/virt-config.go
+++ b/pkg/virt-config/virt-config.go
@@ -42,10 +42,12 @@ const (
        MigrationCompletionTimeoutPerGiB         int64  = 800
        DefaultAMD64MachineType                         = "q35"
        DefaultPPC64LEMachineType                       = "pseries"
+       DefaultLOONG64MachineType                       = "loongson7a_v1.0"
        DefaultCPURequest                               = "100m"
        DefaultMemoryOvercommit                         = 100
        DefaultAMD64EmulatedMachines                    = "q35*,pc-q35*"
        DefaultPPC64LEEmulatedMachines                  = "pseries*"
+       DefaultLOONG64EmulatedMachines                  = "loongson7a*"
        DefaultLessPVCSpaceToleration                   = 10
        DefaultNodeSelectors                            = ""
        DefaultNetworkInterface                         = "bridge"
@@ -69,6 +71,9 @@ func getDefaultMachinesForArch() (string, string) {
        if runtime.GOARCH == "ppc64le" {
                return DefaultPPC64LEMachineType, DefaultPPC64LEEmulatedMachines
        }
+       if runtime.GOARCH == "loong64" || runtime.GOARCH == "loongarch64" {
+               return DefaultLOONG64MachineType, DefaultLOONG64EmulatedMachines
+       }
        return DefaultAMD64MachineType, DefaultAMD64EmulatedMachines
 }
```
```
diff --git a/pkg/virt-launcher/virtwrap/api/converter.go b/pkg/virt-launcher/virtwrap/api/converter.go
index 12fbf987c..b06df9a5e 100644
--- a/pkg/virt-launcher/virtwrap/api/converter.go
+++ b/pkg/virt-launcher/virtwrap/api/converter.go
@@ -739,31 +739,44 @@ func Convert_v1_VirtualMachine_To_api_Domain(vmi *v1.VirtualMachineInstance, dom
                                Value: string(vmi.Spec.Domain.Firmware.UUID),
                        },
                }
+               if vmi.Spec.Domain.Firmware.Bootloader != nil && vmi.Spec.Domain.Firmware.Bootloader.BIOS != nil {
+                       domain.Spec.OS.BootLoader = &Loader{
+                               Path:     "/usr/share/qemu-kvm/loongarch_bios.bin",
+                               ReadOnly: "yes",
+                               Secure:   "no",
+                               Type:     "rom",
+                       }
+
+                       domain.Spec.OS.NVRam = &NVRam{
+                               NVRam:    filepath.Join("/tmp", domain.Spec.Name),
+                               Template: "/usr/share/qemu-kvm/loongarch_bios.bin",
+                       }
+               }
 
                if vmi.Spec.Domain.Firmware.Bootloader != nil && vmi.Spec.Domain.Firmware.Bootloader.EFI != nil {
```
```
diff --git a/pkg/virt-launcher/virtwrap/api/defaults.go b/pkg/virt-launcher/virtwrap/api/defaults.go
index fbd30ac25..d6043a0b5 100644
--- a/pkg/virt-launcher/virtwrap/api/defaults.go
+++ b/pkg/virt-launcher/virtwrap/api/defaults.go
@@ -26,8 +26,10 @@ func (d *Defaulter) SetDefaults_OSType(ostype *OSType) {
        if ostype.Arch == "" {
                if d.Architecture == "ppc64le" {
                        ostype.Arch = "ppc64le"
-               } else {
+               } else if d.Architecture == "amd64"{
                        ostype.Arch = "x86_64"
+               } else {
+                       ostype.Arch = "loongarch64"
                }
        }
 
@@ -36,7 +38,11 @@ func (d *Defaulter) SetDefaults_OSType(ostype *OSType) {
        if ostype.Machine == "" {
                if d.Architecture == "ppc64le" {
                        ostype.Machine = "pseries"
-               } else {
+               }else if d.Architecture == "loong64" {
+                       ostype.Machine = "loongson7a_v1.0"
+               }else if d.Architecture == "loongarch64" {
+                       ostype.Machine = "loongson7a_v1.0"
+               }else {
                        ostype.Machine = "q35"
                }
        }
```
下载完整的代码[点击这里](https://github.com/Loongson-Cloud-Community/kubevirt/releases/download/v0.35.0/kubevirt-v0.35.0-loong64-source.tar.gz)。
## 构建
在`kubevirt`目录下执行`make go-build`，`cmd`目录下所有编译生成的文件存放在`_out`目录。另外，制作镜像时需要用到`csv-generator`二进制，在`tool/csv-generator`目录下，它的编译命令为：
```
GOPROXY=off GOFLAGS=-mod=vendor CGO_ENABLED=0 go build
```
## 部署
[kubevirt单节点部署文档](https://github.com/Loongson-Cloud-Community/Loongson-Cloud-Community/blob/main/docs/%E5%85%B6%E4%BB%96%E6%96%87%E6%A1%A3/kubevirt.md)
