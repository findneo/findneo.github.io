---
title: 在win10家庭版上的Docker中使用Kali
mathjax: true
date: 2018-05-12 00:05:29
---

**全程需保证保证网络畅通**

# 安装Docker

- 从 https://docs.docker.com/toolbox/toolbox_install_windows/ 下载DockerToolbox.exe 。关闭其他程序，右键管理员运行，选项可全部保持默认（如果电脑上未安装Git，在安装过程中需注意勾选）。

- 桌面可看到名为``Docker Quickstart Terminal`的快捷方式，右键管理员运行，**等待直到**出现**可交互命令行**。

## 修改默认存储位置到非系统盘

- 在上一步出现的**可交互命令行界面**运行 `docker-machine.exe stop default` 关闭基础虚拟机。

- 运行桌面上名为`Oracle VM VirtualBox` 的快捷方式。
  - 在`管理->虚拟介质管理器【CTRL+D】` 中复制`disk.vmdk` 到D盘 ，注意最好保持vmdk 格式。
  - 选中`default` 虚拟机，右键`设置->存储->控制器：SATA->添加虚拟硬盘` 中添加D盘的`disk.vmdk` 。删除C盘的`disk.vmdk` 。保存设置。

- 回到 命令行，运行`docker-machine.exe start default` 启动基础虚拟机。

# 下载Kali基础镜像并配置容器

- （**以下命令均在上述命令行中输入**）

- `docker pull  kalilinux/kali-linux-docker `  拉取Kali基础镜像，约700+M。

- `docker run -it --name kali kalilinux/kali-linux-docker /bin/bash` 基于该镜像启动一个容器并命名为`kali` 。

- `apt update && apt full-upgrade && apt auto-remove && apt-autoclean ` 安装工具前的准备工作。此处是**一小段等待**。

- `apt install kali-linux-all ` 安装Kali的工具包。此处是**漫长等待**。 如果报错按错误提示操作即可。

## 配置msf数据库

  - `service postgresql start `

  - `su postgres`

  - `createuser username -P` 设置数据库用户账户密码

  - `createdb --owner=username dbname && exit`  创建数据库

  - `cd /usr/share/metasploit-framework/config && cp database.yml.example database.yml && vi database.yml`  填好username,pass,dbname  。

  - `msfconsole` 
    - `db_status`  查看数据库连接状态
    -  `db_connect username:password@localhost/dbname `  //若没成功连接数据库，则手动连接


# 常用基本操作

## 数据管理

### 文件传输

- `docker cp  kali:/root/testfile testfile` 
- `docker cp test kali:/root/test` 

### 数据卷

- `docker volume create my-vol` 
- ` docker volume ls`
- `docker run --mount source=my-vol,target=/webapp ...` 
- 对应目录是default虚拟机的`/var/lib/docker/volumes/my-vol` ，并不能直接操作，理论上应该先在虚拟机和主机间共享文件夹，然后再使用数据卷。

### 挂载主机目录

- `docker run --mount type=bind,source=/src/webapp,target=/opt/webapp ...`  

## 对镜像(image)的操作

- `docker search kali` 在线搜索镜像。

- `docker pull kalilinux/kali-linux-docker `  下载镜像。

- `docker image ls [-a]` 列出本地镜像。

- `docker image rm kalilinux/kali-linux-docker `   删除本地镜像。

- `docker commit -a findneo -m "kali-all-tools installed;msfdb configured" kali findneo/kali:v1` 生成镜像

- 保存与加载本地镜像

    ```bash
    $ docker image ls
    REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
    findneo/kali                  v1                  16b856910432        About an hour ago   13.2GB
    kalilinux/kali-linux-docker   latest              b8fe82f15421        2 months ago        749MB
    
    docker save -o D:\findneoandOriginKali.tar findneo/kali:v1 kalilinux/kali-linux-docker
    docker load -i D:\findneoandOriginKali.tar
    ```


## 对容器(container)的操作

- `docker run --rm kalilinux/kali-linux-docker /bin/echo "hi"`  
  以`kalilinux/kali-linux-docker` 镜像为基础启动一个新的容器，执行命令`/bin/echo "hi"` ，退出、终止并删除容器。
- `docker run -it --name kali kalilinux/kali-linux-docker /bin/bash`  
  以`kalilinux/kali-linux-docker` 镜像为基础启动一个新的容器，命名为`kali` ，提供bash终端 。执行`exit` 将退出、终止但保留容器。

- `docker start kali `   启动名为`kali` 的容器并在后台运行，**相当于开机** 。
  `docker exec -it kali bash`   进入`kali` 的bash终端。执行`exit` 将退出但不终止容器。
  `docker stop kali`    终止名为`kali` 的容器，**相当于关机** 。

- `docker container ls -a` 列出所有容器，不带`-a` 参数仅列出当前运行中的容器。
  `docker container rm kali` 删除指定容器。若容器正在运行需加`--force` 参数。

- `docker container export -o D:\mykaliv1.tar kali` 导出容器，**相当于拍摄快照** 。
  `docker import D:\mykaliv1.tar- test/kali:v1  `  导入容器，**相当于还原快照** 。

# 扩容

- 参考：https://stackoverflow.com/questions/11659005/how-to-resize-a-virtualbox-vmdk-file 

## 扩容磁盘


```bash
关闭容器和default虚拟机
docker stop kali
docker-machine srop
扩容磁盘
cd C:\Program Files\Oracle\VirtualBox
VBoxManage clonehd "D:\vmac\dockerMachine\disk.vmdk" "D:\vmac\dockerMachine\cloned.vdi" --format vdi
VBoxManage modifyhd "D:\vmac\dockerMachine\cloned.vdi" --resize 204800
VBoxManage clonehd "D:\vmac\dockerMachine\cloned.vdi" "D:\vmac\dockerMachine\resized.vmdk" --format vmdk
```

## 调整分区

- 从 https://gparted.sourceforge.io/download.php 下载gparted-live-0.31.0-1-amd64.iso。
- 在default虚拟机设置面板的`存储->控制器->添加虚拟光驱` 中将gparted-live-0.31.0-1-amd64.iso 加到SATA0端口，使其开机第一个启动。移除原有磁盘，将扩容后的磁盘放在原来磁盘的位置。
- `启动->无界面启动`  ，使用GParted 调整磁盘空间。Apply。双击桌面`EXIT` ，选择shutdown退出，按右CTRL键使焦点回到主机
  ![1526135602464](1526135602464.png)
- 恢复虚拟机存储设置至下入状态
  ![1526142367100](1526142367100.png)

## 查看调整分区是否成功

- `docker-machine start default` 

- `docker-machine ssh default ` 进入default虚拟机的shell，去看看分区扩容是否成功

- 查看并记录当前状态
  - `fdisk -l`
  - `df -h`
  - `cat /etc/fstab`   (/boot/grub/menu.lst文件没找到)

- 对比前后状态可以看到已经成功了
  ![1526100195018](1526100195018.png)
  ![1526137337445](1526137337445.png)

## Partition table entries are not in disk order

`fdisk -l` 出现`Partition table entries are not in disk order` 问题。字面上看是分区表和硬盘分区不一致。查资料据说不影响，不过还是试着解决下。

- 参考链接
  - https://ubuntuforums.org/showthread.php?t=1252662
  - https://blog.csdn.net/wujiangguizhen/article/details/22857667
- 操作步骤
  - `docker-machine ssh default`
  - `sudo -i` 切换到root权限  (https://stackoverflow.com/questions/32646952/docker-machine-boot2docker-root-password)
  - `fdisk /dev/sda`
    - `x` 进入专家模式
    - `f` fix partition order
    - `w` 写入变化
  - ![1526137422738](1526137422738.png)
  - 解决后分区状态如下。对比上图可以发现sda1和sda2互换了。
    ![1526142973113](1526142973113.png)
    

# 图形界面

参考链接：

- [【微信分享】林帆：Docker运行GUI软件的方法](https://mp.weixin.qq.com/s?__biz=MzI4MzAwNTQ3NQ==&mid=209866190&idx=1&sn=0ee75509eb2fab454009125e0a8c6437) 
- [shell中获取本机ip地址](http://www.cnblogs.com/starspace/archive/2009/02/13/1390062.html) 
- [How can I export DISPLAY from a Linux terminal to a Windows PC?](https://superuser.com/questions/325630/how-can-i-export-display-from-a-linux-terminal-to-a-windows-pc) 
- [docker学习8--同主机下容器通信](https://blog.csdn.net/dream_broken/article/details/52414560) 
- [What is the $DISPLAY environment variable?](https://askubuntu.com/questions/432255/what-is-the-display-environment-variable) 
- [Docker for GUI-based environments?](https://stackoverflow.com/questions/24095968/docker-for-gui-based-environments) 
- [Can you run GUI apps in a docker container?](https://stackoverflow.com/questions/16296753/can-you-run-gui-apps-in-a-docker-container)

大致理解Docker网络结构和XX转发流程

![1526182398234](1526182398234.png)

启动一个新配制参数的容器，将主机上X11的unix套接字共享到kali容器里面 

```bash
docker run -it  -v /etc/localtime:/etc/localtime:ro -v /tmp/.X11-unix:/tmp/.X11-unix  -e DISPLAY="192.168.233.101:0.0"  -e GDK_SCALE  -e GDK_DPI_SCALE --name gkali findneo/kali:v1 bash
```

在`Setting->Configuration` 里取消MobaXterm的X server的访问控制。

![1526182806764](1526182806764.png)

启动容器即可使用GUI。可以使用`xcal,xclock,xedit,xmessage,xeyes,xmessage` 等等小程序测试X11转发是否正常工作（`ls /usr/bin/x* ` 可以看到更多）

![1526182630443](1526182630443.png)

## SSH 连入

从容器访问主机可以直接使用主机的IP地址（`ipconfig`），从主机访问容器实际上是访问`boot2docker` 虚拟机的IP （`docker-machine.exe ssh default "/sbin/ifconfig eth1|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'"`）和启动容器时配置的转发端口 （`docker run -p 12345:22 ...` ）。

```bash
所以理论上这样启动一个容器既可以SSH连入，又可以使用图形界面。
docker run -it  -v /etc/localtime:/etc/localtime:ro -v /tmp/.X11-unix:/tmp/.X11-unix  -e DISPLAY="192.168.233.101:0.0"  -e GDK_SCALE  -e GDK_DPI_SCALE -p 52023:22 --name kali findneo/kali:v2
```

# 参考链接

  - <https://yeasy.gitbooks.io/docker_practice/content/>  
  - <https://blogs.technet.microsoft.com/positivesecurity/2017/09/01/setting-up-kali-linux-in-docker-on-windows-10/>   
  - https://stackoverflow.com/questions/32646952/docker-machine-boot2docker-root-password 
  - https://ubuntuforums.org/showthread.php?t=1252662
- https://blog.csdn.net/wujiangguizhen/article/details/22857667 
- https://stackoverflow.com/questions/11659005/how-to-resize-a-virtualbox-vmdk-file 





> 容器不应该是长久性的东西，要保持容器的可抛弃性，有问题就应该rm掉，数据保存在容器外，然后直接run新的容器。 ——http://www.talkwithtrend.com/Question/233635 

看到上面这个，感觉自己的用法可能有点奇怪：）





