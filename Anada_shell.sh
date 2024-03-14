#连接登录集群
ssh lizhuoran1@192.168.61.7 -p 22
ssh cngb-software-0-1   #切换节点，登陆后为login节点，不能在此节点运行；操作运行需在xcompute节点；下载需在下载节点。
ssh cngb-xcompute-0-10

#vim基本用法
vim A               #使用vim语言查看文件A，若无该文件，则生成
                    #v切换成visual模式，此时可以移动光标选中文本，对选中的文本按y键复制，之后会自动转成normal模式，此时可移动光标，在光标处按p键粘贴
vim ~/.bashrc       #名字中带.的文件一般是与环境变量有关的文件，不能随意删除或移动
source ~/.bashrc    #修改.bashrc文件后，需要使用source命令重新加载.bashrc文件才能应用修改
alias lzr1='cd /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1'    #使用lzr1代替cd /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1命令；其中lzr1不能出现空格
export TERMINFO=/usr/share/terminfo                             #在使用clear清屏时报错：terminals database is inaccessible，可使用该命令解决，原因未知

ls -lthr                    #按写入内容的时间从前往后排列文件
ls -al                      #显示所有文件，包括隐藏文件
ll -a                       #同上

git clone https://github.com/XiaofangJ/PhaseFinder #从github上下载PhaseFinder软件

watch -n 1 -d 'A command'    #每隔1秒执行一次A command，-d表示高亮输出发生变化的地方

realpath A                  #显示文件A的绝对路径

md5sum A                    #显示A文件的md5值

history                     #显示历史命令

head -n 20 A                #显示A文件前20行，如不加数字，默认10行
tail -n 20 A                #显示A文件最后20行，如不加数字，默认10行

nl -n ln A > B              #给A文件的每一行加上行号，输出到B文件中
                            #nl命令的-n选项表示行号的格式，ln表示行号左对齐，可以换成rn表示行号右对齐，rz表示行号右对齐且前面补0
\\

#后台运行命令
command 1>std 2>err &       #将command的正常输出重定向到out文件中，报错信息输出到err文件中。如果command里已经有了重定向，那么这里的重定向会覆盖command里的重定向，则需要去掉1>std，否则其输出会直接输出到std文件中
nohup command &             #在后台执行命令，要时刻注意内存和线程的使用情况，报错输出到nohup.out文件中
top/htop                    #查询后台
top -u lizhuoran1           #查询该用户的jobs，top下按q可以退出
jobs                        #查询后台运行的任务状态
jobs -l                     #查询后台运行的任务状态，显示jobsID
kill jobID                  #终止对应ID的后台任务

#命令嵌套
ll `cat list`               #将list文件中的每一行内容作为参数传递给ll命令
ll $(cat list)              #同上，二者等价
ll $(cat $(which bowtie2))  #将which bowtie2命令的输出作为参数传递给cat命令，再将cat命令的输出作为参数传递给ll命令,多重嵌套只能使用$()，不能使用``

#任务投递
qsub -cwd -q st.q -P P17Z10200N0246 -l vf=50g,num_proc=8 -binding linear:8          #普通节点，任务运行无时间限制，等待时间长
qsub -cwd -l vf=50g,num_proc=8 -P P17Z10200N0246 -binding linear:8 -q st_short.q    #short节点，有时间限制，等待时间短
                            #cwd:在投递任务时所在的目录执行任务，无cwd默认执行输出在home 
                            #设置的进程数与binding数须一致
                            #vf=10g 请求内存，内存过小与core文件的生成有关
qsub -cwd -l vf=500g,num_proc=30 -P P17Z10200N0246_super -binding linear:30 -q st_supermem.q vc95.sh #大内存节点，使用前需要申请权限http://stblc.genomics.cn/ODMS/resourceManager/resourceRequest
qstat                       #显示所有已投递的任务
qstat -j jobID              #显示详细状态
qdel id                     #终止对应ID的任务
qdel -u lizhuoran1          #删除lizhuoran1投递的所有任务
qstat | grep "Eqw" | awk '{print $3}' | while read i; do qsub -cwd -q st.q -P P17Z10200N0246 -l vf=10g,num_proc=4 -binding linear:4 ${i}*sh; done
                            #在批量投递任务时，此行命令可以查找处于Eqw的任务，并重新投递任务
