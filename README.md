# Thus have I heard     

大致分3个板块，基础的Linux command line，我常用的生信工具下载安装及运行，其他。

### Linux command line

`ssh`是用来远程连接Linux服务器的命令，运行如下

```bash
# 以用户名lizhuoran1连接到IP地址为192.168.61.7的服务器，使用22端口（22是SSH默认端口，可省略-p 22）
ssh lizhuoran1@192.168.61.7 -p 22
# BGI集群服务器登录后默认在login节点，只能用来跳转，不能运行程序
# 跳转到软件节点，在此可以下载安装软件
ssh cngb-software-0-1
# 跳转到计算节点，在这里可以运行生物信息学分析程序
ssh cngb-xcompute-0-10
```

`sftp`是用来在本地和远程服务器之间安全传输文件的命令

```bash
# 连接到服务器的文件传输界面
sftp lizhuoran1@192.168.61.7
# 使用sftp连接上服务器，可执行以下命令
# 把本地电脑的A文件夹整个上传到服务器，重命名为B文件夹（-R表示递归传输整个文件夹）
put -R Adir Bdir                
# 把服务器的A文件夹整个下载到本地电脑，重命名为B文件夹
get -R Adir Bdir
# 使用技巧：不同终端软件功能不同
# iTerm2支持通配符*，可以批量传输文件，比如 get *.fasta
# Xshell不支持通配符，只能传单个文件
# 如果文件很多，可以先打包成.tar.gz再传输，或者直接用Xftp图形界面拖拽文件
```

`vim`是Linux系统中的文本编辑器，按`i`进入编辑模式，按`Esc`退出编辑模式，输入`:wq`保存并退出。

```bash
# 用vim编辑器打开文件A(后续内容中的A也是如此，不再赘述)，如果文件不存在会自动创建
vim A
# 在vim中的复制粘贴操作：按v键进入选择模式，移动光标选中要复制的内容。按y键复制选中的内容，自动回到普通模式，移动光标到想粘贴的位置，按p键粘贴
# 编辑系统配置文件（以.开头的文件是隐藏的系统配置文件，很重要不能乱动）
vim ~/.bashrc
```

`gpg`是用来加密和解密文件的工具，可以给重要文件设置密码保护。

```bash
# 用密码xxxxxxxx加密文件A，生成加密文件A.gpg
gpg --batch --yes --passphrase 'xxxxxxxx' -c A                  
# 用密码xxxxxxxx解密文件A.gpg，输出解密内容到文件A
gpg --batch --yes --passphrase 'xxxxxxxx' -d A.gpg > A          
# 可以省略--batch --yes --passphrase参数，这样会弹出密码输入框手动输入
# 手动输入更安全但不能批量处理，命令行直接写密码可以批量处理但安全性较低
```

`cd`是用来切换目录（文件夹）的命令，是Linux中最基本的导航命令。

```bash
# 切换到指定目录
cd /home/user/data
# 返回上一级目录（父目录）
cd ..
# 返回到上一个访问过的目录
cd -
# 回到用户主目录（家目录）
cd ~
# 或者直接
cd
# 切换到根目录
cd /
# 使用相对路径切换
cd ./data/genome          # 切换到当前目录下的data/genome文件夹
# 使用绝对路径切换  
cd /usr/local/bin         # 从根目录开始的完整路径
```

`ls`是用来查看目录中文件和文件夹列表的命令，相当于Windows中双击打开文件夹查看内容。

```bash
# 查看当前目录下的文件和文件夹
ls
# 显示详细信息（权限、大小、修改时间等）
ls -l
# 显示所有文件，包括隐藏文件（以.开头的文件）
ls -a
ls -al                                  # 显示所有文件的详细信息，包括隐藏文件
ll -a                                   # 同上（ll是ls -l的简写别名，Ubuntu系统的配置文件里已经设置，其他系统不一定有）
# 以人类可读的方式显示文件大小（KB、MB、GB）
ls -lh
# 按修改时间排序显示（最新的在前面）
ls -lt
# 按时间排序，倒序显示，人类可读格式（最老的文件在前面）
ls -lthr                                # -l详细信息 -t按时间排序 -h人类可读 -r倒序
# 按时间排序，文件夹优先显示在前面
ls -lthr --group-directories-first      
# 查看指定目录的内容
ls /home/user/data
# 使用通配符查看特定类型文件
ls *.fasta              # 查看所有.fasta格式的基因组文件
ls sample*              # 查看所有以sample开头的文件
```

`mkdir`是用来创建新文件夹（目录）的命令。

```bash
# 创建一个名为data的文件夹
mkdir data
# 一次创建多个文件夹
mkdir project1 project2 project3
# 创建多层嵌套文件夹（如果父目录不存在会一起创建）
mkdir -p data/genome/human/chr1
# 创建文件夹并设置权限
mkdir -m 755 public_data
# 显示创建过程的详细信息
mkdir -v new_folder
```

`rm`是用来删除文件和文件夹的命令，删除后无法恢复，需谨慎使用。

```bash
# 删除单个文件
rm file.txt
# 删除多个文件
rm file1.txt file2.txt file3.txt
# 删除文件夹及其所有内容（递归删除）
rm -r folder_name
# 强制删除，不询问确认（危险操作）
rm -f file.txt
# 递归强制删除文件夹，不询问确认（非常危险）
rm -rf folder_name
# 删除前询问确认（安全做法）
rm -i file.txt
# 使用通配符批量删除
rm *.tmp                # 删除所有.tmp文件
rm sample_*             # 删除所有以sample_开头的文件
# 特别提醒：rm -rf /* 会删除整个系统，千万不要执行！
```

`echo`是用来在终端输出（显示）文本内容的命令，相当于编程语言中的print功能。

```bash
# 输出简单文本
echo "Hello World"
# 输出变量内容
echo $HOME                      # 显示家目录路径
echo $USER                      # 显示当前用户名
# 将内容写入文件（覆盖原内容）
echo "sample data" > output.txt
# 将内容追加到文件末尾
echo "new line" >> output.txt
# 输出多行内容
echo -e "A\nB\nC"     # -e启用转义字符解释
# 不换行输出
echo -n "abc"
# 创建简单的配置文件
echo "export PATH=$PATH:/usr/local/bin" >> ~/.bashrc
# 大括号展开（批量生成序列）
echo a{1..100}                  # 输出 a1 a2 a3 a4 ...... a100
echo file{1..5}.txt             # 输出 file1.txt file2.txt file3.txt file4.txt file5.txt
echo {A..Z}                     # 输出 A B C D ...... Z
echo test{001..010}             # 输出 test001 test002 ...... test010
```

`cat`是用来查看和显示文件内容的命令，也可以用来合并文件。

```bash
# 查看文件内容
cat file.txt
# 查看多个文件内容（按顺序显示）
cat file1.txt file2.txt
# 显示行号
cat -n file.txt
# 合并多个文件并保存到新文件
cat file1.txt file2.txt > merged.txt
# 将内容追加到文件
cat file1.txt >> existing_file.txt
# 查看文件并显示特殊字符（如制表符、换行符）
cat -A file.txt
# 创建新文件并输入内容（按Ctrl+D结束输入）
cat > new_file.txt
# 查看大文件的前几行（通常用head命令更合适）
cat large_file.txt | head -10
```

Linux系统不能直接进行数学运算，需要使用 `expr` 命令进行整数运算，或使用 `bc` 命令进行小数运算。

```bash
# expr命令：整数运算
expr 1 + 1                 # 加法运算，结果为2
expr 1 \* 2                # 乘法运算，结果为2，*前需要加\避免被视为通配符
expr 1 / 2                 # 除法运算，结果为0（整数除法）
expr 1 % 2                 # 取余运算，结果为1
expr $a + $b               # 将变量a和b相加
# bc命令：支持小数运算
echo "scale=2; 1/3" | bc   # scale=2表示保留2位小数，结果为0.33
echo "1/3" | bc -l         # -l使用标准库支持小数运算，结果为0.33333333333333333333
echo "${a}/${b}" | bc      # 将变量a和b相除
# bc支持的运算符：+ - * / % ^（^表示乘方）
echo "2^3" | bc            # 2的3次方，结果为8
echo "scale=3; 22/7" | bc  # 计算π的近似值，保留3位小数
```

绝对路径是从根目录/开始的完整路径，如 /home/user/data/sample.fasta，无论在哪个目录下，绝对路径都指向同一个文件

相对路径是相对于当前目录的路径，如 ./data/sample.fasta，会随着当前所在目录的改变而改变含义

```bash
# 查看当前所在目录（绝对路径）
pwd                         
# 显示文件的绝对路径
realpath filename           # 将相对路径转换为绝对路径
readlink -f filename        # 同上，还能解析软链接
# 显示文件所在目录的路径
dirname /home/user/data/file.txt    # 结果：/home/user/data
# 路径表示符：
# .     表示当前目录
# ..    表示上级目录  
# ~     表示用户主目录
# /     表示根目录
# 路径使用示例：
ls /home/user/data          # 绝对路径：无论在哪都能找到这个目录
ls ./data                   # 相对路径：查看当前目录下的data文件夹
ls ../backup                # 相对路径：查看上级目录下的backup文件夹
ls ~/Documents              # 主目录路径：查看家目录下的Documents文件夹
# 实际对比：
pwd                         # 假设显示：/home/user
ls data/genome.fa           # 相对路径，实际指向：/home/user/data/genome.fa  
ls /home/user/data/genome.fa # 绝对路径，明确指向这个文件
```

`watch` 是用来定期重复执行命令并实时观察输出变化的工具，常用于监控系统状态或任务进度。

```bash
# 每隔1秒执行一次指定命令，高亮显示变化部分
watch -n 1 -d 'A command'   
# 实用示例：
# 监控系统资源使用情况
watch -n 2 -d 'free -h'                    # 每2秒查看内存使用情况
# 监控目录文件变化
watch -n 5 -d 'ls -lh /data/analysis/'     # 每5秒查看分析目录文件变化
# 监控任务队列状态  
watch -n 3 -d 'qstat'                      # 每3秒查看集群任务状态
# 监控磁盘使用情况
watch -n 10 -d 'df -h'                     # 每10秒查看磁盘空间
# 监控进程状态
watch -n 1 -d 'ps aux | grep python'       # 监控python进程
# 参数说明：
# -n 秒数：设置刷新间隔
# -d：高亮显示发生变化的部分
# 按Ctrl+C退出监控
```

