#条件判断
if [ $a -eq 1 ]; then echo "1"; else echo "0"; fi       #如果$a等于1，则输出1，否则输出0
    #[ ]中的空格是必须的，否则会报错；[]与(( ))的区别是[]是bash的内建命令，而(( ))是bash的语法结构，[]中只能使用特定的操作符进行比较，而(())可以使用算术操作符，不能使用[]中的操作符
    #[]中的变量需要加$符号，而(())中的变量不必须要加$符号，但是建议加上，以一致。
    #[]中的变量可以是整数和字符串，而(())中的变量必须是整数
    #当[]中的变量是字符串时，=表示等于，!=表示不等于，-z表示为空，-n表示不为空，-f表示是文件，-d表示是文件夹，-e表示存在，-r表示可读，-w表示可写，-x表示可执行
    #当[]中的变量是整数时，-eq表示等于，-ne表示不等于，-gt表示大于，-lt表示小于，-ge表示大于等于，-le表示小于等于
    #当(())中的变量是整数时，==表示等于，!=表示不等于，>表示大于，<表示小于，>=表示大于等于，<=表示小于等于
    #[]中的操作符可以使用-a -o !，而(())中的操作符不能使用-a -o !，而是使用&& || !
    #如果[]中的变量是字符串，建议使用""括起来，以避免一些意外情况如字符串含有空格或为空；如果[]中的变量是整数，可以使用""括起来，也可以不使用
