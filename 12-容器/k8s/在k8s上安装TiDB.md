# 使用TiDB Operator在k8s集群环境部署TiDB

**todo: 经测试，集群可以正常搭建，但是访问存在问题，待修复**

## 集群环境要求

### 软件版本要求

| 软件名称   | 版本                                         |
| :--------- | :------------------------------------------- |
| Docker     | Docker CE 18.09.6                            |
| Kubernetes | v1.12.5+                                     |
| CentOS     | CentOS 7.6，内核要求为 3.10.0-957 或之后版本 |
| Helm       | v3.0.0+                                      |

- 查看docker版本

```
[root@k8s-master ~]# docker version
Client: Docker Engine - Community
 Version:           20.10.7
 API version:       1.41
 Go version:        go1.13.15
 Git commit:        f0df350
 Built:             Wed Jun  2 11:56:24 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.7
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.15
  Git commit:       b0f5bc3
  Built:            Wed Jun  2 11:54:48 2021
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.4.6
  GitCommit:        d71fcd7d8303cbf684402823e425e9dd2e99285d
 runc:
  Version:          1.0.0-rc95
  GitCommit:        b9ee9c6314599f1b4a7f497e1f1f856fe433d3b7
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

```

- 查看kubernetes版本

```
[root@k8s-master ~]# kubectl version
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.9", GitCommit:"7a576bc3935a6b555e33346fd73ad77c925e9e4a", GitTreeState:"clean", BuildDate:"2021-07-15T21:01:38Z", GoVersion:"go1.15.14", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.9", GitCommit:"7a576bc3935a6b555e33346fd73ad77c925e9e4a", GitTreeState:"clean", BuildDate:"2021-07-15T20:56:38Z", GoVersion:"go1.15.14", Compiler:"gc", Platform:"linux/amd64"}

```

- 查看centos版本和内核版本

```
# 查看centos版本
[root@k8s-master ~]# cat /etc/redhat-release
CentOS Stream release 8

# 查看内核版本
[root@k8s-master ~]# uname -r
4.18.0-522.el8.x86_64

```

- 查看helm版本

```
[root@k8s-master ~]# helm version
version.BuildInfo{Version:"v3.13.1", GitCommit:"3547a4b5bf5edb5478ce352e18858d8a552a4110", GitTreeState:"clean", GoVersion:"go1.20.8"}

```

### 配置防火墙

- 关闭防火墙

```
systemctl stop firewalld
systemctl disable firewalld
```

如果无法关闭 firewalld 服务，为了保证 Kubernetes 正常运行，需要打开以下端口：

- master节点：

```
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --add-masquerade --permanent

# 当需要在 Master 节点上暴露 NodePort 时候设置
firewall-cmd --permanent --add-port=30000-32767/tcp

systemctl restart firewalld
```

- node节点

```
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent

systemctl restart firewalld
```

### 配置 Iptables

FORWARD 链默认配置成 ACCEPT，并将其设置到开机启动脚本里：

```
iptables -P FORWARD ACCEPT
```

> `iptables -P FORWARD ACCEPT`这个命令的作用是将iptables的FORWARD链的默认策略设置为ACCEPT。
>
> 在iptables中，有三个预定义的链：INPUT、OUTPUT和FORWARD。FORWARD链处理的是路由转发的数据包。
>
> - `ACCEPT`表示接受数据包。
> - `DROP`表示丢弃数据包。
> - `REJECT`表示拒绝数据包。
>   当FORWARD链的默认配置成ACCEPT时，意味着如果一个数据包没有匹配到FORWARD链中的任何一条规则，那么这个数据包将被接受，而不是被丢弃或者被拒绝。这就是iptables -P FORWARD ACCEPT命令的作用。

- 添加到开启启动脚本：