qstat | grep "Eqw" | awk '{print $1}' | while read i; do qdel $i; done
                            #查找处于Eqw的任务，并删除
\\

ln -s A_absolute_path B     #创建A文件的软链接，名为B，软链接相当于快捷方式。修改软链接也会同步修改其对应的源文件，反之也是

echo a{1..100}              #输出a1 a2 a3 a4 ...... a100

awk '{print $1}' A          #提取A文件的第一列，使用默认分隔符空格符
awk -F '>' '{print $1}' A   #指定分隔符为>，分隔符也可以是字符串
awk '!a[$1]++{print}' A     #可适用于所有需要去冗余的表格
awk '{sum+=$1}'END'{print sum}'     #对一列数字进行累加并输出
awk -F[:\\t] '{if($4>=60){print ($9/$11)}else{print 0}}' A.txt #分隔符为:和\t，对A文件中的第4列进行筛选，若大于60，则输出第9列除以第11列的结果，否则输出0。其中[:\\t]表示分隔符为:或\t
awk -F '/' '{print $NF}' A  #提取A文件中每一行最后一个/后面的内容，$NF表示最后一个字段，$0表示整行，$1表示第一个字段，$NR表示行号

sed 's/aaa/bbb/' A          #以行为单位在A文件中匹配aaa，并将每一行的第一个aaa改为bbb，并输出
sed 's/aaa/bbb/g' A         #将A文件中的aaa全部改为bbb并输出，可以使用正则表达式
sed -i 's/aaa/bbb/g' A      #不输出，直接修改A文件
sed -i 's/aa./bbb/g' A      #将aa*改为bbb
sed '1d' A                  #删除A文件的第一行
sed '1,10d' A               #删除A文件的第一行到第十行
sed "s/${old}/${new}/g" A   #在使用变量时，需要使用双引号，否则变量无法被识别
#sed命令的s(替换)操作允许使用任何字符作为分隔符。通常，我们使用斜杠/作为分隔符，如s/foo/bar/g，这会将所有的foo替换为bar。但是，如果替换的文本中包含斜杠，使用斜杠作为分隔符就会变得麻烦，因为需要对每个斜杠进行转义。在这种情况下，可以选择其他的字符作为分隔符，如#、|、:等。例如，可以写成s#foo#bar#g，这和s/foo/bar/g的效果是一样的。

grep "a" A                  #在A文件中匹配含有a的每一行，grep使用时需注意正则表达
grep "0\.8" A               #在A文件中匹配含有0.8的每一行
grep "0.8" A                #.是正则表达式的一种，被视为*，即匹配含有0*8的每一行
grep "a" -A 1 A             #在A文件匹配含有a的每一行，并输出该行和下一行
grep "a" -v A               #在A文件中匹配含有a的每一行，但输出不匹配行
grep -wvf A B               #在B文件中匹配不含有A文件中任何一行的每一行,并输出，A应为B的子集，-w表示精确匹配，-v表示取反，-f表示从文件中读取内容
grep -wf A B                #在B文件中匹配含有A文件中任何一行的每一行,并输出，A应为B的子集
rg -i "a" A                 #在A文件中匹配含有a的每一行，rg是grep的替代品，速度更快，-i表示忽略大小写
rg -i "a" -A 1 A            #在A文件匹配含有a的每一行，并输出该行和下一行
rg -i "a" -v A              #在A文件中匹配含有a的每一行，但输出不匹配行
rg -wvf A B                 #在B文件中匹配不含有A文件中任何一行的每一行,并输出，A应为B的子集，-w表示精确匹配，-v表示取反，-f表示从文件中读取内容
rg -F "a" A                 #在A文件中匹配含有a的每一行，-F将a视为字符串而非正则表达式
rg -z "a" A.zip             #在A.zip文件中匹配含有a的每一行，-z表示搜索压缩文件
rg -t txt "a"               #在当前目录下的所有txt文件中匹配含有a的每一行，-t表示指定文件类型，-T表示排除文件类型
rg -l "a"                   #在当前目录下的所有文件中匹配含有a的文件名，-l表示只输出文件名，-L表示排除文件名 

