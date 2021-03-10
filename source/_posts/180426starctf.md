---
mathjax: false
title: starctf writeup
date: 2018-04-26 14:20:29
---

# Web

## simpleweb

nc 47.75.4.252 23333

```javascript
var net = require('net');

flag='fake_flag';

var server = net.createServer(function(socket) {
	socket.on('data', (data) => { 
		//m = data.toString().replace(/[\n\r]*$/, '');
		ok = true;
		arr = data.toString().split(' ');
		arr = arr.map(Number);
		if (arr.length != 5) 
			ok = false;
		arr1 = arr.slice(0);
		arr1.sort();
		for (var i=0; i<4; i++)
			if (arr1[i+1] == arr1[i] || arr[i] < 0 || arr1[i+1] > 127)
				ok = false;
		arr2 = []
		for (var i=0; i<4; i++)
			arr2.push(arr1[i] + arr1[i+1]);
		val = 0;
		for (var i=0; i<4; i++)
			val = val * 0x100 + arr2[i];
		if (val != 0x23332333)
			ok = false;
		if (ok)
			socket.write(flag+'\n');
		else
			socket.write('nope\n');
	});
	//socket.write('Echo server\r\n');
	//socket.pipe(socket);
});

HOST = '0.0.0.0'
PORT = 23333

server.listen(PORT, HOST);

```

本地爆破出符合程序判断的数字串，然后使用socket提交：

```python
# understand JavaScript Code
# var arr = [22,12,3,43,56,47,4];
# arr.sort();
# console.log(arr);//[12, 22, 3, 4, 43, 47, 56] 
# console.log(arr.slice(0));//[12, 22, 3, 4, 43, 47, 56]
u=128
def aLSSb(a,b):
	return str(a)<str(b)
for i0 in xrange(0x00,u):
	for i1 in xrange(0x00,u):
		if aLSSb(i0,i1) and i0+i1 == 0x23:
			for i2 in xrange(0x00,u):
				if aLSSb(i1,i2) and i1+i2==0x33:
					for i3 in xrange(0x00,u):
						if aLSSb(i2,i3) and i2+i3==0x23:
							for i4 in xrange(0x00,u):
								if aLSSb(i3,i4) and i3+i4==0x33:
									r=[i0,i1,i2,i3,i4]
									print r
									data_send=' '.join((map(str,r)))

#[15, 20, 31, 4, 47]

import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('47.75.4.252', 23333))
s.send(data_send)
print "send: ", data_send
print "wait for a while here..........."
buffer = []
while True:
    d = s.recv(1024)
    if d:
        buffer.append(d)
    else:
        break
data = ''.join(buffer)
print "rcev: ",data
s.close()
# *ctf{web_chal_made_by_binary_players_lol}
```

# MISC

## yafu

> nc 47.75.4.252 10004

```python
#!/usr/bin/python3

import random,sys
import socketserver
import binascii
import os
import hmac,hashlib
from hashlib import sha256
from Crypto.Util.number import isPrime
import string
from subprocess import run, PIPE, TimeoutExpired
from flag import FLAG

basedir = '/home/sixstars/*ctf/yafu/yafu-1.34'
cmd = basedir+'/yafu'
timelimit = 2

def do_init():
    url = 'https://sourceforge.net/projects/yafu/files/1.34/yafu-1.34.zip/download'
    if os.path.isfile(cmd):
        return
    os.system("wget %s -O %s/yafu-1.34.zip" % (url, basedir))
    os.system("unzip %s/yafu-1.34.zip -d %s/" % (basedir, basedir))
    os.system("chmod +x %s" % (cmd))


def do_factor(num):
    try:
        res = run(cmd, stdout=PIPE, input=('factor(%d)'%num).encode(), timeout=timelimit)
    except TimeoutExpired:
        return False
    tmp = res.stdout.decode()
    tmp = tmp[tmp.find('***factors found***\n\n')+21:].split('\n')
    for line in tmp:
        pos = line.find(' = ')
        if pos == -1:
            break
        factor = int(line[pos+3:])
        if line[0] == 'P' and not isPrime(factor):
            return True
    return False

class Task(socketserver.BaseRequestHandler):
    def proof_of_work(self):
        proof = ''.join([random.choice(string.ascii_letters+string.digits) for _ in range(20)])
        print(proof)
        digest = sha256(proof.encode('ascii')).hexdigest()
        self.request.send(str.encode("sha256(XXXX+%s) == %s\n" % (proof[4:],digest)))
        self.request.send(str.encode('Give me XXXX:'))
        x = self.request.recv(10).decode()
        x = x.strip()
        wtfpy3 = x+proof[4:]
        if len(x) != 4 or sha256(wtfpy3.encode('ascii')).hexdigest() != digest: 
            return False
        return True

    def handle(self):
        if not self.proof_of_work():
            return
        do_init()
        self.request.sendall(str.encode("No bruteforce required. Do not DOS plz >_<\n"))
        self.request.sendall(str.encode("The number to factorize: "))
        x = self.request.recv(1024)
        try:
            x = int(x, 16)
        except:
            return
        if do_factor(x):
            self.request.sendall(str.encode("What happened? Anyway your flag here: %s\n" % FLAG))
        else:
            self.request.sendall(str.encode("Bye\n"))

class ThreadedServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass

if __name__ == "__main__":
    HOST, PORT = '0.0.0.0', 10004
    print(HOST)
    print(PORT)
    server = ThreadedServer((HOST, PORT), Task)
    server.allow_reuse_address = True
    server.serve_forever()

```

### solution

```python
import socket
import re
import string
import itertools
import hashlib
def crack_sha256(data_part,hash):
    for i in itertools.product(string.ascii_letters+string.digits,repeat=4):
        if hashlib.sha256(''.join(i)+data_part).hexdigest()==hash:
            return ''.join(i).strip()

def get(s):
    buffer = []
    try:
        while True:
            d = s.recv(10)
            if d:
                buffer.append(d)
    except Exception as e:
        data = ''.join(buffer)
        return data

socket.setdefaulttimeout(2)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('47.75.4.252', 10004))
# ------------
proof_din=get(s)
print proof_din
r=re.findall("sha256\(XXXX\+([0-9a-zA-Z]{16})\) == ([0-9a-z]{64})",proof_din)
# print r
proof_part,sha_value=r[0][0],r[0][1]
# print proof_part,sha_value
proof_part_0=crack_sha256(proof_part,sha_value)
s.send(proof_part_0)
print "XXXX is %s"%proof_part_0
# ------------
print get(s)
s.send('286b7fb2af5f5d27d216771c90ac6f43a9892a690c48e4b06bcbc1cd')
print get(s)
```

### 原理

https://github.com/sixstars/starctf2018/blob/master/misc-yafu/README.md

> When yafu delete factors, it fails to update the factor type correctly. So it's possible to fool yafu if you use a smooth number which consists of many small primes. Follow the link in `solve.py` for more details.
>
> I expect someone would find it when feeding some special cases (like the smooth number as mentioned above) towards yafu. But maybe most players instead focused on the prime test. I released a hint (*yafu can be wrong*) but seems (as xdd suggested) they just turned to prime test inside yafu lol.

![1525069115392](1525069115392.png)



# 题目备份

https://github.com/sixstars/starctf2018