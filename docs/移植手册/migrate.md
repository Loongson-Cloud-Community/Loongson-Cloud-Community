# migrate

<!-- note -->
???+ note
    * 本文假设网络通畅，如遇网络问题请自行解决
<!-- note end -->

## 项目信息

|名称       |描述|
|--         |--|
|名称       |migrate|
|版本       |4.15.1|
|项目地址   |[https://github.com/migrate/migrate](https://github.com/migrate/migrate)|
|官方指导   |[https://github.com/migrate/migrate/blob/v4.15.1/README.md](https://github.com/migrate/migrate/blob/v4.15.1/README.md)|


## 环境信息

|名称       |描述|
|--         |--|
|CPU        |3A5000|
|系统       |4.19.190-7.6.lns8.loongarch64|


## 移植说明

  
## 移植步骤

__编译环境和依赖__
1. Linux kernel version 2.6.23 or later
2. go 1.20.0 以上版本
  龙芯go下载地址: [http://ftp.loongnix.cn/toolchain/golang/](http://ftp.loongnix.cn/toolchain/golang/)


__移植__

具体见`https://github.com/Loongson-Cloud-Community/migrate/commit/53f240cbee83d86036ccc6749b734d35f3dcde58`
主要修改了Makefile文件中架构相关部分
```
diff --git a/Makefile b/Makefile
index 79fa85f..05616a3 100644
--- a/Makefile
+++ b/Makefile
@@ -1,6 +1,7 @@
 SOURCE ?= file go_bindata github github_ee bitbucket aws_s3 google_cloud_storage godoc_vfs gitlab
 DATABASE ?= postgres mysql redshift cassandra spanner cockroachdb clickhouse mongodb sqlserver firebird neo4j pgx
-DATABASE_TEST ?= $(DATABASE) sqlite sqlite3 sqlcipher
+#DATABASE_TEST ?= $(DATABASE) sqlite sqlite3 sqlcipher
+DATABASE_TEST ?= $(DATABASE) sqlite sqlcipher
 VERSION ?= $(shell git describe --tags 2>/dev/null | cut -c 2-)
 TEST_FLAGS ?=
 REPO_OWNER ?= $(shell cd .. && basename "$$(pwd)")
@@ -10,7 +11,7 @@ build:
        CGO_ENABLED=0 go build -ldflags='-X main.Version=$(VERSION)' -tags '$(DATABASE) $(SOURCE)' ./cmd/migrate
 
 build-docker:
-       CGO_ENABLED=0 go build -a -o build/migrate.linux-386 -ldflags="-s -w -X main.Version=${VERSION}" -tags "$(DATABASE) $(SOURCE)" ./cmd/migrate
+       CGO_ENABLED=0 go build -a -o build/migrate.linux-loongarch64 -ldflags="-s -w -X main.Version=${VERSION}" -tags "$(DATABASE) $(SOURCE)" ./cmd/migrate
 
 build-cli: clean
        -mkdir ./cli/build
@@ -20,6 +21,7 @@ build-cli: clean
        cd ./cmd/migrate && CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -a -o ../../cli/build/migrate.darwin-amd64 -ldflags='-X main.Version=$(VERSION) -extldflags "-static"' -tags '$(DATABASE) $(SOURCE)' .
        cd ./cmd/migrate && CGO_ENABLED=0 GOOS=windows GOARCH=386 go build -a -o ../../cli/build/migrate.windows-386.exe -ldflags='-X main.Version=$(VERSION) -extldflags "-static"' -tags '$(DATABASE) $(SOURCE)' .
        cd ./cmd/migrate && CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -a -o ../../cli/build/migrate.windows-amd64.exe -ldflags='-X main.Version=$(VERSION) -extldflags "-static"' -tags '$(DATABASE) $(SOURCE)' .
+       cd ./cmd/migrate && CGO_ENABLED=0 GOOS=linux GOARCH=loong64 go build -a -o ../../cli/build/migrate.linux-loongarch64 -ldflags='-X main.Version=$(VERSION) -extldflags "-static"' -tags '$(DATABASE) $(SOURCE)' .
        cd ./cli/build && find . -name 'migrate*' | xargs -I{} tar czf {}.tar.gz {}
        cd ./cli/build && shasum -a 256 * > sha256sum.txt
        cat ./cli/build/sha256sum.txt
@@ -36,7 +38,7 @@ test-short:
 test:
        @-rm -r $(COVERAGE_DIR)
        @mkdir $(COVERAGE_DIR)
-       make test-with-flags TEST_FLAGS='-v -race -covermode atomic -coverprofile $$(COVERAGE_DIR)/combined.txt -bench=. -benchmem -timeout 20m'
+       make test-with-flags TEST_FLAGS='-v  -covermode atomic -coverprofile $$(COVERAGE_DIR)
```

__编译__
1. 编译migrate二进制文件
```
#更新go mod依赖
go mod tidy
#编译二进制
make build 
```
3. 构建镜像
```
./docker-deploy.sh
```
__测试__
1. 测试migrate二进制
```
[yzw@kubernetes-master-1 migrate]$ ./migrate -h
Usage: migrate OPTIONS COMMAND [arg...]
       migrate [ -version | -help ]

Options:
  -source          Location of the migrations (driver://url)
  -path            Shorthand for -source=file://path
  -database        Run migrations against this database (driver://url)
  -prefetch N      Number of migrations to load in advance before executing (default 10)
  -lock-timeout N  Allow N seconds to acquire database lock (default 15)
  -verbose         Print verbose logging
  -version         Print version
  -help            Print usage

Commands:
  create [-ext E] [-dir D] [-seq] [-digits N] [-format] [-tz] NAME
	   Create a set of timestamped up/down migrations titled NAME, in directory D with extension E.
	   Use -seq option to generate sequential up/down migrations with N digits.
	   Use -format option to specify a Go time format string. Note: migrations with the same time cause "duplicate migration version" error.
           Use -tz option to specify the timezone that will be used when generating non-sequential migrations (defaults: UTC).

  goto V       Migrate to version V
  up [N]       Apply all or N up migrations
  down [N] [-all]    Apply all or N down migrations
	Use -all to apply all down migrations
  drop [-f]    Drop everything inside database
	Use -f to bypass confirmation
  force V      Set version V but don't run migration (ignores dirty state)
  version      Print current migration version

Source drivers: github-ee, godoc-vfs, gcs, s3, github, gitlab, go-bindata, file, bitbucket
Database drivers: neo4j, pgx, mongodb+srv, sqlserver, firebird, clickhouse, cockroach, crdb-postgres, postgres, postgresql, redshift, spanner, cassandra, firebirdsql, mongodb, mysql, stub, cockroachdb
```
