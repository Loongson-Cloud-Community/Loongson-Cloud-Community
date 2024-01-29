# vector

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |vector|
|版本       |0.26.0|
|项目地址   |[https://github.com/vectordotdev/vector](https://github.com/vectordotdev/vector)|
|官方指导   |[https://vector.dev/docs/setup/installation/manual/from-source/](https://vector.dev/docs/setup/installation/manual/from-source/)|


## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |4.19.190-7.6.lns8.loongarch64|


## 移植说明
由于rust-musl暂未支持，alpine版本的vector镜像暂时只有Dockerfile，无法开展制作
制品
vector-0.26.0-loongarch64-unknown-linux-gnu.tar.gz
vector_0.26.0-1_loongarch64.deb

## 移植步骤

__编译环境和依赖__
1. rust 1.64 +
    [安装文档](http://docs.loongnix.cn/rust/rustup.html)
2. deb 打包所需工具
    ``` cmark-gfm ```
    ``` cargo install cargo-deb@1.39.3 ```
3. 项目所需工具
    - 依赖项目aws-smithy-async需要：
    ``` apt-get install libsasl2-dev or dnf install cyrus-sasl-devel libssl-devel ```
    - 依赖项目loki-logproto需要高版本protobuf 此处使用了3.21.12

__下载源码__
``` git clone -b v0.26.0 --depth 1 https://github.com/vectordotdev/vector```
或直接下载适配后的源码：
``` git clone -b loongarch64-0.26.0 https://github.com/Loongson-Cloud-Community/vector.git```

__移植__

- 项目本身移植部分
    - Makefile部分适配loongarch64编译目标，包括` build-loong64-unknown-linux-gnu 、 build-loong64-unknown-linux-musl ` 等，具体见[]()
    - 适配Dockerfile，` distribution/docker/ `，主要修改vector获取的url以及基础镜像
- 依赖项目需要下载后移植或更新的支持LA的版本，为了更好支持指定的vector版本，选择离线适配依赖项目移植
    - 执行 ` cargo vendor` 获取离线vendor目录，并根据提示将指定内容添加到`.cargo/config.toml`中，保证项目编译时使用vendor目录下适配好的依赖项目
    - 适配项目包括：linux-raw-sys 多个版本，nix 多版本，rustix-0.34.4，ring，heim-host，tikv-jemalloc-sys，下面具体给出适配过程及相关信息
        - 修改依赖项目后，rust编译前会校验字段报错如：
            ```
             error: the listed checksum of `/rust-xxx/vendor/async-channel/tests/bounded.rs` has changed:
            expected: b4818293e8a4080b7bc2107b1b5704678d2984e99bb3647219f8aa61aaf189fc
            actual:   788245e613eb88beb150fd7817606581399eee1df63f6fbbd72ff4509fc8f63c
            directory sources are not intended to be edited, if modifications are required then it is recommended that `[patch]` is used with a forked copy of the source
            The command '/bin/sh -c cargo build --release --offline' returned a non-zero code: 101
            ERROR: Job failed: exit status 1
            ```
            修改该项目的.cargo-checksum.json，` sed -i 's/expected-list/actual-list/g' ../.cargo-checksum.json`
        - linux-raw-sys
            - 需要添加src/loongarch64 文件夹，文件夹内容已经在该项目高版本，直接复制即可[LA部分](https://github.com/sunfishcode/linux-raw-sys/tree/main/src/loongarch64)
            - src/lib.rs部分添加loongarch，见[https://github.com/sunfishcode/linux-raw-sys/blob/main/src/lib.rs](https://github.com/sunfishcode/linux-raw-sys/blob/main/src/lib.rs)
        - nix
            - src/sys/ioctl/linux.rs 部分需要添加` target_arch = "loongarch64" ` [https://github.com/Loongson-Cloud-Community/vector/blob/loongarch64-0.26.0/vendor/nix/src/sys/ioctl/linux.rs](https://github.com/Loongson-Cloud-Community/vector/blob/loongarch64-0.26.0/vendor/nix/src/sys/ioctl/linux.rs)
            - 修改openssl-src项目的src/lib.rs [https://github.com/Loongson-Cloud-Community/vector/blob/loongarch64-0.26.0/vendor/openssl-src/src/lib.rs](https://github.com/Loongson-Cloud-Community/vector/blob/loongarch64-0.26.0/vendor/openssl-src/src/lib.rs)
        - rustix
            - 按照搜索的上游LA内容添加 [https://github.com/search?q=repo%3Abytecodealliance%2Frustix%20loong&type=code](https://github.com/search?q=repo%3Abytecodealliance%2Frustix%20loong&type=code)
        - ring
            - 按照下面的代码添加LA架构后，该问题解决 ring/include/GFp/base.h
            <pre>
            72 #if defined(__x86_64) || defined(_M_AMD64) || defined(_M_X64)
            73 #define OPENSSL_64_BIT
            74 #define OPENSSL_X86_64
            75 #elif defined(__x86) || defined(__i386) || defined(__i386__) || defined(_M_IX86)
            76 #define OPENSSL_32_BIT
            77 #define OPENSSL_X86
            78 #elif defined(__AARCH64EL__) || defined(_M_ARM64)
            79 #define OPENSSL_64_BIT
            80 #define OPENSSL_AARCH64
            81 #elif defined(__ARMEL__) || defined(_M_ARM)
            82 #define OPENSSL_32_BIT
            83 #define OPENSSL_ARM
            84 #elif defined(__MIPSEL__) && !defined(__LP64__)
            85 #define OPENSSL_32_BIT
            86 #define OPENSSL_MIPS
            87 #elif defined(__MIPSEL__) && defined(__LP64__)
            88 #define OPENSSL_64_BIT
            89 #define OPENSSL_MIPS64
            90 #elif defined(__wasm__)
            91 #define OPENSSL_32_BIT
            92 #elif defined(__loongarch64)
            93 #define OPENSSL_64_BIT
            94 #define OPENSSL_LOONGARCH64
            95 #else
            96 // Note BoringSSL only supports standard 32-bit and 64-bit two's-complement,
            97 // little-endian architectures. Functions will not produce the correct answer
            98 // on other systems. Run the crypto_test binary, notably
            99 // crypto/compiler_test.cc, before adding a new architecture.
            100 #error "Unknown target CPU"
            101 #endif
            </pre>
            - ring/src/rand.rs
            <pre>
            208         #[cfg(target_arch = "aarch64")]
            209         const SYS_GETRANDOM: c_long = 278;
            210
            211         #[cfg(target_arch = "arm")]
            212         const SYS_GETRANDOM: c_long = 384;
            213
            214         #[cfg(target_arch = "loongarch64")]
            215         const SYS_GETRANDOM: c_long = 278;
            216
            217         #[cfg(target_arch = "x86")]
            218         const SYS_GETRANDOM: c_long = 355;
            219
            220         #[cfg(target_arch = "x86_64")]
            221         const SYS_GETRANDOM: c_long = 318;
            </pre>
        - heim-host
            - heim-host/src/os/linux.rs
            ```
                    cfg_if::cfg_if! {
            // aarch64-unknown-linux-gnu has different type
            if #[cfg(all(any(target_arch = "aarch64", target_arch = "loongarch64"), not(target_family = "musl")))] {
                /// User session ID.
                pub type SessionId = i64;
            } else {
                /// User session ID.
                pub type SessionId = i32;
            }
        }
            ```
        - tikv-jemalloc-sys
            - 修改tikv-jemallocator/benches/roundtrip.rs tikv-jemallocator/src/lib.rs
            ```
                        const MIN_ALIGN: usize = 8;
            #[cfg(all(any(
                target_arch = "x86",
                target_arch = "x86_64",
                target_arch = "aarch64",
                target_arch = "powerpc64",
                target_arch = "powerpc64le",
                target_arch = "loongarch64",
                target_arch = "mips64",
                target_arch = "riscv64",
                target_arch = "s390x",
                target_arch = "sparc64"
            )))]
            const MIN_ALIGN: usize = 16;
            ```
            ```
                        #[cfg(all(any(
                target_arch = "x86",
                target_arch = "x86_64",
                target_arch = "aarch64",
                target_arch = "powerpc64",
                target_arch = "powerpc64le",
                target_arch = "loongarch64",
                target_arch = "mips64",
                target_arch = "riscv64",
                target_arch = "s390x",
                target_arch = "sparc64"
            )))]
            const ALIGNOF_MAX_ALIGN_T: usize = 16;
            ```

__编译__
1. 编译vector二进制
```
make build
or
cargo build --release --no-default-features --verbose
```
2. 打包loongarch架构下的vector tar、rpm、deb包
```
TARGET=loongarch64-unknown-linux-gnu bash scripts/package-archieve.sh
TARGET=loongarch64-unknown-linux-gnu bash scripts/package-deb.sh
TARGET=loongarch64-unknown-linux-gnu bash scripts/package-rpm.sh
```


