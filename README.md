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
# 用vim编辑器打开文件A，如果文件不存在会自动创建
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

