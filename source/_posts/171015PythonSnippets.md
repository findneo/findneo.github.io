---
title: 用python实现几种常见简单加密
date: 2017-10-15 16:45:21
description: 凯撒加密，摩斯电码，栅栏密码，base家族混合编解码。	
---

### 栅栏密码加解密

#### 单行版本

```python
railFence = lambda s: [[i, ''.join([s[k * i + j] for j in range(i) for k in range(len(s) / i)])] for i in range(1, len(s)) if not len(s) % i]
print railFence('hello world , 2017 ! ')
```

#### 正常版本

```python
def railFence(s):
    ll = len(s)
    res = dict()
    for i in range(1, ll):
        r = ''
        if ll % i == 0:
            for j in range(i):
                for k in range(ll / i):
                    r += s[k * i + j]
            res[i] = r
    return res

# test
print railFence('hello world , 2017 ! ')
# {1: 'hello world , 2017 ! ', 3: 'hlwl,0 eood 1!l r 27 ', 7: 'ho2er0ll1ld7o   ,!w  '}
```

### 凯撒密码加解密

#### 单行版本

```python
def caesar(s): return [[off, ''.join([chr((ord(i) - 97 + off) % 26 + 97) if 'a' <= i <= 'z' else chr((ord(i) - 65 + off) % 26 + 65) if 'A' <= i <= 'Z' else i for i in str(s)])] for off in range(26)]
print caesar('h3llo')
```

#### 正常版本

```python
def caesar(s):
    cycle = 26
    res = []
    for offset in range(26):
        r = ''
        for i in str(s):
            if 'a' <= i <= 'z':
                r += chr((ord(i) - ord('a') + offset) % cycle + ord('a'))
            elif 'A' <= i <= 'Z':
                r += chr((ord(i) - ord('A') + offset) % cycle + ord('A'))
            else:
                r += i
        res.append([offset, r])
    return res

# test
print caesar('h3llo')
#[  [0, 'h3llo'], [1, 'i3mmp'], [2, 'j3nnq'], [3, 'k3oor'], [4, 'l3pps'], [5, 'm3qqt'], [6, 'n3rru'], [7, 'o3ssv'],
#   [8, 'p3ttw'], [9, 'q3uux'], [10, 'r3vvy'], [11, 's3wwz'], [12, 't3xxa'], [13, 'u3yyb'], [14, 'v3zzc'],
#   [15, 'w3aad'], [16, 'x3bbe'], [17, 'y3ccf'], [18, 'z3ddg'], [19, 'a3eeh'], [20, 'b3ffi'], [21, 'c3ggj'],
#   [22, 'd3hhk'], [23, 'e3iil'], [24, 'f3jjm'], [25, 'g3kkn']]
```

### 莫尔斯电码加解密

```python
# by https://findneo.github.io/
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

# test
print morse('Hello word,2017!')
print morse('.... . .-.. .-.. ---   .-- --- .-. -.. --..-- ..--- ----- .---- --... -.-.--')
```

### base64混合编码

```python
from base64 import *
import random


def baseRandomEncode(s, depth=3):
    for i in xrange(depth):
        s = random.choice([b64encode, b32encode, b16encode])(s)
    return s


print baseRandomEncode('hello world!')  # test
```

### base64混合解码

```python
# by https://findneo.github.io/
from base64 import *
import re


res = []
# repattern is a self-defining item.
# In CTF games,flag often comes as a printable string containing  '{' and '}'.
repattern = "[ -~]*{[ -~]*}[ -~]*|[ -~]*}[ -~]*{[ -~]*"


def basefuzzDecode(s):
    global res
    for f in [b64decode, b32decode, b16decode]:
        try:
            t = f(s)
            if re.match(repattern, t):
                res.append(t)
                return 0
            else:
                basefuzzDecode(t)
        except:
            pass
    return res


print basefuzzDecode(baseRandomEncode('flag{hello ctf!}'))  # test
```



