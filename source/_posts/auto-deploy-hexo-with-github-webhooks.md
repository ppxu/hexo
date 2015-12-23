title: 使用Github的Webhooks实现hexo的自动部署
date: 2015-12-21 17:29:24
categories: blog
tags: [github, webhooks, hexo, deploy, shell]
---
博客之前的更新方式是先在本地写好文章，push到Github，然后ssh连到服务器上，pull下来，如果每次都要这样操作一遍实在麻烦，今天就试着用Github的Webhooks功能实现了hexo博客的自动部署，过程记录如下。

<!--more-->

整个过程有两个环节：

### 本地代码自动部署到Github

hexo本身就有deploy功能，只要在`_config.yml`里面做一下[配置](https://hexo.io/zh-cn/docs/deployment.html)，就可以部署到Github、Heroku等平台上，如果博客是托管在Github Pages上的话使用这种方式可以很方便的实现自动部署，不过通过这种方式发送到Github上的只有`public`目录，我这里希望托管整个应用的代码，就不能使用这种方式了，反正只要可以push就行了，我们搬出shell大法好。

创建文件`deploy.sh`

{% codeblock %}
#!/bin/bash

echo -e "\033[32m [AUTO DEPLOY] deploy hexo start \033[0m"
echo -e "\033[32m [AUTO DEPLOY] hexo generate...  \033[0m"
hexo g
echo -e "\033[32m [AUTO DEPLOY] git commit...  \033[0m"
d=`date +%x-%T`
git add .
git commit -m "auto deploy at "${d}
echo -e "\033[32m [AUTO DEPLOY] git push...  \033[0m"
git push origin master
echo -e "\033[32m [AUTO DEPLOY] deploy hexo finish \033[0m"
{% endcodeblock %}

然后增加权限

{% codeblock %}
# chmod +x ./deploy.sh
{% endcodeblock %}

这样完成本地开发后，只要执行命令

{% codeblock %}
# ./deploy.sh
{% endcodeblock %}

就可以让hexo生成静态文件并push到Github上。

### Github自动同步到服务器

为了让服务器可以自动同步Github上面的更新，我们需要用到Github的Webhooks。

首先创建文件`sync.sh`

{% codeblock %}
#!/bin/bash

echo -e "\033[32m [AUTO SYNC] sync hexo start \033[0m"
cd /ppxu/blog
echo -e "\033[32m [AUTO SYNC] git pull...  \033[0m"
git pull origin master
echo -e "\033[32m [AUTO SYNC] sync hexo finish \033[0m"
{% endcodeblock %}

目标是每当Github有push的时候就自动调用这个脚本。

然后找到Github仓库的Settings页

![http://7xpbfd.com1.z0.glb.clouddn.com/hook.png](http://7xpbfd.com1.z0.glb.clouddn.com/hook.png)

添加一条Webhook，填写请求地址`http://xx.xx.xx.xx:7777/webhook`，这样每当Github收到push或者其他事件时就会自动向这个地址发送一条POST请求。

下面在服务器上补充这个请求地址，我们用node搭一个简单的http服务，这里用到了[github-webhook-handler](https://github.com/rvagg/github-webhook-handler)处理hook消息，创建文件`server.js`

{% codeblock %}
var http = require('http')
var exec = require('child_process').exec;
var createHandler = require('github-webhook-handler')
var handler = createHandler({ path: '/webhook', secret: '********' });

http.createServer(function (req, res) {
  handler(req, res, function (err) {
    res.statusCode = 404;
    res.end('no such location');
  });
}).listen(7777);

handler.on('error', function (err) {
  console.error('Error:', err.message);
});

handler.on('push', function (event) {
  console.log('Received a push event for %s to %s',
    event.payload.repository.name,
    event.payload.ref);
  exec('/ppxu/blog/sync.sh', function(err, stdout, stderr){
    if(err) {
      console.log('sync server err: ' + stderr);
    } else {
      console.log(stdout);
    }
  });
});
{% endcodeblock %}

这里的`secret`要和在Github上新建hook时设置的一样，请求时校验用的。

然后启动服务

{% codeblock %}
# node server.js &
{% endcodeblock %}

这里也可以用forever之类的工具防止进程挂掉。

这样一套自动部署系统就建立好了，在本机和服务器的实际效果如下：

![http://7xpbfd.com1.z0.glb.clouddn.com/deploy.png](http://7xpbfd.com1.z0.glb.clouddn.com/deploy.png)

![http://7xpbfd.com1.z0.glb.clouddn.com/sync.png](http://7xpbfd.com1.z0.glb.clouddn.com/sync.png)

感觉生活一下子美好起来了呢：）

#### 参考资料

* [https://hexo.io/zh-cn/docs/deployment.html](https://hexo.io/zh-cn/docs/deployment.html)

* [https://developer.github.com/webhooks/](https://developer.github.com/webhooks/)

* [http://www.lovelucy.info/auto-deploy-website-by-webhooks-of-github-and-gitlab.html](http://www.lovelucy.info/auto-deploy-website-by-webhooks-of-github-and-gitlab.html)
