# k8s常用命令

## 命名空间

### 创建命名空间

```
kubectl create ns hello
```

### 删除命名空间

```
kubectl delete ns hello
```

## 节点管理

### 查看集群中所有节点

```
kebuctl get nodes
```

## 操作pod

### 查看所有pod

```
kubectl get pods -A
```

### 创建pod

```
kubectl run mynginx --image=nginx
```

> 使用nginx镜像创建一个pod，名称为mynginx



### 查看pod描述信息

```
 kubectl describe pod mynginx
```


### 删除pod

```
kubectl delete pod mynginx -n default 
```


## 日志管理

### 查看pod运行日志

```
kubectl log -f mynginx -n default
```
