---
mathjax: false
title: 华为2018年校园招聘软件题
date: 2018-04-04 00:13:26
---

> 2018.4.3 19:00 ~ 2018.4.3 21:00

# 求回文子字符串数量

```python
import sys
def check(s):
    length=len(s)
    for i in range(length):
        if s[i]!=s[length-1-i]:
            return 0
    return 1
s=sys.stdin.readline().strip()
res=0
try:
    for i in range(len(s)):
        for j in range(i+1,len(s)+1):
            if check(s[i:j]):
                res=max(res,len(s[i:j]))
except:
    print res
    exit(0)
    
print res
```

# 根据规则输出IPv6地址类型

```python
import sys
def check(ip):
    if len(ip)!=8:
        return 0
    s="0123456789abcdefABCDEF"
    for i in (''.join(ip)).strip():
        if i not in s:
            return 0
    return 1

s=sys.stdin.readline().split(":") 
if not check(s):
    print "Error"
elif int(s[0],16)^0xfe80<(2**6):
    print "LinkLocal"
elif int(s[0],16)^0xfec0<(2**6):
    print "SiteLocal"
elif int(s[0],16)^0xff00<(2**8):
    print "Multicast"
elif ":".join(s).strip()=="0000:0000:0000:0000:0000:0000:0000:0000":
    print "Unspecified"
elif ":".join(s).strip()=="0000:0000:0000:0000:0000:0000:0000:0001":
    print "Loopback"
else:
    print "GlobalUnicast"
```

# 试用软件赚流量方案

```python
import sys
def check_t(down):
    t_all=0
    for i in range(len(down)):
        if down[i]=='1':
            t_all+=appt[i]
    #print t_all,t,down
    return t_all<=t

def get_m(down):
    m_all=0
    for i in range(len(down)):
        if down[i]=='1':
            m_all+=appm[i]
    return m_all

def get_prior(a,b):
    #print a
    #print b
    return a if int(a,2)>int(b,2) else b

def parse(down):
    res=[]
    res.extend([str(i+1) for i in range(len(down)) if down[i]=='1'])
    print (" ".join(res)).strip() #,down

t=int(sys.stdin.readline().strip())
appt=map(int,sys.stdin.readline().strip().split())
appm=map(int,sys.stdin.readline().strip().split())
length=len(appt)
res,money="0"*length,0

for i in xrange(2**length):
    down=bin(i)[2:].zfill(length)
    if check_t(down):
        tmpm=get_m(down)
        if tmpm >money:
            res,money=down,tmpm
        elif tmpm == money:
            res=get_prior(down,res)
parse(res)
```

