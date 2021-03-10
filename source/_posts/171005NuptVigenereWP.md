---
title: 南邮CTF平台 Vigenere writeup
date: 2017-10-05 19:40:09
description: 题目挺不错的，实打实，没脑洞，也锻炼了使用python的能力。
---

### 题目

>  It is said that Vigenere cipher does not achieve the perfect secrecy actually :-)
>
>  Tips:
>  1.The encode pragram is given;
>  2.Do u no [index of coincidence ](https://en.wikipedia.org/wiki/Index_of_coincidence)？
>  3.The key is last 6 words of the plain text(with "nctf{}" when submitted, also without any interpunction)
>
>  [encode.cpp](http://ctf.nuptsast.com/static/uploads/13706e3281c1fb0c04417d3452cb745b/encode.cpp)   [code.txt](http://ctf.nuptsast.com/static/uploads/9a27a6c8b9fb7b8d2a07ad94924c02e5/code.txt) 

### 什么是异或

异或（exclusive or）是二元逻辑运算符，符号为 XOR 或 EOR 或 ⊕或 ^ 。对于表达式 `a^b` 的取值，当且仅当a、b逻辑值不同时为真。具体来说就是四个式子：`1^1=0;	0^0=0;	1^0=1;	0^1=1` 。另外，异或有一些基本的特性，**本题仅用到第七行的特性**即可。

```php
a^a=0;
a^0=a;
a^b=b^a;
a^(b^c)=(a^b)^c;
a^b^b=a;
------------------------------------------
如果 cipher = plain ^ key，那么 plain = cipher ^ key
简单地证明一下：
	        c = p ^ k
 -->  	c ^ k = p ^ k ^ k
 -->  	c ^ k = p
------------------------------------------
一个以字节为单位进行异或的例子：
  97^98	--> 01100001 ^ 01100010 = 00000011 -> 3
```

### 概念

我们知道，英文中的每个字母使用频率是不同的，在够长的一段话里，各个字母的占比大致稳定，并且这个稳定值也已经用巨大的语料库统计出来了，这就是[字母频率](https://zh.wikipedia.org/wiki/%E5%AD%97%E6%AF%8D%E9%A2%91%E7%8E%87)。这种统计层面的现象，就给我们提供了判断一段文字是否可能有意义的依据，并且这种判断可以通过编程轻松完成。然而，给定两个字母组合，只计算出其中各字母的占比是不够的，想要准确高效地比较两段文字谁更可能具备有意义的语义，我们最好算出一个归一化参数，用以直观表示可能性的大小，这就是文中提到的 [correlation](https://en.wikipedia.org/wiki/Index_of_coincidence#Example)  ，计算公式也是有的，![\mathbf{\chi} = \sum_{i=1}^{c}n_i f_i](https://wikimedia.org/api/rest_v1/media/math/render/svg/1b77b0ca8571bb219a9ad2ddf00b982d983d17d3)  ，其中n(i)指字母i在一段话的所有字母中所占的比例，f(i)就是已经统计出来的i字母的频率，具体如下所示。

字母频率列表：

```php
frequencies = {"e": 0.12702, "t": 0.09056, "a": 0.08167, "o": 0.07507, "i": 0.06966,
               "n": 0.06749, "s": 0.06327, "h": 0.06094, "r": 0.05987, "d": 0.04253,
               "l": 0.04025, "c": 0.02782, "u": 0.02758, "m": 0.02406, "w": 0.02360,
               "f": 0.02228, "g": 0.02015, "y": 0.01974, "p": 0.01929, "b": 0.01492,
               "v": 0.00978, "k": 0.00772, "j": 0.00153, "x": 0.00150, "q": 0.00095,
               "z": 0.00074}
```

### 解题

#### 理解加密

题目的加密方式大致等价于这样写：

```python
# coding:utf8
key = [0xba, 0x1f, 0x91, 0xb2, 0x53, 0xcd, 0x3e]  # 长度范围是1-13，当然，我们还不知道key是多少
plain = open('ptext.txt').read()
cipher = open('ctext.txt', 'w+')
c = ''
k = 0
for p in plain:
    c += hex(ord(p) ^ key[k])[2:].zfill(2)
    k = (k + 1) % len(key)
cipher.write(c)
```

程序意思是将明文和密钥逐字节异或，每次异或后的值用两位十六进制表示写入文件，也就是我们见到的code.txt，在这个过程中，密钥是循环使用的。

那么现在情况是这样的，我们知道：

>  密钥的长度区间为1-13字节
>
>  加密方式为逐字节循环异或 
>
>  加密结果，即密文的完整内容

我们想知道

> 明文内容 
>
> 密钥内容

(⊙﹏⊙) 这看起来有点困难。

不过，其实还有两个不言而喻但非常重要的信息

> 明文的每一个字节都是可见字符。
>
> 明文是一段有意义的话。

#### 解密代码主程序

先放个主程序，和下面的对照着看。全部代码在[文章底部](#解密代码全文) 。

```python
def main():
    ps = []
    ks = []
    ss = []
    ps.extend(xrange(32, 127))
    ks.extend(xrange(0xff + 1))
    ss.extend(xrange(1, 14))
    cipher = getCipher()

    keyPool = getKeyPool(cipher=cipher, stepSet=ss, plainSet=ps, keySet=ks)
    for i in keyPool:
        freq = getFrequency(cipher, keyPool[i])
        key = analyseFrequency(freq)
        plain = vigenereDecrypt(cipher, key)
        print key, plain
```

#### 确定密钥的长度和候选字符集

明文由可见字符组成。这意味着任何一个使明文出现不可见字符的值都不可能出现在key里。
依据此可以取得两个进展。

1. 求出key的每一个字节有哪些候选字符。
   具体操作：
   当我们假设某一字节的key的值时，就可以使用前文提到的plain = cipher ^ key 求出这一字节密文对应的明文，如果这个明文是不可见的，那么我们假设的这个值就不可能出现在key的这个字节。
   因为是循环异或，所以每个字节的key会去加密多个字节的明文，我们就可以如法炮制，大大缩小key的每个字节的候选字符集。
2. 在1的基础上，确定key可能有哪几种长度。
   具体操作：
   我们假设key每一种可能的长度，一一去求对应的候选字符集， 如果有一种长度的key在某一字节的候选字符集为空，那么key就不可能是这个长度。

至此，我们可以从无到有求得  **key有哪些可能的长度** 以及  **key在每一种长度下对应的每个字节的候选字符集 **。

上代码：

```python
def getKeyPool(cipher, stepSet, plainSet, keySet):
    ''' 传入的密文串、明文字符集、密钥字符集、密钥长度范围均作为数字列表处理.形如[0x11,0x22,0x33]
        返回一个字典，以可能的密钥长度为键，以对应的每一字节的密钥字符集构成的列表为值，
        密钥字符集为数字列表。
            形如{
                    1:[[0x11]],
                    3:[
                        [0x11,0x33,0x46],
                        [0x22,0x58],
                        [0x33]
                       ]
                }
    '''
    keyPool = dict()
    for step in stepSet:
        maybe = [None] * step
        for pos in xrange(step):
            maybe[pos] = []
            for k in keySet:
                flag = 1
                for c in cipher[pos::step]:
                    if c ^ k not in plainSet:
                        flag = 0
                if flag:
                    maybe[pos].append(k)
        for posPool in maybe:
            if len(posPool) == 0:
                maybe = []
                break
        if len(maybe) != 0:
            keyPool[step] = maybe
    return keyPool
```

#### 遍历候选字符集，求出对应的字频

这虽是个体力活，却也得小心翼翼。

```python
def getFrequency(cipher, keyPoolList):
    ''' 传入的密文作为数字列表处理
        传入密钥的字符集应为列表，依次包含各字节字符集。
            形如[[0x11,0x12],[0x22]]
        返回字频列表，依次为各字节字符集中每一字符作为密钥组成部分时对应的明文字频
            形如[{
                    0x11:{'a':2,'b':3},
                    0x12:{'e':6}
                 },
                 {
                    0x22:{'g':1}
                 }]
    '''
    freqList = []
    keyLen = len(keyPoolList)
    for i in xrange(keyLen):
        posFreq = dict()
        for k in keyPoolList[i]:
            posFreq[k] = dict()
            for c in cipher[i::keyLen]:
                p = chr(k ^ c)
                posFreq[k][p] = posFreq[k][p] + 1 if p in posFreq[k] else 1
        freqList.append(posFreq)
    return freqList
```

#### 根据字频求得密钥

明文是一段有意义的话。这意味着它算出来的correlation值一定是所有候选明文中最大的，依照这一点就能挑出密钥每个字节的值，从而得到整个密钥。这也是整个解密过程最核心的一部分。

```python
def calCorrelation(cpool):
    '''传入字典，形如{'e':2,'p':3}
        返回可能性，0~1,值越大可能性越大
        (correlation between the decrypted column letter frequencies and
        the relative letter frequencies for normal English text)
    '''
    frequencies = {"e": 0.12702, "t": 0.09056, "a": 0.08167, "o": 0.07507, "i": 0.06966,
                   "n": 0.06749, "s": 0.06327, "h": 0.06094, "r": 0.05987, "d": 0.04253,
                   "l": 0.04025, "c": 0.02782, "u": 0.02758, "m": 0.02406, "w": 0.02360,
                   "f": 0.02228, "g": 0.02015, "y": 0.01974, "p": 0.01929, "b": 0.01492,
                   "v": 0.00978, "k": 0.00772, "j": 0.00153, "x": 0.00150, "q": 0.00095,
                   "z": 0.00074}
    relative = 0.0
    total = 0
    fpool = 'etaoinshrdlcumwfgypbvkjxqz'
    total = sum(cpool.values())  # 总和应包括字母和其他可见字符
    for i in cpool.keys():
        if i in fpool:
            relative += frequencies[i] * cpool[i] / total
    return relative


def analyseFrequency(cfreq):
    key = []
    for posFreq in cfreq:
        mostRelative = 0
        for keyChr in posFreq.keys():
            r = calCorrelation(posFreq[keyChr])
            if r > mostRelative:
                mostRelative = r
                keychar = keyChr
        key.append(keychar)

    return key
```

#### 根据密钥解密

求出密钥剩下的就好办了。

```python
def vigenereDecrypt(cipher, key):
    plain = ''
    cur = 0
    ll = len(key)
    for c in cipher:
        plain += chr(c ^ key[cur])
        cur = (cur + 1) % ll
    return plain
```

### 一些数据

#### 可能的密钥长度和对应字符集

```
{7: 
[[162, 165, 168, 169, 170, 174, 175, 178, 179, 180, 184, 185, 186, 187, 189, 190, 191], 

[0, 2, 10, 11, 12, 17, 21, 23, 25, 26, 27, 28, 29, 30, 31, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95], 

[132, 133, 142, 144, 145, 146, 147, 148, 149, 150, 155, 159, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223], 

[161, 166, 167, 170, 173, 176, 177, 178, 179, 180, 181, 182, 183, 186, 188], 

[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 68, 70, 72, 76, 78, 80, 81, 82, 83, 84, 86, 87, 90, 93], 

[128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 195, 196, 200, 201, 202, 204, 205, 206, 207, 208, 210, 213, 216, 217, 223], 

[33, 39, 43, 44, 52, 55, 57, 58, 59, 60, 61, 62, 63]
]}
```

#### 最后结果

```
[186, 31, 145, 178, 83, 205, 62] Cryptography is the practice and study of techniques for, among other things, secure communication in the presence of attackers. Cryptography has been used for hundreds, if not thousands, of years, but traditional cryptosystems were designed and evaluated in a fairly ad hoc manner. For example, the Vigenere encryption scheme was thought to be secure for decades after it was invented, but we now know, and this exercise demonstrates, that it can be broken very easily.
[Finished in 2.2s]
```

### 解密代码全文

```python
# coding:utf8
# by https://findneo.github.io/
def getCipher(file='code.txt'):
    '''从文件中读取十六进制串，返回十六进制数组
    '''
    c = open(file).read()
    codeintlist = []
    codeintlist.extend(
        (map(lambda i: int(c[i:i + 2], 16), range(0, len(c), 2))))
    return codeintlist


def getKeyPool(cipher, stepSet, plainSet, keySet):
    ''' 传入的密文串、明文字符集、密钥字符集、密钥长度范围均作为数字列表处理.形如[0x11,0x22,0x33]
        返回一个字典，以可能的密钥长度为键，以对应的每一字节的密钥字符集构成的列表为值，密钥字符集为数字列表。
            形如{
                    1:[[0x11]],
                    3:[
                        [0x11,0x33,0x46],
                        [0x22,0x58],
                        [0x33]
                       ]
                }
    '''
    keyPool = dict()
    for step in stepSet:
        maybe = [None] * step
        for pos in xrange(step):
            maybe[pos] = []
            for k in keySet:
                flag = 1
                for c in cipher[pos::step]:
                    if c ^ k not in plainSet:
                        flag = 0
                if flag:
                    maybe[pos].append(k)
        for posPool in maybe:
            if len(posPool) == 0:
                maybe = []
                break
        if len(maybe) != 0:
            keyPool[step] = maybe
    return keyPool


def calCorrelation(cpool):
    '''传入字典，形如{'e':2,'p':3}
        返回可能性，0~1,值越大可能性越大
        (correlation between the decrypted column letter frequencies and
        the relative letter frequencies for normal English text)
    '''
    frequencies = {"e": 0.12702, "t": 0.09056, "a": 0.08167, "o": 0.07507, "i": 0.06966,
                   "n": 0.06749, "s": 0.06327, "h": 0.06094, "r": 0.05987, "d": 0.04253,
                   "l": 0.04025, "c": 0.02782, "u": 0.02758, "m": 0.02406, "w": 0.02360,
                   "f": 0.02228, "g": 0.02015, "y": 0.01974, "p": 0.01929, "b": 0.01492,
                   "v": 0.00978, "k": 0.00772, "j": 0.00153, "x": 0.00150, "q": 0.00095,
                   "z": 0.00074}
    relative = 0.0
    total = 0
    fpool = 'etaoinshrdlcumwfgypbvkjxqz'
    total = sum(cpool.values())  # 总和应包括字母和其他可见字符
    for i in cpool.keys():
        if i in fpool:
            relative += frequencies[i] * cpool[i] / total
    return relative


def analyseFrequency(cfreq):
    key = []
    for posFreq in cfreq:
        mostRelative = 0
        for keyChr in posFreq.keys():
            r = calCorrelation(posFreq[keyChr])
            if r > mostRelative:
                mostRelative = r
                keychar = keyChr
        key.append(keychar)

    return key


def getFrequency(cipher, keyPoolList):
    ''' 传入的密文作为数字列表处理
        传入密钥的字符集应为列表，依次包含各字节字符集。
            形如[[0x11,0x12],[0x22]]
        返回字频列表，依次为各字节字符集中每一字符作为密钥组成部分时对应的明文字频
            形如[{
                    0x11:{'a':2,'b':3},
                    0x12:{'e':6}
                 },
                 {
                    0x22:{'g':1}
                 }]
    '''
    freqList = []
    keyLen = len(keyPoolList)
    for i in xrange(keyLen):
        posFreq = dict()
        for k in keyPoolList[i]:
            posFreq[k] = dict()
            for c in cipher[i::keyLen]:
                p = chr(k ^ c)
                posFreq[k][p] = posFreq[k][p] + 1 if p in posFreq[k] else 1
        freqList.append(posFreq)
    return freqList


def vigenereDecrypt(cipher, key):
    plain = ''
    cur = 0
    ll = len(key)
    for c in cipher:
        plain += chr(c ^ key[cur])
        cur = (cur + 1) % ll
    return plain


def main():
    ps = []
    ks = []
    ss = []
    ps.extend(xrange(32, 127))
    ks.extend(xrange(0xff + 1))
    ss.extend(xrange(1, 14))
    cipher = getCipher()

    keyPool = getKeyPool(cipher=cipher, stepSet=ss, plainSet=ps, keySet=ks)
    for i in keyPool:
        freq = getFrequency(cipher, keyPool[i])
        key = analyseFrequency(freq)
        plain = vigenereDecrypt(cipher, key)
        print key, plain


if __name__ == '__main__':
    main()

```

### 题目备份

```c
http://ctf.nuptsast.com/static/uploads/13706e3281c1fb0c04417d3452cb745b/encode.cpp

#include <stdio.h>
#define KEY_LENGTH 2 // Can be anything from 1 to 13

main(){
  unsigned char ch;
  FILE *fpIn, *fpOut;
  int i;
  unsigned char key[KEY_LENGTH] = {0x00, 0x00};
  /* of course, I did not use the all-0s key to encrypt */

  fpIn = fopen("ptext.txt", "r");
  fpOut = fopen("ctext.txt", "w");

  i=0;
  while (fscanf(fpIn, "%c", &ch) != EOF) {
    /* avoid encrypting newline characters */  
    /* In a "real-world" implementation of the Vigenere cipher, 
       every ASCII character in the plaintext would be encrypted.
       However, I want to avoid encrypting newlines here because 
       it makes recovering the plaintext slightly more difficult... */
    /* ...and my goal is not to create "production-quality" code =) */
    if (ch!='\n') {
      fprintf(fpOut, "%02X", ch ^ key[i % KEY_LENGTH]); // ^ is logical XOR    
      i++;
      }
    }
 
  fclose(fpIn);
  fclose(fpOut);
  return;
} 
----------------------------------------------------------------------------------
http://ctf.nuptsast.com/static/uploads/9a27a6c8b9fb7b8d2a07ad94924c02e5/code.txt

F96DE8C227A259C87EE1DA2AED57C93FE5DA36ED4EC87EF2C63AAE5B9A7EFFD673BE4ACF7BE8923CAB1ECE7AF2DA3DA44FCF7AE29235A24C963FF0DF3CA3599A70E5DA36BF1ECE77F8DC34BE129A6CF4D126BF5B9A7CFEDF3EB850D37CF0C63AA2509A76FF9227A55B9A6FE3D720A850D97AB1DD35ED5FCE6BF0D138A84CC931B1F121B44ECE70F6C032BD56C33FF9D320ED5CDF7AFF9226BE5BDE3FF7DD21ED56CF71F5C036A94D963FF8D473A351CE3FE5DA3CB84DDB71F5C17FED51DC3FE8D732BF4D963FF3C727ED4AC87EF5DB27A451D47EFD9230BF47CA6BFEC12ABE4ADF72E29224A84CDF3FF5D720A459D47AF59232A35A9A7AE7D33FB85FCE7AF5923AA31EDB3FF7D33ABF52C33FF0D673A551D93FFCD33DA35BC831B1F43CBF1EDF67F0DF23A15B963FE5DA36ED68D378F4DC36BF5B9A7AFFD121B44ECE76FEDC73BE5DD27AFCD773BA5FC93FE5DA3CB859D26BB1C63CED5CDF3FE2D730B84CDF3FF7DD21ED5ADF7CF0D636BE1EDB79E5D721ED57CE3FE6D320ED57D469F4DC27A85A963FF3C727ED49DF3FFFDD24ED55D470E69E73AC50DE3FE5DA3ABE1EDF67F4C030A44DDF3FF5D73EA250C96BE3D327A84D963FE5DA32B91ED36BB1D132A31ED87AB1D021A255DF71B1C436BF479A7AF0C13AA14794
```

### 参考链接

* https://en.wikipedia.org/wiki/Index_of_coincidence
* https://en.wikipedia.org/wiki/One-time_pad
* https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher
* https://en.wikipedia.org/wiki/Letter_frequency
* https://www.lijinma.com/blog/2014/05/29/amazing-xor/
* http://blog.csdn.net/qq_31344951/article/details/77934717