`basename` 是用来从路径中提取文件名，或者去掉文件后缀的命令。

```bash
# 从路径中提取文件名
basename A/B/C.txt          # 显示 C.txt
# 去掉文件的指定后缀
basename A.fa .fa           # 去掉.fa后缀，显示 A
# 更多用法示例：
basename /home/user/data/genome.fasta           # 显示 genome.fasta
basename /home/user/data/genome.fasta .fasta    # 显示 genome
basename sample.tar.gz .tar.gz                  # 显示 sample
```

`head` 和 `tail` 是用来查看文件开头和结尾部分内容的命令，在查看大文件时非常有用。

```bash
# head：查看文件开头部分
head -n 20 A                # 显示文件A的前20行
head A                      # 不指定行数时，默认显示前10行
head -20 A                  # 也可以省略-n，直接写数字
# tail：查看文件结尾部分  
tail -n 20 A                # 显示文件A的最后20行
tail A                      # 不指定行数时，默认显示最后10行
tail -20 A                  # 也可以省略-n，直接写数字
# 实用场景：
head -5 sample.fasta        # 快速查看fasta文件格式和前几条序列
tail -100 analysis.log      # 查看分析日志的最后100行，检查是否出错
# tail的特殊用法：
tail -f analysis.log        # 实时监控日志文件变化（程序运行时查看输出）
tail -f +1 A                # 从第1行开始持续显示文件内容
# 组合使用：
head -100 A | tail -10      # 显示第91-100行内容
```

管道符 `|` 是将前一个命令的输出传递给后一个命令作为输入，重定向符`> <`是将命令的输出保存到文件或从文件读取输入。

```bash
# 管道符 | ：将前一个命令的输出传给后一个命令
ls -l | grep ".txt"         # 先列出文件，再筛选出.txt文件
cat file.fasta | head -10   # 先显示文件内容，再取前10行
history | grep ssh          # 先显示历史命令，再搜索包含ssh的命令
# 多个管道连用
cat data.txt | grep "sample" | wc -l    # 统计包含"sample"的行数
# 重定向符：
# > 输出重定向（覆盖文件）
ls -l > file_list.txt       # 将文件列表保存到文件中
echo "Hello" > output.txt   # 将文本写入文件（覆盖原内容）
# >> 输出追加重定向
echo "World" >> output.txt  # 将文本追加到文件末尾
ls >> log.txt               # 将文件列表追加到日志文件
# < 输入重定向
wc -l < data.txt            # 从文件读取内容并统计行数
# 2> 错误信息重定向
ls /nonexistent 2> error.log    # 将错误信息保存到文件
ls /nonexistent 2>/dev/null     # 将错误信息丢弃（不显示）
# &> 所有输出重定向
command &> all_output.txt   # 将正常输出和错误信息都保存到文件
# 实用组合：
grep "gene" *.fasta | head -20 > results.txt    # 搜索基因信息并保存前20个结果
```

Linux文件权限是控制谁可以对文件进行什么操作的安全机制。

Linux文件权限主要包括：

1. 三种权限类型：读(r)、写(w)、执行(x)

2. 三种用户类型：所有者(owner)、同组用户(group)、其他用户(others)

3. 权限的数字表示：4(读)、2(写)、1(执行)，7=4+2+1(读写执)、5=4+1(读执)

`chgrp`改变文件属组，`chmod`改变访问权限，`setfacl`设置更精细的权限控制。

```bash
# chgrp: 改变文件或目录的属组
chgrp -R st_p17z10200n0246 A        # 将A及其所有子文件的属组改为st_p17z10200n0246
                                    # -R表示递归处理所有子目录和文件
chgrp newgroup file.txt             # 将单个文件的属组改为newgroup
# chmod: 改变文件权限
chmod 755 file.txt                  # 设置权限为755（所有者全权限，其他人读执行）
chmod -R 754 A                      # 递归设置A及子文件权限为754
chmod +x script.sh                  # 给文件添加执行权限
chmod +s ./A                        # 给目录设置粘滞位，使新建文件继承目录的属组
chmod u+w,g-x,o=r file.txt         # 复杂权限设置：所有者加写权限，组用户去执行权限，其他人只读
# setfacl: 设置访问控制列表（ACL），实现更精细的权限控制
setfacl -R -m u:st_stereonote:rx,u:st_notebook:rx,u:bigdata_autoanalysis:rx,u:bigdata_warehouse:rx,u:st_dcscloud_odms:rwx A
# 分解说明：
# -R: 递归应用到所有子文件
# -m: 修改ACL权限
# u:用户名:权限: 为指定用户设置权限
# rx: 读和执行权限
# rwx: 读写执行权限
# setfacl其他用法：
setfacl -m g:biogroup:r file.txt    # 给用户组biogroup设置读权限
setfacl -x u:username file.txt      # 删除特定用户的ACL权限
getfacl file.txt                    # 查看文件的ACL权限设置
```

Linux可以将耗时的命令放在后台运行，这样不会阻塞终端，可以继续执行其他操作。

```bash
# 后台运行命令
command 1>std 2>err &       # 将command放到后台运行
                            # 1>std: 正常输出重定向到std文件
                            # 2>err: 错误信息重定向到err文件
                            # &: 放到后台执行
                            # 注意：如果command内部已有重定向，这里的1>std会覆盖它
nohup command &             # 使用nohup在后台执行命令
                            # 正常输出和错误都重定向到nohup.out文件
                            # 不会覆盖command内部的输出重定向
                            # 即使关闭终端，程序也会继续运行
# 查看后台任务
top                         # 查看系统所有进程状态（按q退出）
htop                        # top的增强版，界面更友好，部分系统不自带，需要自行安装
top -u lizhuoran1           # 只查看指定用户lizhuoran1的进程
jobs                        # 查看当前终端启动的后台任务状态
jobs -l                     # 显示后台任务的详细信息，包括jobID
ps aux                      # 显示系统所有进程详细信息
                            # a=所有进程 u=显示用户 x=包括无终端进程
ps jobID                    # 显示指定ID进程的详细信息（运行时间、命令等）
pwdx jobID                  # 显示指定ID进程的工作目录路径
# 终止后台任务
kill jobID                  # 温和地终止指定ID的后台任务
kill -9 jobID               # 强制终止指定ID的后台任务（无法拒绝）
# htop中终止任务：在htop界面中选择进程，按F9键，选择15 SIGTERM（温和终止）或9 SIGKILL（强制终止）
# 实用示例：
nohup python analysis.py > result.log 2>&1 &    # 后台运行Python分析，所有输出保存到result.log
```

Linux可以将一个命令的输出结果作为另一个命令的参数，我称之为命令嵌套和参数传递。

```bash
# 命令嵌套：将命令输出作为参数
ll `cat list`               # 将list文件中每一行内容作为ll命令的参数
ll $(cat list)              # 同上，两种写法等价，推荐使用$()
# 多重嵌套（只能用$()，不能用反引号）
ll $(cat $(which bowtie2))  # 先执行which bowtie2，结果传给cat，cat的结果传给ll
                            # 多重嵌套时反引号``会出错，必须用$()
# xargs命令：将输入转换为命令参数
echo file1.txt file2.txt file3.txt | xargs rm -rf               
# 将echo的输出（三个文件名）作为rm命令的参数
# 等价于：rm -rf file1.txt file2.txt file3.txt
echo file1.txt file2.txt file3.txt | xargs -I {} mv {} {}.bak   
# -I {}：定义占位符，{}代表每个参数
# 将每个文件重命名为.bak结尾
# 等价于：mv file1.txt file1.txt.bak; mv file2.txt file2.txt.bak; mv file3.txt file3.txt.bak
# 实用示例：
find . -name "*.tmp" | xargs rm              # 删除所有.tmp文件
cat filelist.txt | xargs -I {} cp {} backup/ # 将文件列表中的文件复制到backup目录
ls *.fasta | xargs -I {} wc -l {}            # 统计所有fasta文件的行数
find -name "M*gz" | grep -v "rmhost" | xargs seqkit stat -a -j 32
# 注意事项：
# 1. 多重嵌套只能用$()，不能用``
# 2. xargs后面只能使用实际命令，不能使用alias别名
# 3. {}占位符可以换成其他符号，如{file}，但使用时要保持一致
# 4. 如果不使用占位符，xargs会把所有的内容一次性全部传递给后面的命令
```

`awk` 是Linux中强大的文本处理工具，专门用于处理结构化数据（如表格），可以提取列、计算、筛选和格式化数据。

```bash
# awk基本用法（awk和gawk功能相同，gawk是awk的增强版）
# 提取指定列
awk '{print $1}' A                                              # 提取A文件的第一列，默认用空格分隔
awk '{print $1, $3}' A                                          # 提取第一列和第三列
# 指定分隔符
awk -F '>' '{print $1}' A                                       # 用>作为分隔符
awk -F '\\.e' '{print $1}' A                                    # 用.e作为分隔符，.需要转义成\\.
awk -F[:\\t] '{if($4>=60){print ($9/$11)}else{print 0}}' A.txt  # 用:或制表符\t作为分隔符，[:\\t]表示多种分隔符
# 指定输出格式
awk 'BEGIN {OFS = ","} {print $1, $3}' filename                 # 用逗号作为输出分隔符
# 特殊字段变量
awk -F '/' '{print $NF}' A                                      # $NF表示最后一个字段
                                                                # $0=整行 $1=第一列 $NR=行号
# 数据处理
awk '!a[$1]++{print}' A                                         # 根据第一列去重（去除重复行）
awk '{sum+=$1}'END'{print sum}'                                 # 对第一列数字求和
awk '{ print "Line " NR ": Length = " length($0) }' A           # 输出每行的长度
# 条件筛选
awk 'NR%3==2' tmp1.txt                                          # 输出行号除以3余数为2的行
awk '{if($4>=60){print ($9/$11)}else{print 0}}' A               # 条件判断：第4列>=60就计算比值
# 输出指定范围的列
awk '{for(i=3;i<=NF;i++) printf $i"\t"; print ""}' filename     # 输出第3列到最后一列
awk '{$1=$2=""; print $0}' filename                             # 将前两列置空，输出其余列
# 传递变量
for((i=1;i<=100;i++)); do awk -v a=$i '{print $a}' A; done     # 用-v传递变量，提取第1-100列
# 生物信息学应用示例：
awk -F '\t' '{if($3=="gene") print $1,$4,$5}' annotation.gff    # 从GFF文件提取基因信息
awk '{if(length($2)>50) print $1}' sequences.fasta             # 筛选长度大于50的序列ID
```