```
#!/bin/bash

cat > set-iptables.sh <<EOF
#!/bin/bash
# chkconfig: 2345 90 10
# description: set-iptables.sh is a script to set iptables

# The iptables command
/sbin/iptables -P FORWARD ACCEPT
EOF

# Move the script to /etc/rc.d/init.d and make it executable
mv ./set-iptables.sh /etc/rc.d/init.d
chmod 755 /etc/rc.d/init.d/set-iptables.sh

# Add the script to startup items
cd /etc/rc.d/init.d
chkconfig --add set-iptables.sh
chkconfig set-iptables.sh on

```

### 禁用SELinux

```
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

### 关闭swap

```
swapoff -a
sed -i 's/^\(.*swap.*\)$/#\1/' /etc/fstab
```

### 内核参数设置

按照下面的配置设置内核参数，也可根据自身环境进行微调：

```
modprobe br_netfilter

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.core.somaxconn = 32768
vm.swappiness = 0
net.ipv4.tcp_syncookies = 0
net.ipv4.ip_forward = 1
fs.file-max = 1000000
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 1024
net.ipv4.conf.all.rp_filter = 1
net.ipv4.neigh.default.gc_thresh1 = 80000
net.ipv4.neigh.default.gc_thresh2 = 90000
net.ipv4.neigh.default.gc_thresh3 = 100000
EOF

sysctl --system
```

### 配置 Irqbalance 服务

`irqbalance`服务可以将各个设备对应的中断号分别绑定到不同的 CPU 上，以防止所有中断请求都落在同一个 CPU 上而引发性能瓶颈。

```
systemctl enable irqbalance
systemctl start irqbalance
```

### CPUfreq 调节器模式设置

为了让 CPU 发挥最大性能，请将 CPUfreq 调节器模式设置为 performance 模式。

如果是 `虚拟机`或者 `云主机`，则不需要调整。前面查看节能策略时命令输出通常为 `Unable to determine current policy`。

```
# 查看cpufreq模块选用的节能策略
cpupower frequency-info --policy

# 将 CPUfreq 调节器模式设置为 performance 模式。
cpupower frequency-set --governor performance
```

### Ulimit 设置

TiDB 集群默认会使用很多文件描述符，需要将工作节点上面的 `ulimit` 设置为大于等于 `1048576`：

```sh
cat <<EOF >>  /etc/security/limits.conf
root        soft        nofile        1048576
root        hard        nofile        1048576
root        soft        stack         10240
EOF

sysctl --system
```

### docker服务

- 将 Docker 的数据保存到一块单独的盘上，Docker 的数据主要包括镜像和容器日志数据。`如果已经创建了k8s集群，需要谨慎操作该步骤，如非必要可以不执行。`

```
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "data-root": "/data1/docker"
}
EOF
```

- 设置 Docker daemon 的 ulimit。

  1. 创建 docker service 的 systemd drop-in 目录 `/etc/systemd/system/docker.service.d`：

     ```sh
     mkdir -p /etc/systemd/system/docker.service.d
     ```
  2. 创建 `/etc/systemd/system/docker.service.d/limit-nofile.conf` 文件，并配置 `LimitNOFILE` 参数的值，取值范围为大于等于 `1048576` 的数字即可。

     ```sh
     cat > /etc/systemd/system/docker.service.d/limit-nofile.conf <<EOF
     [Service]
     LimitNOFILE=1048576
     EOF
     ```

     注意

     请勿将 `LimitNOFILE` 的值设置为 `infinity`。由于 [`systemd` 的 bug](https://github.com/systemd/systemd/commit/6385cb31ef443be3e0d6da5ea62a267a49174688#diff-108b33cf1bd0765d116dd401376ca356L1186)，`infinity` 在 `systemd` 某些版本中指的是 `65536`。
  3. 重新加载配置。

     ```sh
     systemctl daemon-reload && systemctl restart docker
     ```

## 配置存储类型

### TiDB 集群推荐存储类型

TiKV 自身借助 Raft 实现了数据复制，出现节点故障后，PD会自动进行数据调度补齐缺失的数据副本，同时 `TiKV `要求存储有较低的读写延迟，所以生产环境强烈推荐 `使用本地 SSD 存储`。

`PD `同样借助 Raft 实现了数据复制，但作为存储集群元信息的数据库，并不是 IO 密集型应用，所以一般 `本地普通 SAS 盘或网络 SSD 存储`（例如 AWS 上 gp2 类型的 EBS 存储卷，Google Cloud 上的持久化 SSD 盘）就可以满足要求。

`监控组件以及 TiDB Binlog、备份等工具`，由于自身没有做多副本冗余，所以为保证可用性，推荐用网络存储。其中 TiDB Binlog 的 pump 和 drainer 组件属于 IO 密集型应用，需要较低的读写延迟，所以推荐用 `高性能的网络存储`（例如 AWS 上的 io1 类型的 EBS 存储卷，Google Cloud 上的持久化 SSD 盘）。

在利用 TiDB Operator 部署 TiDB 集群或者备份工具的时候，需要持久化存储的组件都可以通过 values.yaml 配置文件中对应的 `storageClassName` 设置存储类型。不设置时默认都使用 `local-storage`。

### 网络PV配置

- 查看当前全部存储类型

```
[root@k8s-master test]# kubectl get sc -A
NAME                    PROVISIONER                                   RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-storage (default)   k8s-sigs.io/nfs-subdir-external-provisioner   Delete          Immediate           false                  11d

