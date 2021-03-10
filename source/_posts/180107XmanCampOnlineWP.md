---
title: “华为杯”极客出发XMan冬令营线上CTF解题赛
date: 2018-01-07 19:11:25
description: 只做了个签到题，总的来说是一个脑洞和简单AES加密的结合。
---

#### 中二的成长之路

> 我用真心对你，你却用QR敷衍我。
>
> [附件下载](http://xman.xctf.org.cn/media/task/6704c696-0a81-4715-b16c-38a093dadedf.jpg)
>
> ![QR](QR.jpg)
>
> - 试试QR的哈希，并且注意红字。
> - 使用图片显示的某些信息做哈希
> - 再次观察图片，看看不一样的颜色和字体，也许需要做一下哈希

- 扫描题目给的图片得到`3ukka4wZf2Q9H8PEI5YKFA==` ，但直接base64解码得到乱码。谷歌搜索发现可能性很多，各种尝试无果。
- 使用binwalk分离出压缩包。不是伪加密，爆破也无果。
- 经过主办方提示`看看不一样的颜色和字体` 注意到AES，搜索发现与今年9月份的问鼎杯CTF一道题极为相似，就是压缩包的密码经过AES加密后再进行base64编码。这样就有了基本的思路。但还缺少一些信息，比如AES采用哪种模式，key是什么，如果有IV，又会是什么。
- 对着三次关于`哈希` 的提示，猜想做出来的哈希就是key，那么就不需要IV，那么就可能是ECB或CTR模式。但哈希是对谁做的呢，产生了很多联想，做了一些尝试无果。后来猛然发现，基本上能用来产生哈希用于AES加密并产生BASE64串的东西一定是在图片生成之前就存在。那么可能性就不多了，甚至没有了。比赛快结束前注意到`试试QR的哈希` 这一提示，不报什么希望地试了下字符串"QR"的哈希，没想到成了。解密后得到压缩包密码`1Znmpr4jzChwxXqB` 。
- 打开压缩包后迎面而来又一张QR，解出`bqIGBfOGuOsxLYV16OI7xRNAZrcFdYLJtHaDym2O7so=` 。很容易想到这是要故技重施，又要找一串key。因为key可能是16、24或32字节，很自然想到上一次解密就试过的16个字节的文件名`s776051080zum92N` ，一试便成，得到`XCTF{W0W_U_G0T_TH3_FL4G}` 。
- 勉强拿到门票，即将和大佬们一起学习，有点兴奋：）

附上解题脚本：

```python
#coding:utf-8
import base64,hashlib
from Crypto.Cipher import AES
key = hashlib.md5('QR').hexdigest()
secret="3ukka4wZf2Q9H8PEI5YKFA==" # 图片扫码结果
def decrypt(enc):
  aes = AES.new(key, AES.MODE_ECB)
  return aes.decrypt(enc)
res=decrypt(base64.b64decode(secret))
print len(res),res
#-------------------------------------------
key = "s776051080zum92N" #压缩包里面图片的文件名
secret="bqIGBfOGuOsxLYV16OI7xRNAZrcFdYLJtHaDym2O7so=" #压缩包里图片是涨二维码，扫出来这个
def decrypt2(enc):
  aes = AES.new(key, AES.MODE_ECB)
  return aes.decrypt(enc)
res=decrypt2(base64.b64decode(secret))
print len(res),res
#------运行结果--------------
#16 1Znmpr4jzChwxXqB
#32 XCTF{W0W_U_G0T_TH3_FL4G}
```