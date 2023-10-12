# moby
## 1. 项目介绍
moby即docker-ce，官方源码地址：https://github.com/moby/moby

## 2. 构建版本
v23.0.4

## 3. 构建步骤
（1）loong64架构构建
按照官方方法，是先生成开发环境的镜像，然后在镜像中构建moby项目，由于官方镜像还不支持loong64，故在不构建镜像的条件下可以按照以下步骤构建dockerd二进制：

```
export GOPATH=/go
go env -w GOPATH=/go GO11MODUEL=off

mkdir -p /go/src/github.com/docker/
cd /go/src/github.com/docker/
git clone https://github.com/moby/moby.git
mv moby docker

cd /go/src/github.com/docker/docker
hack/make.sh  binary
```
编译完成后，二进制存储在bundles/binary-deamon/ 路径下。

（2）x86架构构建
对于官方支持镜像的架构，可以按照官方方法进行构建，以下是在x86架构下构建：
1）生成开发环境 --- 镜像
```
make BIND_DIR=. shell  //该命令实际调用的是”docker buildx build  --build-arg=GO_VERSION  -f "Dockerfile" --target=dev-base --load -t "docker-dev" .“
```
该命令执行成功后，会生成一个镜像docker-dev，并自动进入到生成的镜像当中，log信息如下：
```
......
#116 exporting to image
#116 exporting layers
#116 exporting layers 8.7s done
#116 writing image sha256:16cbb16a6d828a822b2799d96c5bb703ffb6cc894b27c0ad9143cdd50b826467
#116 writing image sha256:16cbb16a6d828a822b2799d96c5bb703ffb6cc894b27c0ad9143cdd50b826467 0.0s done
#116 naming to docker.io/library/docker-dev 0.1s done
#116 DONE 9.3s
docker run --rm --privileged  -e BUILD_APT_MIRROR -e BUILDFLAGS -e KEEPBUNDLE -e DOCKER_BUILD_ARGS -e DOCKER_BUILD_GOGC -e DOCKER_BUILD_OPTS -e DOCKER_BUILD_PKGS -e DOCKER_BUILDKIT -e DOCKER_BASH_COMPLETION_PATH -e DOCKER_CLI_PATH -e DOCKER_DEBUG -e DOCKER_EXPERIMENTAL -e DOCKER_GITCOMMIT -e DOCKER_GRAPHDRIVER -e DOCKER_LDFLAGS -e DOCKER_PORT -e DOCKER_REMAP_ROOT -e DOCKER_ROOTLESS -e DOCKER_STORAGE_OPTS -e DOCKER_TEST_HOST -e DOCKER_USERLANDPROXY -e DOCKERD_ARGS -e DELVE_PORT -e GITHUB_ACTIONS -e TEST_FORCE_VALIDATE -e TEST_INTEGRATION_DIR -e TEST_INTEGRATION_USE_SNAPSHOTTER -e TEST_SKIP_INTEGRATION -e TEST_SKIP_INTEGRATION_CLI -e TESTCOVERAGE -e TESTDEBUG -e TESTDIRS -e TESTFLAGS -e TESTFLAGS_INTEGRATION -e TESTFLAGS_INTEGRATION_CLI -e TEST_FILTER -e TIMEOUT -e VALIDATE_REPO -e VALIDATE_BRANCH -e VALIDATE_ORIGIN_BRANCH -e VERSION -e PLATFORM -e DEFAULT_PRODUCT_LICENSE -e PRODUCT -e PACKAGER_NAME -v "/home/zhaixiaojuan/docker-project/moby/.:/go/src/github.com/docker/docker/." -v "/home/zhaixiaojuan/docker-project/moby/.git:/go/src/github.com/docker/docker/.git" -v docker-dev-cache:/root/.cache -v docker-mod-cache:/go/pkg/mod/     -t -i "docker-dev" bash
```
也可以单独执行下面的命令进入到镜像当中：
```
docker run --rm --privileged  -e BUILD_APT_MIRROR -e BUILDFLAGS -e KEEPBUNDLE -e DOCKER_BUILD_ARGS -e DOCKER_BUILD_GOGC -e DOCKER_BUILD_OPTS -e DOCKER_BUILD_PKGS -e DOCKER_BUILDKIT -e DOCKER_BASH_COMPLETION_PATH -e DOCKER_CLI_PATH -e DOCKER_DEBUG -e DOCKER_EXPERIMENTAL -e DOCKER_GITCOMMIT -e DOCKER_GRAPHDRIVER -e DOCKER_LDFLAGS -e DOCKER_PORT -e DOCKER_REMAP_ROOT -e DOCKER_ROOTLESS -e DOCKER_STORAGE_OPTS -e DOCKER_TEST_HOST -e DOCKER_USERLANDPROXY -e DOCKERD_ARGS -e DELVE_PORT -e GITHUB_ACTIONS -e TEST_FORCE_VALIDATE -e TEST_INTEGRATION_DIR -e TEST_INTEGRATION_USE_SNAPSHOTTER -e TEST_SKIP_INTEGRATION -e TEST_SKIP_INTEGRATION_CLI -e TESTCOVERAGE -e TESTDEBUG -e TESTDIRS -e TESTFLAGS -e TESTFLAGS_INTEGRATION -e TESTFLAGS_INTEGRATION_CLI -e TEST_FILTER -e TIMEOUT -e VALIDATE_REPO -e VALIDATE_BRANCH -e VALIDATE_ORIGIN_BRANCH -e VERSION -e PLATFORM -e DEFAULT_PRODUCT_LICENSE -e PRODUCT -e PACKAGER_NAME -v "/home/zhaixiaojuan/docker-project/moby/.:/go/src/github.com/docker/docker/." -v "/home/zhaixiaojuan/docker-project/moby/.git:/go/src/github.com/docker/docker/.git" -v docker-dev-cache:/root/.cache -v docker-mod-cache:/go/pkg/mod/     -t -i "docker-dev" bash
```
2）编译dockerd二进制
在进入到容器以后，执行下面的命令：
```
hack/make.sh binary
```
构建完成后二进制会存储在bundles/binary-daemon/ 目录下。

3）安装
```
make install
```
执行完以后默认安装到/usr/local/bin目录下。

### 4. 备注
在上面3的构建步骤中按照 "（1）loong64架构构建" 和 "（2）x86架构构建" 编译后最后生成的二进制个数不同，这是因为在构建镜像的过程中会下载对应的runc，containerd等项目源码并进行构建，在构建完成后，将这些二进制复制到了bundles/binary-daemon/ 目录下。
