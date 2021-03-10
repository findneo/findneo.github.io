---
title: 拨钟问题
date: 2019-03-26 13:15:55
---

# 拨钟问题

![1553577507309](1553577507309.png)

![1553577522929](1553577522929.png)


#  解法一

全局暴力搜索

```python
import itertools
initstate=[3,3,0,2,2,2,2,1,2]
update=[
[1,2,4,5],
[1,2,3],
[2,3,5,6],
[1,4,7],
[2,4,5,6,8],
[3,6,9],
[4,5,7,8],
[7,8,9],
[5,6,8,9]
]

for i in itertools.product([0,1,2,3],repeat=9):
	initstate=[3,3,0,2,2,2,2,1,2]
	for j in range(9):
		for k in update[j]:
			initstate[k-1]+=i[j]
			initstate[k-1]%=4
	if sum(initstate)==0:
		print ' '.join([' '.join(str(m+1)*i[m]) for m in range(9) if i[m]!=0])
		break
# 4 5 8 9
```

# 解法二

局部暴力搜索

```python
import itertools
for i in itertools.product([0,1,2,3],repeat=3):
	initstate=[-1,3,3,0,2,2,2,2,1,2]
	op=[0]+list(i)+[0]*6
	op[4]=(4-(initstate[1]+op[1]+op[2])%4)%4
	op[5]=(4-(initstate[2]+op[1]+op[2]+op[3])%4)%4
	op[6]=(4-(initstate[3]+op[2]+op[3])%4)%4
	op[7]=(4-(initstate[4]+op[1]+op[4]+op[5])%4)%4
	op[9]=(4-(initstate[6]+op[3]+op[5]+op[6])%4)%4 
	op[8]=(4-(initstate[8]+op[5]+op[7]+op[9])%4)%4
	sum=0
	sum+=(initstate[1]+op[1]+op[2]+op[4])%4
	sum+=(initstate[2]+op[1]+op[2]+op[3]+op[5])%4
	sum+=(initstate[3]+op[2]+op[3]+op[6])%4
	sum+=(initstate[4]+op[1]+op[4]+op[5]+op[7])%4
	sum+=(initstate[5]+op[1]+op[3]+op[5]+op[7]+op[9])%4
	sum+=(initstate[6]+op[3]+op[5]+op[6]+op[9])%4
	sum+=(initstate[7]+op[4]+op[7]+op[8])%4
	sum+=(initstate[8]+op[5]+op[7]+op[8]+op[9])%4
	sum+=(initstate[9]+op[6]+op[8]+op[9])%4
	if sum==0:
		print ' '.join([' '.join(str(m)*op[m]) for m in range(10) if op[m]!=0])
		break
# 4 5 8 9
```

# 其它

函数传参传值还是引用的问题，还是需要注意的。

```python
foo=0
bar=[0]
painting=[[0]]
paintingdict={0:[0]}
print foo,bar,painting
def guess(foo2,bar2,painting2,paintingdict2):
	foo2=1
	bar2[0]=1
	painting2[0][0]=1
	paintingdict2[0]=[1]
guess(foo,bar,painting,paintingdict)

print foo,bar,painting,paintingdict

# 输出结果：
# 0 [0] [[0]]
# 0 [1] [[1]] {0: [1]}
```

# 参考

https://blog.csdn.net/C20191618/article/details/69388416 