title: Nginx配置SPDY
date: 2015-12-22 17:32:20
categories: blog
tags: [aliyun, ecs, centos, nginx, spdy]
---
本来准备给服务器搞个HTTP/2上去，发现Nginx要到1.9.5才可以支持HTTP/2协议，现在服务器上的Nginx版本才1.8.0，想了想先试试SPDY吧，改天再来升级Nginx和HTTP/2。

<!--more-->

首先查看一下本地的Nginx是不是已经包含了SPDY

``` bash
$ nginx -V |grep spdy
```

如果看到有`–-with-http_spdy_module`，就说明已经支持了SPDY，如果没有的话需要重新下载和编译Nginx，在编译的时候加上`--with-http_spdy_module`选项。

然后修改Nginx的配置文件

```
server {
    listen       80;
    listen       443 ssl spdy;
    server_name  ppxu.me *.ppxu.me;

    add_header   Alternate-Protocol  443:npn-spdy/3.1;
    ...
```

重启Nginx，SPDY就配置完成了。

访问一下网站，然后在chrome中打开`chrome://net-internals/#http2`，就可以看到站点已经支持了SPDY3.1

![/img/spdy.png](/img/spdy.png)

还可以在这个[网站](https://spdycheck.org/)检查SPDY情况。

不过毕竟SPDY协议已经废弃了，还是赶紧搞上HTTP/2才是正事。

#### 参考资料

* [http://nginx.org/](http://nginx.org/)

* [http://www.stefanwille.com/2013/04/using-spdy-with-nginx-1-4/](http://www.stefanwille.com/2013/04/using-spdy-with-nginx-1-4/)

* [http://www.linuxidc.com/Linux/2015-09/123251.htm](http://www.linuxidc.com/Linux/2015-09/123251.htm)

* [http://www.linuxidc.com/Linux/2015-02/112979.htm](http://www.linuxidc.com/Linux/2015-02/112979.htm)

* [http://www.jb51.net/article/59017.htm](http://www.jb51.net/article/59017.htm)

* [http://www.tuicool.com/articles/2mi63q](http://www.tuicool.com/articles/2mi63q)
