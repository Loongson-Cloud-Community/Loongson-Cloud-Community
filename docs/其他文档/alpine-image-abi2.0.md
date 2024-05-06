## alpine abi2.0 镜像移植情况

|序号|项目     	|是否移植   	|阻塞项|
|--  |--        |--           |--|
|	1	|	apache/httpd/2.4.38-alpine/Dockerfile	|	是	|		|
|	2	|	apache/httpd/2.4.39-alpine/Dockerfile	|	是	|		|
|	3	|	apache/httpd/2.4.46-alpine/Dockerfile	|	是(并完成2.4.58版本制作)	|		|
|	4	|	calico/calico/3.26.1/0001-support-loong64.patch	|	正在进行	|		|
|	5	|	curlimages/curl/latest/Dockerfile	|	是（完成8.7.1版本制作）	|		|
|	6	|	deepflowio/deepflow/6.1.4-alpine-server/Dockerfile	|	是	|		|
|	7	|	dragonflyoss/dfclient/1.0.6/0001-port-to-loong64.patch	|	是	|		|
|	8	|	dragonflyoss/nginx/alpine/Dockerfile	|	是  |		|
|	9	|	dragonflyoss/supernode/1.0.6/0001-port-to-loong64.patch	|	是	|		|
|	10	|	edgexfoundry/app-service-configurable/2.3.0/0001-port-to-loong64.patch	|	是	|		|
|	11	|	edgexfoundry/app-service-configurable/3.0.0/0001-port-to-loong64.patch	|	是	|		|
|	12	|	edgexfoundry/core-command/3.0.0/0001-fix-add-loong64-support.patch	|	是	|		|
|	13	|	edgexfoundry/core-data/3.0.0/0001-fix-add-loong64-support.patch	|	是	|		|
|	14	|	edgexfoundry/core-metadata/3.0.0/0001-fix-add-loong64-support.patch	|	是	|		|
|	15	|	edgexfoundry/device-rest/0001-loong64-support-for-device-rest.patch	|	是	|		|
|	16	|	edgexfoundry/device-virtual/0001-add-loong64-support-device-virtual.patch	|	是	|		|
|	17	|	edgexfoundry/edgex-go/2.3.0/0001-port-to-loong64.patch	|	是	|		|
|	18	|	edgexfoundry/edgex-ui/3.0.0/0001-port-to-loong64.patch	|	是	|		|
|	19	|	edgexfoundry/support-notifications/3.0.0/0001-fix-add-loong64-support.patch	|	是	|		|
|	20	|	edgexfoundry/support-scheduler/3.0.0/0001-fix-add-loong64-support.patch	| 是	|		|
|	21	|	edgexfoundry/sys-mgmt-agent/3.0.0/0001-fix-add-loong64-support.patch	|	是	|		|
|	22	|	flannel-io/cni-plugin/1.2.0/0001-add-dockerfile-loong64.patch	|	正在制作	|		|
|	23	|	flannel-io/cni-plugin/1.4.0-flannel1/0001-support-loong64.patch	|		|		|
|	24	|	flannel-io/flannel/0.22.1/0001-support-loong64-in-v0.22.1.patch	|		|		|
|	25	|	flannel-io/flannel/0.24.2/0001-support-loong64.patch	|		|		|
|	26	|	flannel-io/flannel/0.24.3/0001-support-loong64.patch	|		|		|
|	27	|	fluent/fluentd/13.3.3-alpine/Dockerfile	|		|		|
|	28	|	gitlab/gitlab-runner-helper/13.11/Dockerfile	|是		|		|
|	29	|	gitlab/gitlab-runner/13.11-alpine/Dockerfile	|	是	|		|
|	30	|	grafana/loki/2.8.5/0001-support-loong64.patch	|		|		|
|	31	|	jenkins/jenkins/2.270/Dockerfile	|	是	|		|
|	32	|	justwatchcom/elasticsearch_exporter/1.1.0/0001-add-loong64-support.patch	|		|		|
|	33	|	k3s-io/klipper-lb/0.12/Dockerfile	|	正在制作	|		|
|	34	|	k8s-staging-ingress-nginx/controller/1.2.1/0001-port-to-loong64.patch	|		|		|
|	35	|	k8s-staging-ingress-nginx/nginx/1.2.1/0001-port-to-loong64.patch	|		|		|
|	36	|	kbudde/rabbitmq_exporter/1.0.0/Dockerfile	|		|		|
|	37	|	kubernetes-sigs/cluster-proportional-autoscaler/1.8.4/0001-port-to-loong64.patch	|		|		|
|	38	|	kubernetes-sigs/metrics-server/0.4.2/Dockerfile	|		|		|
|	39	|	kubernetes-sigs/metrics-server/0.5.0/0001-init-vendor.patch	|		|		|
|	40	|	kubernetes/etcd/3.3.12/Dockerfile	|		|		|
|	41	|	kubesphere/fluentbit-operator/0.13.0/Dockerfile	|		|		|
|	42	|	kubesphere/ks-installer/v3.2.1/Dockerfile	|		|		|
|	43	|	kubesphere/ks-installer/v3.3.0/Dockerfile	|		|		|
|	44	|	kubesphere/kube-events-exporter/0.3.0/0001-port-to-loong64.patch	|		|		|
|	45	|	kubesphere/kube-events-ruler/0.3.0/0001-port-to-loong64.patch	|		|		|
|	46	|	kubesphere/log-sidecar-injector/1.1/0001-port-to-loong64.patch	|		|		|
|	47	|	kubesphere/openpitrix-jobs/3.2.1/Dockerfile	|		|		|
|	48	|	lfedge/ekuiper/1.6-alpine/Dockerfile	|		|		|
|	49	|	library/bash/5.2/Dockerfile	|		|		|
|	50	|	library/consul/1.15.2/Dockerfile	|		|		|
|	51	|	library/dockerfile/1.5.0/0001-add-loongarch64-support.patch	|		|		|
|	52	|	library/eclipse-mosquitto/2.0.15/Dockerfile	|		|		|
|	53	|	library/golang/1.15-alpine/Dockerfile	|		|		|
|	54	|	library/golang/1.19-alpine/Dockerfile	|	是	|		|
|	55	|	library/golang/1.20-alpine/Dockerfile	|	是	|		|
|	56	|	library/golang/1.21-alpine/Dockerfile	|		|		|
|	57	|	library/golang/1.22-alpine/Dockerfile	|		|		|
|	58	|	library/haproxy/2.3-alpine/Dockerfile	|		|		|
|	59	|	library/kong/2.5.0-centos/0002-port-to-loong64.patch	|		|		|
|	60	|	library/kong/2.5.0-centos/0002-port-to-loong64.patch	|		|		|
|	61	|	library/nextcloud/17-fpm-alpine/Dockerfile	|		|		|
|	62	|	library/nginx/1.23.1-alpine/Dockerfile	|	是	|		|
|	63	|	library/php/7.4.30-cli-alpine/Dockerfile	|		|		|
|	64	|	library/php/7.4.30-fpm-alpine/Dockerfile	|		|		|
|	65	|	library/postgres/13-alpine/Dockerfile	|	是	|		|
|	66	|	library/postgres/9.6.24-alpine/Dockerfile	|	是	|		|
|	67	|	library/python/3.8.0-alpine/Dockerfile	|		|		|
|	68	|	library/rabbitmq/3.8.18/Dockerfile	|	正在进行	|		|
|	69	|	library/rabbitmq/3.8.2/Dockerfile	|	正在进行	|		|
|	70	|	library/rabbitmq/3.8.2/management/Dockerfile	|		|		|
|	71	|	library/rabbitmq/3.9.22/Dockerfile	|	正在进行	|		|
|	72	|	library/rabbitmq/3.9.22/management/Dockerfile	|		|		|
|	73	|	library/rabbitmq/3.9.4/Dockerfile	|		|		|
|	74	|	library/redis/7.0-alpine/Dockerfile	|		|		|
|	75	|	library/ruby/2.5.9-alpine/Dockerfile	|		|		|
|	76	|	library/spiped/1.6-alpine/Dockerfile	|		|		|
|	77	|	library/sqlite/3.35.5-alpine/Dockerfile	|		|		|
|	78	|	minio/mc/RELEASE.2019-08-07T23-14-43Z/Dockerfile	|		|		|
|	79	|	minio/minio/RELEASE.2019-08-07T01-59-21Z/0001-port-to-loong64.patch	|		|		|
|	80	|	nicolaka/netshoot/0.0.6/Dockerfile	|		|		|
|	81	|	oliver006/redis_exporter/1.44.0/Dockerfile	|		|		|
|	82	|	osixia/docker-keepalived/release-2.1.5-dev/0001-add-loong64-support-keepalived.patch	|		|		|
|	83	|	osixia/light-baseimage/alpine-0.1.6/0001-add-loong64-support-light-baseimage.patch	|		|		|
|	84	|	phpmyadmin/phpmyadmin/4.9.2-fpm-alpine/Dockerfile	|		|		|
|	85	|	plndr/kube-vip/0.3.8/0001-port-to-loong64.patch	|		|		|
|	86	|	rancher/klipper-helm/v0.4.3/0001-add-loong64-support.patch	|		|		|
|	87	|	rancher/klipper-lb/v0.1.2/0001-add-loong64-support.patch	|		|		|
|	88	|	rancher/library-traefik/2.4.8/0001-add-loong64-support.patch	|		|		|
|	89	|	rancher/local-path-provisioner/v0.0.19/0001-add-loong64-support.patch	|		|		|
|	90	|	spotahome/redis-operator/v1.1.1/0001-add-loong64-support.patch	|		|		|
|	91	|	vectordotdev/vector/0.26.0/Dockerfile.alpine	|		|		|
|	92	|	zabbix/zabbix-server-mysql/alpine-3.4.15/Dockerfile	|		|		|
|	93	|	zabbix/zabbix-web-apache-mysql/alpine-3.4.15/Dockerfile	|		|		|
|	94	|	zabbix/zabbix-web-apache-mysql/alpine-5.0.2/Dockerfile	|		|		|
|	95	|	edgexfoundry/app-service-configurable/2.3.0	|	是	|		|
|	96	|	edgexfoundry/core-command/2.3.0	|	是	|		|
|	97	|	edgexfoundry/core-data/2.3.0	|	是	|		|
|	98	|	edgexfoundry/core-metadata/2.3.0	|	 是	|		|
|	99	|	edgexfoundry/device-rest/2.3.0	| 是	|		|
|	100	|	edgexfoundry/device-virtual/2.3.0	|	是	|		|
|	101	|	edgexfoundry/edgex-ui/2.3.0	|	是	|		|
|	102	|	edgexfoundry/support-notifications/2.3.0	|	是	|		|
|	103	|	edgexfoundry/support-scheduler/2.3.0	|	是	|		|
|	104	|	edgexfoundry/sys-mgmt-agent/2.3.0	|	是	|		|
