#Thus have I heard

#archlinux安装软件
sudo pacman -S A B C D    #安装软件A B C D

#连接登录集群
ssh lizhuoran1@192.168.61.7 -p 22
ssh cngb-software-0-1   #切换节点，登陆后为login节点，不能在此节点运行；操作运行需在xcompute节点；下载需在下载节点。
ssh cngb-xcompute-0-10

#在电脑终端使用sftp连接服务器
sftp lizhuoran0@192.168.61.7
put -R Adir Bdir                #将电脑的A文件夹上传到集群的B文件夹
get -R Adir Bdir                #将集群的A文件夹下载到电脑的B文件夹
#使用不同的软件连接集群，所能用的command也不一样，iterm2比Xshell方便，前者可以识别command中的*，能够批量下载；后者无法识别，只能传递单个文件。若确需要传递大量文件，可将其打包后再下载；也可使用Xftp传文件，其优点是交互式操作

whoami                          #显示当前用户

#vim基本用法
vim A               #使用vim语言查看文件A，若无该文件，则生成
                    #v切换成visual模式，此时可以移动光标选中文本，对选中的文本按y键复制，之后会自动转成normal模式，此时可移动光标，在光标处按p键粘贴
vim ~/.bashrc       #名字中带.的文件一般是与环境变量有关的文件，不能随意删除或移动
source ~/.bashrc    #修改.bashrc文件后，需要使用source命令重新加载.bashrc文件才能应用修改
alias lzr1='cd /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1'    #使用lzr1代替cd /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1命令；其中lzr1不能出现空格
export TERMINFO=/usr/share/terminfo                             #在使用clear清屏时报错：terminals database is inaccessible，可使用该命令解决，原因未知

arch                            #显示系统架构，x86_64表示64位系统

gpg --batch --yes --passphrase 'xxxxxxxx' -c A                  #对A文件进行加密，密码为xxxxxxxx，加密后的文件为A.gpg
gpg --batch --yes --passphrase 'xxxxxxxx' -d A.gpg > A          #对A.gpg文件进行解密，密码为xxxxxxxx，解密后的文件为输出为A
#加密解密时，可以不加--batch --yes --passphrase 'xxxxxxxx'，但会弹出密码输入框，需要手动输入密码，这样会更安全，但不适用于批量处理

cd -                                    #切换到上一个目录，用于在两个目录间切换；change directory to the last directory

ls -lthr                                #按写入内容的时间从前往后排列文件，-l表示显示详细信息，-t表示按时间排序，-h表示文件大小以人类可读的方式显示（G M K），-r表示倒序
ls -al                                  #显示所有文件，包括隐藏文件
ll -a                                   #同上
ls -lthr --group-directories-first      #按写入内容的时间从前往后排列文件，文件夹排在前面

mkdir A                      #创建A文件夹
mkdir -p A/B/C               #递归创建A/B/C,即创建A文件夹，再在A文件夹中创建B文件夹，再在B文件夹中创建C文件夹; -p表示递归创建;如果目录存在，也不会报错
mkdir -p A/{B,C,D}           #创建A文件夹，再在A文件夹中创建B、C、D文件夹

git clone https://github.com/XiaofangJ/PhaseFinder /path/to/A #从github上下载PhaseFinder软件到A文件夹中

watch -n 1 -d 'A command'   #每隔1秒执行一次A command，-d表示高亮输出发生变化的地方

realpath A                  #显示文件A的绝对路径

dirname a/b/c.txt           #显示c.txt所在路径，即a/b；不等同于绝对路径
readlink -f a/b/c.txt       #显示c.txt的绝对路径，即/a/b/c.txt

basename A/B/C.txt          #显示C.txt
basename A.fa .fa           #去掉A.fa的后缀，显示A

ID=${INPUT%.*}              #删除INPUT变量中最后一个.及其右边的内容，即将INPUT的后缀去掉，赋值给ID变量；%表示从右边开始删除，#表示从左边开始删除；只针对变量，不针对文件

md5sum A                    #显示A文件的md5值，用于校验文件是否被修改

history                     #显示历史命令

head -n 20 A                #显示A文件前20行，如不加数字，默认10行
tail -n 20 A                #显示A文件最后20行，如不加数字，默认10行

nl -n ln A > B              #给A文件的每一行加上行号，输出到B文件中；nl命令的-n选项表示行号的格式，ln表示行号左对齐，可以换成rn表示行号右对齐，rz表示行号右对齐且前面补0

lfs quota -gh st_p17z10200n0246 /ldfssz1/ #查看st_p17z10200n0246在ld1盘中所占用的磁盘空间 
du -sh A                                  #查看A所占用的磁盘空间
ncdu A                                    #查看A所占用的磁盘空间，ncdu是一个交互式的磁盘使用情况分析工具，可以查看文件夹的大小，文件夹下的文件大小，文件夹下的文件夹大小等

