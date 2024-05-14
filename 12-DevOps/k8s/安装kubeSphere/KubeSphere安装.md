# 安装KubeSphere

## 一、前置环境准备

### 安装nfs文件系统

#### 安装nfs工具

```
# 在所有节点执行
sudo yum install -y nfs-utils
```

#### 初始化主节点

```
# 在master 执行以下命令 
echo "/nfs/data/ *(insecure,rw,sync,no_root_squash)" > /etc/exports


# 执行以下命令，启动 nfs 服务;创建共享目录
mkdir -p /nfs/data


# 在master执行
systemctl enable rpcbind
systemctl enable nfs-server
systemctl start rpcbind
systemctl start nfs-server

# 使配置生效
exportfs -r


#检查配置是否生效
exportfs
```

#### 初始化客户端节点

```
# 将这里的IP改为主机点的IP
showmount -e 192.168.1.22
mkdir -p /nfs/data
mount -t nfs 192.168.1.22:/nfs/data /nfs/data
```

#### 配置默认存储

```yaml
## 创建了一个存储类
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-storage
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner
parameters:
  archiveOnDelete: "true"  ## 删除pv的时候，pv的内容是否要备份

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  labels:
    app: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/nfs-subdir-external-provisioner:v4.0.2
          # resources:
          #    limits:
          #      cpu: 10m
          #    requests:
          #      cpu: 10m
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: k8s-sigs.io/nfs-subdir-external-provisioner
            - name: NFS_SERVER
              value: 192.168.1.22 ## 指定自己nfs服务器地址
            - name: NFS_PATH  
              value: /nfs/data  ## nfs服务器共享的目录
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.1.22
            path: /nfs/data
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io
```

#### 存储类型测试

- 创建一个pvc并执行

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nginx-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 200Mi
```

这里我们创建了一个名为nginx-pvc的pvc，但是没有声明和绑定pv。在执行 `kubectl apply -f sc.yaml` 之后执行 `kubectl get pv`  查看pv，可以发现系统自动创建了一个大小为200M的pv。

```
[root@k8s-master ~]# kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS   REASON   AGE
pvc-26ad0f4c-9270-40e7-b812-e6836401cfe8   200Mi      RWX            Delete           Bound    default/nginx-pvc   nfs-storage             21s

```

### 安装**metrics-server**

> metrics-server用于集群指标监控

#### 安装metrics

```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  - nodes/stats
  - namespaces
  - configmaps
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --kubelet-insecure-tls
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        image: registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/metrics-server:v0.4.3
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          periodSeconds: 10
        securityContext:
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
```

将以上内容保存至metrics.yaml中，并执行 `kubectl apply -f metrics.yaml` 。完成后执行 `kubectl get pod -n kube-system` ，此时会新建一个metrics开头的pod，等待其状态为running即为安装成功。

```
[root@k8s-master ~]# kubectl get pod -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-577f77cb5c-2t4wq   1/1     Running   1          15h
calico-node-crzr9                          1/1     Running   0          15h
calico-node-p99bl                          1/1     Running   0          15h
calico-node-wt96k                          1/1     Running   2          15h
coredns-5897cd56c4-75w76                   1/1     Running   1          15h
coredns-5897cd56c4-lskp7                   1/1     Running   1          15h
etcd-k8s-master                            1/1     Running   2          15h
kube-apiserver-k8s-master                  1/1     Running   2          15h
kube-controller-manager-k8s-master         1/1     Running   2          15h
kube-proxy-5vnkt                           1/1     Running   0          15h
kube-proxy-cmb5p                           1/1     Running   2          15h
kube-proxy-zfnlb                           1/1     Running   0          15h
kube-scheduler-k8s-master                  1/1     Running   2          15h
metrics-server-6497cc6c5f-5jgrt            1/1     Running   0          4m18s

```

#### 查看集群状态

- 查看node占用资源信息

```
[root@k8s-master ~]# kubectl top node
NAME         CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
k8s-master   125m         3%     1987Mi          26%
k8s-node01   67m          1%     3749Mi          48%
k8s-node02   67m          1%     3456Mi          45%

