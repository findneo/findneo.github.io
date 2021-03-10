---
toc: false
mathjax: false
title: GitHub 可用短ID
date: 2018-04-19 20:27:42
---

做了件无聊的事，做完发现有人做过了（https://www.v2ex.com/t/401615 ） ，记录一下。

GitHub用户名要求是

```html
Username may only contain alphanumeric characters or single hyphens, and cannot begin or end with a hyphen
```

也就是满足正则 `^[0-9a-zA-Z]$|[0-9a-zA-Z][-0-9a-zA-Z]*[0-9a-zA-Z]`  ，

因为大小写不敏感，所以相当于 `^[0-9a-z]$|[0-9a-z][-0-9a-z]*[0-9a-z]` 

产生一位和两位的符合GitHub命名要求的名字

```python
import string
import itertools

f=open("GithubName12.txt",'w+')
a=string.lowercase +string.digits+'-'
tmp=[]
for i in xrange(1,3):
	for j in itertools.product(a,repeat=i):
		name=''.join(j)
		if j[0]=='-' or j[-1]=='-':
			continue
		tmp.append(name)
f.write('\n'.join(tmp))

```

产生三位的符合GitHub命名要求的名字

```python
import requests
import string
import itertools
import random

f=open("GithubName3.txt",'w+')
a=string.lowercase +string.digits+'-'
tmp=[]
for i in xrange(3,4):
	for j in itertools.product(a,repeat=i):
		name=''.join(j)
		if j[0]=='-' or j[-1]=='-':
			continue
		tmp.append(name)
	random.shuffle(tmp)
f.write('\n'.join(tmp)+'\n')
```

然后用burp的intruder跑就可以了，404为用户名未被占用。

```html
HEAD /$asdf$ HTTP/1.1
Host: github.com
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:54.0) Gecko/20100101 Firefox/54.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: zh-CN,en-US;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
Connection: close
Upgrade-Insecure-Requests: 1


```

实测未被占用的名字未必都可用，比如一/二个字母的基本上都不能用了。

一位长的名字只有 `w` 未被使用，但实际修改名字时响应为`Login name 'w' is a reserved word` 

两位长的倒是颇多，但也都不可用，响应均为 `Login is already taken ` 

```c
06 0e 0t 0y 2e 2l 2n 2v 3u 4j 4r 4t 4y 5b 5f 5h 5j 5n 5q 5t 5u 5z 6e 6i 6j 6l 6m 6n 6o 6p 6r 6y 7j 7p 7y 8a 8n 8y 96 9e 9g 9j 9w 9y j3 m6 n5 u6 y4  y6 y9 
```

三位长的就很多了，部分结果放在 [GIthub](https://github.com/findneo/scripts/blob/master/attaches/Github%E5%8F%AF%E7%94%A8%E7%9F%ADID%5Bupto201804%5D/GithubNiceID.txt) 上了，其中不乏一些靓号：）

但也有一些是保留字或者被使用过，如

`Login name 'api' is a reserved word`  

`Login name 'ssh' is a reserved word` 

 `see ,Login is already taken ` 

`vxv, Login is already taken ` 

...



提取出其中全字母或全数字的名字：

```python
import string
a=string.lowercase
a=string.digits
r=[]
with open('final.txt') as f:
	for i in f.readlines():
		if i[0] in a and i[1] in a and i[2] in a:
			r.append(i.strip())
print ' '.join(r)
```

结果：

```python
049 061 065 067 082 087 115 116 144 158 185 211 214 232 249 258 279 302 362 363 378 379 387 401 402 405 406 408 409 410 411 412 413 414 417 418 419 421 423 425 426 427 428 433 436 442 455 469 473 476 484 485 489 495 501 504 506 507 508 510 557 558 566 594 622 632 635 642 643 652 663 672 674 675 676 683 694 739 746 756 769 771 781 783 795 801 806 807 822 827 834 836 843 849 852 859 860 872 896 900 905 924 927 932 942 948 952 965 970 976 981

any api bkk cgf cla dsr eer eou evx exn exv eyh ezj faj hff iei ird iro iuu izl jxq kbx lbi lpo mqe mxq nhj nmf oia ouu qbd qcp qeq qfv qje qkj qtx qvg raw rre see sfv ssh tqo uau ueu ump unw upk uqy urr uyy vfj vhw vnv vqj vqk vxv vxx wek wiq xnn xoy xpp xsu xxt yiy yqv zdq zvt
```