chgrp -R st_p17z10200n0246 A        #将A路径及子路径中所有文件的属组都改为st_p17z10200n0246，比较费时，建议挂后台
chmod +s ./A                        #给A文件夹赋予s权限，即使A文件夹下的文件都具有和A文件夹相同的属组
chmod -R 753 A                      #将A及A下面所有的文件权限都改为754。7读写执、5读执、4只读；第一个数字是自己；第二数字是同属组其他人；第三个数字是所有人；同一类型文件，若权限不同，则颜色也会有差异，如需要更改颜色也可使用此命令
setfacl -R -m u:st_stereonote:rx,u:st_notebook:rx,u:bigdata_autoanalysis:rx,u:bigdata_warehouse:rx,u:st_dcscloud_odms:rwx A  #给A文件夹下的所有文件赋予st_stereonote、st_notebook、bigdata_autoanalysis、bigdata_warehouse、st_dcscloud_odms的读权限，st_dcscloud_odms的读写权限

#运算，在Linux里，不能直接在命令行中进行运算，需要使用一些命令进行运算
expr 1 + 1                 #加法运算，运算结果为2
expr 1 \* 2                #乘法运算，运算结果为2，*前面需要加\，否则会被视为通配符
expr 1 / 2                 #除法运算，运算结果为0
expr 1 % 2                 #取余运算，运算结果为1
expr $a + $b               #将变量a和b相加
#expr的运算结果只能是整数，若需要计算小数，可以使用bc命令
echo "scale=2; 1/3" | bc   #scale=2表示小数点后保留两位，运算结果为0.33
echo "1/3" | bc -l         #-l表示使用标准库，即支持小数运算，运算结果为0.33333333333333333333
echo "${a}/${b}" | bc      #将变量a和b相除
#echo ""内部的运算符号为 + - * / % ^，^表示乘方运算


#后台运行命令
command 1>std 2>err &       #将command的正常输出重定向到std中，报错信息输出到err中。如果command里已经对输出进行了重定向，那么这里的1>std重定向会覆盖command里的输出重定向，需要去掉1>std，否则输出会直接输出到std文件中
nohup command &             #在后台执行命令，正常输出和报错都重定向到nohup.out文件中，但不会覆盖command里的输出重定向
top/htop                    #查询后台
top -u lizhuoran1           #查询该用户的jobs，top下按q可以退出
jobs                        #查询后台运行的任务状态
jobs -l                     #查询后台运行的任务状态，显示jobID
kill jobID                  #终止对应ID的后台任务，有些时候可能终止不了，需要强制终止
kill -9 jobID               #强制终止对应ID的后台任务
#在遇上kill无法终止的任务时，除kill -9外，还可以在htop中，选择对应的任务，按F9，选择15 SIGTERM或9 SIGKILL，即可终止任务
ps aux                      #显示所有进程，a表示显示所有进程，u表示显示用户，x表示显示无终端的进程
ps jobID                    #显示对应ID的进程信息，包括运行时间，cmd命令等
pwdx jobID                  #显示对应ID的进程所在路径，只能显示当前用户的进程

#命令嵌套和参数传递
ll `cat list`               #将list文件中的每一行内容作为参数传递给ll命令
ll $(cat list)              #同上，二者等价
ll $(cat $(which bowtie2))  #将which bowtie2命令的输出作为参数传递给cat命令，再将cat命令的输出作为参数传递给ll命令,多重嵌套只能使用$()，不能使用``
echo file1.txt file2.txt file3.txt | xargs rm -rf               #将echo的输出作为参数传递给xargs命令，xargs默认将参数传递给后面的命令，xargs后面的内容似乎只能使用命令，不能使用别名
echo file1.txt file2.txt file3.txt | xargs -I {} mv {} {}.bak   #将echo的输出作为参数传递给xargs命令，xargs默认将参数传递给后面的命令，-I {}表示将参数传递给{}，{}可以换成其他字符，但在使用时需要保持一致，注意不要与别的命令冲突；此处使用命令不会使用bashrc内的别名


