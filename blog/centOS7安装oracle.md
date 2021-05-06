### centos7安装oracle

- [原文链接](https://blog.csdn.net/weixin_35867471/article/details/90051222)

#### 一、安装依赖包

- 输入如下命令安装所需依赖

  ```shell
  yum -y install binutils compat-libstdc++-33 compat-libstdc++-33.i686 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc.i686 glibc-common glibc-devel glibc-devel.i686 glibc-headers ksh libaio libaio.i686 libaio-devel libaio-devel.i686 libgcc libgcc.i686 libstdc++ libstdc++.i686 libstdc++-devel make sysstat  ld-linux.so.2  unixODBC unixODBC-devel
  ```

  ```shell
  yum install libXp.i686
  ```

#### 二、添加用户和组

- 创建用户和组

  ```shell
  groupadd oinstall
  
  groupadd dba
  
  groupadd oper
  
  useradd -g oinstall -G dba,oper oracle
  ```

- 修改用户密码

  ```shell
  passwd oracle
  # 输入密码
  ```

#### 三、创建安装目录

- 创建安装目录

  ```shell
  # 这里的目录名称中12.1.0根据实际oracle版本修改
  mkdir -p /orcl/app/oracle/product/12.1.0/db_1
  ```

- 修改目录所有者

  ```shell
  chown -R oracle:oinstall /orcl/app
  ```

- 更改目录权限

  ```shell
  chmod -R 775 /orcl/app
  ```

#### 四、修改内核参数

- 输入命令`vim /etc/sysctl.conf`编辑该文件，输入：

  ```shell
  fs.aio-max-nr = 1048576
  fs.file-max = 6815744
  # 下面这个属性可取最大值是根据服务器实际内存大小计算出来的
  # 公式为 n*1024*1024*1024-1 其中n为服务器内存大小
  # 一般建议实际值应多于物理内存的一半
  kernel.shmall = 2097152
  # 该参数控制可以使用的共享内存的总页数。 Linux 共享内存页大小为 4KB, 共享内存段的大小都是共享内存页大小的整数倍。
  # 一个共享内存段的最大大小是 16G ，那么需要共享内存页数是 16GB/4KB==4194304
  kernel.shmmax = 2147483648
  kernel.shmmni = 4096
  kernel.sem = 250 32000 100 128
  net.ipv4.ip_local_port_range = 9000 65500
  net.core.rmem_default = 262144
  net.core.rmem_max = 4194304
  net.core.wmem_default = 262144
  net.core.wmem_max = 1048576
  ```

- 输入`sysctl -p`使配置文件生效

#### 五、修改用户设置

- 修改文件限制

  输入`vim /etc/security/limits.conf `  添加如下内容

  ```shell
  oracle soft nproc 2047
  oracle hard nproc 16384
  oracle soft nofile 1024
  oracle hard nofile 65536
  oracle soft stack 10240
  ```

- 修改验证选项

  输入 `vim /etc/pam.d/login `  添加

  ```shell
  session required /lib64/security/pam_limits.so
  session required pam_limits.so
  ```

- 修改全局环境变量文件

  输入 `vim /etc/profile` 添加

  ```shell
  if [ $USER = "oracle" ]; then
  if [ $SHELL = "/bin/ksh" ]; then
  ulimit -p 16384
  ulimit -n 65536a
  else
  ulimit -u 16384 -n 65536
  fi
  fi
  ```

  输入`source /etc/profile`使其生效

- 修改用户配置文件

  输入 `vim /home/oracle/.bash_profile` 输入

  ```shell
  export ORACLE_BASE=/orcl/app/oracle 
  # 这里的12.1.0根据实际的oracle版本修改
  export ORACLE_HOME=/orcl/app/oracle/product/12.1.0/db_1
  export ORACLE_SID=orcl
  export ORACLE_TERM=xterm
  export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
  export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
  export LANG=C
  export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
  ```

   输入`source /home/oracle/.bash_profile`是配置文件生效

#### 六、安装JDK

- 输入如下命令卸载系统自带的openjdk

  ```shell
  yum remove *openjdk*
  ```

- 将java安装文件上传到`/usr/local/src`

- 创建java安装目录

  ```shell
  mkdir /usr/local/java
  ```

- 进入`src`目录解压java

  ```shell
  tar -xvf jdk-8u271-linux-x64.tar.gz -C ../java
  ```

- 输入`vim /etc/profile`配置环境变量

  ```shell
  export JAVA_HOME=/usr/local/java/jdk1.8.0_271
  export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
  export PATH=$JAVA_HOME/bin:$PATH
  ```

- 使用`source /etc/profile`使配置生效，输入`java -version`测试是否成功

#### 七、安装图形界面

- 安装图形界面

  ```shell
  yum groupinstall -y "X Window System"
  yum install -y xterm
  ```

#### 八、上传oracle文件

- 使用xftp或其他工具上传文件到`/orcl/app/oracle`

- 将上传的两个源文件解压到当前目录

  ```shell
  unzip linux.x64_11gR2_database_1of2.zip
  unzip linux.x64_11gR2_database_2of2.zip 
  ```

#### 九、安装xmanager

- 安装xmanager[教程](https://www.xshellcn.com/xmg_column/xm-az.html)
- 使用xmanager中的xstart连接服务器
  - 打开 `xmanager` 选择`文件` —> `新建` —> `Xstart会话`
  - 主机输入linux服务器地址，用户名输入oracle，密码输入oracle密码
  - 在`执行命令`后面的输入框输入`/usr/bin/xterm -ls -display $DISPLAY`

#### 十、安装oracle

- 在`xmanager`的会话列表中双击创建的`xstart`会话，出现如下信息及命令行窗口表示连接成功

  ```
  ......
  [15:01:58] Start timer (TIMER_SHUTDOWN, 180).
  [15:01:58] X11 渠道 (id=1)已打开。
  [15:01:58] Stop timer (TIMER_SHUTDOWN).
  ```

- 输入`cd /orcl/app/oracle/database`进入目录，运行`./runInstaller`出现oracle图形界面，安装步骤参考[原文链接](https://blog.csdn.net/weixin_35867471/article/details/90051222)

#### 十一、安装信息

- 在安装过程中要注意安装路径问题，如果出现路径编码错误就重新选择路径即可
- 在Prerequisite Check这一步中可能会提示缺少依赖，对于缺少的包实际测试之后发现直接忽略即可

#### 十二、启动数据库

- 使用oracle用户登录，输入命令`lsnrctl status`查看数据库是否正常启动。

- 若果不能识别上面的命令，检查`/home/oracle/.bash_profile`文件中的`ORALCE_HOME` 是否正确。修改后使用`source /home/oracle/.bash_profile`刷新文件信息。

- 显示`Listener using listener name LISTENER has already been started1`说明数据库状态正常，输入`sqlplus`登录，用户名`sys as sysdba`，密码回车，出现如下信息说明连接成功，至此数据库安装成功！

  ```
  [root@localhost oracle]# sqlplus
  
  SQL*Plus: Release 11.2.0.1.0 Production on Mon Apr 26 02:57:55 2021
  
  Copyright (c) 1982, 2009, Oracle.  All rights reserved.
  
  Enter user-name: su^H
  Enter password: 
  ERROR:
  ORA-01005: null password given; logon denied
  
  
  Enter user-name: sys as sysdba
  Enter password: 
  
  Connected to:
  Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production
  With the Partitioning, OLAP, Data Mining and Real Application Testing options
  
  SQL> 
  
  ```

  