```

- 查看pod占用资源信息

```
[root@k8s-master ~]# kubectl top pod -A
NAMESPACE     NAME                                       CPU(cores)   MEMORY(bytes)
default       nfs-client-provisioner-5cfcd965b6-mg5cz    1m           14Mi
kube-system   calico-kube-controllers-577f77cb5c-2t4wq   2m           25Mi
kube-system   calico-node-crzr9                          14m          130Mi
kube-system   calico-node-p99bl                          16m          130Mi
kube-system   calico-node-wt96k                          16m          153Mi
kube-system   coredns-5897cd56c4-75w76                   1m           16Mi
kube-system   coredns-5897cd56c4-lskp7                   2m           16Mi
kube-system   etcd-k8s-master                            7m           47Mi
kube-system   kube-apiserver-k8s-master                  27m          306Mi
kube-system   kube-controller-manager-k8s-master         6m           55Mi
kube-system   kube-proxy-5vnkt                           1m           21Mi
kube-system   kube-proxy-cmb5p                           1m           19Mi
kube-system   kube-proxy-zfnlb                           1m           19Mi
kube-system   kube-scheduler-k8s-master                  2m           23Mi
kube-system   metrics-server-6497cc6c5f-5jgrt            2m           13Mi

```

## 二、安装KubeSphere

> 您的 Kubernetes 版本必须为：v1.20.x、v1.21.x、v1.22.x、v1.23.x、* v1.24.x、* v1.25.x 和 * v1.26.x。带星号的版本可能出现边缘节点部分功能不可用的情况。因此，如需使用边缘节点，推荐安装 v1.23.x。
>
> 确保您的机器满足最低硬件要求：CPU > 1 核，内存 > 2 GB。
>
> 在安装之前，需要配置 Kubernetes 集群中的**默认**存储类型。

### 部署KubeSphere

#### 默认自动安装

```
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.4.0/kubesphere-installer.yaml
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.4.0/cluster-configuration.yaml

```

如果以上安装失败，可以尝试将文件下载到本地再执行安装

#### 下载文件到本地

```
wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.0/kubesphere-installer.yaml

wget https://github.com/kubesphere/ks-installer/releases/download/v3.4.0/cluster-configuration.yaml
```

#### 编辑cluster-configuration.yaml配置文件

- 修改spec.etcd.monitoring为true，开启etcd监控
- 修改spec.common.redis.enabled为true，开启redis功能
- 根据实际情况决定是否修改spec.common.redis.enableHA为true，开启redis高可用。

  > 开启后可以提高系统的稳定性和可靠性，但是会消耗更多的系统资源用来维护redis实例。
  >
- 修改spec.common.openldap.enabled为true，开启轻量级目录协议。
- 修改spec.alerting.enabled为true，开启系统告警功能。
- 修改spec.auditing.enabled为true，开启审计功能。
- 修改spec.devops.enabled为true，开启devops功能。
- 修改spec.events.enabled为true，开启集群事件功能。
- 修改spec.logging.enabled为true，开启日志功能。
- spec.metrics_server.enabled不建议修改。

  > 这里如果设置为true，kubesphere会从官方下载镜像，可能会导致下载失败。前面在前置环境准备中已经安装了metrice。
  >
- 修改spec.network.networkpolicy.enabled为true，开启网络策略。

  > 网络策略允许在同一集群内进行网络隔离，这意味着可以在某些实例（Pod）之间设置防火墙。
  >

  > 确保集群使用的CNI网络插件支持NetworkPolicy。有许多CNI网络插件支持NetworkPolicy，包括Calico、Cilium、Kube路由器、Romana和Weave Net。
  >
- 修改spec.network.ippool.type为calico。

  > 使用Pod IP池来管理Pod网络地址空间。可以从Pod IP池中为要创建的Pod分配IP地址。
  >

  > 如果calico用作CNI插件，请在此字段中指定“calico”。“none”表示Pod IP池已禁用。
  >
- 修改spec.openpitrix.store.enabled为true，开启KubeSphere的应用商店功能。
- 修改spec.servicemesh.enabled为true，开启服务治理功能。
