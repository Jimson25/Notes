# TiDB笔记

## 整体架构

在内核设计上，TiDB 分布式数据库将整体架构拆分成了多个模块，各模块之间互相通信，组成完整的 TiDB 系统。![img](..\doc\image\TiDB\整体架构.png)

- **TiDB Server：** SQL 层，对外暴露 MySQL 协议的连接 endpoint，负责接受客户端的连接，执行 SQL 解析和优化，最终生成分布式执行计划。TiDB 层本身是无状态的，实践中可以启动多个 TiDB 实例，通过负载均衡组件（如 LVS、HAProxy 或 F5）对外提供统一的接入地址，客户端的连接可以均匀地分摊在多个 TiDB 实例上以达到负载均衡的效果。**TiDB Server 本身并不存储数据，只是解析 SQL**，将实际的数据读取请求转发给底层的存储节点 TiKV（或 TiFlash）。
- **PD (Placement Driver) Server：** 整个 TiDB 集群的元信息管理模块，负责存储每个 TiKV 节点实时的数据分布情况和集群的整体拓扑结构，提供 TiDB Dashboard 管控界面，并为分布式事务分配事务 ID。PD 不仅存储元信息，同时还会根据 TiKV 节点实时上报的数据分布状态，下发数据调度命令给具体的 TiKV 节点，可以说是整个集群的“大脑”。此外，PD 本身也是由至少 3 个节点构成，拥有高可用的能力。建议部署奇数个 PD 节点。
- **存储节点：**
  - **TiKV Server：** 负责存储数据，从外部看 TiKV 是一个分布式的提供事务的 Key-Value 存储引擎。存储数据的基本单位是 Region，每个 Region 负责存储一个 Key Range（从 StartKey 到 EndKey 的左闭右开区间）的数据，每个 TiKV 节点会负责多个 Region。TiKV 的 API 在 KV 键值对层面提供对分布式事务的原生支持，默认提供了 SI (Snapshot Isolation) 的隔离级别，这也是 TiDB 在 SQL 层面支持分布式事务的核心。TiDB 的 SQL 层做完 SQL 解析后，会将 SQL 的执行计划转换为对 TiKV API 的实际调用。所以，数据都存储在 TiKV 中。另外，TiKV 中的数据都会自动维护多副本（默认为三副本），天然支持高可用和自动故障转移。
  - **TiFlash：** TiFlash 是一类特殊的存储节点。和普通 TiKV 节点不一样的是，在 TiFlash 内部，数据是以列式的形式进行存储，主要的功能是为分析型的场景加速。

## TiDB 工具

### TiUP