paste A B                   #将A和B按行对行拼接在一起
paste <(echo $a) <(echo $b) #将变量a和b按行对行拼接在一起

find A -size 0                      #递归查找A路径下大小为0的文件
find A -maxdepth 1 -size0           #仅在A路径中查找大小为0的文件，不对子路径进行检索
find A -maxdepth 1 -size0 -delete   #仅在A路径下查找大小为0的文件，不对子路径进行检索，并将查找到的文件删除；-maxdepth应放在最前面
find -name "*a*" A                  #递归查找A路径下名字中含有a的文件
find ! -name "*a*" A                #递归查找A路径下名字中不带有a的文件
find -not -name "*a*" A             #同上 
find -name "*a*" A -exec ll {} \;   #查找每一个名字含有a的文件，并显示。ll也可换成其他command;
                                    #\;为终止
find A -name "*a*" -exec du -sh {} \;
find A -type d                      #递归查找A路径下类型为d的文件，即查找所有文件夹，配合循环命令可以实现遍历每一个文件夹
find A -type f                      #递归查找A路径下类型为f的文件，即查找所有文件
\\

xxd A                               #以16进制查看二进制文件A，可用于查看命令的源码

sort A                              #将表格A按第一列进行排序
sort A -k 2                         #将表格A按第二列进行排序
sort -t ,                           #以逗号作为分隔符，与-k联用
sort -n -t ' ' -k 5                 #将表格A按第五列进行排序，且第五列为数字，-n表示按数字排序

lfs quota -gh st_p17z10200n0246 /ldfssz1/ #查看st_p17z10200n0246在ld1盘中所占用的磁盘空间 
du -sh A                                  #查看A所占用的磁盘空间

chgrp -R st_p17z10200n0246 A        #将A路径及子路径中所有文件的属组都改为st_p17z10200n0246，比较费时，建议挂后台
chmod -R 754 A                      #将A及A下面所有的文件权限都改为754。7读写执、5读执、4只读；第一个数字是自己；第二数字是同属组其他人；第三个数字是所有人；同一类型文件，若权限不同，则颜色也会有差异，如需要更改颜色也可使用此命令

#在电脑终端使用sftp连接服务器
sftp lizhuoran1@192.168.61.7
put -R 文件夹A 文件夹B                #将电脑的A上传到集群的B
get -R 文件夹A 文件夹B                #将集群的A下载到电脑的B
#使用不同的软件连接集群，所能用的command也不一样，iterm2明显比Xshell方便，前者可以识别command中的*，能够批量下载；后者无法识别，只能传递单个文件。若确需要传递大量文件，可将其打包后再下载；也可使用Xftp传文件，其优点是交互式操作

#压缩与解压
zip -r A.zip A                      #将A文件夹压缩成A.zip格式
unzip A.zip                         #解压A文件，会直接生成原来的文件夹
gzip A                              #压缩文件A，后缀为gz，会覆盖原来的文件
gzip -d A.gz                        #适用于后缀为gz的解压缩
gunzip A.gz                         #解压后缀为gz的文件，覆盖原先的gz文件
tar zxvf A.tgz                      #在当前目录解压后缀为tgz的文件，也适用于tar.gz文件
                                    #z表示使用gzip作为解压方式；x表示解压；v显示正在处理的文件名称；f指定解压的文件
tar cvf A.tar A                     #将A文件夹打包成A.tar文件
tar cvzf A.tar.gz A                 #将A文件夹打包成A.tar.gz文件
                                    #c表示打包；v显示正在处理的文件名称；z表示使用gzip作为压缩方式；f指定打包的文件
pigz -p 4 -k -6 A                   #使用pigz进行压缩，pigz是gzip的并联版本，速度更快。pigz只能对文件进行压缩，若是文件夹需要先使用tar进行打包。
                                    #-p为线程数；-k表示保留原文件，不删除。-6为压缩等级，可选1-9，数字越大压缩效果越好，耗时越长。
\\

