# github配置代理提交代码

在本地使用代理访问github时，页面可以正常打开，但是拉取、提交代码时经常会出现超时。这种情况是因为git 命令在执行时没有走代理节点，需要为git单独配置git代理。

参考链接：

[设置代理解决github被墙](https://zhuanlan.zhihu.com/p/481574024)

[新增 SSH 密钥到 GitHub 帐户](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

[生成新的 SSH 密钥并将其添加到 ssh-agent](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

## 针对http方式代理

使用SOCKS5代理和HTTP代理访问GitHub提交拉取代码，主要有以下几点区别：

- 工作层次：SOCKS5代理工作在传输层，支持TCP和UDP协议，传输速度较快。而HTTP代理工作在应用层，主要支持HTTP协议。
- 通用性：SOCKS5代理更通用和灵活，不仅可以处理HTTP流量，还能处理其他类型的流量，比如FTP和邮件传输等。而HTTP代理更专注于处理HTTP请求，并具有一些特定的功能和优化，适用于代理HTTP流量的场景。
- 安全性：SOCKS5代理提供身份验证和加密功能，提升数据传输的安全性。而HTTP代理必须对HTTP请求进行解析，所以更容易被检测到。
- 适用场景：如果你需要代理多种网络流量，包括HTTP以外的协议，那么使用SOCKS5代理可能更为适合。如果你只需要代理HTTP流量，那么HTTP代理可能更为适合。

### 配置全局代理(不推荐)

```
#使用http代理 （将代理服务器调整为自己的节点）
git config --global http.proxy http://127.0.0.1:10809
git config --global https.proxy https://127.0.0.1:10809
#使用socks5代理（将代理服务器调整为自己的节点）
git config --global http.proxy socks5://127.0.0.1:10808
git config --global https.proxy socks5://127.0.0.1:10808
```

### 针对github配置代理

```
# 将代理服务器调整为自己的节点
#使用socks5代理（推荐）
git config --global http.https://github.com.proxy socks5://127.0.0.1:10808
#使用http代理（不推荐）
git config --global http.https://github.com.proxy http://127.0.0.1:10809
```

### 取消代理

```
git config --global --unset http.proxy 
git config --global --unset https.proxy
```

## 针对ssh方式代理

### 配置ssh登录

#### 生成ssh密钥对

- 在gitbash中执行：

```
# 将邮箱地址设置为github配置的邮箱地址
ssh-keygen -t ed25519 -C "your_email@example.com"
```

执行成功之后，在 `C:\Users\xxxxx\.ssh\` 目录下会生成 `id_ed25519` 和 `id_ed25519.pub`两个文件， `.pub`为公钥文件。

#### 配置SSH密钥

将 SSH 公钥添加到 GitHub 上的帐户，参考“[新增 SSH 密钥到 GitHub 帐户](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)”。

#### 测试ssh连接

在github上打开任意项目，点击 `code` - `ssh` 复制仓库地址，在本地执行后检查是否正常克隆。

### 配置ssh代理

在 `C:\Users\xxxxx\.ssh\` 目录下创建 `config `文件。编辑文件添加以下内容：

```
# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
# 修改为本机connect路径
ProxyCommand "D:\Develop\Git\mingw64\bin\connect" -S 127.0.0.1:10808 -a none %h %p

# github 代理配置
Host github.com
  User git
  Port 22
  Hostname github.com
  # 修改为前面生成的私钥路径
  IdentityFile "C:\Users\xxxxx\.ssh\github_access\id_ed25519"
  TCPKeepAlive yes

# github 代理配置
Host ssh.github.com
  User git
  Port 443
  Hostname ssh.github.com
  # 修改为前面生成的私钥路径
  IdentityFile "C:\Users\xxxxx\.ssh\github_access\id_ed25519"
  TCPKeepAlive yes
```

- 保存退出后执行以下命令测试是否配置成功：

```
# 测试是否设置成功
ssh -T git@github.com

```

- 返回信息：

```
Hi xxxxx! You've successfully authenticated, but GitHub does not provide shell access.
```

## 调整远程仓库地址

如果前面已经使用http将远程仓库克隆到本地，可以执行以下命令修改为ssh：

```
git remote set-url origin git@xxxxxxxx/xxxxxxx.git
```