#任务投递
qsub -cwd -q st.q -P P17Z10200N0246 -l vf=50g,num_proc=8 -binding linear:8 A.sh          #普通节点，任务运行无时间限制，资源申请最大为100g内存，8个线程
qsub -cwd -l vf=50g,num_proc=8 -P P17Z10200N0246 -binding linear:8 -q st_short.q A.sh    #short节点，有时间限制，等待时间短
#-cwd:在投递任务时所在的目录执行任务，无cwd默认执行输出在home 
#-q:指定队列，st.q为普通队列，st_short.q为短队列
#-P:指定项目，P17Z10200N0246为项目名
#-l:资源申请，一般申请内存和线程数；vf=10g申请内存；num_proc=8申请线程；申请资源需要与实际任务需求相符，若申请资源过小，任务运行途中可能会被强行中断；若申请资源过大，等待时间会很长
#-binding linear:8 将任务与指定线程数进行绑定，请求的线程数与绑定线程数需相等
qsub -cwd -l vf=500g,num_proc=30 -P P17Z10200N0246_super -binding linear:30 -q st_supermem.q A.sh #大内存节点，使用前需要申请权限http://stblc.genomics.cn/ODMS/resourceManager/resourceRequest
while read i; do qsub -cwd -q st.q -P P17Z10200N0246 -l vf=80g,num_proc=8 -binding linear:8 A.sh $i ; done < list.txt  #批量投递任务，list.txt中每一行为一个参数传递给A.sh
qstat                       #显示所有已投递的任务
qstat -j jobID              #显示详细状态
qdel id                     #终止对应ID的任务
qdel -u lizhuoran1          #删除lizhuoran1投递的所有任务
qhold jobID                 #暂停对应ID的任务
qrls jobID                  #恢复对应ID的任务
qstat | grep "Eqw" | awk '{print $3}' | while read i; do qsub -cwd -q st.q -P P17Z10200N0246 -l vf=10g,num_proc=4 -binding linear:4 ${i}*sh; done       #在批量投递任务时，此行命令可以查找处于Eqw的任务，并重新投递任务
qstat | grep "Eqw" | awk '{print $1}' | while read i; do qdel $i; done      #查找处于Eqw的任务，并删除

ln -s A_absolute_path B     #创建A文件的软链接，名为B，软链接相当于快捷方式。修改软链接也会同步修改其对应的源文件，反之也是

echo a{1..100}              #输出a1 a2 a3 a4 ...... a100

#awk的使用，下面的命令中的awk都可以换成gawk，gawk是awk的一个超集，它包含了所有awk的功能，并添加了一些额外的功能
awk '{print $1}' A                                              #提取A文件的第一列，使用默认分隔符空格符
awk -F '>' '{print $1}' A                                       #指定分隔符为>，分隔符也可以是字符串
awk -F '\\.e' '{print $1}' A                                    #指定分隔符为.e，分隔符中，.为正则表达式中的通配符，需要转义，即\.；在awk里，转义符为\\，所以为\\.
awk 'BEGIN {OFS = ","} {print $1, $3}' filename                 #指定输出分隔符为逗号，输出A文件的第一列和第三列
awk '!a[$1]++{print}' A                                         #可适用于所有需要去冗余的表格
awk '{sum+=$1}'END'{print sum}'                                 #对一列数字进行累加并输出
awk -F[:\\t] '{if($4>=60){print ($9/$11)}else{print 0}}' A.txt  #分隔符为:和\t，对A文件中的第4列进行筛选，若大于60，则输出第9列除以第11列的结果，否则输出0。其中[:\\t]表示分隔符为:或\t
awk -F '/' '{print $NF}' A                                      #提取A文件中每一行最后一个/后面的内容，$NF表示最后一个字段，$0表示整行，$1表示第一个字段，$NR表示行号
awk 'NR%3==2' tmp1.txt                                          #输出tmp1.txt文件的第2行，NR表示行号，%表示取余；即当行号除以3余数为2时输出该行
for((i=1;i<=100;i++)); do awk -v a=$i 'print $a' A; done        #提取A文件的第1-100列，需注意，awk命令无法直接用已设置的变量，需要使用-v选项传递变量
awk '{for(i=3;i<=NF;i++) printf $i"\t"; print ""}' filename     #输出filename文件的第3列到最后一列，每一列之间用制表符分隔
awk '{$1=$2=""; print $0}' filename                             #将filename文件的第一列和第二列置空，输出剩余列，$0表示整行，会在每一行的开头输出空格
awk '{ print "Line " NR ": Length = " length($0) }' A           #输出A文件的每一行的长度，通常是字符数

sed 's/aaa/bbb/' A                  #以行为单位在A文件中匹配aaa，并将每一行的第一个aaa改为bbb，并输出
sed 's/aaa/bbb/g' A                 #将A文件中的aaa全部改为bbb并输出，可以使用正则表达式
sed 's/^ *//' A                     #将A文件中每一行的开头的任意多个空格删除
sed '/^$/d' A                       #删除A文件中的空行
sed "s/${old}/${new}/g" A           #在使用变量时，需要使用双引号，否则变量无法被识别
sed -e 's/aaa/bbb/; s/ccc/ddd/' A   #在A文件中匹配aaa并将其改为bbb，再匹配ccc并将其改为ddd
sed -i 's/aaa/bbb/g' A              #不输出，直接修改A文件
sed -i 's/aa./bbb/g' A              #将aa*改为bbb
sed "s/${old}/${new}/g" A           #在使用变量时，需要使用双引号，否则变量无法被识别
sed '1d' A                          #删除A文件的第一行
sed '1,10d' A                       #删除A文件的第一行到第十行
sed -n '1p' A                       #只输出A文件的第一行
sed -n '1,10p' A                    #只输出A文件的第一行到第十行
sed -n "${a}p" A                    #输出A文件的第a行
sed -n "${a},${b}p" A               #输出A文件的第a行到第b行
sed -n '1~2p' A                     #~2表示步长，即从第1行开始，输出文件的第1,3,5,7,...行
sed -i 's/\r//' A                   #删除A文件中的\r，即windows下的换行符。大多数windows下的文件在linux使用时,每一行末尾会出现^M，即\r，需要使用sed命令删除
#sed命令的s(替换)操作允许使用任何字符作为分隔符。通常，我们使用斜杠/作为分隔符，如s/foo/bar/g，这会将所有的foo替换为bar。但是，如果替换的文本中包含斜杠，使用斜杠作为分隔符就会变得麻烦，因为需要对每个斜杠进行转义。在这种情况下，可以选择其他的字符作为分隔符，如@、#、|、:等。例如，可以写成s#foo#bar#g，这和s/foo/bar/g的效果是一样的。