`cut` 是用来从文件中提取指定列或字符位置内容的工具，常用于处理结构化数据文件。

```bash
# 按列提取（默认制表符分隔）
cut -f1 A                           # 提取A文件的第1列
cut -f1,3 A                         # 提取第1列和第3列
cut -f1-3 A                         # 提取第1到3列
cut -f1,3-5 A                       # 提取第1列和第3到5列
# 指定分隔符
cut -d, -f1 A                       # 用逗号作为分隔符，提取第1列
cut -d: -f1,3 /etc/passwd           # 用冒号分隔，提取用户名和用户ID
cut -d' ' -f2 A                     # 用空格作为分隔符
# 按字符位置提取
cut -c1-10 A                        # 提取每行的第1到10个字符
cut -c1,5,9 A                       # 提取第1、5、9个字符
cut -c-5 A                          # 提取每行前5个字符
cut -c10- A                         # 提取第10个字符到行尾
# 排除指定列
cut --complement -f2 A              # 提取除第2列外的所有列
# 指定输出分隔符
cut -d, -f1,3 --output-delimiter=: A    # 输入用逗号分隔，输出用冒号分隔
# 实用示例：
cut -f1 gene_list.txt > gene_names.txt         # 提取基因列表的第一列
cut -d, -f2,4 sample_data.csv                  # 从CSV文件提取第2和4列
cut -c1-20 sequences.fasta                     # 提取序列的前20个字符
# 生物信息学应用：
cut -f1,4,5 annotation.gff > gene_coords.txt   # 从GFF文件提取基因坐标
cut -d'|' -f2 protein_ids.txt                  # 从蛋白质ID中提取特定部分
cut -f2- expression_matrix.txt                 # 提取表达矩阵的数据列（去掉基因名）
# 与其他命令结合：
ls -l | cut -d' ' -f1,9                        # 提取文件权限和文件名
cat /etc/passwd | cut -d: -f1,3               # 提取用户名和用户ID
```

`sed` 是Linux中的流编辑器，用来对文本进行查找、替换、删除等编辑操作，支持正则表达式。

```bash
# sed基本替换操作
sed 's/aaa/bbb/' A                  # 将A文件中每行第一个aaa替换为bbb并输出
sed 's/aaa/bbb/g' A                 # 将A文件中所有aaa替换为bbb并输出（g表示全局替换）
# 使用正则表达式
sed 's/^ *//' A                     # 删除每行开头的任意多个空格
sed 's/aa./bbb/g' A                 # 将aa加任意字符替换为bbb（.表示任意字符）
sed '/^$/d' A                       # 删除空行（^$匹配空行，d表示删除）
# 使用变量（需要双引号）
sed "s/${old}/${new}/g" A           # 用变量进行替换，必须使用双引号
# 多个操作
sed -e 's/aaa/bbb/; s/ccc/ddd/' A   # 同时进行两个替换操作
sed -e '/complement/s/CDS/CDS -/g' -e '/complement/!s/CDS/CDS +/g' A
# -e 指定一条编辑命令
# /complement/ 指定条件，即行中要包含complement
# /complement/！ 指定条件，即不包含complement
# s/CDS/CDS -/g 替换
# 直接修改文件
sed -i 's/aaa/bbb/g' A              # -i参数直接修改原文件，不输出到屏幕，用前记得备份原文件
# 删除指定行
sed '1d' A                          # 删除第一行
sed '1,10d' A                       # 删除第1到10行
# 输出指定行
sed -n '1p' A                       # 只输出第一行（-n抑制默认输出，p表示打印）
sed -n '1,10p' A                    # 只输出第1到10行
sed -n "${a}p" A                    # 输出第a行（使用变量）
sed -n "${a},${b}p" A               # 输出第a行到第b行
sed -n '1~2p' A                     # 输出第1,3,5,7...行（~2表示步长为2）
# 处理特殊字符
sed -i 's/\r//' A                   # 删除Windows换行符\r（显示为^M）,不同操作系统使用不同的换行符标准，Windows文件在Linux系统中会出现格式问题，导致程序运行错误。
# sed命令的s(替换)操作允许使用任何字符作为分隔符。通常，我们使用斜杠/作为分隔符，如s/foo/bar/g，这会将所有的foo替换为bar。但是，如果替换的文本中包含斜杠/，使用斜杠作为分隔符就会变得麻烦，因为需要对每个斜杠进行转义。在这种情况下，可以选择其他的字符作为分隔符，如@、#、|、:等.
sed 's#/path/old#/path/new#g' A     # 当替换内容包含/时，可用#作为分隔符
sed 's@old@new@g' A                 # 也可以用@或其他字符作为分隔符
sed 's|old|new|g' A                 # 或使用|作为分隔符
# 生物信息学应用示例：
sed 's/>/>/g' sequences.fasta       # 格式化FASTA文件
sed '/^>/!d' sequences.fasta        # 只保留序列头（以>开头的行）
sed 's/T/U/g' dna.txt              # 将DNA序列中的T替换为U（转录）
```

`grep` 是Linux中的文本搜索工具，用来在文件中查找匹配指定模式的行，支持正则表达式。

```bash
# grep基本用法
grep "a" A                          # 在A文件中匹配包含字母a的每一行
# 正则表达式使用（需要注意转义）
grep "0\.8" A                       # 匹配包含0.8的行，\.表示字面意思的点号
grep "0.8" A                        # .是正则通配符，匹配0加任意字符加8（如008、018、0x8等）
# 上下文输出
grep "a" -A 1 A                     # 匹配包含a的行，并输出该行和下一行(-A 1表示after 1行)
grep "a" -B 2 A                     # 输出匹配行和前2行(-B表示before)
grep "a" -C 3 A                     # 输出匹配行和前后各3行(-C表示context)
# 反向匹配
grep "a" -v A                       # 输出不包含a的行(-v表示取反)
# 从文件读取匹配模式
grep -wf A B                        # 在B文件中匹配A文件的每一行内容，A应为B的子集
                                    # -w表示精确匹配整个单词，-f表示从文件读取模式
grep -wvf A B                       # 在B中查找不匹配A文件内容的行（取反）
# 使用Perl正则表达式
grep -P "a\db" A                    # 匹配a和b之间有一个数字的行
                                    # -P启用Perl正则，\d表示数字，不加-P则\d被视为普通字符
# 只输出文件名
grep -l "a" *                       # 在当前目录查找内容包含a的文件，只输出文件名
# 其他常用选项
grep -i "Hello" A                   # 忽略大小写匹配
grep -n "pattern" A                 # 显示匹配行的行号
grep -c "pattern" A                 # 只显示匹配行的数量
grep -r "pattern" directory/        # 递归搜索目录下的所有文件
# 生物信息学应用示例：
grep ">" sequences.fasta            # 查找FASTA文件中的序列头
grep -c "^>" sequences.fasta        # 统计FASTA文件中的序列数量
grep -v "^#" annotation.gff         # 过滤掉GFF文件中的注释行
```

`find` 是Linux中用来查找文件和目录的强大工具，可以根据文件名、大小、类型等条件递归搜索。

```bash
# 根据文件大小查找
find A -size 0                       # 递归查找A路径下大小为0的文件
find A -maxdepth 1 -size 0           # 仅在A路径中查找大小为0的文件，不搜索子目录
find A -maxdepth 1 -size 0 -delete   # 查找并删除A路径下大小为0的文件（-maxdepth要放在前面）
# 根据文件名查找
find A -name "*a*"                  # 递归查找A路径下名字包含a的文件
find A ! -name "*a*"                # 查找名字不包含a的文件
find A -not -name "*a*"             # 同上，另一种写法
# 根据文件类型查找
find A -type d                      # 递归查找A路径下的所有目录（d=directory）
find A -type f                      # 递归查找A路径下的所有普通文件（f=file）
find A -type l                      # 查找符号链接文件（l=link）
# 执行操作（-exec）, {}代表找到的文件名, \;是-exec的终止符
find A -name "*a*" -exec ls -l {} \;     # 对找到的每个文件执行ls -l命令
find A -name "*a*" -exec du -sh {} \;    # 显示找到文件的大小
find A -type f -exec wc -l {} \;          # 统计所有文件的行数
# 更多查找条件
find A -size +100M                  # 查找大于100MB的文件
find A -size -1k                    # 查找小于1KB的文件
find A -mtime -7                    # 查找7天内修改的文件
find A -name "*.txt" -mtime +30     # 查找30天前的txt文件
# 组合条件
find A -name "*.log" -size +10M     # 查找大于10MB的log文件
find A -type f -name "*.tmp" -delete # 查找并删除所有.tmp文件
# 生物信息学应用示例：
find /data -name "*.fasta" -size 0 -delete    # 删除空的fasta文件
find /analysis -name "*.log" -mtime +30       # 查找30天前的日志文件
find /genome -type d -exec chmod 755 {} \;    # 给所有目录设置755权限
```

`paste` 是用来将多个文件按行对行拼接合并的工具，就像把两张表格并排放在一起。

```bash
# 基本用法
paste A B                           # 将A和B文件按行对应拼接，默认用制表符分隔
# 指定分隔符
paste -d, A B                       # 用逗号作为分隔符拼接A和B文件
paste -d: A B                       # 用冒号作为分隔符
paste -d" " A B                     # 用空格作为分隔符
# 使用变量（进程替换）
paste <(echo $a) <(echo $b)         # 将变量a和b的值按行拼接
# 多个文件拼接
paste A B C                         # 同时拼接三个文件
# 转置文件（行列互换）
paste -s A                          # 将A文件的所有行合并成一行，用制表符分隔
paste -s -d, A                      # 将A文件的所有行合并成一行，用逗号分隔
# 生物信息学应用：
paste sample_names.txt counts.txt > results.tsv     # 合并样本名和计数数据
paste <(cut -f1 file1.txt) <(cut -f2 file2.txt)    # 合并两个文件的指定列
paste -d, gene_ids.txt expression_values.txt        # 制作CSV格式的基因表达数据
# 与其他命令结合：
paste <(ls *.fasta) <(wc -l *.fasta)               # 列出文件名和对应的行数
```

`sort` 是用来对文件内容按行进行排序的工具，可以按字母、数字、指定列等多种方式排序。

