# ml-cpp

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |ml-cpp|
|版本       |8.4.0|
|项目地址   |[https://github.com/elastic/ml-cpp](https://github.com/elastic/ml-cpp)|
|官方指导   |[https://github.com/elastic/ml-cpp/blob/main/build-setup](https://github.com/elastic/ml-cpp/blob/main/build-setup)|


## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |5.10.0-60.101.0.126.oe2203.loongarch64|

## 移植依赖
安装依赖
``` yum install bzip2 gcc-c++ texinfo tzdata unzip zlib-devel java-1.8.0-openjdk autoconf libtool diffutils ```
欧拉缺少patchelf libxml2 boost 需要手动编译
- libxml2 编译
配置编译环境
    ```
    export LD_LIBRARY_PATH=/usr/local/gcc103/lib64:/usr/local/gcc103/lib:/usr/lib:/lib
    export PATH=$JAVA_HOME/bin:/usr/local/gcc103/bin:/usr/local/cmake/bin:/usr/bin:/bin:/usr/sbin:/sbin:/home/vagrant/bin
    export CPP_SRC_HOME=/home/yzw/ml-cpp
    wget https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.14.tar.xz
    ```
- boost 编译
    ```
        boost编译 使用云组织适配的boost https://github.com/Loongson-Cloud-Community/boost 1.77.0 版本
    ./bootstrap.sh --without-libraries=context --without-libraries=coroutine --without-libraries=graph_parallel --without-libraries=mpi --without-libraries=python --without-icu
    修改
    Edit boost/unordered/detail/implementation.hpp and change line 287 from:

    (17ul)(29ul)(37ul)(53ul)(67ul)(79ul) \
    to:
    (3ul)(17ul)(29ul)(37ul)(53ul)(67ul)(79ul) \
    ./b2 -j6 --layout=versioned --disable-icu pch=off optimization=speed inlining=full define=BOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS define=BOOST_LOG_WITHOUT_DEBUG_OUTPUT define=BOOST_LOG_WITHOUT_EVENT_LOG define=BOOST_LOG_WITHOUT_SYSLOG define=BOOST_LOG_WITHOUT_IPC define=_FORTIFY_SOURCE=2 cxxflags=-std=gnu++14 cxxflags=-fstack-protector linkflags=-Wl,-z,relro linkflags=-Wl,-z,now
    配置环境变量 env PATH="$PATH" LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ./b2 install --prefix=/usr/local/gcc75 --layout=versioned --disable-icu pch=off optimization=speed inlining=full define=BOOST_MATH_NO_LONG_DOUBLE_MATH_FUNCTIONS define=BOOST_LOG_WITHOUT_DEBUG_OUTPUT define=BOOST_LOG_WITHOUT_EVENT_LOG define=BOOST_LOG_WITHOUT_SYSLOG define=BOOST_LOG_WITHOUT_IPC define=_FORTIFY_SOURCE=2 cxxflags=-std=gnu++14 cxxflags=-fstack-protector linkflags=-Wl,-z,relro linkflags=-Wl,-z,now
    ```
- patchelf
    Extract it to a temporary directory using:

    bzip2 -cd patchelf-0.13.tar.bz2 | tar xvf -
    In the resulting patchelf-0.13.20210805.a949ff2 directory, run the:

    ./configure --prefix=/usr/local/gcc103
    script. This should build an appropriate Makefile. Assuming it does, run:

    make
    sudo make install
    编译可能会报错，需要编译caffe2：[编译教程](https://blog.csdn.net/weixin_43624538/article/details/84712617)
- 还需要编译pytroch
    原因：ml-cpp本身无问题 报错 找不到libtorch_cpu.so
    翻阅官方文档 需要安装pytorch
    pip3 install install numpy ninja pyyaml setuptools cffi typing_extensions future six requests dataclasses
    git clone --depth=1 --branch=v1.11.0 git@github.com:pytorch/pytorch.git
    cd pytorch
    git submodule sync
    git submodule update --init --recursive
    编辑 torch/csrc/jit/codegen/fuser/cpu/fused_kernel.cpp 并将所有出现的 system( 替换为 strlen(。此文件用于编译融合 CPU 内核，我们不希望这样做，也永远不想这样做出于安全原因。替换对 system() 的调用可确保在我们发布的产品中寻找潜在危险函数调用的启发式病毒扫描程序不会遇到这些运行外部进程的函数。
    编译参数
    [ $(uname -m) = x86_64 ] && export BLAS=MKL || export BLAS=Eigen
    export BUILD_TEST=OFF
    [ $(uname -m) = x86_64 ] && export BUILD_CAFFE2=OFF
    [ $(uname -m) != x86_64 ] && export USE_FBGEMM=OFF
    [ $(uname -m) != x86_64 ] && export USE_KINETO=OFF
    [ $(uname -m) = x86_64 ] && export USE_NUMPY=OFF
    export USE_DISTRIBUTED=OFF
    export USE_MKLDNN=ON
    export USE_QNNPACK=OFF
    export USE_PYTORCH_QNNPACK=OFF
    [ $(uname -m) = x86_64 ] && export USE_XNNPACK=OFF
    Breakpad is undesirable as it causes libtorch_cpu to have an executable stack
    export USE_BREAKPAD=OFF
    export PYTORCH_BUILD_VERSION=1.11.0
    export PYTORCH_BUILD_NUMBER=1
    /usr/local/gcc103/bin/python3.7 setup.py install
    最终：sudo mkdir -p /usr/local/gcc103/include/pytorch
    sudo cp -r torch/include/* /usr/local/gcc103/include/pytorch/
    sudo cp torch/lib/libtorch_cpu.so /usr/local/gcc103/lib
    sudo cp torch/lib/libc10.so /usr/local/gcc103/lib

##  编译
mkdir build && cmake .. && make


