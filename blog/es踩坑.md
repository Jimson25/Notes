一、新版ES不能使用 `root`用户启动,报错信息如下:
```
org.elasticsearch.bootstrap.StartupException: java.lang.RuntimeException: can not run elasticsearch as root
    at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:140) ~[elasticsearch-6.3.1.jar:6.3.1]
    at org.elasticsearch.bootstrap.Elasticsearch.execute(Elasticsearch.java:127) ~[elasticsearch-6.3.1.jar:6.3.1]
    at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86) ~[elasticsearch-6.3.1.jar:6.3.1]
    at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:124) ~[elasticsearch-cli-6.3.1.jar:6.3.1]
    at org.elasticsearch.cli.Command.main(Command.java:90) ~[elasticsearch-cli-6.3.1.jar:6.3.1]
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:93) ~[elasticsearch-6.3.1.jar:6.3.1]
    at org.elasticsearch.bootstrap.Elasticsearch.main(Elasticsearch.java:86) ~[elasticsearch-6.3.1.jar:6.3.1]
Caused by: java.lang.RuntimeException: can not run elasticsearch as root
    at org.elasticsearch.bootstrap.Bootstrap.initializeNatives(Bootstrap.java:104) ~[elasticsearch-6.3.1.jar:6.3.1]
    at org.elasticsearch.bootstrap.Bootstrap.setup(Bootstrap.java:171) ~[elasticsearch-6.3.1.jar:6.3.1]
    at org.elasticsearch.bootstrap.Bootstrap.init(Bootstrap.java:326) ~[elasticsearch-6.3.1.jar:6.3.1]
    at org.elasticsearch.bootstrap.Elasticsearch.init(Elasticsearch.java:136) ~[elasticsearch-6.3.1.jar:6.3.1]
    ... 6 more
```     
解决方案: 新建一个用户登录  
```
[root@desktop-aemsrqg bin]# adduser es
[root@desktop-aemsrqg bin]# passwd es
更改用户 es 的密码 。
新的 密码：
无效的密码： 密码少于 8 个字符
重新输入新的 密码：
passwd：所有的身份验证令牌已经成功更新。
[root@desktop-aemsrqg bin]# su es
``` 

二、运行elasticsearch,报错显示部分目录无访问权限
```
Exception in thread "main" java.nio.file.AccessDeniedException: /opt/elasticsearch-6.3.1/config/jvm.options
	at sun.nio.fs.UnixException.translateToIOException(UnixException.java:84)
	at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:102)
	at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:107)
	at sun.nio.fs.UnixFileSystemProvider.newByteChannel(UnixFileSystemProvider.java:214)
	at java.nio.file.Files.newByteChannel(Files.java:361)
	at java.nio.file.Files.newByteChannel(Files.java:407)
	at java.nio.file.spi.FileSystemProvider.newInputStream(FileSystemProvider.java:384)
	at java.nio.file.Files.newInputStream(Files.java:152)
	at org.elasticsearch.tools.launchers.JvmOptionsParser.main(JvmOptionsParser.java:58)
```

解决方案: 提升权限 
     
- 简单粗暴使用 `chmod 777 *` 提示权限不足,不允许的操作;
- 使用 `sudo` 临时提权报错, `es 不在 sudoers 文件中。此事将被报告。`
- 切换到`root`用户,给予`sudoers`文件写权限 `chmod -v u+w /etc/sudoers`
- 编辑 `sudoers`文件在其中添加es用户权限
```
 # Allow root to run any commands anywher
      root   ALL=(ALL)    ALL
      es    ALL=(ALL)    ALL 
```
- 取消 `sudoers`文件写权限
- 切换到`es`用户,再次运行搞定;


三、使用 `es`用户运行elasticsearch报错显示java找不到
```
[es@192 bin]$ sudo ./elasticsearch
[sudo] es 的密码：
which: no java in (/sbin:/bin:/usr/sbin:/usr/bin)
could not find java; set JAVA_HOME or ensure java is in PATH
```
报错原因: /etc/sudoers里面的secure_path里面的命令是sudo可以使用的命令，环境变量默认不会加载进去。

解决方案: 用root账户递归修改elasticsearch-5.5.0目录的权限为elasticsearch:elasticsearch
```
[root@192 opt]# chown es:es -R elasticsearch-6.3.1
[root@192 opt]# su es
[es@192 opt]$ cd elasticsearch-6.3.1/
[es@192 elasticsearch-6.3.1]$ cd bin/
[es@192 bin]$ ./elasticsearch
```

四、接上，启动后报错三个 `is too low`
```
ERROR: [2] bootstrap checks failed
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```
解决方案: 
```
-- 待定 --
* hard nofile 65535
* soft nofile 131072
* hard nproc 4096
* soft nproc 2048
```



