---
title: IP地址混淆
date: 2017-11-25 16:18:25
description: 一个IP地址，可能有上百种面目
---

不知有多少人了解IP地址`127.0.0.1` 一定程度上是完全等价于`127.1` 和`0x7f.1` 的，不过我从上回看到`ping 127.1` 能正常工作开始，就一直很好奇背后的原因，最近又在 [一个CTF题目](http://findneo.github.io/171112HITCONCTFBabyfirstRevengeSeriesWP/) 用到基于IP表示法的技巧，于是决定稍微探索一下。

我发现一个IPv4地址可能拥有上百个不同的表示形式，而由于一些历史原因，在这方面的标准尚未完全统一，因此这些形式在大部分情况下都是可被正常解析的(举个例子，URL http://000000300.0x000000000a8.00102.00000000351 会解析成http://192.168.66.233/ )，这就在绕过限制和其他一些安全问题上提供了想象的空间。

本文主要介绍这些混淆背后的历史原因和原理，至于如何生成适用形式的IP也不复杂，并且常常需要考虑具体场景。不过我写了个小脚本，放在了[GitHub](https://github.com/findneo/IP-Obfuscator) 上，有需要可作为参考。

### 关于IP和IPv4地址

IPv4是应用于分组交换网络的无状态协议，是网际协议(Internet Protocol , IP)的第四个版本，也是第一个投入生产的版本，1983年开始首先应用在ARPANET项目中。

IP地址用以标记使用IP接入网络的设备。IPv4把IP地址定义为32位二进制数，可表示 `2**32` 约42亿个网络设备接口，早期使用分类网络(Classful Addressing)的方法划分为五类，随着IP地址需求的增长，这种分类法被无类别域间路由(Classless Inter-Domain Routing , CIDR)取代。【参见RFC 1517-1519】

### IPv4 地址句法的历史与现状

一个IPv4地址除了被机器解析外，还会用在很多需要人类阅读理解的地方，而一个32位二进制数(如`11000000101010000100001011101001` )对人类是很不友好的，因此人们必然会需要某种文本描述(textual representation) 。我们现在最常见到的点分十进制表示法(dotted-decimal notation) 就是其一。什么是点分十进制呢？就是由点号分隔开的四个十进制数(如`192.168.66.233` ） ，其中每个十进制数表示一个字节(octets , 八位二进制数)，较高有效位在左，较低有效位在右。

尽管从上面的描述我们可以了解到IPv4地址的常见形式，但是关于IP地址的文本描述具体应该如何，似乎从来没有严谨全面的定义。另一方面，IP作为互联网中较为基础的设施之一，常常不可避免地出现在各种协议的描述里，这些描述有时顺带也会提及IP地址的写法，但提法不尽相同，也并不足够强硬和严谨。这篇 [文章](https://tools.ietf.org/html/draft-main-ipaddr-text-rep-02) 细数了一些RFC文档里出现过的描述 ，可以看到不同场景下出现过`#127.0.0.1` 、`[127.0.0.1]` 、`127.000.000.001` 等形式的写法。

当IETF版本的句法处于无意识发展时，BSD版本的句法悄然登场。一个权威的解释大概也不是那么重要，尤其是当一项技术的某种实现已经被广泛使用。对于IPv4地址而言，这个实现就是`4.2BSD` 。 `4.2BSD` 引入了名为`inet_aton()` 的用于将字符串解释为IP地址的函数，这个函数被广泛地复制和演绎，从而使得BSD版本的关于IP地址文本描述的句法成为了事实上的标准——能够被`inet_aton()` 解释即合标准。至于`inet_aton()` 接受哪些形式的IP地址，将在下文给出。

这里先简要谈谈这两种句法的异同。

#### 相同点

对于最大多数情况——不带前导0的点分十进制( `dotted decimal octets with leading zeroes suppressed` ) ，两者都是支持的。

#### 不同点

- BSD版本的许多句法IETF版本都不支持
- ***最重要的。***IETF版本的句法在所有表述中始终如一地暗示要将带有前导0的数字解释为十进制，而BSD版本的句法在实现中将带有前导0的数字解释为八进制。举个例子，前者认为`192.168.1.011` 等价于`192.168.1.11` ，而后者认为等价于`192.168.1.9` 。

值得一提的是IPv6 的发展也对此产生了一定的影响。IPv6中的函数`inet_pton()` 在处理IPv4地址时只接受点分十进制，并且明确地拒绝了一些能够被`inet_aton()` 接受的句法。然而，对于是否接受前导0语焉不详。

此外，2005年的RFC 3986 提出取两者安全的公共子集作为严格的IP地址句法定义，形成倾向于IETF的标准，但同时保持对BSD实现的后向兼容。这个子集的定义如下，简单说就是用点号分隔的四个十进制数，禁止使用前导0。

```python
A 32-bit IPv4 address is divided into four octets.  Each octet is
represented numerically in decimal, using the minimum possible number
of digits (leading zeroes are not used, except in the case of 0
itself).  The four encoded octets are given most-significant first,
separated by period characters.

        IPv4address = d8 "." d8 "." d8 "." d8

        d8          = DIGIT               ; 0-9
                    / %x31-39 DIGIT       ; 10-99
                    / "1" 2DIGIT          ; 100-199
                    / "2" %x30-34 DIGIT   ; 200-249
                    / "25" %x30-35        ; 250-255
```





### inet_aton()允许哪些形式的IP地址

- a single number giving the entire 32-bit address.
- dot-separated octet values.  
- It also interpreted two intermediate syntaxes: 
- octet-dot-octet-dot-16bits, intended for class B addresses
- octet-dot-24bits, intended for class A addresses. 
- It also allowed some flexibility in how the individual numeric parts were specified. it allowed octal and hexadecimal in addition to decimal, distinguishing these radices by using the C language syntax involving a prefix "0" or "0x", and allowed the numbers to be arbitrarily long.

归纳起来有这么几种情况

- IP地址只有一个部分，表示为`a` ，每部分表示32位二进制数
- IP地址有两个部分，表示为`a.b` ，`a` 表示8位二进制数，`b` 表示24位二进制数
- IP地址有三部分，表示为`a.b.c` ，`a` 和`b` 各表示8位二进制数，`c` 表示16位二进制数
- IP地址有四个部分，表示为`a.b.c.d` ，每部分表示8位二进制数

以及这么两个重点

- 每一个部分可以都有三种表示法，十进制、十六进制和八进制，用前缀表明进制。
- 每部分的数字可以是任意长度。（这意味着可以把`077` 和`0xff` 表示成`000000077` 和`0x00000ff` 等）

到此为止，可以看到`127.1` 属于上述第二种情况，最开始的疑惑也就不复存在。

这应该算是一个历史遗留问题，不过在未来一段时间内，在广泛涉及URL和IP地址的浏览器和许多应用层程序(如Ping、telnet、wget、curl、GET、HEAD等)中，符合BSD版本句法的IPv4地址表示形式仍然是可接受的，而这些表示可以多达上百种，就可能在一些安全问题上发挥出人意料的作用。

### 生成一个IP地址的上百种形式

```python
# coding:utf8
# by https://findneo.github.io/
# ref: https://linux.die.net/man/3/inet_aton
#      https://tools.ietf.org/html/draft-main-ipaddr-text-rep-02
#      https://tools.ietf.org/html/rfc3986
#      http://www.linuxsa.org.au/pipermail/linuxsa/2007-September/088131.html
import itertools as it
import random
ip = '192.168.66.233'
i = ip.split('.')


def f(x):
    return hex(int(x))[2:].zfill(2)


hi = [f(i[0]),
      f(i[1]),
      f(i[2]),
      f(i[3]),
      # hi[4]:part c of "a.b.c"
      f(i[2]) + f(i[3]),
      # hi[5]:part b of "a.b"
      f(i[1]) + f(i[2]) + f(i[3]),
      # hi[6]:'a'
      f(i[0]) + f(i[1]) + f(i[2]) + f(i[3]),
      ]


def hex2oct(x):
    """ arbitrary length is supported
    """
    moreZero = random.choice(range(10))
    return oct(int(x, 16)).zfill(moreZero + len(oct(int(x, 16)))).strip('L')


def hex2int(x): return str(int(x, 16))


def hex2hex(x):
    moreZero = random.choice(range(10))
    return '0x' + '0' * moreZero + x


p = [hex2hex, hex2int, hex2oct]
res = []
# "a.b.c.d"
# Each of the four numeric parts specifies a byte of the address;
# the bytes are assigned in left-to-right order to produce the binary address.
res.extend(['.'.join([i[0](hi[0]), i[1](hi[1]), i[2](hi[2]), i[3](hi[3])]) for i in it.product(p, p, p, p)])

# "a.b.c"
# Parts a and b specify the first two bytes of the binary address.
# Part c is interpreted as a 16-bit value that defines the rightmost two bytes of the binary address.
res.extend(['.'.join([i[0](hi[0]), i[1](hi[1]), i[2](hi[4])]) for i in it.product(p, p, p)])

# "a.b"
# Part a specifies the first byte of the binary address.
# Part b is interpreted as a 24-bit value that defines the rightmost three bytes of the binary address.
res.extend(['.'.join([i[0](hi[0]), i[1](hi[5])]) for i in it.product(p, p)])

# "a"
# The value a is interpreted as a 32-bit value that is stored directly into the binary address without any byte rearrangement.
res.extend(['.'.join([i[0](hi[6])]) for i in it.product(p)])
for i in xrange(len(res)):
    print "[%d]\t%s" % (i, res[i])

# -------------------------------------------------------------------------------
# test
import os

except_ip = []


def test_notation(ip_notation):
    global except_ip
    x = os.popen('ping -n 1 -w 0.5 ' + ip_notation).readlines()
    answer = x[0] if len(x) == 1 else x[1]
    if ip not in answer:
        except_ip.append(ip_notation)
    return answer.decode('gbk').strip()


print "\nchecking. . .",
for i in xrange(len(res)):
    # print "[%d] %s\t\t\t%s" % (i, res[i], test_notation(res[i]))
    test_notation(res[i])
    print '.',

print "\n\ntotally %d notations of ip checked ,all are equivalent to %s" % (len(res), ip)
if len(except_ip):
    print "except for notations following:\n", except_ip

```

### 结果列表

```python
[0]	0x000c0.0xa8.0x0000042.0x0e9
[1]	0x0000c0.0x0000000a8.0x000042.233
[2]	0x000000000c0.0x000000000a8.0x000000042.0000000000351
[3]	0x000c0.0x000000a8.66.0x000000e9
[4]	0xc0.0xa8.66.233
[5]	0x000000c0.0x000000000a8.66.0351
[6]	0x000000000c0.0x00000000a8.0000102.0x0000000e9
[7]	0x0000c0.0x000a8.00102.233
[8]	0x00000000c0.0x00000a8.00000000102.0000000351
[9]	0x00c0.168.0x0042.0x00000e9
[10]	0x000000c0.168.0x00000000042.233
[11]	0x0000000c0.168.0x0042.0000000351
[12]	0x00000000c0.168.66.0x000000000e9
[13]	0x000000c0.168.66.233
[14]	0xc0.168.66.00351
[15]	0xc0.168.0000102.0x00000e9
[16]	0x00c0.168.000000000102.233
[17]	0x0000c0.168.00102.00000000351
[18]	0x0000000c0.0000250.0x00042.0xe9
[19]	0x000c0.0000000250.0x000000042.233
[20]	0x0c0.0000000250.0x00042.00000000351
[21]	0xc0.0000000250.66.0xe9
[22]	0x0000000c0.00000250.66.233
[23]	0x000c0.00250.66.000000351
[24]	0x00000c0.00000250.0000102.0xe9
[25]	0x00000c0.000250.00102.233
[26]	0x000c0.00000250.0000000000102.00000351
[27]	192.0x000000000a8.0x0042.0x0e9
[28]	192.0x0000000a8.0x0042.233
[29]	192.0x0000000a8.0x0000042.0000351
[30]	192.0x000000a8.66.0xe9
[31]	192.0x00000000a8.66.233
[32]	192.0x0000000a8.66.000351
[33]	192.0xa8.00102.0x0000e9
[34]	192.0x00a8.00102.233
[35]	192.0x00000a8.000102.0000000000351
[36]	192.168.0x42.0xe9
[37]	192.168.0x000042.233
[38]	192.168.0x0000000042.000000351
[39]	192.168.66.0x000000000e9
[40]	192.168.66.233
[41]	192.168.66.0000351
[42]	192.168.000102.0x00e9
[43]	192.168.00000102.233
[44]	192.168.00000000102.00000351
[45]	192.0000000250.0x0000000042.0x000e9
[46]	192.000250.0x00000000042.233
[47]	192.0250.0x000000042.0351
[48]	192.000250.66.0x000000e9
[49]	192.0000250.66.233
[50]	192.0000000000250.66.000351
[51]	192.000000000250.00000102.0xe9
[52]	192.00250.0000000102.233
[53]	192.0250.00000000102.0351
[54]	0000000300.0x000a8.0x0000000042.0x0000e9
[55]	000000000300.0x000000000a8.0x0000000042.233
[56]	0000000300.0x000000a8.0x00000042.000351
[57]	0000000300.0x0000a8.66.0x000000000e9
[58]	0000000000300.0x00000000a8.66.233
[59]	0000000300.0x0a8.66.0000351
[60]	0000300.0x00a8.0102.0x00e9
[61]	0000300.0x0000000a8.000102.233
[62]	000000300.0x000000000a8.00102.00000000351
[63]	0000300.168.0x000042.0xe9
[64]	0300.168.0x042.233
[65]	0000000300.168.0x0000000042.0000351
[66]	0000000300.168.66.0x000000000e9
[67]	000300.168.66.233
[68]	0000300.168.66.00000351
[69]	000000000300.168.00102.0x00e9
[70]	0300.168.000000000102.233
[71]	0000300.168.000000102.00000351
[72]	0000000000300.00000000250.0x0042.0x00000000e9
[73]	00300.000000000250.0x42.233
[74]	00000300.000250.0x00000000042.0000351
[75]	000300.000000250.66.0x000000000e9
[76]	0000000000300.000000250.66.233
[77]	000000300.0250.66.00000351
[78]	0000000300.000250.000000102.0xe9
[79]	000300.00000000250.000102.233
[80]	000000000300.0000000250.000102.0000000000351
[81]	0x000000c0.0x00a8.0x42e9
[82]	0x0000c0.0x000a8.17129
[83]	0x000000c0.0x0000a8.00041351
[84]	0x000000000c0.168.0x000042e9
[85]	0x0000c0.168.17129
[86]	0x0000c0.168.000041351
[87]	0x0000000c0.00000000250.0x000000042e9
[88]	0x00000c0.000000000250.17129
[89]	0x000c0.00250.00041351
[90]	192.0x0a8.0x0000000042e9
[91]	192.0x000a8.17129
[92]	192.0x000000a8.0041351
[93]	192.168.0x000042e9
[94]	192.168.17129
[95]	192.168.00041351
[96]	192.00250.0x000000042e9
[97]	192.0250.17129
[98]	192.000000000250.000041351
[99]	00000300.0x00000a8.0x000000042e9
[100]	000000000300.0x00000a8.17129
[101]	00000300.0x000a8.00000000041351
[102]	0300.168.0x000000042e9
[103]	0300.168.17129
[104]	00000000300.168.00000000041351
[105]	0300.000000000250.0x0042e9
[106]	000000000300.0000250.17129
[107]	000000000300.00250.00000000041351
[108]	0x0c0.0x00000a842e9
[109]	0x00c0.11027177
[110]	0x000000c0.0052041351
[111]	192.0x0000a842e9
[112]	192.11027177
[113]	192.000000000052041351
[114]	00000300.0x0000000a842e9
[115]	0000000300.11027177
[116]	0000000300.000000000052041351
[117]	0x0000000c0a842e9
[118]	3232252649
[119]	000000030052041351

checking. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 

totally 120 notations of ip checked ,all are equivalent to 192.168.66.233
[Finished in 3.1s]
```