TiUP是TiDB的包管理工具，管理着 TiDB 生态下众多的组件，如 TiDB、PD、TiKV 等。[文档链接](https://docs.pingcap.com/zh/tidb/stable/tiup-overview)

#### 安装TiUP

- 安装

```shell
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
```

该命令将 TiUP 安装在 `$HOME/.tiup` 文件夹下，之后安装的组件以及组件运行产生的数据也会放在该文件夹下。同时，它还会自动将 `$HOME/.tiup/bin` 加入到 Shell Profile 文件的 PATH 环境变量中。

- 刷新配置文件

```shell
source ~/.profile
```

- 检查版本

```shell
tiup --version
```

#### TiUP使用

- 查看帮助信息

```shell
tiup --help
```

- 可用的命令
  - install：用于安装组件
  - list：查看可用组件列表
  - uninstall：卸载组件
  - update：更新组件版本
  - status：查看组件运行记录
  - clean：清除组件运行记录
  - mirror：从官方镜像克隆一个私有镜像
- 可用的组件
  - playground：在本机启动集群
  - client：连接本机的集群
  - cluster：部署用于生产环境的集群
  - bench：对数据库进行压力测试

命令和组件的区别在于，命令是 TiUP 自带的，用于进行包管理的操作。而组件是 TiUP 通过包管理操作安装的独立组件包。比如执行 tiup list 命令，TiUP 会直接运行自己内部的代码，而执行 tiup playground 命令则会先检查本地有没有叫做 playground 的组件包，若没有则先从镜像上下载过来，然后运行这个组件包。

##### 查询组件列表

使用 `tiup list [component] [flags]` 命令来查询组件列表

- 查询组件列表

```
root@DESKTOP-L7OB3EL:~# tiup list
Available components:
Name            Owner      Description
----            -----      -----------
PCC             community  A tool used to capture plan changes among different versions of TiDB
bench           pingcap    Benchmark database with different workloads
br              pingcap    TiDB/TiKV cluster backup restore tool
cdc             pingcap    CDC is a change data capture tool for TiDB
chaosd          community  An easy-to-use Chaos Engineering tool used to inject failures to a physical node
client          pingcap    Client to connect playground
cloud           pingcap    CLI tool to manage TiDB Cloud
cluster         pingcap    Deploy a TiDB cluster for production
ctl             pingcap    TiDB controller suite
dm              pingcap    Data Migration Platform manager
dmctl           pingcap    dmctl component of Data Migration Platform
errdoc          pingcap    Document about TiDB errors
pd-recover      pingcap    PD Recover is a disaster recovery tool of PD, used to recover the PD cluster which cannot start or provide services normally
playground      pingcap    Bootstrap a local TiDB cluster for fun
tidb            pingcap    TiDB is an open source distributed HTAP database compatible with the MySQL protocol
tidb-dashboard  pingcap    TiDB Dashboard is a Web UI for monitoring, diagnosing, and managing the TiDB cluster
tidb-lightning  pingcap    TiDB Lightning is a tool used for fast full import of large amounts of data into a TiDB cluster
tikv-br         pingcap    TiKV cluster backup restore tool
tikv-cdc        pingcap    TiKV-CDC is a change data capture tool for TiKV
tiproxy         pingcap    TiProxy is a database proxy that is based on TiDB.
tiup            pingcap    TiUP is a command-line component management tool that can help to download and install TiDB platform components to the local system
```

- 查询组件版本列表

```shell
root@DESKTOP-L7OB3EL:~# tiup list client
Available versions for client:
Version                        Installed  Release                    Platforms
-------                        ---------  -------                    ---------
nightly -> v1.12.2-nightly-18             2023-08-09T10:43:12Z       darwin/amd64,darwin/arm64,linux/amd64,linux/arm64
v0.0.1                                    2020-04-13T23:23:54+08:00  darwin/amd64,linux/amd64
v0.0.3                                    2020-03-03T19:39:35+08:00  darwin/amd64,linux/amd64
v0.0.4                                    2020-03-03T19:39:35+08:00  darwin/amd64,linux/amd64
v0.0.5                                    2020-03-03T19:39:35+08:00  darwin/amd64,linux/amd64
v0.0.6                                    2020-04-13T23:23:35+08:00  darwin/amd64,linux/amd64
v1.2.5                                    2020-11-27T18:11:55+08:00  darwin/amd64,linux/amd64,linux/arm64
v1.3.0                                    2020-12-18T19:07:37+08:00  darwin/amd64,linux/amd64,linux/arm64
v1.3.1                                    2020-12-31T17:41:50+08:00  darwin/amd64,linux/amd64,linux/arm64
v1.3.2                                    2021-03-02T15:00:02+08:00  darwin/amd64,linux/amd64,linux/arm64
······
```

- 使用 `--installed`查询已安装的组件
- 使用 `--all`查询全部组件（含隐藏组件）
- 使用 `--verbose`显式所有列（安装的版本、支持的平台）
- 查询组件版本：

##### 安装组件

使用 `tiup install <component>:[version] ` 命令来安装组件。当使用该命令安装组件时，如果没有指定版本，则默认下载镜像仓库中的最新版本。

- 安装最新版本的TiDB

```
tiup install tidb
```

- 安装 `v7.1.1 `版本的TiDB

```
tiup install tidb:v7.1.1
```

##### 升级组件

使用 `tiup update [component1][:version] [component2..N] [flags]`命令升级组件。

- 升级 `client`至 `1.12.5`版本

```
tiup update client:v1.12.5
```

- `--all`：升级所有组件

* `--nightly`：升级至 nightly 版本
* `--self`：升级 TiUP 自己至最新版本
* `--force`：强制升级至最新版本

##### 运行组件

使用 `tiup [flags] <component>[:version] [args...] `运行组件。若不提供版本，则使用该组件已安装的最新稳定版。

- 运行client组件

```shell
tiup client:v1.12.5
```

在组件启动之前，TiUP 会先为它创建一个目录，然后将组件放到该目录中运行。组件会将所有数据生成在该目录中，目录的名字就是该组件运行时指定的 tag 名称。如果不指定 tag，则会随机生成一个 tag 名称，并且在实例终止时*自动删除*工作目录。

如果想要多次启动同一个组件并复用之前的工作目录，就可以在启动时用 `--tag` 指定相同的名字。指定 tag 后，在实例终止时就*不会自动删除*工作目录，方便下次启动时复用。

##### 查看组件状态

使用 `tiup status` 命令来查看组件的运行状态。

##### 清理组件

可以使用 `tiup clean <name> [flags]` 命令来清理组件实例，并删除工作目录。如果在清理之前实例还在运行，会先 kill 相关进程。

- 清理client实例信息

```shell
tiup clean client
```

##### 卸载组件

使用 `tiup uninstall [component][:version] [flags]`卸载组件。

支持的参数：

* `--all`：卸载所有的组件或版本
* `--self`：卸载 TiUP 自身

使用案例：

- 卸载client:v1.12.4

```shell
root@DESKTOP-L7OB3EL:~# tiup list client --installed
Available versions for client:
Version  Installed  Release               Platforms
-------  ---------  -------               ---------
v1.12.4  YES        2023-07-13T14:36:54Z  darwin/amd64,darwin/arm64,linux/amd64,linux/arm64
v1.12.5  YES        2023-07-17T11:25:52Z  darwin/amd64,darwin/arm64,linux/amd64,linux/arm64
root@DESKTOP-L7OB3EL:~# tiup uninstall client:v1.12.4
/root/.tiup/components/client/v1.12.4
Uninstalled component `client:v1.12.4` successfully!
root@DESKTOP-L7OB3EL:~# tiup list client --installed
Available versions for client:
Version  Installed  Release               Platforms
-------  ---------  -------               ---------
v1.12.5  YES        2023-07-17T11:25:52Z  darwin/amd64,darwin/arm64,linux/amd64,linux/arm64
```

## 本地部署

### 安装TiUP

```shell
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
```

### 声明全局环境变量

```
# source ${your_shell_profile}
source ~/.profile
```

### 启动本地数据库

```shell
tiup playground v7.1.1 --db 2 --pd 3 --kv 3 --monitor
```

执行以上命令之后会在本地启动一个v7.1.1版本的TiDB数据库集群，其中包含两个TiDB Server节点、三个PD Server节点、三个TiKV Server节点。

## 应用开发

### SQL性能优化

#### 使用单个语句多行数据操作

当需要修改多行数据时，推荐使用单个 SQL 多行数据的语句，不推荐使用多个 SQL 单行数据的语句。

```sql
INSERT INTO t VALUES (1, 'a'), (2, 'b'), (3, 'c');

DELETE FROM t WHERE id IN (1, 2, 3);
```

原因：

- **较少网络开销：** 每次与数据库建立连接、执行 SQL 语句、返回结果都需要网络传输。通过使用单个 SQL 语句修改多行数据，可以减少网络传输开销。
- **减少数据库操作开销：** 执行单个 SQL 语句通常比逐个执行多个 SQL 语句更高效。数据库管理系统可以对单个语句进行优化和批量处理，从而降低了数据库操作的开销。
- **减少锁定和事务管理开销：** 在数据库中，锁定和事务管理是开销较大的操作。逐个执行多个 SQL 语句会增加锁定和事务的开销，而使用单个 SQL 语句可以更好地管理锁定和事务。
- **提升数据库引擎优化能力：** 数据库引擎在优化 SQL 语句时会考虑多个因素，包括查询计划、索引等。通过合并多个操作为一个 SQL 语句，数据库引擎有更大的机会优化整个操作。

#### 使用TRUNCATE删除全表数据

当需要删除一个表中的全部数据时，推荐使用 `TRUNCATE`

```
TRUNCATE TABLE t;
```

原因：

- **执行速度：**TRUNCATE只会在数据库事务日志中保存删除表操作，而DELETE会逐行保存每一行的删除信息。
- **事务处理：**TRUNCATE是DDL语句，在执行完成后会自动提交事务，无法回滚。DELETE是DML语句，在语句执行完成后可以根据需要执行回滚。
- **释放空间：**TRUNCATE会释放表所占用的存储空间，将表重置为其初始状态，包括重置自增长序列等。DELETE只删除数据，不释放存储空间。
- **触发器和约束：**TRUNCATE命令在执行时不会触发表上的触发器和约束。DELETE命令会触发表上的触发器和约束。
