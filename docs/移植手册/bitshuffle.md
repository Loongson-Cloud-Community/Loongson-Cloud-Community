# kiyo-masui/bitshuffle

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息
|名称       |描述|
|--         |--|
|名称       |bitshuffle|
|版本       |0.5.1|
|项目地址   |[https://github.com/kiyo-masui/bitshuffle](https://github.com/kiyo-masui/bitshuffle)|
|官方指导   |[https://github.com/kiyo-masui/bitshuffle/blob/master/README.rst](https://github.com/kiyo-masui/bitshuffle/blob/master/README.rst)|

Bitshuffle是一个用于高效压缩和解压缩Numpy的多维数组的开源项目。它使用了一种基于位操作的压缩技术，可在保持数据准确性的前提下，显著减少存储空间和I/O带宽需求。

Bitshuffle库专门为具有规律的二进制数据设计，例如科学计算、传感器数据、遥感数据等。它特别适用于处理具有较高数据重复性和较低信息熵的数据。通过使用位重排算法，Bitshuffle可以将重复的二进制模式重新排列，以便更好地利用压缩算法的性质，从而实现更高的压缩比率和更快的I/O速度。

Bitshuffle项目包括两个核心库：Bitshuffle和Bitshuffle-HDF5。Bitshuffle用于压缩和解压缩Numpy数组，而Bitshuffle-HDF5则为HDF5文件格式提供了透明的压缩和解压缩功能，可从HDF5文件中读取和写入压缩的数据。

Bitshuffle具有跨平台的特性，可以在各种操作系统上使用，包括Linux、Windows和Mac OS。它还支持多种编程语言，如Python、C和C++，为用户提供了方便的接口和易于集成的能力。

Bitshuffle项目被广泛应用于科学计算、大数据分析、天文学、气候模拟等领域，以加快数据处理和降低存储成本。

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |Loongnix-Server 4.19.0|


## 移植说明
- 需要的软件依赖：
    ```
    python3.3 or later ,
    HDF5 1.8.4 or later, 
    HDF5 for python (h5py), 
    Numpy and Cython
     pip3 install Cython
    ```
    另外，hdf5需要安装devel和static库 也通过yum安装
    寻找hdf5的安装路径 rpm -qi/ql hdf5.loongrach64
    发现hdf5的动态库和静态库在usr/lib64下

## 移植步骤

__编译__

    `python setup.py install --h5plugin --h5plugin-dir=spam --zstd`
    编译执行可能报错：
   `Can't find hdf5 with pkg-config fallback to static config`
    需要手动创建hdf5的pkg-config文件
    使用命令 `pkg-config --variable pc_path pkg-config `查找 pkg-config 的搜索路径。
    在pkg-config的搜索路径下添加hdf5.pc
    ` sudo vim hdf5.pc `
    写入
    ```
    prefix=/usr
    exec_prefix=${prefix}
    libdir=${exec_prefix}/lib64
    includedir=${prefix}/include
    
    Name: hdf5
    Description: HDF5 Library
    Version: 1.10.5
    Cflags: -I${includedir}
    Libs: -L${libdir} -lhdf5
    ```
    保存后继续运行，可能出现的其他问题：
    ```
    loongarch64-loongson-linux-gnu-gcc: error: unrecognized command line option ‘-mcpu=native’; did you mean ‘-march=native’?
    error: command 'loongarch64-loongson-linux-gnu-gcc' failed with exit status 1  
    ```
    解决方案：这个错误是由于编译器不识别 -mcpu=native 这个参数引起的，它可能是由于平台或编译器版本的不同导致的。一种解决方法是将 -mcpu=native 参数替换为 -march=native，两者的作用是相同的
    1.打开 setup.py 文件，并找到使用 -mcpu 参数的位置。
    2.添加loongarch64架构。
    3.保存文件

