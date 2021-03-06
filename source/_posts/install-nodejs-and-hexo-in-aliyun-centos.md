title: 阿里云ECS搭建Hexo博客
date: 2015-12-19 10:31:27
categories: blog
tags: [aliyun, ecs, centos, nodejs, hexo, blog]
---
最近刚撸了个阿里云ECS服务器来折腾，先搭个Hexo博客耍耍，这里记录一下操作步骤。

<!--more-->

撸主选的是最便宜的阿里云ECS，应付日常小撸妥妥的，具体配置如下：

```
CPU：1核
内存：1024MB
操作系统：CentOS 7.2 64位
带宽：1Mbps
```

下面是具体的步骤：

* 连接服务器

``` bash
$ ssh root@xx.xx.xx.xx
```

* 安装Nodejs环境

  * 更新软件源

  ``` bash
  $ yum -y update
  ```

  * 下载Node.js

  ``` bash
  $ cd /usr/local/src
  $ wget http://nodejs.org/dist/node-latest.tar.gz
  ```

  * 解压

  ``` bash
  $ tar zxf node-latest.tar.gz
  $ cd node-v*.*.*
  ```

  * 编译安装

  ``` bash
  $ ./configure
  $ make && make install
  ```

  * 确认安装成功

  ``` bash
  $ node -v
  $ npm -v
  ```

* 安装Hexo

``` bash
$ npm install -g hexo-cli
$ hexo init blog
$ cd blog
$ npm install
```

* 启动Hexo

``` bash
$ hexo server    //普通启动
$ hexo server &  //静默启动
```

启动成功后就可以通过服务器的ip地址`xx.xx.xx.xx:4000`访问到页面了，然后把4000转到80上，通常做法是用Nginx做反向代理，这里先用iptables防火墙简单做一下转发处理。

* 转到80端口

编辑iptables文件

``` bash
$ vi /etc/sysconfig/iptables
```

加上下面这段

```
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 4000 -j ACCEPT

*nat
-A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 4000
COMMIT
```

重启iptables服务

``` bash
$ service iptables restart
```

这时发现报错了

```
Failed to restart iptables.service: Unit iptables.service failed to load: No such file or directory.
```

查了一下原来是CentOS 7中的防火墙改成了firewalld，这里先换回iptables。

``` bash
$ systemctl stop firewalld
$ systemctl mask firewalld
$ yum install iptables-services
$ systemctl enable iptables
$ service start iptables
```

这样就可以通过ip地址`xx.xx.xx.xx`直接访问网站了。

* 域名解析

再撸个域名`ppxu.me`，把`@`和`www`都解析到服务器ip地址就可以了。

* git管理

再配置一下git环境，以后就可以通过git来管理内容了。

#### 参考资料

* [https://hexo.io/zh-cn/docs/index.html](https://hexo.io/zh-cn/docs/index.html)
* [http://wsgzao.github.io/post/hexo-guide/](http://wsgzao.github.io/post/hexo-guide/)
* [http://zipperary.com/categories/hexo/](http://zipperary.com/categories/hexo/)
* [http://www.jianshu.com/p/73779eacb494](http://www.jianshu.com/p/73779eacb494)
* [http://www.tuijiankan.com/2015/05/04/阿里云Centos6安装配置Nodejs、Nginx、Hexo操作记录/](http://www.tuijiankan.com/2015/05/04/%E9%98%BF%E9%87%8C%E4%BA%91Centos6%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AENodejs%E3%80%81Nginx%E3%80%81Hexo%E6%93%8D%E4%BD%9C%E8%AE%B0%E5%BD%95/)
* [http://codybonney.com/installing-node-js-0-10-24-on-centos-6-4/](http://codybonney.com/installing-node-js-0-10-24-on-centos-6-4/)
* [http://codybonney.com/redirect-port-80-to-another-port-using-iptables-on-centos/](http://codybonney.com/redirect-port-80-to-another-port-using-iptables-on-centos/)
* [http://www.vkilo.com/rhel-7-iptables-service.html](http://www.vkilo.com/rhel-7-iptables-service.html)
