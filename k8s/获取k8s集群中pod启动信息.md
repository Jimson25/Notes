# 获取k8s集群中pod启动信息

- 使用 `kubectl get pod -n {ns_name} {pod_name} -o yaml` 获取pod对应的yaml描述文件。
- 找到其中名为imageID的属性，分析镜像名称及版本。
- 使用 `docker images | grep {imageInfo}`查找docker镜像的ImageID
- 使用 `docker history --no-trunc {imageID}`查看镜像的打包信息。

>  这里如果数据太长导致显示混乱，可以将输出重定向到一个txt文件中，再下载到本地使用vscode查看

- 分析数据中的 `CREATED BY`获取启动相关信息
