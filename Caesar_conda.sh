conda install -c conda-forge -c bioconda parallel-fastq-dump
conda uninstall ***
#conda安装prokka
conda create -n prokka                          #创建名为prokka的环境
conda activate prokka                           #激活prokka环境
conda install -c bioconda prokka                #安装prokka
conda deactivate                                #退出环境
#经历上述步骤理论上可以安装好prokka，并使用。但在实际使用时发现prokka内置的blastp版本不兼容，此时可按下述步骤解决。
conda activate prokka
conda update -c conda-forge -c bioconda blast prokka

#conda不能直接修改环境名，可以通过如下命令来实现
conda create --name hamburger --clone prokka    #克隆prokka环境并将其命名为hamburger
conda remove --name prokka --all                #移除prokka环境下的所有内容

pydoc modules                                   #显示当前环境下的python模块

#.condarc配置
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