title: 在阿里云服务器上安装ShadowSocks服务
date: 2016-03-29 14:55:04
categories: blog
tags: [aliyun, ecs, centos, shadowsocks]
---
记录一下如何在服务器上安装科学上网工具ShadowSocks，因为没有国外的主机，只好拿阿里云试试手。

<!--more-->

### 安装shadowsocks

``` bash
$ yum install epel-release
$ yum update
$ yum install python-setuptools
$ easy_install pip
$ pip install shadowsocks
```

### 配置shadowsocks

``` bash
$ vi /etc/shadowsocks.json
```

输入以下内容

``` json
{
  "server": "0.0.0.0",
  "server_port": 端口号,
  "local_address": "127.0.0.1",
  "local_port": 1080,
  "password":" 你的密码",
  "timeout": 500,
  "method":" aes-256-cfb",
  "fast_open": true
}
```

### 启动服务

``` bash
$ yum install python-setuptools supervisor
$ easy_install pip
$ pip install shadowsocks
```

加入自动启动

``` bash
$ vi /etc/supervisord.conf
```

在最后输入

```
[program:shadowsocks]
command=ssserver -c /etc/shadowsocks.json
autostart=true
autorestart=true
user=root
```

刷新

``` bash
$ sudo chkconfig --add supervisord
$ sudo chkconfig supervisord on
$ service supervisord start
$ supervisorctl reload
```

最后，重启一下服务器即可，更多的优化手段可以参考下面链接。

#### 参考

* [http://www.linexy.net/archives/digitalocean-build-shadowsocks-services-and-optimization-program/](http://www.linexy.net/archives/digitalocean-build-shadowsocks-services-and-optimization-program/)
