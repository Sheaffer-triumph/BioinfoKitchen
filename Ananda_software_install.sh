#下载安装软件时，先查找与此软件有关的文章，找到软件的官方网站，根据网站上的指引进行安装，如网站上提供了conda安装方式，优先使用conda安装

#mamba
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
sh Miniforge3-$(uname)-$(uname -m).sh -b -p /data/work/software/miniforge3

#bwa
git clone https://github.com/lh3/bwa.git
cd bwa
make

#SOAPnuke
git clone https://github.com/BGI-flexlab/SOAPnuke.git
cd SOAPnuke
make

#seqkit
mamba install -y -c conda-forge -c bioconda seqkit

#fastp
mamba install -y -c bioconda fastp

#checkv
mamba create -n checkv
mamba activate checkv
mamba install -y -c conda-forge -c bioconda checkv
wget https://portal.nersc.gov/CheckV/checkv-db-v1.5.tar.gz
tar zxvf checkv-db-v1.5.tar.gz
cd checkv-db/genome_db
diamond makedb --in checkv_reps.faa --db checkv_reps

#prodigal
git clone https://github.com/hyattpd/Prodigal
cd Prodigal
make install INSTALLDIR=/where/i/want/prodigal/

#blast
#如果有安装quast，可以不用安装这个
wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.16.0+-x64-linux.tar.gz
tar zxvf ncbi-blast-2.16.0+-x64-linux.tar.gz

#hmmer
#如果有安装checkv，可以不用安装这个
wget http://eddylab.org/software/hmmer/hmmer-3.4.tar.gz
tar zxf hmmer-3.4.tar.gz
cd hmmer-3.4
./configure --prefix /path/to/hmmer
make
make check
make install

#seqtk
git clone https://github.com/lh3/seqtk.git
cd seqtk
make

#SPAdes
mamba install -y -c conda-forge -c bioconda spades #也可以从源码进行编译安装，尝试时发现存在一些问题需要解决，所以这里直接用conda安装

#Quast
mamba create -n quast -y -c conda-forge -c bioconda quast

#seqret
mamba install -y -c conda-forge -c bioconda emboss

#bowtie2
mamba install -y -c bioconda bowtie2

#samtools
wget https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2
tar -xjf samtools-1.21.tar.bz2
cd samtools-1.21
./configure --prefix=/where/to/install
make
make install

#bedtools
wget https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz
tar -zxvf bedtools-2.31.1.tar.gz

#prokka
mamba install -y -c conda-forge -c bioconda prokka

#pharokka
mamba create -n pharokka
mamba install -y -c bioconda pharokka
install_databases.py -o path/to/databse_dir

#bakta
mamba create -n batka
mamba install -y -c conda-forge -c bioconda bakta
wget https://zenodo.org/record/14916843/files/db-light.tar.xz
bakta_db install -i db-light.tar.xz

#megahit
mamba install -y -c bioconda megahit

#deepvirfinder
mamba create --name dvf
mamba activate dvf
mamba install -y -c conda-forge -c bioconda seqkit python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py=2.10.0
git clone https://github.com/jessieren/DeepVirFinder
cd DeepVirFinder

#virsorter2
mamba create -n vs2 -c conda-forge -c bioconda virsorter=2
mamba activate vs2
wget https://osf.io/v46sc/download
tar -xzf db.tgz
virsorter config --init-source --db-dir=./db

#genomad
mamba create -n genomad -c conda-forge -c bioconda genomad
mamba activate genomad
genomad download-database ./

#vibrant
mamba create -n vibrant
mamba activate vibrant
mamba install -y -c conda-forge -c bioconda python=3.5 prodigal hmmer
pip install biopython pandas matplotlib "seaborn>=0.9.0" "numpy>=1.17.0" "scikit-learn==0.21.3"
mamba install -y -c bioconda vibrant
download-db.sh

#iphop
mamba create -n iphop -y python=3.8
mamba activate iphop
mamba install -y -c conda-forge -c bioconda iphop
wget https://portal.nersc.gov/cfs/m342/iphop/db/iPHoP.latest_rw.tar.gz
tar zxvf iPHoP.latest_rw.tar.gz

#mafft
mamba install -y -c conda-forge mafft

#iqtree
mamba install -y -c bioconda iqtree

#vcontact3
mamba create -n vcontact3
mamba activate vcontact3
mamba install -y -c bioconda vcontact3
vcontact3 prepare_databases --get-version "latest" --set-location /path/to/download/location

#phold
mamba create -n phold -y -c conda-forge -c bioconda phold pytorch=*=cuda* #这个命令运行时，需要存在gpu和cuda
phold install -d /path/to/download                                        #默认路径为/software/miniforge3/envs/phold/lib/python3.11/site-packages/phold/database
nvidia-smi  #获得cuda版本
mamba install -y -c conda-forge -c bioconda -c pytorch -c nvidia phold pytorch pytorch-cuda=12.4 #如果没有安装时系统没有gpu和cuda，需要指定cuda版本

#phabox2
mamba create -n phabox phabox=2.1.10 -c conda-forge -c bioconda -y
mamba activate phabox
git clone https://github.com/KennthShang/PhaBOX.git
cd PhaBOX
python -m pip install .
cd ..
rm -rf PhaBOX
wget https://github.com/KennthShang/PhaBOX/releases/download/v2/phabox_db_v2.zip
unzip phabox_db_v2.zip > /dev/null

#metaphlan4
mamab create --name metaphlan -c conda-forge -c bioconda python=3.7 metaphlan
metaphlan --install --index mpa_vJun23_CHOCOPhlAnSGB_202403 --bowtie2db ./

#