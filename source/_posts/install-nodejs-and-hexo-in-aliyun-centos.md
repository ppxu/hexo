title: install-nodejs-and-hexo-in-aliyun-centos
date: 2015-12-19 10:31:27
tags:
---
最近刚撸了个阿里云服务器，搭了个hexo博客，这里记录一下操作步骤。

撸主选的是最便宜的阿里云ECS，应付一下日常小撸足够了，具体配置如下：

{% codeblock %}
CPU：1核
内存：1024MB
操作系统：CentOS 7.0 64位
带宽：1Mbps
{% endcodeblock %}

下面是具体的步骤（mac系统环境）：

* 连接服务器

{% codeblock %}
ssh root@xx.xx.xx.xx
{% endcodeblock %}

* 安装Nodejs环境

  * 更新软件源

  {% codeblock %}
  yum -y update
  {% endcodeblock %}

  * 下载Nodejs

  {% codeblock %}
  cd /usr/local/src
  wget http://nodejs.org/dist/node-latest.tar.gz
  {% endcodeblock %}

  * 解压

  {% codeblock %}
  tar zxf node-latest.tar.gz
  cd node-v*.*.*
  {% endcodeblock %}

  * 编译安装

  {% codeblock %}
  ./configure
  make
  make install
  {% endcodeblock %}

  * 确认安装成功

  {% codeblock %}
  node -v
  npm -v
  {% endcodeblock %}

* 安装hexo

{% codeblock %}
npm install -g hexo-cli
hexo init blog
cd blog
npm install
{% endcodeblock %}

* 启动hexo

{% codeblock %}
hexo server    //普通启动
hexo server &  //静默启动
{% endcodeblock %}

启动成功后就可以通过ip地址`xx.xx.xx.xx:4000`访问到页面了，当然我们并不想输端口号，所以要把4000转到80上，这次先没有用nginx的反向代理，只是用iptables做了一下转发处理。

* 转到80端口

编辑iptables文件

{% codeblock %}
vi /etc/sysconfig/iptables
{% endcodeblock %}

加上下面这段

{% codeblock %}
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 4000 -j ACCEPT

*nat
-A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 4000
COMMIT
{% endcodeblock %}

重启iptables服务

{% codeblock %}
service iptables restart
{% endcodeblock %}

这时候发现报错了

{% codeblock %}
Failed to restart iptables.service: Unit iptables.service failed to load: No such file or directory.
{% endcodeblock %}

查了一下原来是CentOS 7中防火墙改成了firewalld，所以要换回iptables。

{% codeblock %}
systemctl stop firewalld
systemctl mask firewalld
yum install iptables-services
systemctl enable iptables
service iptables start
{% endcodeblock %}

然后就可以通过ip地址`xx.xx.xx.xx`访问网站了。

* 域名解析

再撸个域名，把`@`和`www`都解析到ip地址就可以了。

* git管理

配置一下git环境，以后就可以通过git来管理内容了。

参考资料

* [https://hexo.io/zh-cn/docs/index.html](https://hexo.io/zh-cn/docs/index.html)
* [http://wsgzao.github.io/post/hexo-guide/](http://wsgzao.github.io/post/hexo-guide/)
* [http://www.tuijiankan.com/2015/05/04/阿里云Centos6安装配置Nodejs、Nginx、Hexo操作记录/](http://www.tuijiankan.com/2015/05/04/%E9%98%BF%E9%87%8C%E4%BA%91Centos6%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AENodejs%E3%80%81Nginx%E3%80%81Hexo%E6%93%8D%E4%BD%9C%E8%AE%B0%E5%BD%95/)
* [http://codybonney.com/installing-node-js-0-10-24-on-centos-6-4/](http://codybonney.com/installing-node-js-0-10-24-on-centos-6-4/)
* [http://codybonney.com/redirect-port-80-to-another-port-using-iptables-on-centos/](http://codybonney.com/redirect-port-80-to-another-port-using-iptables-on-centos/)
* [http://www.vkilo.com/rhel-7-iptables-service.html](http://www.vkilo.com/rhel-7-iptables-service.html)
