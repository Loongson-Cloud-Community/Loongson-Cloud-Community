## debian abi2.0 镜像移植情况

|序号|项目     	|是否移植   	|阻塞项|
|--  |--        |--           |--|
|	1	|	gitlab/gitlab-runner/13.11-buster/Dockerfile	|
|	2	|	confluentinc/base/5.3.0/Dockerfile	|
|	3	|	prometheus/busybox/glibc/Dockerfile	|
|	4	|	kubernetes/coredns/v1.10.1/0001-support-loong64.patch	|
|	5	|	kubernetes/coredns/1.11.2/0001-support-loong64.patch	|
|	6	|	kubernetes/kube-state-metrics/2.3.0/Dockerfile	|
|	7	|	kubernetes/etcd/3.4.27/0001-support-loong64.patch	|
|	8	|	joyieldnic/predixy/1.0.5/Dockerfile	|
|	9	|	osixia/light-baseimage/1.2.0/0001-port-to-loong64.patch	|
|	10	|	osixia/light-baseimage/v1.3.2/0001-port-to-loong64.patch	|
|	11	|	bitnami/zookeeper/3.5.9/Dockerfile	|
|	12	|	bitnami/kafka/2.7.0/Dockerfile	|
|	13	|	clickhouse/clickhouse-server/22.3.2.2/Dockerfile	|
|	14	|	nacos/nacos-server/2.0.3-slim/Dockerfile	|
|	15	|	library/ruby/2.5.5/Dockerfile	|
|	16	|	library/elasticsearch/8.7.0/Dockerfile	|
|	17	|	library/logstash/8.7.0/Dockerfile	|
|	18	|	library/python/3.7.10/Dockerfile	| 是 |
|	19	|	library/python/3.9/debian/Dockerfile	| 是 |
|	20	|	library/python/3.12/debian/Dockerfile	| 是 |
|	21	|	library/python/3.10/debian/Dockerfile	| 是 |
|	22	|	library/python/3.11/debian/Dockerfile	|  是 |
|	23	|	library/php/7.4.30-apache/Dockerfile	|
|	24	|	library/mariadb/10.6/Dockerfile	|
|	25	|	library/mariadb/10.5.18/Dockerfile	|
|	26	|	library/mariadb/10.3.34/Dockerfile	|
|	27	|	library/mariadb/10.11/Dockerfile	|
|	28	|	library/openjdk/17-buster/Dockerfile	|
|	29	|	library/openjdk/11-buster/Dockerfile	|
|	30	|	library/openjdk/8-buster/Dockerfile	|
|	31	|	library/openjdk/21-buster/Dockerfile	|
|	32	|	library/postgres/13.13-debian/Dockerfile	|
|	33	|	library/caddy/debian/Dockerfile	|
|	34	|	library/buildpack-deps/buster-curl/Dockerfile	|
|	35	|	library/nginx/1.24.0/debian/Dockerfile	|
|	36	|	library/node/18.18.1-debian/Dockerfile	|
|	37	|	library/node/16.20.2-debian/Dockerfile	|
|	38	|	library/node/16.3.0-debian/Dockerfile	|
|	39	|	library/node/16.17.1-debian/Dockerfile	|
|	40	|	library/node/16.5.0-debian/Dockerfile	|
|	41	|	library/node/18.13.0-debian/Dockerfile	|
|	42	|	library/node/20.8.0-debian/Dockerfile	|
|	43	|	library/kibana/8.7.0/Dockerfile	|
|	44	|	library/haproxy/2.9/Dockerfile	|
|	45	|	library/haproxy/2.3/Dockerfile	|
|	46	|	library/haproxy/2.8/Dockerfile	|
|	47	|	library/neo4j-community/5.7.0/Dockerfile	|
|	48	|	library/spiped/1.6/Dockerfile	|
|	49	|	library/redis/7.0/debian/Dockerfile	|
|	50	|	library/redis/6.2/debian/Dockerfile	|
|	51	|	library/redis/6.0/debian/Dockerfile	|
|	52	|	minio/mc/debian/Dockerfile	|
|	53	|	minio/minio/debian/Dockerfile	|
|	54	|	goharbor/spilo-11/1.6-p3/0001-port-to-loong64.patch	|
|	55	|	goharbor/harbor-operator/release-1.2.0/0004-Generate-image.patch	|
|	56	|	kubernetes-ingress-controller/kube-webhook-certgen/1.1.2/rootfs/Dockerfile	|
|	57	|	rancher/rancher/2.4.8/Dockerfile	|
|	58	|	rancher/coredns-coredns/1.8.3/0001-add-loong64-support.patch	|
|	59	|	k8s-build-image/debian-base/latest/Dockerfile	|
|	60	|	k8s-build-image/debian-iptables/latest/Dockerfile	|
|	61	|	k8s-build-image/go-runner/latest/Dockerfile	|
|	62	|	influxdata/kapacitor/1.6.6/Dockerfile	|
|	63	|	influxdata/kapacitor/1.6.6/Dockerfile_build_ubuntu64	|
|	64	|	guacamole/guacamole-server/1.5.3/Dockerfile	|
|	65	|	guacamole/guacamole-server/1.5.3/guacenc/Dockerfile	|
|	66	|	guacamole/guacamole-server/1.5.3/guacenc/Dockerfile	|
|	67	|	google_containers/nginx-slim/0.14/Dockerfile	|
|	68	|	nicolaka/netshoot/0.0.6/Dockerfile	|
|	69	|	kubernetes-sigs/metrics-server/0.5.0/0001-init-vendor.patch	|
|	70	|	kubernetes-sigs/metrics-server/0.5.0/0003-Add-support-for-loong64.patch	|
|	71	|	kong/fpm/0.5.1/0001-port-to-loong64.patch	|
|	72	|	onlyoffice/documentserver/7.1.1/Dockerfile	|
|	73	|	calico/bpftool/5.19/0001-port-to-loong64.patch	|
|	74	|	calico/bird/0.3.3/0001-port-to-loong64.patch	|
|	75	|	calico/node/3.24.1/0001-port-to-loong64.patch	|
|	76	|	grafana/promtail/2.8.2/0001-support-loong64.patch	|
|	77	|	grafana/promtail/2.6.1/0001-port-to-loong64.patch	|
|	78	|	kubevirt/passwd/0.50.0/Dockerfile	|
|	79	|	openpolicyagent/gatekeeper/3.5.2/Dockerfile	|
|	80	|	tdengine/tdengine/3.0.0.0/Dockerfile	|
|	81	|	kubesphere/notification-manager-operator/1.4.0/Dockerfile	|
|	82	|	kubesphere/fluentbit-operator/0.13.0/Dockerfile	|
|	83	|	kubesphere/notification-manager/1.4.0/Dockerfile	|
|	84	|	kubesphere/kube-events-ruler/0.3.0/0001-port-to-loong64.patch	|
|	85	|	kubesphere/notification-tenant-sidecar/3.2.0/Dockerfile	|
|	86	|	vectordotdev/vector/0.26.0/Dockerfile.debian	|
|	87	|	openstackhelm/ceph-config-helper/latest-ubuntu_bionic/Dockerfile	|
|	88	|	stackanetes/kubernetes-entrypoint/0.3.1/Dockerfile	|
|	89	|	emqx/emqx/5.3.2/Dockerfile	|
|	90	|	istio/proxyv2/1.11.1/0001-add-loong64-support.patch	|
|	91	|	fluent/fluent-bit/1.8.11/Dockerfile	|



