# 欧拉操作系统FAQ

## 1. openEuler-22.03-LTS preview 版本发布内容

（1）[镜像下载地址](https://mirror.sjtu.edu.cn/openeuler/openEuler-preview/loongarch/openEuler-22.03-LTS-Loongarch/ISO/loongarch64/openEuler-22.03-LTS-loongarch64-dvd.iso)<br>
（2）[发布说明](https://mirror.sjtu.edu.cn/openeuler/openEuler-preview/loongarch/openEuler-22.03-LTS-Loongarch/openEuler-loongarch-PreView-ISO-releasenotes.md)<br>

## 2. openEuler-22.03-LTS preview 版本本地repo源配置方法

（1）创建挂载目录
```
sudo mkdir -p /data/iso
```
（2）获取openEuler-22.03-LTS版本镜像
```
cd /data
wget https://mirror.sjtu.edu.cn/openeuler/openEuler-preview/loongarch/openEuler-22.03-LTS-Loongarch/ISO/loongarch64/openEuler-22.03-LTS-loongarch64-dvd.iso
```
（3）挂载镜像
```
sudo mount openEuler-22.03-LTS-loongarch64-dvd.iso /data/iso
```
（4）配置本地源，并生成缓存
```
sudo cp /etc/yum.repos.d/openEuler.repo /etc/yum.repos.d/openEuler.repo.bac
cat <<EOF > /etc/yum.repos.d/openEuler.repo
[OS]
name=OS
baseurl=file:///data/iso
enabled=1
gpgcheck=0
gpgkey=http://repo.openeuler.org/openEuler-22.03-LTS/OS/$basearch/RPM-GPG-KEY-openEuler
EOF
yum makecache
```
