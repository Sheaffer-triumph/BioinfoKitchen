# Thus have I heard     

##### 本人(Zoran)的生信笔记，大致分3个板块，基础的Linux command line(我觉得基础)，常用的生信工具下载安装及运行(我觉得常用)，其他。

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
# 注意事项：
# 1. 多重嵌套只能用$()，不能用``
# 2. xargs后面只能使用实际命令，不能使用alias别名
# 3. {}占位符可以换成其他符号，如{file}，但使用时要保持一致
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
