# node-re2
该项目架构无关

## 1. 构建版本
1.17.4     

## 2. 构建命令
```
git clone git@github.com:uhop/node-re2.git
cd node-re2
git submodule update --init --recursive
npm install
npm run rebuild
```
构建完成后会在build目录下生成Release/re2.node

## 3. 备注
从1.19.0版本之后，在源码中调用了v8::RegExp:kHasIndices，在我们现有的v8版本中不支持，会编译报错：
```
make: 进入目录“/home/zhaixiaojuan/workspace/node-re2/build”
  CXX(target) Release/obj.target/re2/lib/addon.o
  CXX(target) Release/obj.target/re2/lib/new.o
../lib/new.cc: In static member function ‘static Nan::NAN_METHOD_RETURN_TYPE WrappedRE2::New(Nan::NAN_METHOD_ARGS_TYPE)’:
../lib/new.cc:313:41: error: ‘kHasIndices’ is not a member of ‘v8::RegExp’
   hasIndices = bool(flags & v8::RegExp::kHasIndices);
                                         ^~~~~~~~~~~
make: *** [re2.target.mk:224：Release/obj.target/re2/lib/new.o] 错误 1
make: 离开目录“/home/zhaixiaojuan/workspace/node-re2/build”
gyp ERR! build error 
gyp ERR! stack Error: `make` failed with exit code: 2
gyp ERR! stack     at ChildProcess.onExit (/usr/lib/node_modules/npm/node_modules/node-gyp/lib/build.js:194:23)
gyp ERR! stack     at ChildProcess.emit (events.js:315:20)
gyp ERR! stack     at Process.ChildProcess._handle.onexit (internal/child_process.js:277:12)
gyp ERR! System Linux 4.19.190-7.4.lns8.loongarch64
gyp ERR! command "/usr/bin/node" "/usr/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js" "rebuild" 
```
