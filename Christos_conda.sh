#安装conda及mamba
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
#下载好后，执行安装
sh Miniforge3-Linux-x86_64.sh
#安装过程中会提示输入安装路径，写入工作路径，不要写入~目录
#安装好后，运行运行下面命令初始化conda
conda init

#conda常用命令，以下命令中的conda可以替换为mamba
conda install -c conda-forge -c bioconda parallel-fastq-dump  #在当前环境下，从指定channel安装软件
conda uninstall A                                             #在当前环境下，卸载软件A
conda create -n amita                                         #创建名为amita的环境
conda activate amita                                          #激活amita环境
conda deactivate                                              #退出当前环境；如果.bashrc里没有conda相关的内容，可以直接使用source ~/.bashrc，退出所有环境
conda update -c conda-forge -c bioconda blast prokka          #更新指定环境下的软件

#conda不能直接修改环境名，可以通过如下命令来实现
conda create --name hamburger --clone prokka                  #克隆prokka环境并将其命名为hamburger
conda remove --name prokka --all                              #移除prokka环境下的所有内容

pydoc modules                                                 #显示当前环境下的python模块

#.condarc配置，可以在~/.condarc文件中配置conda的默认channel，加速下载
channels:
  - conda-forge
  - bioconda
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/Paddle/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/fastai/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
show_channel_urls: true
ssl_verify: false

channels:
  - conda-forge
  - bioconda
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  deepmodeling: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/
