title: 平滑升级Nginx并配置HTTP/2
date: 2015-12-23 12:47:40
categories: blog
tags: [aliyun, ecs, centos, nginx, http2]
---
之前说到SPDY已经被HTTP/2上位了，继续用SPDY也不合适，今天就趁空升级了最新的Nginx，并开启了HTTP/2，操作过程如下

<!--more-->

1. 检查当前Nginx版本和配置参数

  ``` bash
  $ nginx -V
  nginx version: nginx/1.8.0
  built by gcc 4.8.2 20140120 (Red Hat 4.8.2-16) (GCC)
  built with OpenSSL 1.0.1e-fips 11 Feb 2013
  TLS SNI support enabled
  configure arguments: --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-openssl=../libressl-2.2.2 --with-http_v2_module --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_spdy_module --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'
  ```

  记下这里的configure arguments，后面编译的时候要用的。

2. 安装PCRE，Nginx的rewrite模块依赖PCRE

  ``` bash
  $ cd /ppxu
  $ yum -y install make zlib zlib-devel gcc-c++ libtool
  $ wget http://nchc.dl.sourceforge.net/project/pcre/pcre/8.37/pcre-8.37.tar.gz
  $ tar zxvf pcre-8.37.tar.gz
  $ cd pcre-8.37/
  $ ./configure
  $ make && make install
  ```

3. 下载OpenSSL，可以从[OpenSSL](https://www.openssl.org/)或者[LibreSSL](http://www.libressl.org/)下载

  ``` bash
  $ cd /ppxu
  $ wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.3.1.tar.gz
  $ tar zxvf libressl-2.3.1.tar.gz
  ```

4. 下载，配置并编译Nginx

  ``` bash
  $ cd /ppxu
  $ wget http://nginx.org/download/nginx-1.9.9.tar.gz
  $ tar zxvf nginx-1.9.9.tar.gz
  $ cd nginx-1.9.9/
  $ ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-openssl=../libressl-2.3.1 --with-http_v2_module --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'
  $ make
  ```

  其中的`--with-http_v2_module`就是开启HTTP/2的设置。

5. 替换Nginx

  ``` bash
  $ which nginx    //查找nginx路径
  $ mv /usr/sbin/nginx /usr/sbin/nginx.old    //备份旧版nginx
  $ cp objs/nginx /usr/sbin/    //将编译好的新版nginx复制过去
  ```

6. 确认更新生效

  ``` bash
  $ /usr/sbin/nginx -t
  nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
  nginx: configuration file /etc/nginx/nginx.conf test is successful
  $ /usr/sbin/nginx -v
  nginx version: nginx/1.9.9
  ```

7. 更新Nginx配置文件

  ```
  server {
      listen       80;
      listen       443 ssl http2;
      server_name  ppxu.me *.ppxu.me;

      ...
  ```

8. 重启Nginx即可

访问网站，在响应头里可以看到`server:nginx/1.9.9`，同时，在[chrome://net-internals/#http2](chrome://net-internals/#http2)上面可以看到网站已经支持了HTTP/2

![http://7xpbfd.com1.z0.glb.clouddn.com/http2.png](http://7xpbfd.com1.z0.glb.clouddn.com/http2.png)

#### 参考资料

* [http://www.linuxde.net/2011/08/554.html](http://www.linuxde.net/2011/08/554.html)
* [http://www.linuxidc.com/Linux/2014-02/96137.htm](http://www.linuxidc.com/Linux/2014-02/96137.htm)
* [http://www.poluoluo.com/server/201403/265778.html](http://www.poluoluo.com/server/201403/265778.html)
* [https://imququ.com/post/http2-resource.html](https://imququ.com/post/http2-resource.html)
* [https://imququ.com/post/nginx-http2-patch.html](https://imququ.com/post/nginx-http2-patch.html)
* [http://www.tuicool.com/articles/3eeIVfi](http://www.tuicool.com/articles/3eeIVfi)