grep "a" A                          #在A文件中匹配含有a的每一行，grep使用时需注意正则表达
grep "0\.8" A                       #在A文件中匹配含有0.8的每一行
grep "0.8" A                        #.是正则表达式的一种，被视为*，即匹配含有0*8的每一行
grep "a" -A 1 A                     #在A文件匹配含有a的每一行，并输出该行和下一行
grep "a" -v A                       #在A文件中匹配含有a的每一行，但输出不匹配行
grep -wvf A B                       #-f表示从文件中读取内容，即从A中读取每一行作为匹配项与B文件进行匹配；-w为精确匹配，只有两行完全相同才会被匹配上；-v为取反；当没有输出时，会被视为报错、
grep -wf A B                        #在B文件中匹配含有A文件中任何一行的每一行,并输出，A应为B的子集
grep -P "a\db" A                    #在A文件中匹配含有a和b之间有一个数字的每一行，-P表示使用perl正则表达式。若不加-P，则\d会被视为普通字符
grep -l "a" *                       #在当前目录下匹配内容中含有a的文件，只输出匹配到的文件名，不输出匹配到的内容

paste A B                           #将A和B按行对行拼接在一起
paste -d, A B                       #将A和B按行对行拼接在一起，且用逗号分隔
paste <(echo $a) <(echo $b)         #将变量a和b按行对行拼接在一起

find A -size 0                      #递归查找A路径下大小为0的文件
find A -maxdepth 1 -size0           #仅在A路径中查找大小为0的文件，不对子路径进行检索
find A -maxdepth 1 -size0 -delete   #仅在A路径下查找大小为0的文件，不对子路径进行检索，并将查找到的文件删除；-maxdepth应放在最前面
find -name "*a*" A                  #递归查找A路径下名字中含有a的文件
find ! -name "*a*" A                #递归查找A路径下名字中不带有a的文件
find -not -name "*a*" A             #同上 
find -name "*a*" A -exec ll {} \;   #查找每一个名字含有a的文件，并显示。ll也可换成其他command， \;为终止
find A -name "*a*" -exec du -sh {} \;
find A -type d                      #递归查找A路径下类型为d的文件，即查找所有文件夹，配合循环命令可以实现遍历每一个文件夹
find A -type f                      #递归查找A路径下类型为f的文件，即查找所有文件

xxd A                               #以16进制查看二进制文件A，可用于查看命令的源码

sort A                              #将表格A按第一列进行排序
sort A -k 2                         #将表格A按第二列进行排序
sort -t ,                           #以逗号作为分隔符，与-k联用
sort -n -t ' ' -k 5                 #将表格A按第五列进行排序，且第五列为数字，-n表示按数字排序
sort -k2,2nr -k10,10nr A            #将表格A按第二列从大到小排序，若第二列相同，则按第十列从大到小排序；去掉r则为从小到大排序

shuf A                              #将A文件的内容随机打乱；shuf的随机打乱是打乱了行的顺序，每一行的内容不会发生变化
shuf -n 10 A                        #将A文件的内容随机打乱，并输出前10行
shuf A -o B                         #将A文件的内容随机打乱，并输出到B文件中；-o表示输出到文件中，也可以输出到原文件A中
cat A | shuf                        #查看A文件的内容，并将内容随机打乱

#压缩与解压
zip -r A.zip A                          #将A文件夹压缩成A.zip格式
unzip A.zip                             #解压A文件，会直接生成原来的文件夹
gzip A                                  #压缩文件A，后缀为gz，会覆盖原来的文件
gzip -d A.gz                            #适用于后缀为gz的解压缩
gunzip A.gz                             #解压后缀为gz的文件，覆盖原先的gz文件
gunzip -c A.gz > A                      #解压文件并输出到指定位置 
tar xvzf A.tgz                          #在当前目录解压后缀为tgz的文件，也适用于tar.gz文件
                                        #z表示使用gzip作为解压方式；x表示解压；v显示正在处理的文件名称；f指定解压的文件
tar cvzf A.tar.gz A                     #将A文件夹打包成A.tar.gz文件
                                        #c表示打包；v显示正在处理的文件名称；z表示使用gzip作为压缩方式；f指定打包的文件
