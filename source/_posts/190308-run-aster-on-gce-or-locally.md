---
title: 使用谷歌云进行深度学习训练，以aster为例
date: 2019-03-08 16:33:07
---

<!-- 光阴似箭，我也做起了毕业设计。随波逐流，我也玩起了深度学习。-->

深度学习需要较强的计算能力，在网络上找了一圈，列出一些可用的方案。

- [极客云](https://www.jikecloud.net)
- [谷歌云](https://console.cloud.google.com/freetrial/signup/tos) 。提供一年免费试用，但需要外币信用卡。
- 谷歌的[Colaboratory](https://www.138vps.com/jc/1325.html) 
- [厦大HPC](https://net.xmu.edu.cn/19/47/c17463a334151/page.htm) 
- [淘宝西电机房等](https://item.taobao.com/item.htm?id=572068150187) 
- [百度深度学习平台](https://cloud.baidu.com/product/bdl.html) 
- [AWS](https://amazonaws-china.com/cn/free/)
- [DeepBrain Chain](https://www.deepbrainchain.org/)
- 美团云 售罄
- [滴滴云](https://blog.csdn.net/sinat_36256646/article/details/80745792)
- [华为云](https://www.huaweicloud.com/product/hmi.html)
- 阿里云
- 参考文章
  - [机器学习深度学习云GPU资源与对比](https://blog.csdn.net/cccat6/article/details/79057746)
  - [有没有云端的深度学习计算服务？](https://www.zhihu.com/question/51362855)  

# 基本环境

在谷歌云上搭建起 **Ubuntu16.04 + Python3.5 + tensorflow-gpu-1.4 + CUDA v8 + cuDNN v6** 的环境。

## 申请试用谷歌云

地址可随意填，记录两个。

`台中市大甲区大甲里 邮编：43749` 

`California(加利福尼亚省) Adelanto(阿德兰托市) 邮编[ADELANTO CA 92301]` 

## 新建虚拟机

进入Google Cloud Platform -> Compute Engine -> VM 实例 ，通过“创建实例”新建一台虚拟机。

- 机器类型中选择自定义来添加GPU数量和类型。
- 需要先按提示申请升级账户才能进行上述操作。很快会有邮件反馈申请成功。
- 自定义磁盘容量，防火墙允许流量。
- 点击创建得到一台全新的云端虚拟机。

## 远程访问

- 添加静态外部IP地址。在VM实例页面，实例右侧的设置处点击查看网络详情即可。
- 在Compute Engine -> 元数据 中修改SSH 密钥。使用XHSELL或命令行工具生成密钥对后在云端按指定格式添加公钥，然后可在本地用私钥远程登陆。

## 安装Anaconda

- `wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh`

- `chmod +x Anaconda3-4.2.0-Linux-x86_64.sh`

- `./Anaconda3-4.2.0-Linux-x86_64.sh` 按提示选择，对于是否添加到PATH记得选yes。

- `source ~/.bashrc` 使conda等命令生效。

- `conda create -n tensorflow python=3.5`  建立虚拟环境。

- `source activate tensorflow` 激活环境。

- `pip install --ignore-installed --upgrade tensorflow-gpu==1.4.0` 安装tensorflow。

- `lspci -vnn | grep VGA -A 12` 查看显卡类型

  ```bash
  (tensorflow) dfindneo@gaster:~/tf/aster/c_ops$ lspci -vnn | grep VGA -A 12
  00:03.0 Non-VGA unclassified device [0000]: Red Hat, Inc. Virtio SCSI [1af4:1004]
          Subsystem: Red Hat, Inc. Virtio SCSI [1af4:0008]
          Physical Slot: 3
          Flags: bus master, fast devsel, latency 0, IRQ 11
          I/O ports at c080 [size=64]
          Memory at fd000000 (32-bit, non-prefetchable) [size=128]
          Capabilities: <access denied>
          Kernel driver in use: virtio-pci
  
  
  00:04.0 3D controller [0302]: NVIDIA Corporation GP100GL [Tesla P100 PCIe 16GB] [10de:15f8] (rev a1)
          Subsystem: NVIDIA Corporation Device [10de:118f]
          Physical Slot: 4
          Flags: fast devsel, IRQ 11
  ```


## 安装显卡驱动

  - 访问[NVIDIA官网](https://www.nvidia.com/Download/index.aspx?lang=en-us) ，选择配置。
    ![1552054146667](1552054146667.png)

  - 点击search，看到对应的版本是384.66
    ![1552054275727](1552054275727.png)

  - 安装驱动

    ```bash
    sudo add-apt-repository ppa:graphics-drivers/ppa  
    sudo apt-get update  
    sudo apt-get install nvidia-384 #此处要根据上面查询到的版本适当更改
    sudo apt-get install mesa-common-dev  
    sudo apt-get install freeglut3-dev
    sudo reboot -h now
    ```

  - 重启后可以使用`nvidia-smi` 命令查看是否安装成功。
    ![1552054400444](1552054400444.png)

## 安装CUDA8.0

- 我使用`sudo apt install nvidia-cuda-toolkit` 安装的CUDA是7.?版本的，使用`sudo apt remove nvidia-cuda*`  卸载掉了。

- 要安装CUDAv8.0，在[这个页面](https://developer.nvidia.com/cuda-80-ga2-download-archive)选择系统、架构、发行版及其版本，安装类型可选择runfile。如果是Ubuntu16.04，可直接 `wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run` ，然后 `sh  cuda_8.0.61_375.26_linux-run`  。询问是否安装驱动时应选择否，因为我们已经安装过驱动了。

- 看到提示

  ```
  Please make sure that
  -   PATH includes /usr/local/cuda-8.0/bin
  -   LD_LIBRARY_PATH includes /usr/local/cuda-8.0/lib64, or, add /usr/local/cuda-8.0/lib64 to /etc/ld.so.conf and run ldconfig as root
  ```

  于是将 `export PATH="/usr/local/cuda-8.0/bin:$PATH";export LD_LIBRARY_PATH="/usr/lib/nvidia-384:$LD_LIBRARY_PATH"` 添加到`~/.bashrc` 并source更新。将`/usr/local/cuda-8.0/lib64` 添加到文件 /etc/ld.so.conf 然后 sudo ldconfig。

- 执行 `cd ~/NVIDIA_CUDA-8.0_Samples/1_Utilities/deviceQuery && make && ./deviceQuery` 。如果输出末尾有PASS字样，表示安装成功。

- 使用 `nvcc --version` 查看版本信息。
  ![1552056076810](1552056076810.png) 

## 安装cuDNN6.0

- 登陆账号后访问 `https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v6/prod/8.0_20170307/cudnn-8.0-linux-x64-v6.0-tgz `  ，点击下载，在chrome浏览器中按CTRL+J查看真实下载链接，暂停下载，然后在shell里wget该链接即可。下载后重命名文件为`cudnn-8.0-linux-x64-v6.0.tgz` 。
- `tar xzf cudnn-8.0-linux-x64-v6.0.tgz` 
  `sudo cp cuda/include/cudnn.h /usr/local/cuda/include/` 
  `sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64/` 
  `sudo chmod a+r /usr/local/cuda/include/cudnn.h` 
  `sudo chmod a+r /usr/local/cuda/lib64/libcudnn*` 
- 安装完成
  ![1552056065910](1552056065910.png)

到此为止深度学习的基本环境已经安装完成。可以在Compute Engine -> 快照 中建立一个快照。

接下来记录想要复现和改进的模型 `aster`  的基本环境配置。

# ASTER环境

## 激活虚拟环境并安装依赖

```bash
source activate tensorflow
cd ~
sudo apt update
sudo apt install git cmake libcupti-dev build-essential protobuf-compiler unzip python-pip3
pip install --user protobuf tqdm numpy editdistance Pillow scipy matplotlib edit_distance
```

## 下载源码

```bash
mkdir tf && cd tf
git clone https://github.com/bgshih/aster.git
```

## 按照readme依次完成三步配置

①`Go to c_ops/ and run build.sh to build the custom operators` 

```bash
cd ~/tf/aster/c_ops
chmod +x build.sh
./build.sh
```

![1552093922587](1552093922587.png)

![1552092594436](1552092594436.png)

②`Execute protoc aster/protos/*.proto --python_out=. to build the protobuf files`

```bash
cd ~/tf
protoc aster/protos/*.proto --python_out=.
```

![1552092638172](1552092638172.png)

③`Add /path/to/aster to PYTHONPATH, or set this variable for every run` 

在`~/.bashrc` 末尾加两行

```
export PYTHONPATH="${PYTHONPATH}:/home/neo/tf/aster"
source activate tensorflow
```

## 下载作者提供的模型

```bash
cd ~/tf/aster/experiments/demo/
wget  https://github.com/bgshih/aster/releases/download/v1.0.1/model-demo.zip
unzip model-demo.zip
```

## 运行demo

 `python aster/demo.py` 

![1552079776694](1552079776694.png)

## 数据集下载

### cute80

- [主页](http://cs-chan.com/downloads_CUTE80_dataset.html) 
- 下载：[CUTE80_Dataset.zip](http://cs-chan.com/source/CUTE80_Dataset.zip) (44 MB) 

### ic03

[下载](http://www.iapr-tc11.org/mediawiki/index.php/ICDAR_2003_Robust_Reading_Competitions) 

### ic13

- [主页](http://dagdata.cvc.uab.es/icdar2013competition/?ch=2&com=downloads) 
- [下载](http://rrc.cvc.uab.es/?ch=2&com=downloads) （注册账号后可见）

### ic15

- [主页](http://rrc.cvc.uab.es/?ch=4) 
- [下载](http://rrc.cvc.uab.es/?ch=4&com=downloads) （注册账号后可见）
- 文件说明

***Downloads - Incidental Scene Text***
Download below the training dataset and associated ground truth information for each of the Tasks.

---

***Task 4.1: Text Localization (2015 edition)***
**Training Set** 
Training Set Images (88.5MB).- 1000 images obtained with wearable cameras

Training Set Localisation and Transcription Ground Truth (157KB).- 1000 text files with word level localisation and transcription ground truth

**Test Set**
Test Set Images (43.3MB).- 500 images obtained with wearable cameras. You can submit your results for this Task over the images of the test set through the My Methods section.

Test Set Ground Truth (244Kb). - 500 text files with text localisation bounding boxes for the images of the test set.

---

***Task 4.2: Text Segmentation (N/A)***
Not available.

---

***Task 4.3: Word Recognition (2015 edition)***
**Training Set**
Training Set Word Images, along with Transcriptions Ground truth (40.5MB).- ~4468 cut out word images corresponding to the axis oriented bounding boxes of the words are provided along with a single text file with the relative coordinates of the bounding shape within each word image. Transcription ground truth is provided in a single txt file.

**Test Set**
Test Set Word Images (21.5MB).- 2077 cut out word images corresponding to the axis oriented bounding boxes of the words are provided along with a single text file with the relative coordinates of the bounding shape within each word image. You can submit your results for this Task over the images of the test set through the My Methods section.

Test Set Ground Truth (49Kb). - A single text file with the transcriptions of the 2077 images of the test set. Each line corresponds to an image of the test set.

------

***Task 4.4: End to End (2015 edition)***
**Training Set**
Training Set Images (88.5MB).- 1000 images obtained with wearable cameras

Training Set Vocabulary (16KB).- Vocabulary of all words (words of 3 characters or longer comprising only letters) appearing in the training set

Training Set Per-image Vocabularies (504KB).- Vocabularies of 100 words per image, comprising the words appearing in the image plus distractors

Training Set Localisation and Transcription Ground Truth (157KB).- 1000 text files with word level localisation and transcription ground truth

**Test Set**
Test Set Images (43.3MB).- 500 images obtained with wearable cameras. You can submit your results for this Task over the images of the test set through the My Methods section.

Test Set Vocabulary (8KB).- Vocabulary of all words (words of 3 characters or longer comprising only letters) appearing in the test set

Test Set Per-image Vocabularies (248KB).- Vocabularies of 100 words per image, comprising the words appearing in the image plus distractors

Test Set Ground Truth (244 Kb). - 500 text files with text localisation bounding boxes for the images of the test set.

------

***Other***
 Generic Vocabulary (796 KB).- A vocabulary of about 90 k words derived from the dataset publicly available here. Please consult [1,2] for further information as well as the disclaimer in the vocabulary file itself.

### iiit5k

- [主页](http://cvit.iiit.ac.in/projects/SceneTextUnderstanding/IIIT5K.html) 
- 下载：[IIIT5K-Word_V3.0.tar.gz](http://cvit.iiit.ac.in/projects/SceneTextUnderstanding/IIIT5K-Word_V3.0.tar.gz) (106 MB) 

### svt

- [主页](http://vision.ucsd.edu/~kai/svt/)
- 下载：[Street View Text ](http://vision.ucsd.edu/~kai/svt/svt.zip)(118MB)

### synth90k

- [主页](http://www.robots.ox.ac.uk/~vgg/data/text/)
- 下载：[mjsynth.tar.gz](http://www.robots.ox.ac.uk/~vgg/data/text/mjsynth.tar.gz) ( 10 GB )，解压后约34 G，生成的 tfrecord 约16 G。

![1552092702860](1552092702860.png)

### synthtext

- [主页](http://www.robots.ox.ac.uk/~vgg/data/scenetext/)
- 下载：[SynthText.zip](http://www.robots.ox.ac.uk/~vgg/data/scenetext/SynthText.zip) 约40G

## 数据集处理

在 `~/tf/data` 目录下存放数据集文件夹，配置 `~/tf/aster/tools/creat_*.py` 中的输入输出目录，运行脚本可在数据集同目录下得到tfrecord文件。

![1552092743066](1552092743066.png)

## 训练

在`~/tf/data/`目录下存放`tfrecord`文件；

 在`~/tf/aster/experiments/` 新建`train1` 文件夹，再在其中新建`config` 和 `log` 文件夹；

在`config` 文件夹内新建`trainval.prototxt` ，内容参照`~/tf/aster/experiments/demo/config/trainval.prototxt` 。

执行训练命令后在`~/tf/aster/experiments/train1/log` 目录下生成checkpoint文件等。

train :

```bash
cd ~/tf/
python aster/train.py --exp_dir=aster/experiments/train1/ --num_clones=2 
```

![1552094702649](1552094702649.png)

eval :

```bash
cd ~/tf/
python aster/eval.py  --exp_dir=aster/experiments/train1/
```

![1552093439964](1552093439964.png)

# 其他

## 提高访问速度

如果是位于国内的服务器，可更改部分操作以提高访问速度。

### 修改Ubuntu更新源

编辑Ubuntu16.04的 `/etc/apt/source.list` 为以下内容。

```bash
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
```

### 使用ssh

`sudo apt update && sudo apt install openssh-server && sudo service ssh start` 

`sudo apt install lrzsz` 安装 lrzsz 后用`sz` / `rz` 命令进行小文件传输，大文件用sftp。

### 下载Anaconda

`wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda3-4.2.0-Linux-x86_64.sh ` 

### 修改Anaconda软件源

```bash
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ 
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --set show_channel_urls yes
```

### 修改pip源

- `mkdir -p ~/.pip && touch ~/.pip/pip.conf` 

- 修改 `~/.pip/pip.conf` 内容为

  ```bash
  [global]
  index-url = https://pypi.tuna.tsinghua.edu.cn/simple
  [install]
  trusted-host=mirrors.aliyun.com
  ```

（Windows下为 `C:\Users\USERNAME\AppData\Roaming\pip\pip.ini` ） 

## 克隆GitHub公开repo到私有

GitHub前段时间已经支持免费使用私有仓库，可以将代码仓库镜像自己的私有仓库，更方便地记录代码更改。

- sudo apt install git

- 设置git配置和远程访问

    ```bash
    git config --global user.name findneo
    git config --global user.email username@gmail.com
    ssh-keygen -t rsa -b 4096 -C "usernameo@gmail.com"
	```

- 将~/.ssh/id_rsa.pub添加到GitHub的SSH keys。

- `ssh -T git@github.com` 测试是否成功

- mirror 公开仓库 bgshih/aster 到 私有仓库 findneo/myaster

  - 在GitHub新建名为myaster的私有仓库

  - ```bash
    git clone --bare https://github.com/bgshih/aster.git
    cd aster.git
    git push -mirror https://github.com/findneo/myaster.git
    cd ..
    rm -rf aster.git
    git clone git@github.com:findneo/myaster.git
    ```

## protocol buffers

和XML/JSON/Thrift类似，优点在于简单，快，小，后向兼容，语言平台应用无关；缺点在于自解释性不够，不能表示很复杂的结构。

只要描述proto文件，就可以使用编译器protoc(支持c++/Java/Python)自动生成用于序列化、反序列化、读写对象的操作的代码。

# 感谢

最后，感谢慷慨借用信用卡的朋友。

# 参考链接

- [学姿势 - 校园金融第一站](https://www.xuezishi.net/) ——学习信用卡相关的姿势 
- [美国人信息生成，美国身份生成-世界各国身份信息、地址、信用卡生成](http://www.haoweichi.com/) 
- [CUDA 下载](https://developer.nvidia.com/cuda-toolkit-archive) 
- [cuDNN下载](https://developer.nvidia.com/cudnn) 
- [NVIDIA显卡驱动下载](https://www.nvidia.com/Download/index.aspx?lang=en-us) 
- [保姆级教程——Ubuntu16.04 Server下深度学习环境搭建：安装CUDA8.0，cuDNN6.0，Bazel0.5.4，源码编译安装TensorFlow1.4.0(GPU版)](https://www.cnblogs.com/zpcdbky/p/9757821.html)  
- [深度学习环境搭建：Tensorflow1.4.0+Ubuntu16.04+Python3.5+Cuda8.0+Cudnn6.0](https://www.cnblogs.com/pprp/p/9463974.html) 
- 论文下载：[【PAMI2018】ASTER_An Attentional Scene Text Recognizer with Flexible Rectification.pdf](http://www.vlrlab.net/admin/uploads/avatars/ASTER_An_Attentional_Scene_Text_Recognizer_with_Flexible_Rectification.pdf) 
- 代码仓库：[https://github.com/bgshih/aster](https://github.com/bgshih/aster)  
- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/) 
  - [国内Anaconda下载](https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/) 
- [国际Anaconda下载](https://repo.continuum.io/archive/) 
- [Duplicating a repository](https://help.github.com/en/articles/duplicating-a-repository) 
- [Google Protocol Buffer 的使用和原理](https://www.ibm.com/developerworks/cn/linux/l-cn-gpb/index.html) 