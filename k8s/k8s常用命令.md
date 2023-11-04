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
