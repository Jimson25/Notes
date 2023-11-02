# 安装K8S

## 一、环境配置

安装k8s集群需要确保集群内各个主机的主机名和mac地址不同

### 调整hostname

```
hostnamectl set-hostname k8s-01
```

这里设置主机名为k8s-01，多台机器可以根据实际情况设置

### 查看MAC地址

```
ifconfig eth0 |egrep "ether" |awk '{print $2}'
```

### 关闭SELinux

```
# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

### 关闭swap

```
swapoff -a  
sed -ri 's/.*swap.*/#&/' /etc/fstab
```

### 允许 iptables 检查桥接流量

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

```

### 放行 **6443** 端口

> 这里如果是虚拟机或者开发测试环境，可以直接禁用防火墙

```
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

```
# 查看防火墙状态
sudo systemctl status firewalld

# 放行端口（tcp+udp）
sudo firewall-cmd --zone=public --add-port=6443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=6443/udp --permanent

# 重新加载防火墙
sudo firewall-cmd --reload

# 检查端口是否放行
sudo firewall-cmd --list-ports | grep 6443



```

### 配置静态IP

> 如果配置IP为DHCP，后面重启后IP发生变化会很麻烦。这里以ens33网卡为例

- 修改网卡配置信息

```
vim /etc/sysconfig/network-scripts/ifcfg-ens33
```

- 调整如下配置

```
DEVICE=ens33         #描述网卡对应的设备别名，例如ifcfg-eth0的文件中它为eth0
BOOTPROTO=static       #设置网卡获得ip地址的方式，可能的选项为static，dhcp或bootp，分别对应静态指定的 ip地址，通过dhcp协议获得的ip地址，通过bootp协议获得的ip地址
BROADCAST=192.168.86.255   #对应的子网广播地址
IPADDR=192.168.86.138      #如果设置网卡获得 ip地址的方式为静态指定，此字段就指定了网卡对应的ip地址
NETMASK=255.255.255.0    #网卡对应的网络掩码
NETWORK=192.168.86.0     #网卡对应的网络地址
```

- 修改网关配置

```
vim /etc/sysconfig/network
```

- 调整如下配置

```
NETWORKING=yes     #(表示系统是否使用网络，一般设置为yes。如果设为no，则不能使用网络，而且很多系统服务程序将无法启动)
HOSTNAME=centos    #(设置本机的主机名，这里设置的主机名要和/etc/hosts中设置的主机名对应)
GATEWAY=192.168.86.1  #(设置本机连接的网关的IP地址。)
```

- 重启网络

```
service network restart
```

## 二、 **安装集群所需组件**

官网链接：[使用 kubeadm 创建集群](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

### 组件说明

- **kubeadm：** 用来初始化集群的指令。
- **kubelet：** 在集群中的每个节点上用来启动 Pod 和容器等。
- **kubectl：** 用来与集群通信的命令行工具。

### 安装步骤

- 设置k8s源

```bash
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
   http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
```

- 安装k8s集群

```
sudo yum install -y kubelet-1.20.9 kubeadm-1.20.9 kubectl-1.20.9 --disableexcludes=kubernetes

```

- 启动 kubelet

```
sudo systemctl enable --now kubelet
```

## 三、引导启动集群

### 提前下载所需文件

```bash
sudo tee ./images.sh <<-'EOF'
#!/bin/bash
images=(
kube-apiserver:v1.20.9
kube-proxy:v1.20.9
kube-controller-manager:v1.20.9
kube-scheduler:v1.20.9
coredns:1.7.0
etcd:3.4.13-0
pause:3.2
)
for imageName in ${images[@]} ; do
docker pull registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images/$imageName
done
EOF
   