tar -cI 'gzip -9' -f A.tar.gz A         #将A文件夹打包成A.tar.gz文件，使用gzip进行压缩，压缩等级为9
                                        #-c表示打包；-I表示使用gzip进行压缩；-9表示压缩等级，数字越大压缩效果越好，耗时越长；-f指定打包的文件；-I指定gzip压缩并指定压缩等级
#tar命令各种字母的含义：x 解开打包；c 打包；v 显示详细信息；f 指定文件；z 使用gzip压缩；j 使用bzip2压缩；t 显示文件列表；r 向压缩文件中追加文件；A 解开打包时，自动识别压缩格式
pigz -p 4 -k -6 A                       #使用pigz进行压缩，pigz是gzip的并联版本，速度更快。pigz只能对文件进行压缩，若是文件夹需要先使用tar进行打包；会默认生成A.gz文件
                                        #-p为线程数；-k表示保留原文件，不删除。-6为压缩等级，可选1-9，数字越大压缩效果越好，耗时越长。
tar cf - A | pigz -p 4 -k -6 > A.tar.gz #将A文件夹打包成A.tar.gz文件，使用pigz进行压缩，速度更快
tar --no-same-owner -xvf archive.tar    #解压时不保留文件的所有者和组，即解压后文件的所有者和组会变成当前用户和组

#拆分文件:
#用于将多条fa文件拆分成单个，以下内容无需参考，请往下看split和seqkit使用
cat test.fa | tr '\n' '\t' | sed 's/\t>/\n>/g' | sed 's/\t/\n/' | sed 's/\t//g' > test2.fa 
    #tr转换，将换行符\n转换成制表符\t（tab）；sed将\t>替换成\n>，sed处理文本是按行为单位处理，不加g则只对每一行的第一个匹配项进行操作，随后调到下一行进行匹配操作，如此
grep "$i" -A 1 A.fa > ${i}.fa
#均等拆分fasta文件，适用于序列是多行书写的情况，没有使用价值，非常耗时，仅提供思路
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
    #cd-hit-est用于处理核酸序列，cd-hit用于处理蛋白质序列
#在使用cd-hit时，如果处理序列的长度超过了最大序列长度。此时会有warning提示，可能伴随着无输出。可使用git clone重新下载cd-hit，并在cdhit目录下重新编译安装，安装时需要指定最大序列长度，如make MAX_SEQ=1000000，此时最大序列长度为1000000
#cd-hit使用时，如果出现完全一样的序列，会产生一些bug，不建议使用，建议使用mmseqs
mmseqs easy-linclust -e 0.001 --cov-mode 1 -c 0.8 --min-seq-id 0.9 --kmer-per-seq 80 0.7_gene_dereplication/all_gene.fasta 07.gene_dereplication/clusterRes 07.gene_dereplication/tmp --threads 16
seqkit rmdup -s A.fa > B.fa     #去冗余，-s表示按照序列的相似度进行去冗余，只有完全相同的序列才会被去冗余



#fastANI计算序列相似度
fastANI --ql que.list --rl ref.list -o fastANI_result.txt -t 8    #--ql 指定查询序列列表，每一行为一个序列的路径; --rl 指定参考序列列表，每一行为一个序列的路径; -o 输出文件; -t 线程数

#系统进化树的构建
mafft --auto input.fasta > algined_tree.fasta 2>err             #将输入的蛋白质序列对齐
iqtree -s algined_tree.fasta -bb 1000 --runs 8 -T 8 --mem 50G   #runs进行独立运行的次数，每次运行都会生成一个进化树，最后选择最优的树作为结果；mem内存分配；bb迭代数，1000次耗时很长，可以先不设置迭代；T线程数

#blast比对
makeblastdb -in A.fasta -dbtype prot -parse_seqids -out index #-in：建库的文件 -dbtype：数据库类型，prot是蛋白质，nucl是核酸，生成一系列以index为前缀的文件，用于建库的序列应写在同一个文件里
blastp -query MF19343.faa -db alphafold_db.fasta -outfmt 6 -evalue 1e-5 -out result.txt #evalue值一般设置1e-5
blastn -query CPB1015.fa -db ./index -outfmt "6 qseqid sseqid qcovs qcovhsp pident length mismatch gapopen qstart qend sstart send evalue bitscore" -evalue 1e-5 -out ./CPB1015_blastn.txt #在指定路径查找以index为前缀的文件作为数据库
#blast结果解读:
#qseqid:查询序列的ID sseqid:匹配的数据库序列的ID qcovs:查询序列与匹配序列的匹配长度占查询序列的百分比 qcovhsp:查询序列与匹配序列的匹配长度占匹配序列的百分比 pident:匹配的百分比 length:匹配的长度 mismatch:不匹配的长度 gapopen:间隙的长度 qstart:查询序列的起始位置 qend:查询序列的终止位置 sstart:数据库序列的起始位置 send:数据库序列的终止位置 evalue:随机期望值，可近似理解为错误率 bitscore:打分