```

- 修改nfs-storage开启动态扩容

```
[root@k8s-master test]# kubectl patch storageclass nfs-storage  -p '{"allowVolumeExpansion": true}'
storageclass.storage.k8s.io/nfs-storage patched

```

### 本地PV配置

#### 准备本地存储

> 如果您计划在 TiDB 中使用本地持久卷（Local Persistent Volumes，即本地PV），您需要在所有的节点上都创建相应的本地挂载目录。本地 PV 是绑定到单个节点上的存储设备或目录的 PV，因此每个节点都需要有自己的挂载目录。

这里如果有足够的硬件配置可以参考[官方文档](https://docs.pingcap.com/zh/tidb-in-kubernetes/dev/configure-storage-class#%E7%AC%AC-1-%E6%AD%A5%E5%87%86%E5%A4%87%E6%9C%AC%E5%9C%B0%E5%AD%98%E5%82%A8)配置本地存储，如果作为测试环境，则在对应位置创建 `/mnt/ssd`、`/mnt/sharedssd`、`/mnt/monitoring` 和 `/mnt/backup`目录即可，不执行磁盘挂载。

#### 部署local-volume-provisioner

- 下载 local-volume-provisioner 部署文件。

```
wget https://raw.githubusercontent.com/pingcap/tidb-operator/master/examples/local-pv/local-volume-provisioner.yaml
```

- 如果前面修改了本地存储路径，则这里需要调整对应的配置文件。

> 修改 ConfigMap 定义中的 `data.storageClassMap` 字段：
>
> * ```yaml
>   apiVersion: v1
>   kind: ConfigMap
>   metadata:
>     name: local-provisioner-config
>     namespace: kube-system
>   data:
>     # ...
>     storageClassMap: |
>       ssd-storage: # 给 TiKV 使用
>         hostDir: /mnt/ssd
>         mountDir: /mnt/ssd
>       shared-ssd-storage: # 给 PD 使用
>         hostDir: /mnt/sharedssd
>         mountDir: /mnt/sharedssd
>       monitoring-storage: # 给监控数据使用
>         hostDir: /mnt/monitoring
>         mountDir: /mnt/monitoring
>       backup-storage: # 给 TiDB Binlog 和备份数据使用
>         hostDir: /mnt/backup
>         mountDir: /mnt/backup
>   ```
>
>   关于 local-volume-provisioner 更多的配置项，参考文档 [Configuration](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/docs/provisioner.md#configuration) 。
> * 修改 DaemonSet 定义中的 `volumes` 与 `volumeMounts` 字段，以确保发现目录能够挂载到 Pod 中的对应目录：
>
>   ```yaml
>   ......
>         volumeMounts:
>           - mountPath: /mnt/ssd
>             name: local-ssd
>             mountPropagation: "HostToContainer"
>           - mountPath: /mnt/sharedssd
>             name: local-sharedssd
>             mountPropagation: "HostToContainer"
>           - mountPath: /mnt/backup
>             name: local-backup
>             mountPropagation: "HostToContainer"
>           - mountPath: /mnt/monitoring
>             name: local-monitoring
>             mountPropagation: "HostToContainer"
>     volumes:
>       - name: local-ssd
>         hostPath:
>           path: /mnt/ssd
>       - name: local-sharedssd
>         hostPath:
>           path: /mnt/sharedssd
>       - name: local-backup
>         hostPath:
>           path: /mnt/backup
>       - name: local-monitoring
>         hostPath:
>           path: /mnt/monitoring
>   ......
>   ```




- 部署 local-volume-provisioner 程序。

```sh
kubectl apply -f local-volume-provisioner.yaml
```

- 检查 Pod 和 PV 状态。

```sh
kubectl get po -n kube-system -l app=local-volume-provisioner && \
kubectl get pv | grep -e ssd-storage -e shared-ssd-storage -e monitoring-storage -e backup-storage
```

`local-volume-provisioner` 会为发现目录下的每一个挂载点创建一个 PV。



## 在 Kubernetes 上部署 TiDB Operator

> [TiDB Operator](https://github.com/pingcap/tidb-operator) 是 Kubernetes 上的 TiDB 集群自动运维系统，提供包括部署、升级、扩缩容、备份恢复、配置变更的 TiDB 全生命周期管理。借助 TiDB Operator，TiDB 可以无缝运行在公有云或自托管的 Kubernetes 集群上。

### 准备环境

TiDB Operator 部署前，请确认以下软件需求：

* Kubernetes v1.12 或者更高版本
* DNS 插件

  > 在 Kubernetes 1.11 及其以后版本中，推荐使用 CoreDNS， kubeadm 默认会安装 CoreDNS。
  >
* PersistentVolume

  > PV、PVC在集群中默认启用
  >
* RBAC 启用（可选）

  > 基于角色（Role）的访问控制（RBAC）是一种基于组织中用户的角色来调节控制对计算机或网络资源的访问的方法。要启用 RBAC，在启动 API 服务器时将 `--authorization-mode` 参数设置为一个逗号分隔的列表并确保其中包含 `RBAC`。
  >

  ```
  kube-apiserver --authorization-mode=Example,RBAC --<其他选项> --<其他选项>
  ```
* [Helm 3](https://helm.sh/)

  > Helm 是 Kubernetes 的包管理器
  >

#### Helm安装

- 创建安装目录

```shell
mkdir /opt/helm
cd /opt/helm
```

- 下载需要安装的版本

这里以 `v3.13.1` 为例，在centos上安装。从github上下载对应版本文件，[文件地址](https://get.helm.sh/helm-v3.13.1-linux-amd64.tar.gz)。

```shell
curl -SLO  https://get.helm.sh/helm-v3.13.1-linux-amd64.tar.gz
```

- 创建安装文件

```shell
# 解压文件
tar -zxvf helm-v3.13.1-linux-amd64.tar.gz