#拆分文件:
#用于将多条fa文件拆分成单个，以下内容无需参考，请往下看split和seqkit使用
cat test.fa | tr '\n' '\t' | sed 's/\t>/\n>/g' | sed 's/\t/\n/' | sed 's/\t//g' > test2.fa 
    #tr转换，将换行符\n转换成制表符\t（tab）；sed将\t>替换成\n>，sed处理文本是按行为单位处理，不加g则只对每一行的第一个匹配项进行操作，随后调到下一行进行匹配操作，如此
grep "$i" -A 1 A.fa > ${i}.fa
#均等拆分fasta文件，适用于序列是多行书写的情况，没有使用价值，非常耗时
for((i=1;i<=2;i++))
    do 
    a=`expr $i \* 15534` #bash不支持基础运算，需要使用一些命令进行运算，此处使用expr，在计算时要注意运算符的书写：+ - \*(防止与*混淆) / %；本行命令还可以用let实现
    head -n $a NC_003454.1.fasta | tail -n 15534 > NC_003454_${i}.fasta
done
#split命令
split -C 1M A.fasta nc_ -a 1 --numeric-suffixes=1 --additional-suffix=.fasta 
    #将A文件拆分成1M的文件，文件统一命名为前缀nc_ 以1,2,3,4...排序，文件统一后缀为.fasta
    #--numeric-suffixes= 等号后面可接任意数字，文件命名排序从此数字开始；若无此项则以英文字母排序，此项可以换成-d 效果为从0开始排序
    #-a 1 只使用1个字符(1 2 3...)进行排序，若无此项，默认为2(01 02 03...)
    #-C 1M 将文件拆分成大小为1M的文件，拆分时保留行的完整性，可以使用单位K M G T P E Z Y ；此项可换成-b，不保证行的完整性进行拆分，但拆分出来的文件大小会更接近于设置值
split -l 1 A.fasta nc_ -a 1 --numeric-suffixes=1 --additional-suffix=.fasta #-l 按行为单位拆分，此处为每行拆分成一个文件，即生成的每个文件都只有一行内容

#fasta去冗余
cd-hit-est -i A.fa -o B.fa -c 0.95 -aL 0.9 -M 16000 -T 8    
    #去冗余，-c 0.95表示相似度大于95%的序列会被去除；
    #-aL 0.9表示比对覆盖率阈值为0.9，即只有当比对覆盖了较长序列的90%或以上时，两个序列才会被认为是相似的；
    #-M 16000表示最大内存为16G
    #-T 8表示使用8个线程
    #在使用cd-hit工具时，如果处理序列的长度超过了最大序列长度。此时会有warninf提示，可能伴随着无输出。可使用git clone重新下载cd-hit，并在cdhit文件夹下重新编译安装，安装时需要指定最大序列长度，如make MAX_SEQ=1000000，此时最大序列长度为1000000
seqkit rmdup -s A.fa > B.fa
    #去冗余，-s表示按照序列的相似度进行去冗余，只有完全相同的序列才会被去冗余
\\

#系统进化树的构建
mafft --auto input.fasta > algined_tree.fasta 2>err         #将输入的蛋白质序列对齐
iqtree -s algined_tree.fasta -bb 1000 --runs 8 -T 8 --mem 50G  #runs进行独立运行的次数，每次运行都会生成一个进化树，最后选择最优的树作为结果；mem内存分配；bb迭代数，1000次耗时很长，可以先不设置迭代；T线程数

#blast比对
makeblastdb -in A.fasta -dbtype prot -parse_seqids -out index #-in：建库的文件 -dbtype：数据库类型，prot是蛋白质，nucl是核酸，生成一系列以index为前缀的文件，用于建库的序列应写在同一个文件里
blastp -query MF19343.faa -db alphafold_db.fasta -outfmt 6 -evalue 1e-5 -out result.txt #evalue值一般设置1e-5
blastn -query CPB1015.fa -db ./index -outfmt "6 qseqid sseqid qcovs qcovhsp pident length mismatch gapopen qstart qend sstart send evalue bitscore" -evalue 1e-5 -out ./CPB1015_blastn.txt #在指定路径查找以index为前缀的文件作为数据库
#blast结果解读:
#qseqid:查询序列的ID sseqid:匹配的数据库序列的ID qcovs:查询序列与匹配序列的匹配长度占查询序列的百分比 qcovhsp:查询序列与匹配序列的匹配长度占匹配序列的百分比 pident:匹配的百分比 length:匹配的长度 mismatch:不匹配的长度 gapopen:间隙的长度 qstart:查询序列的起始位置 qend:查询序列的终止位置 sstart:数据库序列的起始位置 send:数据库序列的终止位置 evalue:随机期望值，可近似理解为错误率 bitscore:打分

