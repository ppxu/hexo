title: 让Hexo支持emoji表情
date: 2015-12-24 21:23:43
categories: blog
tags: [hexo, markdown, emoji]
---
Hexo的文章内容默认是不支持emoji表情的，为了让文章更生动，今天就研究了下怎么支持emoji。

<!--more-->

Hexo默认的markdown编译插件是[hexo-renderer-marked](https://github.com/hexojs/hexo-renderer-marked)，看了一下相关文档，好像没办法支持emoji，还好在Hexo的[plugins](https://hexo.io/plugins/)页，我们找到了另外一个markdown插件[hexo-renderer-markdown-it](https://github.com/celsomiranda/hexo-renderer-markdown-it)，而且号称速度比默认的还要快，最主要的是，在[markdown-it](https://github.com/markdown-it/markdown-it)的文档里面，我们发现它可以通过plugins的方式支持[emoji](https://github.com/markdown-it/markdown-it-emoji)。

下面我们就来替换markdown插件

{% codeblock %}
# cd /ppxu/blog/
# cnpm un hexo-renderer-marked --save
# cnpm i hexo-renderer-markdown-it --save
{% endcodeblock %}

不过此时的hexo-renderer-markdown-it还是用不了emoji的，我们需要加上emoji的plugin

{% codeblock %}
# cd node_modules/hexo-renderer-markdown-it/
# cnpm install markdown-it-emoji --save
{% endcodeblock %}

然后编辑Hexo的配置文件`_config.yml`

{% codeblock %}
markdown:
  render:
    html: true
    xhtmlOut: false
    breaks: false
    linkify: true
    typographer: true
    quotes: '“”‘’'
  plugins:
    - markdown-it-footnote
    - markdown-it-sup
    - markdown-it-sub
    - markdown-it-abbr
    - markdown-it-emoji
  anchors:
    level: 2
    collisionSuffix: 'v'
    permalink: true
    permalinkClass: header-anchor
    permalinkSymbol: ¶
{% endcodeblock %}

关键就是在plugins里加上`- markdown-it-emoji`，其他的配置说明可以参见[wiki](https://github.com/celsomiranda/hexo-renderer-markdown-it/wiki/Advanced-Configuration)。

重启Hexo服务，即可生效，看这里 :smile: :smirk: :relieved: :stuck_out_tongue_closed_eyes: :sleeping:
