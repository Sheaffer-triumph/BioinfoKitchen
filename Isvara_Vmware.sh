#虚拟机配置及远程使用配置

#先下载需要的Linux系统镜像，这里以ubuntu为例。下载地址：https://ubuntu.com/download/desktop
#下载安装Vmware。下载地址：https://www.vmware.com/hk/products/workstation-player.html

#使用Vmware创建虚拟机，选择已下载的iso文件作为安装程序光盘镜像文件，安装虚拟机系统。
#自定义硬件，主要是内存、硬盘、CPU等配置，根据自己的需要进行配置。

#启动虚拟机，选择语言和地区

#在虚拟机终端安装SSH
sudo apt-get install openssh-server

#在设置-网络-查看网络设置中查询虚拟机的IP地址:192.168.23.128
#在Xshell中新建会话，输入虚拟机的IP地址，端口号默认22，用户名和密码为虚拟机系统的用户名和密码
#下面的操作都在Xshell中进行，也可在虚拟机终端中进行

#更新Vim
sudo apt-get remove vim-common
sudo apt-get install vim
#安装Git、Wget等工具
sudo apt-get install -y git wget

#中英文修改
sudo sed -i "s/zh_CN/en_US/g" /etc/default/locale #必须要加sudo，否则无法修改

#其他软件自行安装conda，下载地址：https://docs.conda.io/projects/miniconda/en/latest/
#安装好conda后，可以进一步安装mamba，以加快conda的速度
conda install -c conda-forge mamba #这一步要确认没有激活环境，或者是在base环境下进行