# 移动脚本
cp /opt/helm/linux-amd64/helm /usr/local/bin/
```

- 测试脚本

```
helm version
```

- 配置Helm repo

```
helm repo add pingcap https://charts.pingcap.org/
```

> Kubernetes 应用在 Helm 中被打包为 chart。PingCAP 针对 Kubernetes 上的 TiDB 部署运维提供了多个 Helm chart：
> `tidb-operator`：用于部署 TiDB Operator；
> `tidb-cluster`：用于部署 TiDB 集群；
> `tidb-backup`：用于 TiDB 集群备份恢复；
> `tidb-lightning`：用于 TiDB 集群导入数据；
> `tidb-drainer`：用于部署 TiDB Drainer；

- 测试repo

```
[root@k8s-master ~]# helm search repo pingcap
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
pingcap/br-federation   v1.5.1          v1.5.1          br-federation Helm chart for Kubernetes
pingcap/diag            v1.3.1          v1.3.1          clinic diag Helm chart for Kubernetes
pingcap/tidb-backup     v1.5.1                          DEPRECATED(refer new instructions at https://do...
pingcap/tidb-cluster    v1.5.1                          DEPRECATED(refer new instructions at https://do...
pingcap/tidb-drainer    v1.5.1                          A Helm chart for TiDB Binlog drainer.
pingcap/tidb-lightning  v1.5.1                          A Helm chart for TiDB Lightning
pingcap/tidb-operator   v1.5.1          v1.5.1          tidb-operator Helm chart for Kubernetes
pingcap/tikv-importer   v1.5.1                          A Helm chart for TiKV Importer
pingcap/tikv-operator   v0.1.0          v0.1.0          A Helm chart for Kubernetes

```

### 部署TiDB Opreator

#### 创建CRD

TiDB Operator 使用 Custom Resource Definition (CRD) 扩展 Kubernetes，所以要使用 TiDB Operator，必须先创建 `TidbCluster` 自定义资源类型。

- k8s版本为1.16之后的：

```
kubectl create -f https://raw.githubusercontent.com/pingcap/tidb-operator/master/manifests/crd.yaml
```

- k8s版本为1.16之前的

```
kubectl create -f https://raw.githubusercontent.com/pingcap/tidb-operator/master/manifests/crd_v1beta1.yaml
```

- 验证是否安装成功

```
[root@k8s-master ~]# kubectl get crd |grep pingcap
backups.pingcap.com                                   2023-11-30T08:22:01Z
backupschedules.pingcap.com                           2023-11-30T08:22:01Z
dmclusters.pingcap.com                                2023-11-30T08:22:01Z
restores.pingcap.com                                  2023-11-30T08:22:01Z
tidbclusterautoscalers.pingcap.com                    2023-11-30T08:22:01Z
tidbclusters.pingcap.com                              2023-11-30T08:22:02Z
tidbdashboards.pingcap.com                            2023-11-30T08:22:02Z
tidbinitializers.pingcap.com                          2023-11-30T08:22:02Z
tidbmonitors.pingcap.com                              2023-11-30T08:22:02Z
tidbngmonitorings.pingcap.com                         2023-11-30T08:22:02Z

```

#### 自定义部署TiDB Operator

##### 在线部署TiDB Operator

- 查看当前支持的chart 版本

```
[root@k8s-master tidb-operator]# helm search repo -l tidb-operator
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
pingcap/tidb-operator   v1.5.1          v1.5.1          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.5.0          v1.5.0          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.7          v1.4.7          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.6          v1.4.6          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.5          v1.4.5          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.4          v1.4.4          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.3          v1.4.3          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.2          v1.4.2          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.1          v1.4.1          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.4.0          v1.4.0          tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.3.10         v1.3.10         tidb-operator Helm chart for Kubernetes
pingcap/tidb-operator   v1.3.9          v1.3.9          tidb-operator Helm chart for Kubernetes

```

- 添加chart_version至环境变量

```
cd 
vim .bash_profile

# 添加版本配置并保存退出
export chart_version='v1.5.1'

# 刷新环境变量配置
source .bash_profile

```

- 获取 `tidb-operator` chart 中的 `values.yaml` 文件

```
# 这里可以通过修改前面配置的chart_version调整部署版本
mkdir -p ${HOME}/tidb-operator && \
helm inspect values pingcap/tidb-operator --version=${chart_version} > ${HOME}/tidb-operator/values-tidb-operator.yaml
```

- 配置 TiDB Operator

如果需要使用k8s集群默认的调度管理组件，则需要修改前面下载的values文件中的对应配置 `scheduler:create: true` 为 `false` ，这里以不安装scheduler为例。

- 准备镜像

```
# 提前准备下载所需的镜像
docker pull pingcap/tidb-operator:v1.5.1
docker pull pingcap/tidb-backup-manager:v1.5.1
docker pull bitnami/kubectl:latest
docker pull pingcap/advanced-statefulset:v0.3.3

```

- 部署 TiDB Operator

```
# 创建k8s部署的namespace
kubectl create namespace tidb-admin

# 部署 TiDB Operator
helm install tidb-operator pingcap/tidb-operator --namespace=tidb-admin --version=${chart_version} -f ${HOME}/tidb-operator/values-tidb-operator.yaml && \
kubectl get po -n tidb-admin -l app.kubernetes.io/name=tidb-operator

```

安装过程中终止本次安装：

```
helm uninstall tidb-operator --namespace=tidb-admin
```

- 检查pod状态

```
[root@k8s-master tidb-operator]# kubectl get pod -n tidb-admin
NAME                                       READY   STATUS    RESTARTS   AGE
tidb-controller-manager-6b94875b7b-q2xhb   1/1     Running   0          22s

```

- 升级TiDB Operator

修改 `${HOME}/tidb-operator/values-tidb-operator.yaml` 文件，然后执行下面的命令进行升级：

```
helm upgrade tidb-operator pingcap/tidb-operator --namespace=tidb-admin -f ${HOME}/tidb-operator/values-tidb-operator.yaml
```

## 配置TiDB集群

### 资源配置

参考[官方文档](https://docs.pingcap.com/zh/tidb-in-kubernetes/dev/configure-a-tidb-cluster#%E8%B5%84%E6%BA%90%E9%85%8D%E7%BD%AE)

### 部署配置

#### 创建TiDB集群名称空间

- 创建k8s集群namespace

```
[root@k8s-master tidb-cluster]# kubectl create ns tidb-cluster
namespace/tidb-cluster created

```

#### 将集群名称写入环境变量

```
echo "export cluster_name='tidb-cluster'" >> ~/.bash_profile
source ~/.bash_profile

mkdir ~/tidb-cluster
```


#### 准备 `TidbCluster` 部署文件

参考 TidbCluster [示例](https://github.com/pingcap/tidb-operator/blob/master/examples/advanced/tidb-cluster.yaml) 下载文件，切换版本为前面安装的 `TiDB Operator `版本。移动文件至 `~/tidb-cluster`


**修改 `${cluster_name}/tidb-cluster.yaml `文件执行以下配置：**

#### 修改集群名称和ns

```
metadata:
  name: cloud-tidb
  namespace: tidb-cluster

```


#### 部署TiFlash

如果要在集群中开启 TiFlash，需要在 `${cluster_name}/tidb-cluster.yaml` 文件中配置 `spec.pd.config.replication.enable-placement-rules: true`

```
  ###########################
  # TiDB Cluster Components #
  ###########################

  tiflash:
    baseImage: pingcap/tiflash
    maxFailoverCount: 0
    replicas: 1
    storageClaims:
    - resources:
        requests:
          storage: 100Gi
      storageClassName: local-storage

  pd:
    ##########################
    # Basic PD Configuration #
    ##########################

    ## Base image of the component
    baseImage: pingcap/pd

    ## pd-server configuration
    ## Ref: https://docs.pingcap.com/tidb/stable/pd-configuration-file
    config: |
      [dashboard]
        internal-proxy = true
      [replication]
      enable-placement-rules = true


```


#### 部署 TiCDC

如果要在集群中开启 TiCDC，需要在 `${cluster_name}/tidb-cluster.yaml` 文件中配置 `spec.ticdc`：

```yaml
  ticdc:
    baseImage: pingcap/ticdc
    replicas: 3
    config:
      logLevel: info
```



#### 配置实例个数

由于是测试环境，集群配置有限，这里设置各个组件只启动一个pod。

修改  `spec.<pd/tidb/tikv/pump/tiflash/ticdc>.replicas` 值为1。


## 部署TiDB集群

- 可以先拉取所需的docker镜像，再安装集群。对于离线安装，可以在本地安装docker镜像之后导入到服务器。

```
#!/bin/bash

# Define the list of Docker images to pull
images=(
  "pingcap/pd:v7.5.0"
  "pingcap/tikv:v7.5.0"
  "pingcap/tidb:v7.5.0"
  "pingcap/tidb-binlog:v7.5.0"
  "pingcap/ticdc:v7.5.0"
  "pingcap/tiflash:v7.5.0"
  "pingcap/tidb-monitor-reloader:v1.0.1"
  "pingcap/tidb-monitor-initializer:v7.5.0"
  "grafana/grafana:7.5.11"
  "prom/prometheus:v2.18.1"
  "busybox:1.26.2"
)

# Loop through each image and pull
for image in "${images[@]}"
do
  docker pull "$image"
done

```

- 赋权执行

```
chmod +x pull_images.sh
./pull_images.sh

```

- 部署集群

```
kubectl apply -f {cluster_name} -n clustername−n{namespace}
```


## 初始化TiDB集群

### 下载初始化文件

下载Tidb Initializer [示例](https://github.com/pingcap/tidb-operator/blob/master/manifests/initializer/tidb-initializer.yaml) ，将文件保存到 `${cluster_name}` 中。


### 设置集群的命名空间和名称

在 `${cluster_name}/tidb-initializer.yaml` 文件中，修改 `spec.cluster.namespace` 和 `spec.cluster.name` 字段:

```yaml
# ...
spec:
  # ...
  cluster:
    namespace: ${cluster_namespace}
    name: ${cluster_name}
```


### 初始化账号和密码设置

集群创建时默认会创建 `root` 账号，但是密码为空，这会带来一些安全性问题。可以通过如下步骤为 `root` 账号设置初始密码：

通过下面命令创建 [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) 指定 root 账号密码：

```sh
kubectl create secret generic tidb-secret --from-literal=root=${root_password} --namespace=${namespace}
```

如果希望能自动创建其它用户，可以在上面命令里面再加上其他用户的 username 和 password，例如：

```sh
kubectl create secret generic tidb-secret --from-literal=root=${root_password} --from-literal=developer=${developer_password} --namespace=${namespace}
```

该命令会创建 `root` 和 `developer` 两个用户的密码，存到 `tidb-secret` 的 Secret 里面。并且创建的普通用户 `developer` 默认只有 `USAGE` 权限，其他权限请在 `initSql` 中设置。

在 `${cluster_name}/tidb-initializer.yaml` 中设置 `passwordSecret: tidb-secret`。

### 设置允许访问 TiDB 的主机

在 `${cluster_name}/tidb-initializer.yaml` 中设置 `permitHost: ${mysql_client_host_name}` 配置项来设置允许访问 TiDB 的主机  **host_name** 。如果不设置，则允许所有主机访问。详情请参考 [MySQL GRANT host name](https://dev.mysql.com/doc/refman/5.7/en/grant.html)。


### 执行初始化

```sh
kubectl apply -f ${cluster_name}/tidb-initializer.yaml --namespace=${namespace}
```

以上命令会自动创建一个初始化的 Job，该 Job 会尝试利用提供的 secret 给 root 账号创建初始密码，并且创建其它账号和密码（如果指定了的话）。初始化完成后 Pod 状态会变成 Completed，之后通过 MySQL 客户端登录时需要指定这里设置的密码。