#checkv流程
checkv end_to_end input.fa ./checkv -d /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/checkv/checkv-db-v1.5 -t 8

#prokka注释流程
prokka --prefix ID --locustag ID --addgenes --addmrna --plasmid Plasmid --gcode 11 --outdir A --mincontiglen 100 A.fasta 

#meme流程
meme A.fasta -dna -oc A -nostatus -time 14400 -mod zoops -nmotifs 10 -minw 6 -maxw 50 -objfun classic -revcomp -markov_order 0 -p 8
    #-oc 输出路径
    #-time 14400表示运行时间为14400秒，到达运行时间后，meme会自动停止运行
    #-nmotifs 找到的motif数
    #-minw 6 -maxw 50 表示motif的最小长度为6，最大长度为50
    #-p 8表示使用8个线程
    #-revcomp 表示同时搜索正向和反向序列，仅用于DNA序列
    #-dna 表示输入序列为DNA序列，可替换为-protein表示输入序列为蛋白质序列，-rna表示输入序列为RNA序列
#mpirun -np 4 --mca btl vader,self meme A.fasta -dna -oc A -nostatus -time 14400 -mod zoops -nmotifs 10 -minw 6 -maxw 50 -objfun classic -revcomp -markov_order 0
#mpirun -np 4 --use-hwthread-cpus --mca btl vader,self meme A.fasta -dna -oc A -nostatus -time 14400 -mod zoops -nmotifs 10 -minw 6 -maxw 50 -objfun classic -revcomp -markov_order 0
    #-np设置运行的线程数
    #如果需要投递任务，则要在-np后面加--use-hwthread-cpus，将默认slots数量设置为硬件线程数而不是处理器核心数
    #-maxsize后面的数字为字节数，需要大于输入文件的字节数；默认为100000字节
    #-oc 输出路径
    #-time后接的数字为运行时间，到达运行时间后，meme会自动停止运行
    #-nmotifs输出的结果数
    #在多线程运行meme时，报错频繁，运行完后无法将xml文件转换成html文件，大概与mpirun的并联运行有关，可考虑将线程数设置为1重新运行或使用下面的命令。
    #综上，在批量运行meme时，可先以np为4快速运行完后，再统一将xml文件转换成html文件
#meme_xml_to_html meme.xml meme.html #将xml文件转换成html文件，仅用于meme。meme程序运行的最后一步为此步，但在多线程运行时，总是会报错且不运行此步，因此可以在运行完后单独运行此命令。

#fastp过滤
fastp -i A_1.fastq.gz -o A_1.fq -I A_2.fastq.gz -O A_2.fq -5 -3 -q 20 -w 8 -c -j fastp.json -h fastp.html -R out.prefix -l 30
fastp -i A_1.fastq.gz -o A_1.fq.gz -I A_2.fastq.gz -O A_2.fq.gz -5 -3 -q 20 -w 8 -z 9 -c -j fastp.json -h fastp.html -R out.prefix -l 30
#-i 输入文件 -o 输出文件 -I 输入文件 -O 输出文件 -5 -3 5'3'端质控剪切 -q 质量阈值 -w 线程数，fastp最多只能使用16个线程 -c 修剪 -j 输出json文件报告 -h 输出html文件报告 -R json和html文件的标题 -l 输出文件长度阈值
#-z 9表示压缩等级，数字越大压缩效果越好，耗时越长，可选1-9，如果添加-z，输出文件要改为对应的fq.gz后缀

#宏基因组组装流程
fastp -i A_1.fastq.gz -o A_qc_1.fq.gz -I A_2.fastq.gz -O A_qc_2.fq.gz -5 -3 -z 9 -q 20 -c -j fastp.json -h fastp.html -R out.prefix -l 30 #先使用fastp进行质控，过滤低质量序列
megahit --presets meta-large -t 25 -1 A_qc_1.fq.gz -2 A_qc_2.fq.gz -o megahit_result #使用megahit进行组装，-t 25表示使用25个线程，--presets meta-large表示使用预设的meta-large参数进行组装
#megahit进行组装时，需要很长时间，同时也会产生很大的中间文件，因此在投递任务时需要注意内存、时间的设置以及磁盘空间。如发现磁盘空间不足，可结束任务，但不要删除-o里的中间文件。在磁盘空间充足时，可运行以下命令继续组装。此外，megahit在组装时如果因内存不足而报错停止，也可以继续运行
megahit --presets meta-large -t 25 -1 A_qc_1.fq.gz -2 A_qc_2.fq.gz -o megahit_result --continue #继续组装，使用--continue参数时，会忽略除了-o之外的所有参数，直接读取-o指定的文件夹中的中间文件进行组装
#如宏基因组序列实在太大，花费时间太长，可考虑质控后使用seqkit进行随机序列抽取，以加快组装速度

