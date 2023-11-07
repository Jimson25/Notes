# k8s

## 基本知识

### deployment

k8s使用deployment创建的pod，如果因为意外崩溃了，那么k8s会立即重新拉起一个新的pod起来。

当使用 `kubectl create deployment mytomcat --image=tomcat:8.5.68`创建一个tomcat的pod之后，此时查看pod返回如下：

> NAME                        		READY   	STATUS    RESTARTS   	AGE
> mytomcat-6f5f895f4f-js4d2    1/1     	Running   0          		2m39s

这时候如果我们删除这个pod，可以发现随后k8s会立即拉起一个新的pod

> NAME                        		READY   	STATUS            	  RESTARTS     AGE
> mytomcat-6f5f895f4f-wzl6k   0/1    	 ContainerCreating     0          		14s

这种情况下如果想要删掉这个pod，需要使用删除deployment。

- 多副本部署

在创建deployment的命令后面添加 `--replicas=xxx` 可以控制创建多个副本，这些副本会分散在集群的多个节点上。查看pod会发现此时存在多个后缀不相同的名为，my-app的pod。

```
[root@k8s-01 ~]# kubectl get pods -owide
NAME                        READY   STATUS    RESTARTS   AGE   IP                NODE     NOMINATED NODE   READINESS GATES
my-app-58cbb9b58d-gg5v2     1/1     Running   0          49s   193.168.165.198   k8s-03   <none>           <none>
my-app-58cbb9b58d-jngt4     1/1     Running   0          49s   193.168.165.199   k8s-03   <none>           <none>
my-app-58cbb9b58d-mq65q     1/1     Running   0          49s   193.168.179.6     k8s-02   <none>           <none>
```

### scale

使用kubectl scale 可以实现应用的扩/缩容，如上面我们创建了一个三个副本的deploy，现在我们需要将这个deploy修改为5个副本，命令如下：

```
kubectl scale --replicas=5 deploy/my-app
```

执行以上命令后，再次查看pod可以发现新拉起了两个myapp的pod。同样的方式，可以调整replicas的值实现缩容。

### 集群自愈

k8s自身具备自愈能力，以上面my-app为例，该deployment存在三个pod，而此时如果其中一个pod意外结束了，那么k8s会尝试重新拉起这个pod，如果拉起成功，pod对应的restarts次数会加1.

### 故障转移

在上面的案例中，mq65q的pod位于k8s-02节点上，而此时如果k8s-02节点意外失联，如网络故障等，那么k8s会在剩余的存活节点上再重新创建一个新的pod，保证集群中对应的pod个数为我们前面部署的时候设置replicas的个数。

## 服务网络

### service

k8s将一组pod抽象为一个service并分配一个服务地址，通过这个服务地址可以访问到这一组pod。

### 暴露一组服务

通过下面的命令可以将my-app这个部署作为一组服务暴露出去：

```
kubectl expose deploy my-app --port=8000 --target-port=80
```

> --port: 这一组服务要对外暴露的端口
>
> --target-port: 8000端口对应的pod内部的端口，即将pod内部的80端口通过服务网络的8080端口对外暴露出去
>
> 这个暴露出去的IP只对集群内有效

### 查看集群中的服务

通过以下命令可以查看集群中的service：

```
# 可以使用 -n 参数指定名称空间
kubectl get service -A
```

```
[root@k8s-01 ~]# kubectl get service -A
NAMESPACE              NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
default                kubernetes                  ClusterIP   10.96.0.1       <none>        443/TCP                  26m
default                my-app                      ClusterIP   10.96.229.119   <none>        8000/TCP                 15m
kube-system            kube-dns                    ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   26m
kubernetes-dashboard   dashboard-metrics-scraper   ClusterIP   10.96.20.202    <none>        8000/TCP                 23m
kubernetes-dashboard   kubernetes-dashboard        NodePort    10.96.96.103    <none>        443:32129/TCP            23m

```

### 域名访问服务

#### pod内部访问

在pod内部，可以通过 `{serviceName}.{namespace}.svc:{port}`来访问一组服务。如上面的my-app服务，可以通过 `my-app.default.svc:8000`访问对应服务。但是这种方式只在pod内部有效。