```bash
# 基本排序
sort A                              # 将A文件按第一列字母顺序排序
# 按指定列排序
sort A -k 2                         # 按第二列排序
sort -k 3 A                         # 同上，另一种写法
# 指定分隔符
sort -t, -k2 A                      # 用逗号作为分隔符，按第二列排序
sort -t: -k1 /etc/passwd            # 用冒号分隔，按第一列排序
# 数字排序
sort -n -k5 A                       # 按第五列数字大小排序（-n表示数字排序）
sort -t' ' -n -k5 A                 # 指定空格分隔符，按第五列数字排序
# 倒序排序
sort -r A                           # 按第一列倒序排列
sort -nr -k3 A                      # 按第三列数字倒序排列
# 多列排序
sort -k2,2nr -k10,10nr A            # 先按第二列数字倒序，相同时按第十列数字倒序
sort -k1,1 -k2,2n A                 # 先按第一列字母排序，相同时按第二列数字排序
# 其他常用选项
sort -u A                           # 排序并去重（unique）
sort -f A                           # 忽略大小写排序
sort -V A                           # 版本号排序（如file1.txt, file2.txt, file10.txt）
# 实用示例：
sort -nr -k2 gene_expression.txt    # 按表达量倒序排列基因
sort -t, -k3,3n sample_data.csv     # CSV文件按第三列数字排序
sort -k1,1 -k2,2nr results.txt      # 先按样本名排序，再按数值倒序
# 生物信息学应用：
sort -k1,1 -k4,4n annotation.gff    # GFF文件按染色体和位置排序
sort -nr -k6 blast_results.txt      # BLAST结果按得分倒序排列
```

`uniq` 是用来处理重复行的工具，可以去除相邻的重复行、统计重复次数。uniq只能处理相邻的重复行，所以通常先用sort排序。如果要处理整个文件的重复行，必须先排序。

```bash
# 基本用法（只处理相邻的重复行）
uniq A                              # 去除A文件中相邻的重复行
# 统计重复次数
uniq -c A                           # 显示每行出现的次数
sort A | uniq -c                    # 先排序再统计，得到所有重复行的次数
# 只显示重复行
uniq -d A                           # 只显示相邻的重复行
sort A | uniq -d                    # 显示文件中所有的重复行
# 只显示不重复行
uniq -u A                           # 只显示相邻的不重复行
sort A | uniq -u                    # 显示文件中所有的唯一行
# 忽略大小写
uniq -i A                           # 去重时忽略大小写差异
# 跳过字段或字符
uniq -f 1 A                         # 跳过第一个字段进行比较
uniq -s 5 A                         # 跳过前5个字符进行比较
# 常用组合（先排序再去重）
sort A | uniq                       # 去除所有重复行
sort A | uniq -c                    # 统计每行出现次数
sort A | uniq -c | sort -nr         # 按出现次数倒序排列
# 实用示例：
# 统计基因出现频率
sort gene_list.txt | uniq -c | sort -nr
# 找出重复的样本ID
sort sample_ids.txt | uniq -d
# 生物信息学应用：
sort sequences.fasta | uniq > unique_sequences.fasta   # 去除重复序列
cat *.txt | sort | uniq -c > word_count.txt            # 统计词频
sort protein_ids.txt | uniq -u > unique_proteins.txt   # 提取唯一蛋白质
```

`shuf` 是用来随机打乱文件行顺序的工具，常用于随机抽样和数据随机化，每行内容保持不变。`shuf` 每次运行结果都不同（真随机）

```bash
# 基本用法
shuf A                              # 将A文件的行顺序随机打乱并输出
# 随机选择指定行数，-n参数不能超过文件总行数（除非使用-r允许重复）
shuf -n 10 A                        # 随机打乱A文件，输出前10行
shuf -n 5 gene_list.txt             # 从基因列表中随机选择5个基因
# 输出到文件
shuf A -o B                         # 将A文件随机打乱后保存到B文件
shuf A -o A                         # 直接修改原文件A（将A文件本身随机打乱）
# 与管道符配合
cat A | shuf                        # 查看A文件内容并随机打乱
ls *.txt | shuf                     # 随机打乱文件列表顺序
# 生成随机数序列
shuf -i 1-100                       # 生成1到100的随机排列
shuf -i 1-100 -n 10                 # 从1到100中随机选择10个数
# 重复抽样
shuf -r -n 20 A                     # 允许重复抽样，输出20行（可能有重复）
# 实用示例：
shuf sample_list.txt -n 50 > random_samples.txt     # 随机选择50个样本
shuf -n 1000 large_dataset.txt > test_data.txt      # 从大数据集随机抽取1000行作为测试数据
# 生物信息学应用：
shuf sequences.fasta -n 100 > random_sequences.fasta    # 随机选择100条序列
shuf patient_data.txt -n 200 > training_set.txt         # 随机选择200个患者数据作为训练集
cat *.fastq | shuf > shuffled_reads.fastq               # 随机打乱测序reads顺序
```

压缩与解压是Linux中常用的文件管理操作，可以节省存储空间和加快文件传输速度。

```bash
# zip格式（跨平台兼容性好）
zip -r A.zip A                          # 将A文件夹递归压缩成A.zip格式
unzip A.zip                             # 解压A.zip文件，直接生成原文件夹
# gzip格式（Linux最常用）
gzip A                                  # 压缩文件A，生成A.gz，原文件被删除
gzip -d A.gz                            # 解压.gz文件，原压缩文件被删除
gunzip A.gz                             # 同上，解压.gz文件
gunzip -c A.gz > A                      # 解压并重定向输出，保留原压缩文件
# tar打包（常与gzip结合使用）
tar cvzf A.tar.gz A                     # 将A文件夹打包压缩成A.tar.gz
tar xvzf A.tgz                          # 解压.tgz或.tar.gz文件到当前目录
tar -cI 'gzip -9' -f A.tar.gz A         # 使用最高压缩级别打包
# tar参数说明：
# c=创建打包  x=解压  v=显示详细过程  f=指定文件名
# z=使用gzip  j=使用bzip2 J=使用xz 
# t=列出内容  r=追加文件
# pigz（gzip的多线程版本，速度更快），系统不自带，需自行下载
pigz -p 4 -k -6 A                       # -p 4用4线程压缩文件A，-k保留原文件，-6压缩级别6
tar cf - A | pigz -p 4 -6 > A.tar.gz    # 打包并用pigz压缩文件夹
pigz -d -p 4 A.gz                       # 用4线程解压.gz文件
# 多线程压缩时pigz将数据分块，每个线程压缩一个块，生成多块gzip格式。只有用pigz多线程压缩生成的gzip文件，才能真正实现多线程解压。
# 特殊用法
tar --no-same-owner -xvf archive.tar    # 解压时不保留原文件所有者，使用当前用户
# 压缩级别说明：
# 1-9：数字越大压缩率越高，但耗时越长
# 默认通常是6，最高是9，pigz有更高的压缩等级10，更加耗时但不会明显提高压缩率，不推荐
# 生物信息学常用场景：
gzip *.fastq                            	 # 压缩所有测序文件
tar cvzf analysis_results.tar.gz results/    # 打包分析结果
pigz -p 8 -k large_genome.fasta         	 # 多线程压缩大基因组文件
# 查看压缩文件内容（不解压）
tar -tvf archive.tar.gz                 	 # 列出tar.gz文件内容
zcat file.gz                            	 # 直接查看.gz文件内容
```

`ln` 用于创建文件链接（link），类似于 Windows 的快捷方式，但更强大。

```bash
# 创建符号链接（软链接）- 最常用，软链接是指向文件路径的指针。类似快捷方式，源文件删除会失效
ln -s source.txt link.txt
# -f: 强制覆盖已存在的链接
ln -sf new_source.txt existing_link.txt 
# 创建硬链接，硬链接是同一文件的另一个入口，删除源文件不受影响
ln source.txt link.txt
```

`which` 命令用来查找可执行程序的完整路径，告诉你系统在哪里找到了某个命令。

```bash
# 查找单个命令的位置
which python                    # 显示python命令的完整路径，如 /usr/bin/python
```

Linux中的条件判断用来根据变量值、文件状态等条件执行不同操作，主要有`[ ]`和`(( ))`两种语法。

```bash
# 条件判断基本语法
if [ 条件 ]; then 命令; else 命令; fi
if (( 条件 )); then 命令; else 命令; fi

# [ ] 与 (( )) 的区别：
# [ ]：bash内建命令，可处理整数和字符串，变量需要加$
# (( ))：bash语法结构，只能处理整数，变量可省略$（建议保留）

# 整数比较 - 使用[ ]
if [ $a -eq 1 ]; then echo "1"; else echo "0"; fi       # 等于
if [ $a -ne 1 ]; then echo "1"; else echo "0"; fi       # 不等于
if [ $a -gt 1 ]; then echo "1"; else echo "0"; fi       # 大于
if [ $a -lt 1 ]; then echo "1"; else echo "0"; fi       # 小于
if [ $a -ge 1 ]; then echo "1"; else echo "0"; fi       # 大于等于
if [ $a -le 1 ]; then echo "1"; else echo "0"; fi       # 小于等于

# 整数比较 - 使用(( ))（支持算术运算）
if (( $a == 1 )); then echo "1"; else echo "0"; fi      # 等于
if (( $a != 1 )); then echo "1"; else echo "0"; fi      # 不等于
if (( $a > 1 )); then echo "1"; else echo "0"; fi       # 大于
if (( $a < 1 )); then echo "1"; else echo "0"; fi       # 小于
if (( $a >= 1 )); then echo "1"; else echo "0"; fi      # 大于等于
if (( $a <= 1 )); then echo "1"; else echo "0"; fi      # 小于等于

# 字符串比较（只能用[ ]）
if [ "$a" = "abcd" ]; then echo "1"; else echo "0"; fi  # 字符串相等（推荐加引号）
if [ $a != $b ]; then echo "1"; else echo "0"; fi       # 字符串不等
if [ -z "$a" ]; then echo "1"; else echo "0"; fi        # 字符串为空
if [ -n "$a" ]; then echo "1"; else echo "0"; fi        # 字符串不为空

# 文件测试（只能用[ ]）
if [ -f $a ]; then echo "1"; else echo "0"; fi          # 是普通文件
if [ -d $a ]; then echo "1"; else echo "0"; fi          # 是目录
if [ -e $a ]; then echo "1"; else echo "0"; fi          # 文件存在
if [ -r $a ]; then echo "1"; else echo "0"; fi          # 文件可读
if [ -w $a ]; then echo "1"; else echo "0"; fi          # 文件可写
if [ -x $a ]; then echo "1"; else echo "0"; fi          # 文件可执行

# 逻辑运算 - [ ]中的方式
if [ $a -ne 1 ] && [ $b -ne 1 ]; then echo "1"; else echo "0"; fi    # 与（推荐）
if [ $a -ne 1 ] || [ $b -ne 1 ]; then echo "1"; else echo "0"; fi    # 或（推荐）
if [ ! -f $a ]; then echo "1"; else echo "0"; fi                     # 非
if [ -f $a -a -r $a ]; then echo "1"; else echo "0"; fi              # 与（-a）
if [ -f $a -o -r $a ]; then echo "1"; else echo "0"; fi              # 或（-o）

# 逻辑运算 - (( ))中的方式
if (( $a == 1 && $b == 1 )); then echo "1"; else echo "0"; fi        # 与
if (( $a == 1 || $b == 1 )); then echo "1"; else echo "0"; fi        # 或

# 复杂条件组合（使用括号控制优先级）
if [ -f $a -a \( -r $a -o -d $a \) ]; then echo "1"; else echo "0"; fi
# 如果$a是文件 并且 （可读 或者 是目录）

# 算术运算（只有(( ))支持）
if (( a+1 == b )); then echo "1"; else echo "0"; fi     # 加法
if (( a*2 == b )); then echo "1"; else echo "0"; fi     # 乘法
if (( a%2 == b )); then echo "1"; else echo "0"; fi     # 取余
if (( a**2 == b )); then echo "1"; else echo "0"; fi    # 幂运算

# 注意事项：
# 1. [ ]内的空格是必须的
# 2. 字符串变量建议用双引号包围
# 3. 复杂条件建议分成多个[ ]用&&、||连接
# 4. (( ))中变量的$可省略，但建议保留以保持一致性
```

