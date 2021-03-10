---
mathjax: true
title: 收集整理一个人所有的微博
date: 2018-03-09 00:01:39
---

> 项目地址在  [Github](https://github.com/findneo/scripts/tree/master/attaches/tk%E6%95%99%E4%B8%BB%E8%AF%AD%E5%BD%95) 

人生活在社区里，对一个常使用微博的人来说，微博记录和反映了他在一段时间内所接触的信息，思考的问题和表达的观点，是值得研究的。如果这个研究对象是一个优秀的人，这里面的价值可能比想象要大。

很显然，要做成`收集整理一个人所有的微博` 这件事，首先是收集，其次是整理。

收集主要想到有三种方式：

- 找现成工具（无趣，暂不考虑）。
- 在`https://m.weibo.cn/u/14015127xxx` 页面一直按`END` 键，然后页面会不断异步发送请求以增加页面内容，直到全部内容都被获取。
- 可以看到第二种方法中的请求是向`https://m.weibo.cn/api/container/getIndex?type=uid&value=1401527xxx&containerid=1076031401527xxx&page=1` 发送GET请求，只需迭代page的参数即可得到所有数据。

### 方法二实践

用如下简单脚本模拟按键行为，泡杯茶观察成果。

```python
import win32api
import time
print time.asctime()
cnt=0
while 1:
	cnt+=1
	win32api.keybd_event(35, 0, 0, 0) #35 stands for "END" key; 0 means hold down
 	win32api.keybd_event(35, 0, 1, 0) # 1 means hold up 
	print cnt,
	time.sleep(2)
print time.asctime()
```

发现按了几十下页面就开始不变化了，观察请求发现都是发给`page=50`的，想必是做了限制，最多获取50条记录，暂告失败。

### 方法三实践

要用这个方法首先最好知道总共有多少page，用二分法手动测，很快就能发现目标用户共有1542个page的记录，然后写个脚本dump下这些响应，保存成json文件，以供后面处理即可。

```python
from requests import * 
from time import *
import json
print asctime()
url="https://m.weibo.cn/api/container/getIndex?type=uid&value=1401527xxx&containerid=1076031401527xxx&page="
for i in range(1543,1,-1):
	u=url+str(i)
	f=open("result/%d.json"%i,'w+')
	f.write(get(u).content)
	f.close()
	sleep(2)
	if i%50==0:
		sleep(3)
print asctime()
```

### 处理json

分析响应结构，提取关键信息，构造文件汇总即可。代码见  [GitHub](https://github.com/findneo/TKposts/blob/master/parse_json.py) 。

```python
#coding:utf8
# Github 项目已删，成果暂存 https://findneo.github.io/p/tkposts.html
import json
import re

def parse_cards_to_html(data_cards):
	"""
	微博API
	(https://m.weibo.cn/api/container/getIndex?type=uid&value=1401527553&containerid=1076031401527553&page=1)
	返回的一个字典，形如
	{	ok: 1,
	data: 
	{	cardlistInfo: {...},
		cards: 
		[	{	card_type: 9,	
				itemid: foo,	
				scheme: post链接,
				mblog: {created_at: post发表时间,	...,
						text: post内容,		...,
						retweeted_status: {created_at: repost发表时间,...,text: repost内容,...,}
						},
				show_type: 0
			},
			{...},...
		],
		showAppTips: 0,
		scheme: foo
	}
}
	本函数的功能是将cards中每一个表示post的card里的时间和内容，以及repost的时间和内容(如果有的话)，提取出来，
	构造成HTML语句。
	"""
	ret=""
	for card in data_cards:
		if card["card_type"]==9: 
			# card_type==9 说明当前card是一个post
			is_repost=0
			post=card["mblog"] 
			post_time=post["created_at"]
			post_text=post["text"]
			ret0="<p><code><br />%s</code><br />%s</p>"%(post_time,post_text)
			if "retweeted_status" in post.keys():
				# 当前card中有retweeted_status键说明这是一个repost
				is_repost=1
				repost=post["retweeted_status"]
				repost_time=repost["created_at"]
				repost_text=repost["text"]
				ret1="\n\t<blockquote><p><code>%s</code><br />%s</p></blockquote>"%(repost_time,repost_text)
			ret=ret+ret0+ret1 if is_repost else ret+ret0
			ret=ret+"<hr />\n"
	return ret


def comment_img_in_html(file_name):
	"""
	因为教主post中时有图片，15000+条post里的图片数量相当可观（而且很多加载不出来），
	为了提高加载速度，这个函数将成品中的img标签全部注释掉。
	"""
	with open(file_name) as old_f,open("noimg_%s"%file_name,"w+") as new_f:
		for line in old_f.readlines():
			res=re.sub('(<img.*?>)',r"<!--\1-->",line)
			new_f.write(res)

def main():
	with open("tkposts.html","w+") as f:
		head='<html><head><style type="text/css">html{background:#f2f2f2;font-size:16px;font-family:Monaco}</style><title>TK POSTS</title></head><body>\n'
		f.write(head.encode('utf8'))
		for i in xrange(1,1543):
			data = json.load(open("%d.json"%i))
			if data["ok"]!=1:
				print "%d.json no data"%i
				continue
			msg_list=data["data"]["cards"]
			msg_html=parse_cards_to_html(msg_list)
			f.write(msg_html.encode('utf8'))
		tail="</body></html>"
		f.write(tail.encode('utf8'))
	comment_img_in_html("tkposts.html")

if __name__ == '__main__':
	"""
	截至 2018/3/8 下午一时许，教主在新浪微博上共发表约13831条状态，
	其中约6157条是转发自己或其他人的状态并评论。
	第一条发布在2010-05-21，内容是
	“刚看到的：2007年德国《自然科学》杂志的一篇文章指出，
	最近感染过弓形虫的女性怀孕生男孩的概率为60.8%。也就是说，
	感染弓形虫有助于生儿子——不过，不知道是需要在感染状态才行，还是治好了也行。 ”，
	可以看到风格很早就形成了，幽默感，批判性，科学性具存，这就是让人乐于追随学习的地方。
	"""
	main()
```

### 收获

- 了解了正则表达式的`backreference`和`lazy mode` 。
- 使用 `json.load(file)` 将json文件转换成字典。
- 数据编码问题可能导致写文件报错，可用`f.write(data.encode('utf8'))` 。
- 用`with open("f1") as f1,open("f2") as f2:` 打开多个文件。
- 每一个人作为数字公民的部分可能最后并不能留下太多痕迹，而且这些痕迹可能非常脆弱。当然，话说回来，这同线下生活也是相似的。