#### 公网访问

如果需要将一组服务暴露在公网上，需要在前面暴露服务的命令后面添加 ` --type=NodePort`。如：

```
kubectl expose deploy my-app --port=8000 --target-port=80 --type=NodePort
```

再次查看集群service可以发现，my-app服务存在一个对8000端口的映射

```
[root@k8s-01 ~]# kubectl get service
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP          46m
my-app       NodePort    10.96.14.198   <none>        8000:30678/TCP   8s

```

此时，可以通过集群任意节点IP:{映射的端口}来访问这一组pod服务。

## Ingress

ingress 相当于整个k8s集群的入口，可以理解为一个nginx服务器。所有对于集群的访问请求都会进入到ingress中，然后再由ingress解析请求地址后将请求分配到对应的service网络中。[Ingress配置文档](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/)

### 安装Ingress

- 下载配置文件

```
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml
```

这里如果无法访问链接，可以使用这个[./config/deploy.yaml](./config/deploy.yaml "ingress 配置文件")

- 修改镜像

```
vim deploy.yaml

#将image的值改为如下值：
registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/ingress-nginx-controller:v0.46.0
```

- 安装

```
kubectl apply -f deploy.yaml
```

- 检查安装结果

```
kubectl get pod,svc -n ingress-nginx
```

此时，再查看集群service，可以发现新建了两个以 `ingress-nginx-controller`开头的service，type分别为 `NodePort`和 `ClusterIP` 。并且NodePort服务暴露了80和443端口。

```
[root@k8s-01 ~]# kubectl get service -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.96.89.36   <none>        80:30519/TCP,443:32217/TCP   11m
ingress-nginx-controller-admission   ClusterIP   10.96.51.87   <none>        443/TCP                      11m

```

此时在浏览器访问http://{NodeIP}:{port}，会打开一个nginx的404页面。

### 测试环境搭建

- 搭建测试服务

在k8s集群环境执行  [./config/ingress-test.yaml](./config/ingress-test.yaml "ingress测试环境配置文件") 文件，搭建ingress测试环境。执行完成后会创建 `hello-server`

和 `nginx-demo` 两个service。

```
[root@k8s-01 ~]# kubectl get svc
NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-server   ClusterIP   10.96.59.205   <none>        8000/TCP         8s
kubernetes     ClusterIP   10.96.0.1      <none>        443/TCP          3h21m
my-app         NodePort    10.96.14.198   <none>        8000:30678/TCP   154m
nginx-demo     ClusterIP   10.96.27.177   <none>        8000/TCP         8s

```

- 配置域名访问规则

```
apiVersion: networking.k8s.io/v1
kind: Ingress  
metadata:
  name: ingress-host-bar
spec:
  ingressClassName: nginx
  rules:
  - host: "hello.atguigu.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: hello-server
            port:
              number: 8000
  - host: "demo.atguigu.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: nginx-demo  ## java，比如使用路径重写，去掉前缀nginx
            port:
              number: 8000
```

将上面的内容保存到yaml文件中，并在k8s集群中应用该配置文件。

执行完成后，查看ingress规则，可以看到新增一条数据：

```
[root@k8s-01 ~]# kubectl get ingress
NAME               CLASS   HOSTS                                ADDRESS   PORTS   AGE
ingress-host-bar   nginx   hello.atguigu.com,demo.atguigu.com             80      10s

```

- 配置本地域名映射

修改本机hosts文件，添加 集群任意节点IP 到 hello.atguigu.com,demo.atguigu.com 的映射。

- 查看ingress服务端口

```
[root@k8s-01 ~]# kubectl get service -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.96.89.36   <none>        80:30519/TCP,443:32217/TCP   51m
ingress-nginx-controller-admission   ClusterIP   10.96.51.87   <none>        443/TCP                      51m

```

- 测试

在浏览器访问 `http://hello.atguigu.com:30519/`，返回hello-world，访问 `http://demo.atguigu.com:30519/`返回nginx的欢迎页面。

- 修改ingress规则路径测试

修改inress配置规则，将上面的 host为demo 的规则下的 `path: "/"` 修改为 `path: "/nginx"` 再次访问