#vContact2流程，没什么用了，现在都用vContact3了
source ~/.mamba_init.sh
conda activate vcontact2
prodigal -i A.fa -a A.faa
vcontact2_gene2genome -s Prodigal-FAA -p A.faa -o A.csv
vcontact2 --rel-mode 'Diamond' --pcs-mode MCL --vcs-mode ClusterONE --c1-bin /hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/cluster_one-1.0.jar --db 'ProkaryoticViralRefSeq211-Merged' --verbose --threads 8 --raw-proteins A.faa --proteins-fp A.csv --output-dir result

#metaphlan
metaphlan DP8480003148BR_L01_410_1.fq,DP8480003148BR_L01_410_2.fq --bowtie2out metagenome.bowtie2.bz2 --nproc 16 --input_type fastq -o profiled_metagenome.txt --bowtie2db /data/input/Files/ReferenceData/metaphlan_database -x mpa_vJun23_CHOCOPhlAnSGB_202403 -s sam.bz2 -t rel_ab_w_read_stats --offline

#phold
phold run -i NC_043029.gbk -o test_output_phold -t 8 -f -d /home/zoran/software/databases/phold             #运行全流程，包括cds预测，蛋白质3D结构预测，结构比对，默认使用GPU
    #-i 输入文件，可以是fasta和gbk；若输入是gbk文件，则需要保证gbk文件内容完整，否则报错。如果想要获得完整的gbk文件，可以使用phraokka对fasta文件进行注释，phraokka会自动生成完整的gbk文件
    #-o 输出文件夹，该文件夹是被phold创建的，如果该文件夹已经存在，则会报错，可以添加-f参数，强制覆盖
    #-t 线程数
    #-d 数据库路径，如果下载数据库时没有指定路径，则会下载到默认路径；如果数据库存在于默认路径，则可以不用使用-d指定
phold proteins-predict -i protein.faa -o predict_result -t 8 -d /home/zoran/software/databases/phold -f     #运行蛋白质结构预测，预测输入蛋白质氨基酸序列的3D结构
phold proteins-compare -i protein.faa --predictions_dir predict_result -o compare_result -t 8 -d /home/zoran/software/databases/phold -f    #运行蛋白质结构比对，需要先完成上一步蛋白质结构预测
export HF_ENDPOINT=https://hf-mirror.com    #运行phold有时候会有代理问题，可以设置环境变量HF_ENDPOINT为https://hf-mirror.com，解决代理问题


#seqkit
seqkit fx2tab --gc A.fa                                         #计算A序列的GC含量
seqkit stat A.fa                                                #统计A序列长度
seqkit stat -a A.fa                                             #统计A序列的信息，包括序列长度、GC含量、N50等
seqkit rmdup -i A.fa > B.fa                                     #按照序列的ID，将A文件中的序列去重并输出至B文件
seqkit rmdup -s A.fa > B.fa                                     #按照序列的序列的相似度，将A文件中的序列去重并输出至B文件，只有完全相同的序列才会被去重
seqkit grep -n -f A.id B.fa > C.fa                              #按照A文件中的ID，将B文件中对应ID的序列提取出来输出至C文件，-n按名字提取，两个文件的ID要完全一样才可以提取输出。如不加-n，则按照ID默认提取
seqkit grep -p "gene_675" B.fa > C.fa                           #按照B文件中的序列名，将含有gene_675的序列提取出来输出至C文件，是完全匹配，不必担心匹配到其他序列
seqkit split -i A.fa                                            #按照序列的ID，将A文件中的序列拆分成单个序列
seqkit split -p 100 A.fa                                        #将A文件中的序列拆分成100个序列为一组的文件
seqkit sample -s 100 -n 1000 A.fa > B.fa                        #从A文件中随机抽取1000个序列输出至B文件，-s 100表示随机种子，-n 1000表示抽取的序列数；在处理大文件时，不建议使用-n参数，因为会将所有序列读入内存，占用大量内存
seqkit sample -s 100 -p 0.5 A.fa > B.fa                         #从A文件中随机抽取50%的序列输出至B文件，-s 100表示随机种子，-p 0.5表示抽取的比例
seqkit sample -s 100 -p 0.5 A.fa.gz | pigz -p 4 -9 > B.fa.gz    #从A文件中随机抽取50%的序列输出至B文件，并压缩；seqkit支持处理压缩文件，但不支持输出压缩文件
seqkit sort -l A.fa > B.fa                                      #按照序列的长度，将A文件中的序列按照长度排序由短到长输出至B文件
seqkit sort -lr A.fa > B.fa                                     #按照序列的长度，将A文件中的序列按照长度排序由长到短输出至B文件
seqkit seq -m 6000 A.fa > B.fa                                  #将A文件中的序列长度大于6000的序列输出至B文件
seqkit seq -m 6000 -M 10000 A.fa > B.fa                         #将A文件中的序列长度在6000-10000之间的序列输出至B文件
cat CPB0314_test8.fa | head -n 1 | sed 's/>//g' | xargs -I @ seqkit replace -p "@" -r CPB0314 CPB0314_test8.fa > CPB0314.fa #将CPB0314_test8.fa文件中的第一行的ID替换为CPB0314，输出至CPB0314.fa文件