#checkv流程
checkv end_to_end input.fa ./checkv -d /hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/miniconda_20211218/miniconda/envs/checkv/checkv-db-v1.4 -t 8

#prokka注释流程
prokka --prefix ID --locustag ID --addgenes --addmrna --plasmid Plasmid --gcode 11 --outdir A --mincontiglen 100 A.fasta 

#meme流程
mpirun -np 4 --mca btl vader,self meme A.fasta -dna -oc A -nostatus -time 14400 -mod zoops -nmotifs 10 -minw 6 -maxw 50 -objfun classic -revcomp -markov_order 0
mpirun -np 4 --use-hwthread-cpus --mca btl vader,self meme A.fasta -dna -oc A -nostatus -time 14400 -mod zoops -nmotifs 10 -minw 6 -maxw 50 -objfun classic -revcomp -markov_order 0
    #-np设置运行的线程数
    #如果需要投递任务，则要在-np后面加--use-hwthread-cpus，将默认slots数量设置为硬件线程数而不是处理器核心数
    #-maxsize后面的数字为字节数，需要大于输入文件的字节数；默认为100000字节
    #-oc 输出路径
    #-time后接的数字为运行时间，到达运行时间后，meme会自动停止运行
    #-nmotifs输出的结果数
    #在多线程运行meme时，报错频繁，运行完后无法将xml文件转换成html文件，大概与mpirun的并联运行有关，可考虑将线程数设置为1重新运行或使用下面的命令。
    #综上，在批量运行meme时，可先以np为4快速运行完后，再统一将xml文件转换成html文件
meme_xml_to_html meme.xml meme.html #将xml文件转换成html文件，仅用于meme。meme程序运行的最后一步为此步，但在多线程运行时，总是会报错且不运行此步，因此可以在运行完后单独运行此命令。

#vContact2流程
source ~/.mamba_init.sh
conda activate vcontact2
prodigal -i A.fa -a A.faa
vcontact2_gene2genome -s Prodigal-FAA -p A.faa -o A.csv
vcontact2 --rel-mode 'Diamond' --pcs-mode MCL --vcs-mode ClusterONE --c1-bin /hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/cluster_one-1.0.jar --db 'ProkaryoticViralRefSeq211-Merged' --verbose --threads 8 --raw-proteins A.faa --proteins-fp A.csv --output-dir result

#seqkit
seqkit fx2tab --gc A.fa             #计算A序列的GC含量
seqkit stat A.fa                    #统计A序列长度
seqkit rmdup -i A.fa > B.fa         #按照序列的ID，将A文件中的序列去重并输出至B文件
seqkit rmdup -s A.fa > B.fa         #按照序列的序列的相似度，将A文件中的序列去重并输出至B文件，只有完全相同的序列才会被去重
seqkit grep -n -f A.id B.fa > C.fa  #按照A文件中的ID，将B文件中对应ID的序列提取出来输出至C文件，-n按名字提取，两个文件的ID要完全一样才可以提取输出。如不加-n，则按照ID默认提取
seqkit split -i A.fa                #按照序列的ID，将A文件中的序列拆分成单个序列
seqkit split -p 100 A.fa            #将A文件中的序列拆分成100个序列为一组的文件

#python相关
sed -i 's/\r//' A.py      #将A.py文件中的\r替换为空，解决win下编写的python文件在linux下运行报错的问题
python
    import numpy
    print(numpy.__version__)    #查看numpy版本
    import pkg_resources
    print(pkg_resources.get_distribution("numpy").version) #查看numpy版本
\\
