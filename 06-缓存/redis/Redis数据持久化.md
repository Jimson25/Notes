

# 数据持久化

redis数据持久化策略有 `AOF` 和 `RDB` 两种方案，其中 `AOF`为增量日志，`RDB`为全量内存快照。一般会使用两种方式一起实现redis数据持久化。

## AOF

AOF (Append Only File) 是redis提供的一种增量形式的数据持久化形式，相对于RDB而言，操作更为轻量。在redis配置文件 `redis.conf` 中，默认开启了AOF，其配置为 `appendonly no`。同时，可以通过修改 `appendfilename` 来修改AOF文件保存的位置。

在不同的操作系统中，对于写数据的操作可能会有不同的处理方式。有些操作系统会立即将数据写入到磁盘上，而有些系统会先将数据写入到缓冲区，并在适当的时机将其写入到磁盘上。对于后一种实现，如果数据写入到缓冲区之后出现系统掉电关机，会导致缓冲区的数据丢失。对于以上情况，redis通过调用 `fsync()` 函数通知操作系统将数据写入到磁盘，保证数据安全。

在redis配置文件中，提供了三种fsync函数的调用策略：

- appendfsync no： 不执行fsync，由操作系统决定什么时候写入数据到磁盘。这种情况下速度最快，但是可能会存在数据丢失的风险。
- appendfsync always：在每次写入AOF日志后都执行fsync。这种情况速度最慢，但是可以保证数据安全。但是这种情况下会存在一些问题，加入系统正在执行大量的磁盘IO操作，这种情况下redis调用fsync可能会被长时间阻塞。
- appendfsync everysec：每秒执行一次fsync，这是一种折中的方案。这也是redis提供的默认的方案。

## AOF自动重写功能

AOF文件记录的是redis数据库所有的更新和写入操作，在经过一段时间之后，可能在文件中的数据已经过期或者被删除了，此时这种数据记录在AOF文件中是没有意义的。而随着运行时间的推移，这种这种数据的操作记录是不可避免地会被写入到AOF文件中，导致AOF文件中记录了大量的无效的数据操作，对性能会产生影响。针对以上情况，redis提供了AOF文件重写功能用于优化和压缩AOF文件。

在redis中，提供了 `auto-aof-rewrite-percentage`和 `auto-aof-rewrite-min-size`两个参数用于控制AOF文件重写的触发大小。第一个参数是一个百分比的数值，第二个参数是一个文件大小数值。默认配置如下：

```shell
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
```

如上的配置中，当AOF文件的大小到达上次重写时文件大小的100%，且当前AOF文件大小大于64mb时，触发AOF重写。

在AOF重写过程中，假如说有大量新的操作触发AOF写入。这种情况下，在AOF重写期间会有大量的磁盘IO，可能会导致磁盘负载增大而产生延迟增加响应时间。为了解决这个问题，redis提供 `no-appendfsync-on-rewrite` 参数用于控制是否在AOF重写期间将AOF写入请求写入到磁盘中。当设置参数值为no时，AOF重写期间会继续将AOF写入请求写入到磁盘中，这种情况下可以有效地避免数据的丢失。当设置参数值为yes时，在AOF重写期间，新来的AOF请求会被保存在缓冲区，在等待AOF重写完成之后再被写入到磁盘，这种情况下可以有效地提高redis性能，但是可能存在部分数据丢失。

当redis运行过程中由于系统崩溃导致AOF文件被中途截断时，再次启动redis时，redis会根据 `aof-load-truncated` 参数决定如何处理AOF文件。当设置值为yes时，将加载被截断的 AOF 文件，并且 Redis 服务器开始发出日志以通知用户事件。否则，如果选项设置为 no，服务器将退出并显示错误，并拒绝启动。当选项设置为 no 时，用户需要使用 "redis-check-aof" 工具修复 AOF 文件然后重新启动服务器。

## RDB

RDB是直接保存某一时刻的内存快照，即将整个内存数据保存到文件中。与AOF不同的是，RDB记录的是实际的数据，而AOF记录的是操作数据的命令。

在数据恢复时，RDB的速度会高于AOF。RDB只需要将文件读入内存即可，而AOF需要解析文件之后逐行执行。

在redis中，可以通过配置save来设置RDB保存策略，配置方式如下：

```
save 900 1
save 300 10
save 60 10000
```

以上设置的含义为：当在900秒内执行1次数据修改时保存快照、当在300秒内执行10次数据修改时保存快照、当在60秒内执行10000次数据修改时保存快照。