chmod +x ./images.sh && ./images.sh
```

### 初始化主节点

- 为所有机器添加master节点域名映射

```
# 以实际主节点IP为准
echo "192.168.86.138  cluster-endpoint" >> /etc/hosts
```

- 主节点初始化(**这里要保证所有节点的网络地址不重叠**)

```
kubeadm init \
--apiserver-advertise-address=192.168.86.138  \
--control-plane-endpoint=cluster-endpoint \
--image-repository registry.cn-hangzhou.aliyuncs.com/lfy_k8s_images \
--kubernetes-version v1.20.9 \
--service-cidr=10.96.0.0/16 \
--pod-network-cidr=193.168.0.0/16
```

> - --apiserver-advertise-address
>
> 设置apiserver的广播地址，如果不设置则使用与默认网关关联的网络接口。
>
> - --control-plane-endpoint
>
> 为所有主节点设置共享节点，后面所有所有对control-plane的访问都会进入到这个节点，通过这个节点再以负载均衡算法分发到下面的子节点。可以把这个节点理解为主节点集群的网关。
>
> - --image-repository
>
> 设置镜像仓库地址。
>
> - --kubernetes-version
>
> 设置k8s版本。这里的版本号跟前面安装的版本号对应。
>
> - --service-cidr
>
> 设置k8s集群内部**服务网络**的IP地址范围。服务网络是 Kubernetes 集群中的一个虚拟网络，用于 Kubernetes 服务的 IP 地址分配。当你创建一个 Kubernetes 服务时，Kubernetes 会从这个 CIDR 范围内分配一个 IP 地址给这个服务。这个 IP 地址会被集群中的其他组件（如 Pods）用来访问这个服务。
>
> - --pod-network-cidr
>
> 在 Kubernetes 中，`kubeadm init` 命令的 `--pod-network-cidr` 参数用于指定 **Pod 网络**的 IP 地址范围。区别于上面 `--service-cidr` 的区别，这两个参数一个是用于指定服务网络的IP范围，一个用于指定pod网络的IP范围。
>
> - pod网络和服务网络
>
> **pod网络：** 这是 Kubernetes 集群中的一个虚拟网络，用于 Kubernetes Pod 的 IP 地址分配。当你创建一个 Kubernetes Pod 时，Kubernetes 会从 Pod 网络的 IP 地址范围内分配一个 IP 地址给这个 Pod。这个 IP 地址会被集群中的其他组件（如其他 Pods、服务等）用来访问这个 Pod。每个 Pod 都有自己的 IP 地址，Pod 之间可以直接通信。
>
> **服务网络：** 这也是 Kubernetes 集群中的一个虚拟网络，但它用于 Kubernetes 服务的 IP 地址分配。当你创建一个 Kubernetes 服务时，Kubernetes 会从服务网络的 IP 地址范围内分配一个 IP 地址给这个服务。这个 IP 地址会被集群中的其他组件（如 Pods）用来访问这个服务。服务是一种抽象概念，它代表了一组提供相同功能的 Pod，通过服务可以实现负载均衡和服务发现。
>
> 总的来说，假如我有一组用于访问订单系统的服务，这个服务里面部署了多个pod。那么服务网络分配一个服务网络地址用于访问这一组服务，而pod网络则会为这一组服务的每一个pod分配pod地址。
>
> kubeadm init 更多信息参考 [官方文档](https://kubernetes.io/zh-cn/docs/reference/setup-tools/kubeadm/kubeadm-init/ "kubeadm init文档")

## 四、初始化后续集群

- 在完成上面的操作后，当执行成功后会出现下面内容：

> Your Kubernetes control-plane has initialized successfully!
>
> To start using your cluster, you need to run the following as a regular user:
>
> mkdir -p $HOME/.kube
> sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
> sudo chown $(id -u):$(id -g) $HOME/.kube/config
>
> Alternatively, if you are the root user, you can run:
>
> export KUBECONFIG=/etc/kubernetes/admin.conf
>
> You should now deploy a pod network to the cluster.
> Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
> https://kubernetes.io/docs/concepts/cluster-administration/addons/
>
> You can now join any number of control-plane nodes by copying certificate authorities
> and service account keys on each node and then running the following as root:
>
> kubeadm join cluster-endpoint:6443 --token 3qtkfg.23rdu2horxrhhr2b
> --discovery-token-ca-cert-hash sha256:f1e2c003e9a81ff7d4b973fc26ad29d8955df8624099177c738f8edf6f386706
> --control-plane
>
> Then you can join any number of worker nodes by running the following on each as root:
>
> kubeadm join cluster-endpoint:6443 --token 3qtkfg.23rdu2horxrhhr2b
> --discovery-token-ca-cert-hash sha256:f1e2c003e9a81ff7d4b973fc26ad29d8955df8624099177c738f8edf6f386706

通过上面的信息可以看到，我们需要部署后续节点还需要执行后续部分操作；

### 配置kubectl连接信息

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 安装网络插件

可以从 [这里](https://kubernetes.io/docs/concepts/cluster-administration/addons/) 找到所需的网络插件。

- 安装calico网络插件

```
curl https://docs.projectcalico.org/v3.20/manifests/calico.yaml -O
```

> 如果前面改了--pod-network-cidr 参数，这里需要调整下载下来的calico.yaml中的配置项。搜索 `- name: CALICO_IPV4POOL_CIDR` ，修改下面的value为设置的地址，并将注释打开

- 应用插件

```
kubectl apply -f calico.yaml
```

### 添加主节点

```
kubeadm join cluster-endpoint:6443 --token 3qtkfg.23rdu2horxrhhr2b \
    --discovery-token-ca-cert-hash sha256:f1e2c003e9a81ff7d4b973fc26ad29d8955df8624099177c738f8edf6f386706 \
    --control-plane
