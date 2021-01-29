### Docker配置及使用方法

#### 一、Docker基本概念

docker包含三个基本概念，分别为镜像(Image)、容器(Container)、仓库(Repository) [详细信息](https://www.runoob.com/docker/docker-architecture.html)

- __镜像：__Docker 镜像（Image），就相当于是一个 root 文件系统。比如官方镜像 ubuntu:16.04 就包含了完整的一套 Ubuntu16.04 最小系统的 root 文件系统。

- __容器：__镜像（Image）和容器（Container）的关系，就像是面向对象程序设计中的类和实例一样，镜像是静态的定义，容器是镜像运行时的实体。容器可以被创建、启动、停止、删除、暂停等。

- __仓库：__仓库可看成一个代码控制中心，用来保存镜像。

  

#### 二、Docker安装

- __CentOS自动安装：__ `curl -sSL https://get.daocloud.io/docker | sh`
- __启动Docker：__ `systemctl start docker`

- __验证是否安装成功：__ 运行`sudo docker run hello-world`，打印如下信息说明安装成功

	Unable to find image 'hello-world:latest' locally
	latest: Pulling from library/hello-world
	0e03bdcc26d7: Pull complete 
	Digest: sha256:31b9c7d48790f0d8c50ab433d9c3b7e17666d6993084c002c2ff1ca09b96391d
	Status: Downloaded newer image for hello-world:latest
	
	Hello from Docker!
	This message shows that your installation appears to be working correctly.
	......

#### 三、Docker基本使用

- __拉取镜像：__ 运行拉取Ubuntu镜像`docker pull ubuntu`

  

- __启动镜像：__ 运行 `docker run -it ubuntu /bin/bash` 使用镜像启动一个容器
  - **docker：** Docker 的二进制执行文件。
  
  - **run：**与前面的 docker 组合来运行一个容器。
  
  - __-i：__ 允许用户对容器内的标准输入进行交互（可以敲命令）

  - **-t：** 在新启动的容器内指定一个终端
  
  - **/bin/bash**：放在镜像名后的是命令，这里我们希望有个交互式 Shell，因此用的是 /bin/bash
  
    
  
- **退出容器：** 在容器内运行 `exit`命令或使用 `Ctrl+D`退出一个容器

  

- **查看容器列表：** 运行 `docker ps`查看容器列表 

  - 展示信息如下：

  ```
  [root@localhost src]# docker ps
  CONTAINER ID   IMAGE     COMMAND       CREATED       STATUS             PORTS     NAMES
  6678f17b80c0   ubuntu    "/bin/bash"   2 hours ago   Up About an hour             recursing_clarke
  
  
  **输出信息介绍：
  CONTAINER ID: 容器 ID。
  IMAGE: 使用的镜像。
  COMMAND: 启动容器时运行的命令。
  CREATED: 容器的创建时间。
  STATUS: 容器状态。具体如下：
  	created（已创建）
  	restarting（重启中）
  	running 或 Up（运行中）
  	removing（迁移中）
  	paused（暂停）
  	exited（停止）
  	dead（死亡）
  PORTS: 容器的端口信息和使用的连接类型（tcp\udp）。
  NAMES: 自动分配的容器名称。
  ```

  - 可添加参数如下：

  ```
  -a: 列出全部容器 
  ```

  

- **停止容器：** 运行`docker stop <container id>`结束id对应的容器。如上面看到有一个id为 6678f17b80c0 的容器处于运行中的状态，此时运行 `docker stop 6678f17b80c0`后在执行 `docker ps`查看，发现容器已停止运行；

  

- **启动已停止的容器：** 根据前面查找到的容器id，运行 `docker start <container id>`启动对应容器；如前面我们停止了ubuntu，再次启动该容器指令如下 `docker start 6678f17b80c0` ，再次查看容器列表，输出如下，可以看到此时Ubuntu容器又重新处于运行状态

  ```
  [root@localhost src]# docker ps
  CONTAINER ID   IMAGE     COMMAND       CREATED       STATUS         PORTS     NAMES
  6678f17b80c0   ubuntu    "/bin/bash"   2 hours ago   Up 2 minutes             recursing_clarke
  ```

  

- **后台运行：** 在运行指令中添加`-d`指定容器在后台运行。运行 `docker run -d hello-world` ，输出如下字符串 ,

  ```
  [root@localhost src]# docker run -d hello-world 
  6299e54fce93798bd54e3ea7d97b0a182cd30b75a4b70b6bc401ec2c86c5d1f2
  ```

- **进入容器：** 当使用 `-d`指定容器在后台运行时，再想要进入容器的指令如下： `docker exec -it 6678f17b80c0` 

  ```
  1:> docker attach
  2:> docker exec
  ***** 
  上面两个指令都可以进入后台运行的容器，
  区别为第一个指令进入容器后再退出容器会结束容器运行，第二个指令退出后容器依然在后台运行。推荐使用第二个指令
  
  使用如下：docker exec -it 6678f17b80c0
  ```

- **删除容器：** 查看容器列表后获取容器id， 运行 `docker rm -f <container id>`删除指定容器。同时，可以使用`docker container prune`指令删除所有处于`终止状态`的容器

  

- **导出容器：** 要导出本地某个容器，可以使用指令`docker export 9e7015e407d3 > ubuntu.tar` 将容器id为9e7015e407d3的容器导出到宿主机本地。

  

- **导入容器：** 进入到存放docker快照的目录中，运行`cat ubuntu.tar | docker import - test-ubuntu`将前面导出的快照导入到本地。此时，可以通过查看本地镜像列表找到导入的 `test-ubuntu`镜像。

  

- **运行web应用：** 拉取一个web镜像 `docker pull training/webapp`，运行镜像 `docker run -d -P training/webapp python app.py`，其中 `-P`表示将容器端口映射到宿主机上。此时再查看容器列表，显示如下：

  ```
  [root@localhost src]# docker ps
  CONTAINER ID   IMAGE             COMMAND           CREATED          STATUS          PORTS                     NAMES
  df638ec1276a   training/webapp   "python app.py"   22 seconds ago   Up 20 seconds   0.0.0.0:49153->5000/tcp   flamboyant_mccarthy
  9e7015e407d3   ubuntu            "/bin/bash"       12 minutes ago   Up 12 minutes 
  ```

   这里显示容器中的5000端口被映射到本机的49153端口上，在浏览器请求对应接口，页面打印信息正常。同时，我们可以通过 `-p`手动设置容器端口和宿主机的端口映射关系，指令为 `docker run -d -p 5000:5000 training/webapp python app.py`。此时，再查看容器列表，发现容器中5000端口被映射到宿主机5000端口上。浏览器访问宿主机5000端口，页面显示正常。除了上面的方式外，__*docker还提供了一种快捷方式查看容器和宿主机的端口映射关系，* __指令为`docker port <container id>`

  

- **查看容器日志：** 查看容器打印日志，指令为 `docker logs <container id>/<container name>` 其中，可以添加 `-f` 参数动态打印日志信息。 



- **查看容器内部进程：** 使用 `docker top <container id>/<container name>` 可以查看id对应的容器内部的进程信息

  ```
  [root@localhost src]# docker top 0e1858efceb3
  UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
  root                11085               11064               0                   17:41               ?                   00:00:00            python app.py
  ```

  