```
[root@k8s-01 ~]# kubectl get ingress
NAME               CLASS   HOSTS                                ADDRESS         PORTS   AGE
ingress-host-bar   nginx   hello.atguigu.com,demo.atguigu.com   172.22.74.136   80      32m

```

```
kubectl edit ingress ingress-host-bar

# 进入编辑模式后修改上面的内容，保存后退出
```

此时，再访问 `http://demo.atguigu.com:30519/`会返回404页面，但是这里的页面上显示的nginx后面没有版本号，因为这个页面是ingess返回的，当我们的访问地址没有加任何后缀时，ingress无法将该路径与任何规则匹配，因此返回404。

再次访问 `http://demo.atguigu.com:30519/nginx` 此时依然返回nginx的404页面，但是这个页面下的nginx有版本号，这个页面为pod内部的nginx返回的。此时在ingress层能匹配到/nginx的请求，因此该请求会转发到 `demo.atguigu.com` 服务上，但是在该服务的pod中没有配置任何以 `/nginx` 开头的访问路径，因此服务内部pod返回404.

**即这里的规则会把路径中配置的规则往下送到后面的pod中。**

### 路径重写

使用下面的配置文件覆盖前面上传的ingress-rule.yaml，应用后生效。

```
apiVersion: networking.k8s.io/v1
kind: Ingress  
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: ingress-host-bar
spec:
  ingressClassName: nginx
  rules:
  - host: "hello.atguigu.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: hello-server
            port:
              number: 8000
  - host: "demo.atguigu.com"
    http:
      paths:
      - pathType: Prefix
        path: "/nginx(/|$)(.*)"  # 把请求会转给下面的服务，下面的服务一定要能处理这个路径，不能处理就是404
        backend:
          service:
            name: nginx-demo  ## java，比如使用路径重写，去掉前缀nginx
            port:
              number: 8000
```

此时，再次访问前面的 `http://demo.atguigu.com:30519/nginx` 页面再次跳转到nginx的欢迎页。

### 流量限制

复制下面的内容，在主节点新建一个ingress-rule-flow.yaml并粘贴保存。应用文件使规则生效。

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-limit-rate
  annotations:
    nginx.ingress.kubernetes.io/limit-rps: "1"
spec:
  ingressClassName: nginx
  rules:
  - host: "flow.atguigu.com"
    http:
      paths:
      - pathType: Exact
        path: "/"
        backend:
          service:
            name: nginx-demo
            port:
              number: 8000
```

此时，如果请求流量过大，会触发限流机制返回503页面。

## 存储抽象

### 搭建NFS环境

- 所有节点执行

```
#所有机器安装
yum install -y nfs-utils
```

- 主节点执行

```
#nfs主节点
echo "/nfs/data/ *(insecure,rw,sync,no_root_squash)" > /etc/exports

mkdir -p /nfs/data
systemctl enable rpcbind --now
systemctl enable nfs-server --now
#配置生效
exportfs -r
```

- 从节点执行（IP改为主节点IP）

```
showmount -e 172.31.0.4

#执行以下命令挂载 nfs 服务器上的共享目录到本机路径 /root/nfsmount
mkdir -p /nfs/data

mount -t nfs 172.31.0.4:/nfs/data /nfs/data
# 写入一个测试文件
echo "hello nfs server" > /nfs/data/test.txt
```



### 原生方式挂载

将以下内容保存到deploy-nginx-fv.yaml中：

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-pv-demo
  name: nginx-pv-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-pv-demo
  template:
    metadata:
      labels:
        app: nginx-pv-demo
    spec:
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
        - name: html
          nfs:
            server: 172.22.74.137
            path: /nfs/data/nginx-pv
```

这里会启动一个nginx镜像，将pod内部 `/usr/share/nginx/html` 挂载到nfs服务器上 `/nfs/data/nginx-pv` 上。这里需要确保 `/nfs/data/nginx-pv` 目录存在。

使用 `kubectl apply -f deploy-nginx-fv.yaml` 启动pod，等待两个pod状态为running。再往 `/nfs/data/nginx-pv` 目录中新建任意一个文件，此时进入任意一个创建的pod中，进入 `/usr/share/nginx/html`目录下，会发现目录下同步了前面新建的文件。