if [ $a -ne 1 ]; then echo "1"; else echo "0"; fi                                               #如果$a不等于1，则输出1，否则输出0
if [ $a -gt 1 ]; then echo "1"; else echo "0"; fi                                               #如果$a大于1，则输出1，否则输出0
if [ $a -lt 1 ]; then echo "1"; else echo "0"; fi                                               #如果$a小于1，则输出1，否则输出0
if [ $a -ge 1 ]; then echo "1"; else echo "0"; fi                                               #如果$a大于等于1，则输出1，否则输出0
if [ $a -le 1 ]; then echo "1"; else echo "0"; fi                                               #如果$a小于等于1，则输出1，否则输出0
if [ -f $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a是文件，则输出1，否则输出0
if [ -d $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a是文件夹，则输出1，否则输出0
if [ -e $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a存在，则输出1，否则输出0
if [ -r $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a可读，则输出1，否则输出0
if [ -w $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a可写，则输出1，否则输出0
if [ -x $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a可执行，则输出1，否则输出0
if [ -z $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a为空，则输出1，否则输出0
if [ -n $a ]; then echo "1"; else echo "0"; fi                                                  #如果$a不为空，则输出1，否则输出0
if [ "$a" = "abcd" ]; then echo "1"; else echo "0"; fi                                          #如果$a等于"abcd"，则输出1，否则输出0
if [ $a = $b ]; then echo "1"; else echo "0"; fi                                                #如果$a等于$b，则输出1，否则输出0
if [ $a != $b ]; then echo "1"; else echo "0"; fi                                               #如果$a不等于$b，则输出1，否则输出0
if [ $a -eq $b ]; then echo "1"; else echo "0"; fi                                              #如果$a等于$b，则输出1，否则输出0
if [ $a -ne $b ]; then echo "1"; else echo "0"; fi                                              #如果$a不等于$b，则输出1，否则输出0
if [ $a -gt $b ]; then echo "1"; else echo "0"; fi                                              #如果$a大于$b，则输出1，否则输出0
if [ $a -lt $b ]; then echo "1"; else echo "0"; fi                                              #如果$a小于$b，则输出1，否则输出0
if [ $a -ge $b ]; then echo "1"; else echo "0"; fi                                              #如果$a大于等于$b，则输出1，否则输出0
if [ $a -le $b ]; then echo "1"; else echo "0"; fi                                              #如果$a小于等于$b，则输出1，否则输出0
if [ $a -ne 1 && $b -ne 1 ]; then echo "1"; else echo "0"; fi                                   #如果$a不等于1并且$b不等于1，则输出1，否则输出0；&&表示与
if [ $a -ne 1 || $b -ne 1 ]; then echo "1"; else echo "0"; fi                                   #如果$a不等于1或者$b不等于1，则输出1，否则输出0；||表示或
#像上面两
if [ -f $a -a -r $a ]; then echo "1"; else echo "0"; fi                                         #如果$a是文件并且可读，则输出1，否则输出0，-a表示与
if [ -f $a -o -r $a ]; then echo "1"; else echo "0"; fi                                         #如果$a是文件或者可读，则输出1，否则输出0，-o表示或
if [ ! -f $a ]; then echo "1"; else echo "0"; fi                                                #如果$a不是文件，则输出1，否则输出0，!表示非
if [ -f $a -a -r $a -o -d $a ]; then echo "1"; else echo "0"; fi                                #如果$a是文件并且可读或者是文件夹，则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) ]; then echo "1"; else echo "0"; fi                          #如果$a是文件并且（可读或者是文件夹），则输出1，否则输出0
if [ -f $a -a -r $a -o \( -d $a -a -x $a \) ]; then echo "1"; else echo "0"; fi                 #如果$a是文件并且可读或者（是文件夹并且可执行），则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) -a \( -x $a -o -w $a \) ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且（可读或者是文件夹）并且（可执行或者可写），则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) -a \( -x $a -o -w $a \) -a \( -z $a -o -n $a \) ]; then echo "1"; else echo "0"; fi  
    #如果$a是文件并且（可读或者是文件夹）并且（可执行或者可写）并且（为空或者不为空），则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) -a \( -x $a -o -w $a \) -a \( -z $a -o -n $a \) -a \( $a = $b -o $a != $b \) ]; then echo "1"; else echo "0"; fi  
    #如果$a是文件并且（可读或者是文件夹）并且（可执行或者可写）并且（为空或者不为空）并且（等于或者不等于$b），则输出1，否则输出0
if (( $a == 1 )); then echo "1"; else echo "0"; fi                                              #如果$a等于1，则输出1，否则输出0
if (( $a != 1 )); then echo "1"; else echo "0"; fi                                              #如果$a不等于1，则输出1，否则输出0
if (( $a > 1 )); then echo "1"; else echo "0"; fi                                               #如果$a大于1，则输出1，否则输出0
if (( $a < 1 )); then echo "1"; else echo "0"; fi                                               #如果$a小于1，则输出1，否则输出0
if (( $a >= 1 )); then echo "1"; else echo "0"; fi                                              #如果$a大于等于1，则输出1，否则输出0
if (( $a <= 1 )); then echo "1"; else echo "0"; fi                                              #如果$a小于等于1，则输出1，否则输出0
if (( $a == 1 && $b == 1 )); then echo "1"; else echo "0"; fi                                   #如果$a等于1并且$b等于1，则输出1，否则输出0
if (( $a == 1 || $b == 1 )); then echo "1"; else echo "0"; fi                                   #如果$a等于1或者$b等于1，则输出1，否则输出0
if (( $a == 1 && ( $b == 1 || $c == 1 ) )); then echo "1"; else echo "0"; fi                    #如果$a等于1并且（$b等于1或者$c等于1），则输出1，否则输出0
if (( $a == 1 && ( $b == 1 || $c == 1 ) && ( $d == 1 || $e == 1 ) )); then echo "1"; else echo "0"; fi  
    #如果$a等于1并且（$b等于1或者$c等于1）并且（$d等于1或者$e等于1），则输出1，否则输出0
if (( $a == 1 && ( $b == 1 || $c == 1 ) && ( $d == 1 || $e == 1 ) && ( $f == 1 || $g == 1 ) )); then echo "1"; else echo "0"; fi  
    #如果$a等于1并且（$b等于1或者$c等于1）并且（$d等于1或者$e等于1）并且（$f等于1或者$g等于1），则输出1，否则输出0
if (( a == b )) then echo "1"; else echo "0"; fi            #如果a等于b，则输出1，否则输出0；(())中的空格是可选的，但是建议加上；变量的$符号可以省略，但是建议加上
if (( a+1 == b )) then echo "1"; else echo "0"; fi          #如果a+1等于b，则输出1，否则输出0
if (( a-1 == b )) then echo "1"; else echo "0"; fi          #如果a-1等于b，则输出1，否则输出0
if (( a*2 == b )) then echo "1"; else echo "0"; fi          #如果a*2等于b，则输出1，否则输出0
if (( a/2 == b )) then echo "1"; else echo "0"; fi          #如果a/2等于b，则输出1，否则输出0
if (( a%2 == b )) then echo "1"; else echo "0"; fi          #如果a%2等于b，则输出1，否则输出0；%表示取余
if (( a**2 == b )) then echo "1"; else echo "0"; fi         #如果a的平方等于b，则输出1，否则输出0；**表示幂

#循环
for i in {1..5}; do echo $i; done                           #i从1到5
for i in {5..1}; do echo $i; done                           #i从5到1
for i in $(seq 1 5); do echo $i; done                       #i从1到5
for i in {1..5..2}; do echo $i; done                        #i从1到5，步长为2，即1 3 5
for i in $(seq 1 2 5); do echo $i; done                     #i从1到5，步长为2，即1 3 5
for i in $(seq 5 -1 1); do echo $i; done                    #i从5到1，步长为-1，即5 4 3 2 1
for i in $(seq 5 -2 1); do echo $i; done                    #i从5到1，步长为-2，即5 3 1
for i in $(command)                                         #i从command的输出结果中取值
for i in `command`                                          #i从command的输出结果中取值
for((i=1;i<=5;i++)); do echo $i; done                       #i从1到5
for((i=5;i>=1;i--)); do echo $i; done                       #i从5到1
for i in a b c; do echo $i; done                            #i从a到c
for i in $@; do echo $i; done                               #i从命令行参数中取值
for i in "$@"; do echo $i; done                             #i从命令行参数中取值
for i in "$*"; do echo $i; done                             #i从命令行参数中取值
for i in {a..z}; do echo $i; done                           #i从a到z
for i in {a..z..2}; do echo $i; done                        #i从a到z，步长为2，即a c e g i k m o q s u w y
while [ condition ]; do command; done                       #当condition为真时，执行command，condition内容可以是变量、命令、数学表达式等，参考条件判断
until [ condition ]; do command; done                       #当condition为假时，执行command
while (( condition )); do command; done                     #当condition为真时，执行command
until (( condition )); do command; done                     #当condition为假时，执行command
while read line; do echo $line; done < file                 #从file中读取每一行，赋值给line，然后输出line
cat file | while read line; do echo $line; done             #从file中读取每一行，赋值给line，然后输出line
for i in `cat file`; do echo $i; done                       #从file中读取每一行，赋值给i，然后输出i