Linux中的循环用来重复执行命令，主要有for、while、until三种类型，可以遍历数字、字符、文件内容等。

```bash
# for循环 - 数字范围
for i in {1..5}; do echo $i; done                           # i从1到5
for i in {5..1}; do echo $i; done                           # i从5到1（倒序）
for i in {1..5..2}; do echo $i; done                        # i从1到5，步长为2（1 3 5）
for i in {a..z}; do echo $i; done                           # 字母序列a到z
for i in {a..z..2}; do echo $i; done                        # 字母序列，步长为2（a c e g...）
# for循环 - 使用seq命令
for i in $(seq 1 5); do echo $i; done                       # i从1到5
for i in $(seq 1 2 5); do echo $i; done                     # i从1到5，步长为2
for i in $(seq 5 -1 1); do echo $i; done                    # i从5到1，步长为-1
for i in $(seq 5 -2 1); do echo $i; done                    # i从5到1，步长为-2
# for循环 - C语言风格
for((i=1;i<=5;i++)); do echo $i; done                       # i从1到5，递增
for((i=5;i>=1;i--)); do echo $i; done                       # i从5到1，递减
# for循环 - 遍历列表
for i in a b c; do echo $i; done                            # 遍历指定值
for i in "$@"; do echo $i; done                             # 遍历命令行参数（推荐）
for i in $*; do echo $i; done                               # 遍历命令行参数
for i in *.txt; do echo $i; done                            # 遍历当前目录所有.txt文件
# for循环 - 命令输出
for i in $(command); do echo $i; done                       # 遍历command的输出结果
for i in `command`; do echo $i; done                        # 同上，反引号写法

# while循环 - 条件为真时执行
while [ $i -le 5 ]; do echo $i; i=$((i+1)); done          # 使用[]条件判断
while (( i <= 5 )); do echo $i; ((i++)); done             # 使用(())条件判断

# until循环 - 条件为假时执行
until [ $i -gt 5 ]; do echo $i; i=$((i+1)); done          # 直到i大于5停止
until (( i > 5 )); do echo $i; ((i++)); done              # 同上，使用(())

# 读取文件循环
while read line; do echo $line; done < file                # 从文件读取每一行
cat file | while read line; do echo $line; done            # 同上，管道方式
for i in `cat file`; do echo $i; done                      # 按单词读取文件内容
# 生物信息学应用示例：
for sample in $(cat sample_list.txt);                      
do 
    echo "Processing $sample"
    blast -query $sample.fasta -out $sample.blast
done

for i in {1..22} X Y;                                      
do                                    
    echo "Processing chromosome $i"
    process_chromosome.sh chr$i.fa
done

while read gene_id; 
do
    echo "$gene_id is highly expressed"
done < expression_data.txt
```

`split` 是用来将大文件拆分成多个小文件的工具，常用于处理大型数据文件，便于传输和处理。

```bash
# 按文件大小拆分（保持行完整性）
split -C 1M A.fasta nc_ -a 1 --numeric-suffixes=1 --additional-suffix=.fasta
# 将A.fasta拆分成1M大小的文件，命名为nc_1.fasta, nc_2.fasta...
# -C: 按大小拆分但保持行完整性
# -a 1: 后缀只用1个字符
# --numeric-suffixes=1: 从数字1开始命名生成文件
# --additional-suffix=.fasta: 生成文件添加.fasta后缀
# 按文件大小拆分（精确切割，可能断行）
split -b 1M A.fasta nc_ -a 2 -d --additional-suffix=.fasta
# -b: 严格按大小拆分，可能会在行中间切割
# -d: 使用数字后缀，从0开始（等同于--numeric-suffixes=0）
# 按行数拆分
split -l 1000 A.fasta nc_ -a 1 --numeric-suffixes=1 --additional-suffix=.fasta
# 每1000行拆分成一个文件
split -l 1 A.fasta nc_ -a 1 --numeric-suffixes=1 --additional-suffix=.fasta
# 每行拆分成一个文件，每个文件只有一行
# 大小单位说明
split -C 500K file.txt part_
split -C 2G file.txt part_  
split -C 1T file.txt part_
# 支持单位：K M G T P E Z Y
# 后缀格式控制
split -l 1000 file.txt part_ -a 3 -d
# 生成part_000, part_001, part_002...（3位数字后缀）
split -l 1000 file.txt part_ -a 2
# 生成part_aa, part_ab, part_ac...（2位字母后缀，默认）
# 生物信息学应用示例：
# 拆分大型FASTA文件
split -C 100M genome.fasta chr_ -a 2 -d --additional-suffix=.fasta
# 生成chr_00.fasta, chr_01.fasta...
# 拆分FASTQ文件（按reads数量）
split -l 40000 reads.fastq sample_ -a 3 --numeric-suffixes=1 --additional-suffix=.fastq
# 每10000条reads一个文件（FASTQ每条reads占4行）
# 拆分基因列表
split -l 100 gene_list.txt batch_ -a 2 -d --additional-suffix=.txt
# 每100个基因一个批次文件
# 拆分大型表达矩阵
split -C 50M expression_matrix.txt matrix_part_ -a 2 --numeric-suffixes=1 --additional-suffix=.tsv
# 与其他命令结合使用
# 统计拆分后的文件
ls part_* | wc -l                # 统计拆分出多少个文件
wc -l part_*                     # 统计每个文件的行数
# 重新合并文件
cat part_* > merged_file.txt     # 按字母/数字顺序合并
# 实用技巧：
# 1. -C比-b更适合处理文本文件，因为保持行完整性
# 2. 处理生物序列文件时建议用-C避免序列被截断
# 3. -a参数要根据预期的拆分文件数量来设置，避免后缀不够用
```



### Bioinformatics Software Download, Installation, and Execution