### PVC挂载

#### 创建pv

将以下内容保存在deploy-pv.yaml中

```
apiVersion: v1
# 指定类型
kind: PersistentVolume
metadata:
  # 名称
  name: pv01-10m
spec:
  # 容量为10M
  capacity:
    storage: 10M
  # 访问模式为多节点读写 
  accessModes:
    - ReadWriteMany
  # 存储名称为nfs
  storageClassName: nfs
  # nfs配置信息
  nfs:
    path: /nfs/data/01
    server: 172.22.74.137

# 分隔多个文件
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv02-1gi
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  storageClassName: nfs
  nfs:
    path: /nfs/data/02
    server: 172.22.74.137

# 分隔多个文件
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv03-3gi
spec:
  capacity:
    storage: 3Gi
  accessModes:
    - ReadWriteMany
  storageClassName: nfs
  nfs:
    path: /nfs/data/03
    server: 172.22.74.137
```

执行 kubectl apply -f deploy-pv.yaml 创建3个pv卷。执行完成之后使用 `kubectl get pv` 查看创建的三个pv。

#### 创建pvc

执行以下yaml配置，创建一个pvc。前面我们创建的一个10M，一个1G，一个3G，因此这个pvc跟跟1g的绑定最合适。

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
  storageClassName: nfs
```

此时，执行 `kubectl get pvc` 可以看到新建了一个pvc卷，并且和前面创建的pv02-1gi绑定。通过 `kubectl get pv` 可以看到，pv02-1gi的状态变为Bound，且绑定的为前面创建的nginx-pvc.

```
[root@k8s-01 ~]# kubectl get pvc
NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
nginx-pvc   Bound    pv02-1gi   1Gi        RWX            nfs            11s


[root@k8s-01 ~]# kubectl get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM               STORAGECLASS   REASON   AGE
pv01-10m   10M        RWX            Retain           Available                       nfs                     5m37s
pv02-1gi   1Gi        RWX            Retain           Bound       default/nginx-pvc   nfs                     5m37s
pv03-3gi   3Gi        RWX            Retain           Available                       nfs                     5m37s

```

#### 绑定pvc

执行以下yaml绑定前面创建的pvc。

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deploy-pvc
  name: nginx-deploy-pvc
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-deploy-pvc
  template:
    metadata:
      labels:
        app: nginx-deploy-pvc
    spec:
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
      volumes:
        - name: html
          persistentVolumeClaim:
            claimName: nginx-pvc
```



## 常用命令

### 扩/缩容

#### 对pod扩容

- 操作命令

```
kubectl scale --replicas=5 deploy/my-app
```

### 操作deployment

#### 部署pod

- 操作命令

```
kubectl create deployment mytomcat --image=tomcat:8.5.68
```

#### 删除deployment

```
kubectl delete deployment mytomcat 
```

#### 多副本部署

- 操作命令

```
kubectl create deployment my-app --image=nginx --replicas=3
```

> 部署一个my-app的pod，启动三个副本，三个副本会分散在集群的机器上

#### 滚动更新

k8s支持对pod镜像的滚动更新。即当一个镜像要发布新版本时，如果同时有多个pod部署了这个镜像，k8s支持在一个新的pod中部署这个镜像，部署成功之后选择一个旧版本的pod下线并将流量转发到新的pod中，以此类推逐渐完成整个集群版本的更新。

这里以前面部署的my-app为例，这里我们将nginx镜像版本调整到nginx:1.16.1，使用如下命令：

```
kubectl set image deploy/my-app nginx=nginx:1.16.1 --record
```

> 执行结果：

```
[root@k8s-01 ~]# kubectl get pod -w
NAME                      READY   STATUS    RESTARTS   AGE
my-app-6cdff855db-c7z4n   1/1     Running   0          87s
my-app-6cdff855db-qrtz7   1/1     Running   0          44s
my-app-6cdff855db-tndwt   1/1     Running   0          65s
my-app-5ff664f457-2rc58   0/1     Pending   0          0s
my-app-5ff664f457-2rc58   0/1     Pending   0          0s
my-app-5ff664f457-2rc58   0/1     ContainerCreating   0          0s
my-app-5ff664f457-2rc58   0/1     ContainerCreating   0          2s
my-app-5ff664f457-2rc58   1/1     Running             0          35s
my-app-6cdff855db-qrtz7   1/1     Terminating         0          81s

```

