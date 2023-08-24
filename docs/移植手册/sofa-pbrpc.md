# baidu/sofa-pbrpc

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息
|名称       |描述|
|--         |--|
|名称       |sofa-pbrpc|
|版本       |1.0.1|
|项目地址   |[https://github.com/baidu/sofa-pbrpc](https://github.com/baidu/sofa-pbrpc)|
|官方指导   |[https://github.com/baidu/sofa-pbrpc/blob/v1.0.1/README.md](https://github.com/baidu/sofa-pbrpc/blob/v1.0.1/README.md)|

## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A6000|
|系统       | Linux loongson-pc 4.19.0-19-loongson-3 |

## 移植说明
- 需要的软件依赖：
    ```
    boost-1.53.0  ,
    protobuf-2.4.1 ,
    snappy-1.1.1 ,
    zlib
    ```
## 移植步骤

__移植依赖__
  - 下载 boost-1.53.0
     下载地址 [https://sourceforge.net/projects/boost/files/boost/](https://sourceforge.net/projects/boost/files/boost/)
  	 由于当前项目仅需要boost的头文件./boost/smart_ptr.hpp，分析该部分与架构无关，无需改动
  - 移植protobuf-2.4.1
     参考文档 [https://loongson-cloud-community.github.io/Loongson-Cloud-Community/%E7%A7%BB%E6%A4%8D%E6%89%8B%E5%86%8C/protobuf]
  - 移植snappy-1.1.1
     1. 由于找不到1.1.1且项目对版本没有要求，选定1.1.5进行移植
	    snappy 所需依赖配置
	    ` yum install cmake build-essential ` 
         由于无法直接安装gmock,需要编译安装gmock库
	    `  git clone https://github.com/google/googletest.git `
	    ` cd googletest && mkdir build && cd build && cmake .. && make`
	    ` make install `
	    snappy没有架构相关内容，但由于当前项目需要的是snappy的静态库，而snappy默认生成动态库，需要在CMakeists.txt中做如下修改：
		 ```
		 yzw@loongson-pc:~/workspace/snappy$ git diff CMakeLists.txt
				diff --git a/CMakeLists.txt b/CMakeLists.txt
				index 2c79e46..8d41198 100644
				--- a/CMakeLists.txt
				+++ b/CMakeLists.txt
				@@ -80,8 +80,9 @@ IF (WIN32)
				 ENDIF (WIN32)
				 
				 # Define the main library.
				-ADD_LIBRARY(snappy SHARED
				-        snappy-c.cc
				+# ADD_LIBRARY(snappy SHARED
				+ADD_LIBRARY(snappy STATIC        
				+       snappy-c.cc
						 snappy-c.h
						 snappy-sinksource.cc
						 snappy-sinksource.h
		 ```
     2. 依次执行编译命令
		 ``` 
			./autogen.sh &&./configure
			mkdir build && cd build && cmake ../  && make 
		 ```
     3. 安装
		 ```
		 sudo make install && sudo ldconfig 
		 ```
   - sofa-pbrpc源码修改
	  涉及较多汇编指令修改,具体修改内容见链接[https://github.com/Loongson-Cloud-Community/sofa-pbrpc/commit/4242aab44533c8da2fcd506b134914198c9d226c](https://github.com/Loongson-Cloud-Community/sofa-pbrpc/commit/4242aab44533c8da2fcd506b134914198c9d226c)

__编译__
	``` 
	sudo make build
	```
__安装__

	```
	sudo make install
	```

__测试__
需要下载googletest文件
配置googletest文件路径到untest文件夹的depends.md中
```
make && bash run_test.sh
```
测试执行结果:
```
[----------] Global test environment tear-down
[==========] 2 tests from 1 test case ran. (0 ms total)
[  PASSED  ] 2 tests.

CASE NUM: 9
ALL CASE PASSED!!!
```
