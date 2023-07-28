# cilium-ebpf

## 构建版本
v0.10.0

## 源码修改   
```
diff --git a/cmd/bpf2go/main.go b/cmd/bpf2go/main.go
index 03ff1f8..2413336 100644
--- a/cmd/bpf2go/main.go
+++ b/cmd/bpf2go/main.go
@@ -47,6 +47,7 @@ var targetByGoArch = map[string]target{
        "amd64p32":    {"bpfel", ""},
        "arm":         {"bpfel", "arm"},
        "arm64":       {"bpfel", "arm64"},
+       "loong64":     {"bpfel", ""},
        "mipsle":      {"bpfel", ""},
        "mips64le":    {"bpfel", ""},
        "mips64p32le": {"bpfel", ""},
diff --git a/internal/endian_le.go b/internal/endian_le.go
index 41a6822..273fad8 100644
--- a/internal/endian_le.go
+++ b/internal/endian_le.go
@@ -1,5 +1,5 @@
-//go:build 386 || amd64 || amd64p32 || arm || arm64 || mipsle || mips64le || mips64p32le || ppc64le || riscv64
-// +build 386 amd64 amd64p32 arm arm64 mipsle mips64le mips64p32le ppc64le riscv64
+//go:build 386 || amd64 || amd64p32 || arm || arm64 || loong64 || mipsle || mips64le || mips64p32le || ppc64le || riscv64
+// +build 386 amd64 amd64p32 arm arm64 loong64 mipsle mips64le mips64p32le ppc64le riscv64
 
 package internal
```

## 构建
执行make
在make构建完成后会自动更新文件cmd/bpf2go/test/test_bpfel.go和examples目录下的相关文件

备注：具体项目 https://github.com/Loongson-Cloud-Community/ebpf