`conda` (https://github.com/conda/conda) 是跨平台的包管理和环境管理工具，`mamba` (https://github.com/mamba-org/mamba) 是用C++重写的conda，解决依赖速度更快，命令与`conda`基本相同。

```bash
# 安装conda及mamba
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
sh Miniforge3-Linux-x86_64.sh          			# 安装时需要选择工作路径
bash Miniforge3.sh -b -p "/path/to/miniforge3"	# 静默安装，推荐
mamba shell init                                # 初始化mamba并写入.bashrc中，如果想初始化conda，则运行conda init
# 我印象里旧版本的mamba的激活命令是mamba init，不知道从哪个版本开始变成mamba shell init
# 如果安装的mamba不适用于mamba shell init，可以尝试mamba init
# 环境管理（以下及后续部分中的命令里的conda均可替换为mamba）
conda create -n amita                   		# 创建名为amita的环境
conda activate amita                    		# 激活amita环境
conda deactivate                        		# 退出当前环境
# 软件安装和管理
conda install -c conda-forge -c bioconda A  	# 从指定频道安装软件
# conda-forge含有通用软件（Python包、数学库等）
# bioconda含有生物信息学专用软件（BLAST等）
# 在conda中，当指定多个频道时，conda会按照从左到右的顺序来搜索包
conda uninstall A                       		# 卸载软件A
conda update -c conda-forge -c bioconda A       # 更新软件
# 指定版本安装
mamba install -y -c conda-forge "numpy>=1.20.0"                 # 安装大于等于1.20.0版本，-y在安装时跳过确认步骤
mamba install -y -c conda-forge "numpy=1.20.0"                  # 安装指定版本
mamba install -y -c conda-forge "numpy>=1.20.0" "numpy<1.21.0"  # 安装版本范围
# 创建环境时同时安装软件
mamba create -n amita "python=3.8" "numpy=1.20.0"
mamba create -n amita -c conda-forge -c bioconda "python=3.5" "numpy>=1.20.0"
# 环境重命名（通过克隆实现）
conda create --name hamburger --clone prokka    # 克隆环境并重命名
conda remove --name prokka --all                # 删除原环境
```

如果你的工作环境网络无法顺畅访问境外网站，建议添加国内镜像源，conda默认从海外服务器下载软件很慢，使用国内镜像源（如清华源）更合适。

```bash
# 添加清华大学镜像源加速下载
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/			# 对应-c defaults
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/			# 对应-c defaults
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/	# 对应-c conda-forge
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/		# 对应-c bioconda
# 查看当前配置的镜像源
conda config --show channels
# R语言包镜像源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/r/				# 对应-c r
# PyTorch镜像源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/		# 对应-c pytorch
# NVIDIA镜像源
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/nvidia/			# 对应-c nvidia
# 建议：不要一次性全加，按实际需求添加，因为镜像源太多可能导致软件包依赖冲突
# 一般来说前面4个(main、free、conda-forge、bioconda)就够用了
# 只有在运行conda命令时使用-c手动指定了channel，才会从对应的镜像源进行下载。
# 除了使用命令设置镜像源外，也可以手动更改.condarc的内容实现配置。
conda info | grep "user config file"		#寻找.condarc的位置，通常为 ~/.condarc
# 找到.condarc后，使用vim或其他方式打开，进行编辑。如下即可
channels:
  - conda-forge
  - bioconda
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  r: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

也许你在安装完miniforge3后，重启了bash，依旧找不到mamba（通常是由于~/.bashrc文件里没有配置），可以随便在一个文件里写下如下内容，然后使用 `source` 激活（例如，如果你将下列内容写在~/.bashrc里，只需 `source ~/.bashrc` 即可）

```bash
# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
export MAMBA_EXE='/home/zoran/software/miniforge3/bin/mamba';	#此路径需要根据实际情况进行替换，下同
export MAMBA_ROOT_PREFIX='/home/zoran/software/miniforge3';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup
# <<< mamba initialize <<<
```

`pip`  (https://pypi.org/project/pip/) 是Python的包管理工具，用来安装和管理Python软件包，很多生物信息学的Python工具除了通过conda安装外，也可以通过pip安装。使用conda在环境里安装了python时，也会一并安装pip及相关的工具。

```bash
# 基本用法
pip install numpy                    	# 安装软件包
pip install numpy==1.20.0          		# 安装指定版本
pip install "numpy>=1.20.0"        		# 安装版本范围
pip uninstall numpy                 	# 卸载软件包
pip list                            	# 查看已安装的包
pip show numpy                      	# 查看包详细信息
pip upgrade numpy                   	# 更新软件包
# 从requirements文件批量安装
pip install -r requirements.txt
# 导出当前环境的包列表
pip freeze > requirements.txt
# 查看pip配置信息和配置文件位置
pip config list
pip config debug
# 配置国内镜像源（加速下载）
# 方法1：临时使用
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple/ biopython
pip install biopython -i https://pypi.tuna.tsinghua.edu.cn/simple/ --trusted-host pypi.tuna.tsinghua.edu.cn
# 方法2：永久配置（推荐）
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
# 手动编辑配置文件
# 一般位于 ~/.pip/pip.conf 或 ~/.config/pip/pip.conf
# 配置文件内容：
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple/
trusted-host = pypi.tuna.tsinghua.edu.cn
```

接下来是其他软件的安装，大部分基于conda和pip。

对要安装的软件或包，可先在 https://anaconda.org 里进行搜索，以确定安装的channel。

> [!WARNING]
>
> channel中的软件版本可能不是最新的，而且有些软件包并非由原作者上传和维护，版本更新可能滞后。
>
> 对于重要的分析软件，优先使用官方推荐的安装方式，conda版本可作为备选。

BWA (https://github.com/lh3/bwa) 是用来将测序数据比对到参考基因组的工具，相当于把测序得到的短片段DNA序列找到它们在完整基因组上的正确位置。

```bash
# 安装
git clone https://github.com/lh3/bwa.git
cd bwa
make
# 也可使用conda安装
mamba install -y -c bioconda bwa
# 使用
bwa index reference.fasta
bwa mem -t 8 reference.fasta sample_R1.fastq sample_R2.fastq > sample.sam  # -t指定线程数
```

SOAPnuke (https://github.com/BGI-flexlab/SOAPnuke) 是BGI开发的二代测序数据质量控制工具，用来去除低质量序列、接头序列和污染序列，提高测序数据质量。我没用过，就不介绍用法了。

```bash
# 安装
git clone https://github.com/BGI-flexlab/SOAPnuke.git
cd SOAPnuke
make
```

seqkit (https://bioinf.shenwei.me/seqkit/) 是一个高效的序列处理工具包，用来对FASTA/FASTQ格式的序列文件进行统计、过滤、格式转换、序列提取等各种操作。

```bash
# 安装
mamba install -y -c bioconda seqkit
# 使用
seqkit fx2tab --gc A.fa                                         # 计算A序列的GC含量
seqkit stat A.fa                                                # 统计A信息
seqkit stat -a A.fa                                             # 统计A详细信息
seqkit rmdup -i A.fa > B.fa                                     # 按照序列的ID去冗余
seqkit rmdup -s A.fa > B.fa                                     # 按照序列相似度去冗余，只有完全相同的序列才会被去重
# 抓取
seqkit grep -n -f A.id B.fa > C.fa                              # 按照A文件中的ID，提取B文件中对应ID的序列
																# -n按名字提取，两个文件的ID要完全一样才可以提取输出。
																# 如不加-n，则默认按照ID提取
seqkit grep -p "gene_675" B.fa > C.fa                           # 按照B文件中的序列名，将含有gene_675的序列提取出来输出至C文件
																# 按work进行完全匹配，不必担心匹配到其他序列
# 分割
seqkit split -i A.fa                                            # 按照序列的ID，将A文件中的序列拆分成单个序列
seqkit split -p 100 A.fa                                        # 将A文件中的序列拆分成100个序列为一组的文件
# 随机抽提
seqkit sample -s 100 -n 1000 A.fa > B.fa                        # 随机抽取1000个序列输出至B文件
																# -s 100表示随机种子，-n 1000表示抽取的序列数
seqkit sample -s 100 -p 0.5 A.fa > B.fa                         # -s 100表示随机种子，-p 0.5表示抽取的比例
seqkit sample -s 100 -p 0.5 A.fa.gz | pigz -p 8 -6 > B.fa.gz    # 抽提并压缩；seqkit支持处理压缩文件，但不支持输出压缩文件
# 随机种子是用来控制随机过程的一个数字，设置相同种子能确保每次得到相同的"随机"结果，保证数据分析的可重现性。
# 排序
seqkit sort -l A.fa > B.fa                                      #将序列按照长度排序由短到长输出
seqkit sort -lr A.fa > B.fa                                     #将序列按照长度排序由长到短输出
# 过滤
seqkit seq -m 6000 A.fa > B.fa                                  #将序列长度大于6000的序列输出
seqkit seq -m 6000 -M 10000 A.fa > B.fa                         #将序列长度在6000-10000之间的序列输出
# ID修改
cat CPB0314_test8.fa | head -n 1 | sed 's/>//g' | xargs -I @ seqkit replace -p "@" -r CPB0314 CPB0314_test8.fa > CPB0314.fa #将CPB0314_test8.fa文件中的第一行的ID替换为CPB0314，输出至CPB0314.fa文件
```

fastp (https://github.com/OpenGene/fastp) 是一个快速的FASTQ数据质控和预处理工具，集成了质量过滤、接头去除、质量报告等功能。

```bash
# 安装
mamba install -y -c bioconda fastp
# 双端测序数据质控（输出未压缩文件）
fastp -i A_1.fastq.gz -o A_1.fq -I A_2.fastq.gz -O A_2.fq -5 -3 -q 20 -w 8 -c -j fastp.json -h fastp.html -R out.prefix -l 30
# 双端测序数据质控（输出压缩文件，推荐）
fastp -i A_1.fastq.gz -o A_1.fq.gz -I A_2.fastq.gz -O A_2.fq.gz -5 -3 -q 20 -w 8 -z 9 -c -j fastp.json -h fastp.html -R out.prefix -l 30
# 参数说明：
# -i/-I    输入文件（R1/R2）
# -o/-O    输出文件（R1/R2）
# -5/-3    对5'端和3'端进行质量剪切
# -q 20    质量值阈值（低于20的碱基会被剪切）
# -w 8     使用8个线程（fastp最多支持16线程）
# -c       启用序列校正功能
# -l 30    输出序列的最短长度阈值（短于30bp的序列被丢弃）
# -j       输出JSON格式的质控报告
# -h       输出HTML格式的质控报告（可在浏览器中查看）
# -R       设置报告文件的标题前缀
# -z 9     压缩等级（1-9，数字越大压缩越好但耗时更长）
```

CheckV (https://bitbucket.org/berkeleylab/checkv) 是一款全自动命令行流程工具，用于评估单条连续病毒基因组质量，其功能包括：识别整合原病毒中的宿主污染、评估基因组片段的完整性，以及鉴定完整闭合基因组。

```bash
# 安装
mamba create -n checkv
mamba activate checkv
mamba install -y -c conda-forge -c bioconda checkv
# 下载数据库
wget https://portal.nersc.gov/CheckV/checkv-db-v1.5.tar.gz
tar zxvf checkv-db-v1.5.tar.gz
cd checkv-db/genome_db
diamond makedb --in checkv_reps.faa --db checkv_reps
# 使用
checkv end_to_end input.fa output_path -d checkv-db-v1.5 -t 8
```

prodigal (https://github.com/hyattpd/Prodigal) 是用来预测原核生物（细菌和古菌）基因组中蛋白质编码基因的工具，能够自动识别和标注基因的位置和方向。

```bash
# 安装
git clone https://github.com/hyattpd/Prodigal
cd Prodigal
make install INSTALLDIR=/where/i/want/prodigal/
# 使用
prodigal -i input_genome.fasta -o genes.gff -a proteins.faa -d genes.fna -p meta -f gff -c
# 参数详解：
# -i input_genome.fasta   输入的基因组序列文件
# -o genes.gff            输出基因位置信息（GFF格式，包含基因坐标）
# -a proteins.faa         输出预测的蛋白质序列（氨基酸序列）
# -d genes.fna            输出基因的DNA序列（核酸序列）
# -p meta                 使用宏基因组模式（适合多个物种混合的样本）
# -f gff                  指定输出格式为GFF
# -c                      只预测完整基因（不预测部分基因）
```

BLAST (https://blast.ncbi.nlm.nih.gov/Blast.cgi) 是用来比较序列相似性的工具，能找到与你的查询序列相似的已知序列，用于基因功能注释和同源性分析。需要先用makeblastdb建立数据库索引，再用blastn/blastp等程序进行序列比对。

```bash
# 安装，很多软件包内都有BLAST，可以不必单独安装。比如CheckV的软件包里就有。
wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.16.0+-x64-linux.tar.gz
tar zxvf ncbi-blast-2.16.0+-x64-linux.tar.gz
# 建立BLAST数据库
makeblastdb -in A.fasta -dbtype prot -parse_seqids -out index
# -in           输入的序列文件（所有序列需写在同一个文件中）
# -dbtype       数据库类型（prot=蛋白质，nucl=核酸）  
# -parse_seqids 解析序列ID（推荐加上）
# -out          输出数据库前缀名（会生成一系列以index为前缀的索引文件）
# 蛋白质序列比对蛋白质数据库
blastp -query MF19343.faa -db alphafold_db.fasta -outfmt 6 -evalue 1e-5 -out result.txt
# 核酸序列比对核酸数据库（自定义输出格式）
blastn -query CPB1015.fa -db ./index -outfmt "6 qseqid sseqid qcovs qcovhsp pident length mismatch gapopen qstart qend sstart send evalue bitscore" -evalue 1e-5 -out ./CPB1015_blastn.txt
# 参数说明：
# blastn			核酸序列比对核酸序列
# blastp			蛋白序列比对蛋白序列
# -query       		查询序列文件
# -db          		数据库路径，makeblastdb生成的索引前缀
# -outfmt 6    		表格输出格式
# -evalue 1e-5 		期望值阈值（一般设置为1e-5）
# -out         		输出结果文件
# 自定义输出字段含义：
# qseqid: 查询序列ID	sseqid: 目标序列ID
# qcovs: 查询覆盖度	    pident: 相似度百分比
# length: 比对长度      evalue: 期望值
# bitscore: bit分数
```

HMMER (http://hmmer.org/) 是基于隐马尔科夫模型(HMM)的蛋白质序列分析工具包，主要用于蛋白质功能域预测和同源序列搜索。

```bash
# 安装
wget http://eddylab.org/software/hmmer/hmmer-3.4.tar.gz
tar zxf hmmer-3.4.tar.gz
cd hmmer-3.4
./configure --prefix /path/to/hmmer
make
make check
make install
```

seqtk (https://github.com/lh3/seqtk) 是一个轻量级的序列处理工具包，用来对FASTA/FASTQ文件进行采样、过滤、格式转换、统计等快速操作。

```bash
# 安装
git clone https://github.com/lh3/seqtk.git
cd seqtk
make
# 随机抽提
seqtk sample -s 25 input.fastq 1000 > sample.fastq   # 设定随机种子抽样
```

SPAdes (https://ablab.github.io/spades/) - St. Petersburg genome assembler - a versatile toolkit designed for assembling and analyzing sequencing data from Illumina and IonTorrent technologies. In addition, most of SPAdes pipelines support a hybrid mode allowing the use of long reads (PacBio and Oxford Nanopore) as supplementary data.

> [!WARNING]
>
> spades组装吃内存，尽量不要并行太多。

```bash
# 安装（非官方源）
mamba install -y -c conda-forge -c bioconda spades # 也可以从源码进行编译安装，我测试时发现有些依赖冲突难解决，这里用conda安装，测试没问题
# 组装
python spades.py -k 21,45,63 --careful -1 A_1.fq -2 A_2.fq -o result -t 32
python spades.py --careful -1 A_1.fq -2 A_2.fq -o result -t 32
python spades.py --isolate -1 A_1.fq -2 A_2.fq -o result -t 32
python spades.py --meta -1 A_1.fq -2 A_2.fq -o result -t 32
# 参数介绍：
# -k        	指定组装时使用的kmer组合，如不指定，会使用默认的kmer组合
# --careful 	指定组装模式，careful是减少错误组装的高质量模式
# --isolate 	分离株模式(确认用于测序的基因组来源于分离株)
# --meta    	宏基因组组装模式
# -t        	指定线程数，spades最多只使用32线程
# 主要输出文件：
# contigs.fasta    		- 组装的contigs序列
# scaffolds.fasta  		- 组装的scaffolds序列
# assembly_graph.gfa 	- 组装图文件
# spades.log       		- 运行日志
```

QUAST (https://github.com/ablab/quast) 是用来评估基因组组装质量的工具，能够统计组装结果的各种指标如N50、组装长度等。

```bash
# 安装
mamba create -n quast -y -c conda-forge -c bioconda quast
# 使用
python quast.py -o result input.fa
```

seqret (http://emboss.open-bio.org/) 是EMBOSS软件包中的序列格式转换工具，能在各种序列格式之间进行转换。

```bash
# 安装
mamba install -y -c conda-forge -c bioconda emboss
# 使用
seqret -sequence input.fa -feature -fformat gff -fopenfile input.gff -osformat genbank -outseq output.gbk
# 参数详解：
# -sequence        		输入的序列文件（FASTA格式）
# -feature         		启用特征信息处理
# -fformat gff     		指定特征文件格式为GFF
# -fopenfile       		输入的注释文件路径（GFF格式）
# -osformat genbank 	输出格式为GenBank格式
# -outseq           	输出文件名
```

Bowtie2 (https://github.com/BenLangmead/bowtie2) 是一个快速准确的短序列比对工具，用来将测序数据比对到参考基因组上。

```bash
# 安装
mamba install -y -c bioconda bowtie2
# 使用前需要先建立索引
bowtie2-build reference.fasta ref.fa
# 完整的比对流程（一条命令完成比对、格式转换、排序），需额外安装samtools
bowtie2 -p 32 -x ref.fa -1 A_1.fastq -2 A_2.fastq --very-sensitive | samtools view -bS | samtools sort -@ 20 -o sorted_bowtie2.bam
# 参数详解：
# -p 32              	使用32个线程并行处理
# -x ref.fa          	参考基因组索引前缀
# -1 A_1.fastq       	双端测序的第一个文件（R1）
# -2 A_2.fastq       	双端测序的第二个文件（R2）
# --very-sensitive   	使用最敏感的比对模式（更准确但较慢）
```

samtools是用来处理SAM/BAM格式比对文件的工具包，提供格式转换、排序、索引、统计、提取等各种操作功能。

```bash
# 安装
wget https://github.com/samtools/samtools/releases/download/1.21/samtools-1.21.tar.bz2
tar -xjf samtools-1.21.tar.bz2
cd samtools-1.21
./configure --prefix=/where/to/install
make
make install
# 格式转换
samtools view -bS input.sam > output.bam          # SAM转BAM（二进制压缩）
samtools view -h input.bam > output.sam           # BAM转SAM（文本格式）
samtools view -b -F 4 input.bam > output.bam	  # -F 4 过滤掉flag值为4的序列（flag 4 = 未比对
# 排序索引
samtools sort input.bam -o sorted.bam             # 按坐标排序
samtools index sorted.bam                         # 建立索引（生成.bai文件）
samtools stats sorted.bam						  # 给出整体详细统计
samtools idxstats sorted.bam					  # 给出按序列分组的简要统计，必须用排序和索引后的
```

bedtools (https://bedtools.readthedocs.io/) ，功能很多，我只用过bamToFastq

```bash
# 安装
wget https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz
tar -zxvf bedtools-2.31.1.tar.gz
# bamtofq
bedtools bamtofastq -i input.bam -fq output_R1.fastq -fq2 output_R2.fastq
```

Prokka (https://github.com/tseemann/prokka) 是一个快速的原核生物基因组注释工具，能够自动预测基因、tRNA、rRNA并进行功能注释，是细菌基因组注释的标准工具。

```bash
# 安装
mamba install -y -c conda-forge -c bioconda prokka
# 使用
prokka --prefix ID --locustag ID --addgenes --addmrna --plasmid Plasmid --gcode 11 --outdir A --mincontiglen 100 A.fasta
# 参数详解：
# --prefix ID         		输出文件的前缀名（所有输出文件都以ID开头）
# --locustag ID       		基因标签的前缀（如ID_00001, ID_00002）
# --addgenes          		在输出中添加gene特征信息
# --addmrna           		在输出中添加mRNA特征信息
# --plasmid Plasmid   		指定序列为质粒，质粒名为"Plasmid"
# --gcode 11          		使用遗传密码表11（细菌和古菌标准密码表）
# --outdir A          		输出目录为A文件夹
# --mincontiglen 100  		只注释长度≥100bp的contigs
# A.fasta             		输入的基因组序列文件
```

batka (https://github.com/oschwengers/bakta)：Rapid & standardized annotation of bacterial genomes, MAGs & plasmids

```bash
# 安装
mamba create -n batka -y -c conda-forge -c bioconda bakta
# 下载安装数据库
wget https://zenodo.org/record/14916843/files/db-light.tar.xz
bakta_db install -i db-light.tar.xz
# 使用
bakta --db <db-path> genome.fasta
bakta --db <db-path> --verbose --output results/ --prefix ecoli123 --locus-tag eco634 --prodigal-tf eco.tf --replicons replicon.tsv --threads 8 genome.fasta
# 详细输出结果写入results目录，包含ecoli123文件prefix和eco634 locus-tag ，使用现有prodigal训练文件，附加复制子信息，并启用8线程处理
```

Pharokka (https://github.com/gbouras13/pharokka) is a rapid standardised annotation tool for bacteriophage genomes and metagenomes.

```bash
# 安装
mamba create -n pharokka -y -c conda-forge -c bioconda pharokka
# 下载安装数据库
install_databases.py -o path/to/databse_dir
# 使用
pharokka.py -i phage.fa -o output -d path/to/database_dir -t threads
```

phold (https://github.com/gbouras13/phold) is a sensitive annotation tool for bacteriophage genomes and metagenomes using protein structural homology. 

```bash
# 安装
mamba create -n phold -y -c conda-forge -c bioconda phold
# 安装pytorch版本，此时需要服务器有GPU与cuda，会自动匹配pytorch版本
mamba create -n phold -y -c conda-forge -c bioconda phold pytorch=*=cuda* 
# 如果GPU服务器不能联网，联网节点又没有GPU，可以按如下操作
# 获得GPU服务器中的cuda版本
nvidia-smi
# 安装指定cuda版本的pytorch，假设cuda版本是12.4
mamba install -y -c conda-forge -c bioconda -c pytorch -c nvidia phold pytorch pytorch-cuda=12.4
# 下载安装数据库，如不指定，会下载到默认路径
# 默认路径为/path/to/miniforge3/envs/phold/lib/python3.11/site-packages/phold/database
phold install -d /path/to/download
# 运行全流程，包括cds预测，蛋白质3D结构预测，结构比对，默认使用GPU
phold run -i phage.fa -o test_output_phold -t 8 -f -d /path/to/database
# 参数详解：
# -i 输入文件，可以是fasta和gbk；若输入是gbk文件，则需要保证gbk文件内容完整，否则报错。推荐使用pharokka注释产生的gbk文件。
# -o 输出文件夹，该文件夹是被phold创建的，如果该文件夹已经存在，则会报错，可以添加-f参数强制覆盖
# -d 数据库路径，如果数据库存在于默认路径，则不用指定
# 运行时会检测系统是否有GPU，如果没有，会使用CPU模式，非常慢。建议使用GPU运行
# phold使用pyrodigal预测蛋白序列，也许与其他途径生成的蛋白序列有差别
# 为了避免由于蛋白序列差异带来的注释问题，可以直接向其提供蛋白序列
# 运行蛋白质结构预测，预测输入蛋白质氨基酸序列的3D结构
phold proteins-predict -i protein.faa -o predict_result -t 8 -d /path/to/database -f
# 运行蛋白质结构比对，需要先完成上一步蛋白质结构预测
phold proteins-compare -i protein.faa --predictions_dir predict_result -o compare_result -t 8 -d /path/to/database -f
# 运行phold有时候会有代理等诸多问题，主要体现在prostT5模型下载上，可以使用以下命令
export HF_ENDPOINT=https://hf-mirror.com
mamba activate phold
pip install -U huggingface_hub
huggingface-cli download --resume-download Rostlab/ProstT5_fp16 --local-dir /path/to/database/Rostlab/ProstT5_fp16 --local-dir-use-symlinks False
```

MEGAHIT (https://github.com/voutcn/megahit) 是一个快速、内存高效的宏基因组组装工具，专门用于从复杂微生物群落的测序数据中组装基因组片段。

```bash
# 安装
mamba install -y -c bioconda megahit
# 使用
megahit --presets meta-large -t 25 -1 A_qc_1.fq.gz -2 A_qc_2.fq.gz -o megahit_result
# megahit进行组装时，需要很长时间，同时也会产生很大的中间文件
# 运行时需要注意内存、时间的设置以及磁盘空间。
# 如发现磁盘空间不足，可结束任务，但不要删除-o里的中间文件。在磁盘空间充足时，继续组装。
# megahit在组装时如果因内存不足而报错停止，也可以继续运行
megahit --continue -o megahit_result
# 参数详解：
# --presets meta-large		使用预设的meta-large参数组进行组装
# -t 25						使用25个线程
# --continue				直接读取-o指定的文件夹megahit_result中的中间文件进行组装
```

DeepVirFinder (https://github.com/jessieren/DeepVirFinder) 使用深度学习方法预测病毒序列。该方法对短病毒序列具有良好的预测准确性，可用于预测来自宏基因组数据的序列。DeepVirFinder 的输入是包含待预测序列的 fasta 文件，输出是一个 .txt 文件，其中包含每个输入序列的预测分数和 p 值。分数越高或 p 值越低表示是病毒序列的可能性越高。

```bash
# 安装
mamba create -n dvf -y -c conda-forge -c bioconda seqkit python=3.6 numpy theano=1.0.3 keras=2.2.4 scikit-learn Biopython h5py=2.10.0
git clone https://github.com/jessieren/DeepVirFinder
# 使用
python dvf.py -i meta.fa -o dvf_result -m /path/to/DeepVirFinder/models -l 1500
# 参数详解：
# -m 		指定model路径，在git clone下载的DeepVirFinder文件夹下
# -l 1500	只保留长度大于1500bp的序列
# deepvirfinder运行时依赖theano库
# theano在运行时会在home下创建.theano缓存目录，存储编译后的C代码和CUDA代码，多个并行进程会同时访问同一个缓存目录，导致冲突。
# 运行脚本前，执行以下命令即可解决
export THEANO_FLAGS='base_compiledir=/path/to/work,cxx=/usr/bin/g++'
```

VirSorter2 (https://github.com/jiarong/VirSorter2) applies a multi-classifier, expert-guided approach to detect diverse DNA and RNA virus genomes.

```bash
# 安装
mamba create -n vs2 -c conda-forge -c bioconda virsorter=2
# 下载安装数据库
mamba activate vs2
wget https://osf.io/v46sc/download
tar -xzf db.tgz
virsorter config --init-source --db-dir=./db
# 使用
virsorter run -w vs2 -i meta.fa --min-length 1500 -j 4 all
# 参数详解：
# run                 运行VirSorter2的主命令
# -w vs2              工作目录设为vs2文件夹（所有输出都在这里）
# -i megahit.fa       输入的组装序列文件
# --min-length 1500   只分析长度≥1500bp的序列
# -j 4                使用4个线程并行处理
# all                 运行所有分析步骤（预测+分类+质量评估）
```

geNomad (https://portal.nersc.gov/genomad/index.html) 的主要目标是在测序数据（分离株、宏基因组和宏转录组）中识别病毒和质粒。

```bash
# 安装
mamba create -n genomad -c conda-forge -c bioconda genomad
# 下载安装数据库
mamba activate genomad
genomad download-database ./
# 运行
genomad end-to-end --cleanup --splits 8 meta.fa genomad_result /path/to/genomad_db
# 参数详解：
# end-to-end	运行完整分析流程（预测+分类+注释）
# --cleanup		强制geNomad删除执行过程中生成的中间文件。节省存储空间。
# --splits 8	将搜索分成8个块。
# geNomad会搜索一个占用大量内存的大型蛋白质profiles数据库。
# 为防止执行因内存不足而失败，可以使用--splits参数将搜索分成多个块。
# 如果在大型服务器上运行geNomad，可能不需要分割搜索，这样可以提高执行速度。
# geNomad支持压缩为.gz/.bz2/.xz 的输入文件。
```

VIBRANT (https://github.com/AnantharamanLab/VIBRANT) 利用混合机器学习和蛋白质相似性方法，不依赖于序列特征，可从宏基因组组装中自动恢复和注释病毒，确定基因组质量和完整性，并表征病毒群落功能。

```bash
# 安装
mamba create -n vibrant -y -c conda-forge -c bioconda python=3.5 prodigal hmmer
pip install biopython pandas matplotlib "seaborn>=0.9.0" "numpy>=1.17.0" "scikit-learn==0.21.3"
mamba install -y -c bioconda vibrant
download-db.sh
```

iphop (https://bitbucket.org/srouxjgi/iphop) 用于从噬菌体基因组中计算预测宿主分类学。

```bash
# 安装
mamba create -n iphop -y -c conda-forge -c bioconda python=3.8 iphop
# 下载数据库，300G左右
wget https://portal.nersc.gov/cfs/m342/iphop/db/iPHoP.latest_rw.tar.gz
tar zxvf iPHoP.latest_rw.tar.gz
# iphop预测宿主，如果输入文件过大，运行时间会很长，可以分片并行处理，然后合并结果
iphop predict --fa_file virus.fa --db_dir /path/to/db --out_dir result -t 8   
```

MAFFT (https://mafft.cbrc.jp/alignment/software/) 是一个用于类 Unix 操作系统的多序列比对程序。它提供了多种多序列比对方法。 

```bash
# 安装
mamba install -y -c bioconda mafft
# 使用，将输入的序列对齐
mafft --auto input.fasta > algined.fasta
```

iqtree  (https://iqtree.github.io/) 是用来构建系统发育树的工具，使用最大似然法从序列比对结果推断物种或基因的进化关系。

```bash
# 安装
mamba install -y -c bioconda iqtree
# 使用
iqtree -s algined_tree.fasta -bb 1000 --runs 8 -T 8 --mem 50G --prefix my_tree
# 参数详解：
# -s algined_tree.fasta    		输入的多序列比对文件（FASTA格式）
# -bb 1000                 		进行1000次bootstrap重采样评估分支支持度
# --runs 8                 		运行8次独立分析选择最佳结果
# -T 8                     		使用8个线程并行计算
# --mem 50G                		限制最大内存使用量为50GB
# --prefix my_tree              输出文件前缀
```

vContact3 (https://bitbucket.org/MAVERICLab/vcontact3) 是用来对病毒基因组进行聚类和分类的工具，通过比较病毒蛋白质相似性构建网络来识别相关的病毒群体和家族。

```bash
# 安装
mamba create -n vcontact3 -y -c bioconda vcontact3
# 下载安装数据库
vcontact3 prepare_databases --get-version "latest" --set-location /path/to/download/location
# 使用
vcontact3 run --nucleotide virus_genomes.fasta --output output_directory
```

cdhit (https://github.com/weizhongli/cdhit) 是用来对蛋白质或核酸序列进行聚类和去冗余的工具，能将相似序列合并成代表性序列，常用于构建非冗余数据库。

> [!WARNING]
>
> 经测试，如果出现两条完全一样的序列，两条序列都不会被去除。

```bash
# 安装
git clone https://github.com/weizhongli/cdhit
cd cdhit
make MAX_SEQ=1000000	
# 编译完成后的cdhit处理序列长度的上限为1000000。
# 若处理序列的长度超过了最大序列长度。会有warning提示，可能伴随着无输出。
# 可重新编译安装，并在安装时指定新的序列长度。
# 序列聚类
cd-hit-est -i A.fa -o B.fa -c 0.95 -aL 0.9 -M 16000 -T 8    
# 参数详解：
# -c 0.95				相似度大于95%的序列会被去除；
# -aL 0.9				比对覆盖率阈值为0.9，即只有当比对覆盖了较长序列的90%或以上时，两个序列才会被认为是相似的；
# -M 16000				限制最大内存为16G，单位是M；
# -T 8					使用8个线程；
# cd-hit-est用于处理核酸序列，cd-hit用于处理蛋白质序列
```

MMseqs (https://github.com/soedinglab/MMseqs2) 是一个高速的蛋白质序列搜索和聚类工具，比BLAST快100-1000倍，比CD-HIT更快更准确，常用于大规模序列分析。

> [!WARNING]
>
> 经测试，如果出现两条完全一样的序列，两条序列都不会被去除。

```bash
# 安装
mamba install -y -c conda-forge -c bioconda mmseqs2
# 使用
mmseqs easy-linclust -e 0.001 --cov-mode 1 -c 0.8 --min-seq-id 0.9 --kmer-per-seq 80 0.7_gene_dereplication/all_gene.fasta 07.gene_dereplication/clusterRes 07.gene_dereplication/tmp --threads 16
# 参数详解：
# easy-linclust         线性聚类模式（比cluster更快但精度略低）
# -e 0.001             E值阈值（期望值≤0.001）
# --cov-mode 1         覆盖度计算模式（1=查询序列覆盖度）
# -c 0.8               覆盖度阈值（80%的序列要被比对覆盖）
# --min-seq-id 0.9     最小序列相似度（90%相似度）
# --kmer-per-seq 80    每个序列选择的k-mer数量（影响敏感度和速度）
# --threads 16         使用16线程并行处理
```

