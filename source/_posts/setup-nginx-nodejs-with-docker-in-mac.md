title: 在Mac上使用Docker配置nginx和node.js
date: 2016-09-06 19:52:07
categories: blog
tags: [mac, docker, centos, nginx, nodejs]
---
简单记录一下如何在 Mac 上使用 Docker，并配置 nginx 和 node.js 开发环境的操作步骤。

<!--more-->

Mac 上推荐使用官方的安装包来安装 [Docker](https://www.docker.com/)，这是 [下载地址](https://download.docker.com/mac/stable/Docker.dmg)，安装好后运行软件，在菜单栏上就可以看到一只萌萌的鲸鱼了。

我的目标是基于一个 Linux 镜像，安装 nginx 和 node.js，运行一个简单的 node.js 服务器。

[Docker Hub](https://hub.docker.com/explore/) 上有很多官方和非官方的镜像，我选的是官方的 [centos](https://hub.docker.com/_/centos/)。

下面所有操作都是在命令行中执行。

``` bash
  // 下载最新 centos 镜像
  $ docker pull centos:latest

  // 运行这个镜像，参数说明详见 [reference/commandline](https://docs.docker.com/engine/reference/commandline/)
  $ docker run -it --name web -p 8888:80 centos:latest
```

然后命令行就会切换到容器系统的命令行中，下面就是安装 nginx 和 node.js 了。

``` bash
  # 不更新了，更新会增加几百M镜像体积
  # // 更新包
  # $ yum -y update

  // 安装 nginx
  $ yum -y install wget
  $ wget http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
  $ rpm -ivh nginx-release-centos-7-0.el7.ngx.noarch.rpm
  $ yum -y install nginx

  // 修改一下 nginx 配置，转发 node.js 端口
  $ vi /etc/nginx/conf.d/default.conf
```

```
  server {
    listen       80;
    server_name  localhost;

    location / {
      proxy_pass        http://127.0.0.1:3000/;
      proxy_redirect    off;
      proxy_set_header  X-Real-IP        $remote_addr;
      proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;
    }

    ...
```

``` bash
  // 启动 nginx
  $ nginx
```

下面是手动编译安装 node.js

``` bash
  // 安装依赖
  $ yum -y install gcc-c++

  // 下载最新 node.js
  $ wget https://nodejs.org/dist/v6.5.0/node-v6.5.0.tar.gz

  // 解压&安装
  $ tar zxf node-v6.5.0.tar.gz
  $ cd node-v6.5.0
  $ ./configure
  $ make && make install
```

node.js 安装好后写一个简单的 server.js

```
  const http = require('http')

  const server = http.createServer((req, res) => {
    res.end('Hello Docker!')
  })

  server.listen(3000)
```

``` bash
  // 启动 server
  $ node server.js
```

这样子整个流程就跑通了，在浏览器里面访问 `http://localhost:8888`，就可以看到

![/img/docker.png](/img/docker.png)

接下来我们还可以把这个修改过的容器保存下来

``` bash
  // 退出容器系统
  $ exit

  // 查看容器信息
  $ docker ps -a

  // 将容器转化成镜像，ppxu 是 Docker Hub 上的用户名，cnn 是镜像名，v1 是一个 tag
  $ docker commit -m 'add nginx & node to centos' -a 'ppxu' web ppxu/cnn:v1

  // 查看所有的镜像
  $ docker images

  // 运行刚刚保存的镜像
  $ docker run -it -p 8888:80 ppxu/cnn:v1
```

在这个容器中可以看到刚刚安装的 nginx 和 node.js 都正常运行。

最后我们可以把这个镜像上传到 Docker Hub 中，首先 [注册帐号](https://hub.docker.com/)

``` bash
  // 用刚注册的帐号登录
  $ docker login

  // 上传镜像
  $ docker push ppxu/cnn:v1
```

然后就可以在 [Docker Hub](https://hub.docker.com/) 上看到刚才上传的镜像了，其他人就可以直接使用这个镜像了。

#### 参考资料

* [https://docs.docker.com/engine/getstarted/](https://docs.docker.com/engine/getstarted/)
* [http://blog.saymagic.cn/2015/06/01/learning-docker.html#bqlkp](http://blog.saymagic.cn/2015/06/01/learning-docker.html#bqlkp)
