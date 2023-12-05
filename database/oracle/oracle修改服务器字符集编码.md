# oracle修改服务器端字符集编码

在测试环境搭建oracle数据库时，由于操作疏忽导致字符编码设置错误，在表中写入中文字符时显示为 `？` ，这里提供修改字符集为支持中文的 `AL32UTF16` 编码的方法。在执行操作前建议对数据库中重要数据进行备份。

- 以管理员身份登录到Oracle数据库：

```
sqlplus / as sysdba
```

- 关闭数据库：

```
shutdown immediate;
```

- 启动到mount状态：

```
startup mount;
```

- 启用限制会话：

```
alter system enable restricted session;
```

- 设置作业队列进程为0：

```
alter system set job_queue_processes=0;
```

- 打开数据库：

```
alter database open;
```

- 修改数据库字符集：

```
alter database character set internal_use AL32UTF16;
```

- 关闭数据库：

```
shutdown immediate;
```

- 启动数据库：

```
startup
```