通过上面的日志打印可以看出，当我们执行完命令之后，k8s重新拉起一个后缀为 `2rc58` 的pod，当这个pod成功运行起来之后就开始停止后缀为 `qrtz7` 的pod。这里以一个pod为例，剩余的pod会以同样的方式依次完成。

#### 版本回退

当一个版本上线后，如果需要回退到旧版本，k8s提供 `rollout` 命令实现版本回退。

- 查看历史版本

```
kubectl rollout history deploy/my-app
```

```
[root@k8s-01 ~]# kubectl rollout history deploy/my-app
deployment.apps/my-app
REVISION  CHANGE-CAUSE
1         <none>
3         kubectl set image deployment/my-app nginx=nginx:1.25.3 --record=true
4         kubectl set image deployment/my-app nginx=nginx:1.25 --record=true
5         kubectl set image deployment/my-app nginx=nginx:1.16.1 --record=true
```

> 通过返回信息可以看到，对于my-app 一共存在4个版本。

- 查看某个历史版本详情

```
kubectl rollout history deploy/my-app --revision=3
```

```
[root@k8s-01 ~]# kubectl rollout history deploy/my-app --revision=3
deployment.apps/my-app with revision #3
Pod Template:
  Labels:       app=my-app
        pod-template-hash=5f9f547645
  Annotations:  kubernetes.io/change-cause: kubectl set image deployment/my-app nginx=nginx:1.25.3 --record=true
  Containers:
   nginx:
    Image:      nginx:1.25.3
    Port:       <none>
    Host Port:  <none>
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>

```

- 回退到指定版本

```
kubectl rollout undo deploy/my-app --to-revision=3
```

> 这里会回退到版本号为3的版本

如果不添加 `--to-revision` 参数，则会回退到上一个版本。

### 命名空间

#### 创建命名空间

- 通过命令创建

```
kubectl create ns hello
```

- 通过配置文件创建

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello
```

#### 删除命名空间

- 通过命令删除

```
kubectl delete ns hello
```

- 通过删除配置文件

如果是由配置文件创建的名称空间，只需要删除对应的配置文件即可删除通过该配置文件创建的全部资源。

### 节点管理

#### 查看集群中所有节点

- 操作命令

```
kebuctl get nodes
```

### 操作pod

#### 进入pod内部

- 操作命令

```
kubectl exec -it mynginx -- /bin/bash
```

#### 查看所有pod

- 操作命令

```
kubectl get pods -A
```

- 以更详细的方式显示

```
 kubectl get pod -owide

# NAME       READY   STATUS    RESTARTS   AGE   IP              NODE     NOMINATED NODE   READINESS GATES
# my-nginx   1/1     Running   0          58m   193.168.179.4   k8s-02   <none>           <none>
```

这里可以看到，my-nginx的IP为 `193.168.179.4`，这里的IP就是前面设置的**pod地址范围**，即在执行**`kubeadm init`**时设置的 **`--pod-network-cidr`** 参数。

#### 创建pod

- 操作命令

```
kubectl run mynginx --image=nginx
```

> 使用nginx镜像创建一个pod，名称为mynginx

- 通过配置文件创建

```yaml
# 版本信息
apiVersion: v1
# 资源类型
kind: Pod
metadata:
  labels:
    run: mynginx
  name: mynginx
#  namespace: default
spec:
  containers:
  - image: nginx
    name: mynginx
```

#### 查看pod描述信息

- 操作命令

```
 kubectl describe pod mynginx
```

#### 删除pod

- 操作命令

```
kubectl delete pod mynginx -n default 
```

### 日志管理

#### 查看pod运行日志

```

kubectl log -f mynginx -n default
```

> 查看名称空间为default下的名为mynginx的pod的日志，-f: 滚动打印
