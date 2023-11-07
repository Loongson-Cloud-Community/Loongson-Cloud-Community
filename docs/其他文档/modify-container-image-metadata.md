# 修改容器镜像元数据的方法

本文介绍在不重构容器镜像（后文统称镜像）的情况下，修改镜像元数据的方法。

## 镜像元数据
镜像元数据，就是通过 `docker inspect $image` 看到的信息。包括镜像名称，创建时间，系统，架构等。
将镜像导出为 tar 包之后，一个镜像由 manifest 和 layers 构成，其中 manifest 和 layers 中的 json 文件都属于这个镜像的元数据。

以下是一个镜像构成示例
```
├── 56cd0b7152f568cf0e8e17ec2d37db74416ea32e6d5c0f62c87d9c404d60d4ee.json
├── 84a7aa0301eb675638756dd950eabb17c572809a21a24d60ede2d1f7fbc0c29e
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── dcdeada94ff36fb8f661cf4f72b91c94dc942ed9cea79e0baf108a433827a1f8
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── f508bc28db275267838b552afe909f03fe29c8af12b4f434b57cf7b9c7d1838f
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── faff0f5bd6c542771b1531732e02f21e346e3be146871e52cc46202e40983220
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── manifest.json
└── repositories
```
## 修改元数据
以将镜像 `cr.loongnix.cn/library/haproxy:2.7` 的架构信息从 loongarch64 变更为 loong64 为例。

__拉取镜像__
```
docker pull cr.loongnix.cn/library/haproxy:2.7
```

__导出镜像__
需要将镜像名称中的 `/` 替换成普通字符
```
docker save -o old/cr.loongnix.cn_library_haproxy_2.7.tar
```

__解压__
```
tar -xvf old/cr.loongnix.cn_library_haproxy_2.7.tar -C unpack
```

__修改架构__
```
find unpack -name *json | xargs -L 1 sed 's/loongarch64/loong64/g'
```

__重新打包__
```
tar -cvf cr.loongnix.cn_library_haproxy_2.7.tar -C unpack .
```


## 附录 批量修改元数据脚本
```
#!/bin/bash

set -o nounset
set -o errexit

images=(
)

tar_name=
# pull $image
get_image()
{
  img=$1
  tar_name=${img//\//_}.tar.gz
  echo $img
  echo $tar_name
  docker pull $img
  docker save $img -o old/$tar_name
}

modify()
{
  tar -xvf old/$tar_name -C unpack

  files=$(find -name *json -print)
  for file in ${files[@]}; do
    sed -i 's/loongarch64/loong64/g' $file
  done

  tar -cvf new/$tar_name -C unpack .
}

clean_unpack()
{
  rm -rf unpack/*
}

for image in ${images[@]}; do
  echo $image
  get_image $image
  modify
  clean_unpack
done
      
```
