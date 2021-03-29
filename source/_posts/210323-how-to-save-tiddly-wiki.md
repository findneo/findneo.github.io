---
title: 如何保存tiddlywiki
date: 2021-03-23 21:23:17
tags:
---



一直在寻找称心的笔记工具，前段时间接触到tiddly wiki，觉得很是不错。因为并非完美的开箱即用，使用过程中还是遇到一些问题，其中一些找到了好的解决办法，有一些实在解决不掉，无奈最终弃坑。

##### 自动保存

官方提供了很多的保存选项，却实在没有一个真正优雅，要装浏览器插件，装客户端，甚至还有装浏览器的……

nodejs版勉强能用，实时保存效果极好，但有两个缺点：

1. 文件分散
2. 安装插件的页面刷不出来，只能靠改配置文件或者去找别人的拖过来。

```bash
npm install -g tiddlywiki
tiddlywiki --version
// 5.1.23
tiddlywiki mywiki --init server
tiddlywiki mywiki --listen port=1337
```

最终找到一种比较满意的保存方式。

参考 [jimfoltz](https://gist.github.com/jimfoltz)/**[tw5-server.rb](https://gist.github.com/jimfoltz/ee791c1bdd30ce137bc23cce826096da)** 脚本略作修改，监听localhost，去除日志。

1. 将以下文件保存为`/path/to/wikiserv.rb`，配置`root`和`BACKUP_DIR`的值，并把wiki.html放到`root`对应的目录下。
2. 建个软链接 `ln -s /path/to.wikiserv.rb ~/wiki` 
3. 在home目录执行 `ruby wiki&` ，访问`http://localhost:1337/wiki.html` 
4. 保存时会备份一份到`BACKUP_DIR` 目录下。
5. 用坚果云同步`root`对应的目录，Windows下可结合WSL使用。
6. 使用插件 [$:/plugins/telmiger/EditorCounter](https://tid.li/tw5/plugins-2019.html#%24%3A%2Fplugins%2Ftelmiger%2FEditorCounter) ，每输入一定数量的字符就自动保存一次。

`wikiserv.rb` ：

```ruby
require 'webrick'
require 'fileutils'

if ARGV.length == 0
   # root = ARGV.first.gsub('\\', '/')
   root = '/mnt/d/我的坚果云/tiddly'  						#config
else
   root = '.'
end
BACKUP_DIR = '/mnt/d/wiki/bak'							#config

module WEBrick
   module HTTPServlet

      class FileHandler
         alias do_PUT do_GET
      end

      class DefaultFileHandler
         def do_PUT(req, res)
            file = "#{@config[:DocumentRoot]}#{req.path}"
            res.body = ''
            unless Dir.exists? BACKUP_DIR
               Dir.mkdir BACKUP_DIR
            end
            FileUtils.cp(file, "#{BACKUP_DIR}/#{File.basename(file, '.html')}.#{Time.now.to_i.to_s}.html")
            File.open(file, "w+") {|f| f.puts(req.body)}
         end

         def do_OPTIONS(req, res)
            res['allow'] = "GET,HEAD,POST,OPTIONS,CONNECT,PUT,DAV,dav"
            res['x-api-access-type'] = 'file'
            res['dav'] = 'tw5/put'
         end

      end
   end
end

# https://ruby-doc.org/stdlib-2.5.1/libdoc/webrick/rdoc/WEBrick/HTTPServer.html
server = WEBrick::HTTPServer.new({:BindAddress => "localhost", :Port => 1337, :DocumentRoot => root, :Logger=> WEBrick::Log.new("/dev/null"),:AccessLog=> []})


trap "INT" do
   puts "Shutting down..."
   server.shutdown
end

server.start
```

##### 搜索增强

1. [$:/plugins/telmiger/simple-search](https://tid.li/tw5/plugins.html) ，配合vimium chrome插件搜索还是比较方便的。
2. 搜索结果高亮
   - [$:/plugins/bimlas/highlight-searched-text @github](https://github.com/bimlas/tw5-highlight-searched-text)
   - [demo](https://bimlas.gitlab.io/tw5-highlight-searched-text/) 
   - 如果是和`$:/plugins/telmiger/simple-search`一起用需要在设置里面把`$:/temp/search`改为`$:/temp/advancedsearch`。

##### 其他重度用户等

```
http://cpashow.tiddlyspot.com/
https://rizi.me/
https://onetwo.ren/wiki/#:Index
https://github.com/linonetwo/Tiddlywiki-NodeJS-Github-Template
https://onetwo.ren/用tiddlywiki替代notion和evernote管理知识/
https://onetwo.ren/wiki/#:其他在积极使用TiddlyWiki的朋友的wiki
https://wiki.hintsnet.com/
https://swarma-km.hintsnet.com/
https://wiki.yfd.im/
https://hintsnet.com/digital-garden/
```

##### 缺点

1. 搜索。没有vscode好用。
2. 插件质量良莠不齐。装了几个插件，一些地方就不按预期工作了，找不出原因。
3. 资料少。tiddly wiki这个关键字在Google上的搜索结果简直是一场灾难。

于是弃坑。