#python相关
sed -i 's/\r//' A.py      #将A.py文件中的\r替换为空，解决win下编写的python文件在linux下运行报错的问题

#配置git
git config --global user.name "Sheaffer-triumph"
git config --global user.email zoranlee0118@gmail.com
git clone https://github.com/XiaofangJ/PhaseFinder /path/to/A #从github上下载PhaseFinder软件到A文件夹中

#NCBI工具entrez使用
efetch -db Nucleotide -id NC_010355 -format gb  #在Nucleotide数据库中下载ID为NC_010355的gbk文件；-format指定文件格式，gb为gbk文件，fasta为fa文件；显然，此命令需要联网
cat ICTV.list | sed 's/[^:]*: *//g' | sed 's/ *; */\n/g' | grep .

#pip用法
pip config list #查看pip的配置
pip config unset global.index-url #取消pip的全局配置的index-url
pip config set global.index-url https://pypi.org/simple #设置pip的全局配置的index-url为https://pypi.org/simple
pip 

#shell脚本相关

#shebang行  定义脚本的默认解释器
#!/usr/bin/bash                 #指定脚本的解释器
#!/usr/bin/bash -e              #等同于set -e，一旦脚本中有命令返回非0值，就立即退出脚本，即一旦后面的命令有报错，就停止运行

#当运行一个shell脚本时，它会在一个新的子shell中执行。这个子shell会继承父shell的环境变量，但是它们之间的环境变量是隔离的，所以子shell中的变量改变或者目录改变不会影响到父shell。
#如果想在运行脚本后保持改变的工作目录，需要在当前shell中执行脚本，而不是在子shell中，可以使用如下方式执行脚本：
source A.sh
. A.sh
#这两种方式都会在当前shell中执行脚本，而不是在子shell中执行。.是source的简写，两者是等价的。
#或者在脚本最后加上bash，这样也可以在当前shell中执行脚本

#子shell不会影响父shell，同样，父shell也不会完全影响子shell，父shell里定义的变量在子shell里无法直接使用。父shell里的alias别名在子shell里也无法直接使用，但是可以通过source命令加载父shell的配置文件，从而在子shell里使用父shell的alias别名。

#获取脚本所在的绝对路径
dir=$(dirname $0)
dir=$(dirname $BASH_SOURCE)
#如果是以绝对路径运行脚本，则上面两行命令都可以达到目的；但如果使用sh ../test.sh这种方式，则无法获取到绝对路径，原因在于dirname无法解析变量里的相对路径
dir=$(cd $(dirname $0); pwd)
dir=$(dirname $(readlink -f $0))    #readlink -f解析相对路径，获取绝对路径；以此处为例，readlink -f会解析$0代表的../sh，并返回绝对路径

#cat输入多行内容
cat << EOF > A.sh
#!/bin/bash
echo "Hello World"
EOF
#将多行内容写入A.sh文件中，EOF为结束符，可以换成其他字符，前后一致即可

#参数解析
#shell脚本可以使用getopts进行参数解析，语法为:
getopts optstring name
#通常搭配while嵌套case使用，如下：
#optstring是一个字符串，定义了脚本支持的选项，每个字符代表一个选项，如果选项后面需要参数，需要在字符后面加一个冒号。name是一个变量，用来存储解析到的选项。同时，getopts自带两个内置变量，$OPTIND和$OPTARG，分别表示当前解析到的选项的位置和选项对应的参数。getopts只能解析单个字符选项。
#循环使用getopts解析命令行参数。若输入的选项不在选项列表中，将其视为无效选项，执行case里的\?分支；每个选项后面的冒号表示该选项需要一个参数，若没有提供参数，将执行case里的:分支
#optstring最前面的:表示忽略运行错误，如错误的选项或者缺少参数导致的错误。但如果同时在case里设置了:分支和\?分支，那么错误的选项和缺少参数会分别进入到\?分支和:分支。在:分支里，$OPTARG会存储缺少参数的选项，而不是正常情况下选项的参数。
while getopts :a:b: opt; do
    case $opt in
        a)
            echo "-a was triggered with $OPTARG"
        ;;
        b)
            echo "-b was triggered with $OPTARG"
        ;;
        c)
            echo "-c was triggered"
        ;;
        \?)
            echo "Invalid option: -$OPTARG"
        ;;
        :)
        echo "Option -$OPTARG requires an argument."
        ;;
    esac
done
#内置参数
$#      #传递到脚本的参数个数
$@      #传递到脚本的所有参数
$*      #传递到脚本的所有参数
$?      #上个命令的退出状态，或函数的返回值
$$      #当前shell进程的进程ID
$!      #后台运行的最后一个进程的进程ID
$0      #脚本本身的文件名
$1      #第一个参数
$2      #第二个参数
...