```

### 添加工作节点

```
kubeadm join cluster-endpoint:6443 --token 3qtkfg.23rdu2horxrhhr2b \
    --discovery-token-ca-cert-hash sha256:f1e2c003e9a81ff7d4b973fc26ad29d8955df8624099177c738f8edf6f386706
```

执行完成后在主节点执行 `kubectl get nodes` 查看节点状态


### 执行报错解决

出现 `FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1`

> sysctl -w net.ipv4.ip_forward=1
>
> 这种方式下在重启后不会被保留，如果要永久写入，需要执行以下操作：
>
> 编辑 /etc/sysctl.conf， 添加 `net.ipv4.ip_forward = 1`


### 创建令牌

上面加入集群的命令所用到的令牌的有效期是24h，如果令牌过期，需要重新生成新的令牌。

- 生成集群令牌

```
kubeadm token create --print-join-command
```

## 部署可视化界面

### 安装可视化界面pod

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
```

- 这里如果下载失败，可以将上面的连接在浏览器打开，复制里面的内容保存在文件中，命名为 ` kubectl apply -f recommended.yaml` ，再执行 `kubectl apply -f recommended.yaml` 安装

执行完成后输入 `kubectl get pods -A` 可以看到存在两个namespace为kubernetes-dashboard的pod。

### 配置可视化界面

**这里一定要保证集群中所有节点能够正常连通，如果是生产环境需要确认网络策略正常，如果是测试环境可以禁用防火墙**

- 设置访问端口

```
kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard
```

修改 `type: ClusterIP`为 `type: NodePort`

- 放行端口[port]

执行：

```
kubectl get svc -A |grep kubernetes-dashboard
```

在防火墙将返回的端口放行。参考前面教程。

- 访问可视界面

在浏览器访问 `https://{任意节点ip}:{port}` ,如果是在虚拟机部署的集群环境，可能存在无法访问的情况，此时只需再浏览器界面任意位置敲 `thisisunsafe`即可，不需要在地址栏。

### 创建用户

- 编辑配置文件保存为dash-user.yaml

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

- 根据配置文件添加用户

```
kubectl apply -f dash-user.yaml
```

- 获取访问token

```
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
```

将生成的token输入到页面输入框即可登录。
