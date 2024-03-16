#条件判断
if [ $a -eq 1 ]; then echo "1"; else echo "0"; fi       #如果$a等于1，则输出1，否则输出0
if [ $a -ne 1 ]; then echo "1"; else echo "0"; fi       #如果$a不等于1，则输出1，否则输出0
if [ $a -gt 1 ]; then echo "1"; else echo "0"; fi       #如果$a大于1，则输出1，否则输出0
if [ $a -lt 1 ]; then echo "1"; else echo "0"; fi       #如果$a小于1，则输出1，否则输出0
if [ $a -ge 1 ]; then echo "1"; else echo "0"; fi       #如果$a大于等于1，则输出1，否则输出0
if [ $a -le 1 ]; then echo "1"; else echo "0"; fi       #如果$a小于等于1，则输出1，否则输出0
if [ -f $a ]; then echo "1"; else echo "0"; fi          #如果$a是文件，则输出1，否则输出0
if [ -d $a ]; then echo "1"; else echo "0"; fi          #如果$a是文件夹，则输出1，否则输出0
if [ -e $a ]; then echo "1"; else echo "0"; fi          #如果$a存在，则输出1，否则输出0
if [ -r $a ]; then echo "1"; else echo "0"; fi          #如果$a可读，则输出1，否则输出0
if [ -w $a ]; then echo "1"; else echo "0"; fi          #如果$a可写，则输出1，否则输出0
if [ -x $a ]; then echo "1"; else echo "0"; fi          #如果$a可执行，则输出1，否则输出0
if [ -z $a ]; then echo "1"; else echo "0"; fi          #如果$a为空，则输出1，否则输出0
if [ -n $a ]; then echo "1"; else echo "0"; fi          #如果$a不为空，则输出1，否则输出0
if [ $a = $b ]; then echo "1"; else echo "0"; fi        #如果$a等于$b，则输出1，否则输出0
if [ $a != $b ]; then echo "1"; else echo "0"; fi       #如果$a不等于$b，则输出1，否则输出0
if [ $a -eq $b ]; then echo "1"; else echo "0"; fi      #如果$a等于$b，则输出1，否则输出0
if [ $a -ne $b ]; then echo "1"; else echo "0"; fi      #如果$a不等于$b，则输出1，否则输出0
if [ $a -gt $b ]; then echo "1"; else echo "0"; fi      #如果$a大于$b，则输出1，否则输出0
if [ $a -lt $b ]; then echo "1"; else echo "0"; fi      #如果$a小于$b，则输出1，否则输出0
if [ $a -ge $b ]; then echo "1"; else echo "0"; fi      #如果$a大于等于$b，则输出1，否则输出0
if [ $a -le $b ]; then echo "1"; else echo "0"; fi      #如果$a小于等于$b，则输出1，否则输出0
if [ -f $a -a -r $a ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且可读，则输出1，否则输出0，-a表示与
if [ -f $a -o -r $a ]; then echo "1"; else echo "0"; fi  #如果$a是文件或者可读，则输出1，否则输出0，-o表示或
if [ ! -f $a ]; then echo "1"; else echo "0"; fi         #如果$a不是文件，则输出1，否则输出0，!表示非
if [ -f $a -a -r $a -o -d $a ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且可读或者是文件夹，则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且（可读或者是文件夹），则输出1，否则输出0
if [ -f $a -a -r $a -o \( -d $a -a -x $a \) ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且可读或者（是文件夹并且可执行），则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) -a \( -x $a -o -w $a \) ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且（可读或者是文件夹）并且（可执行或者可写），则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) -a \( -x $a -o -w $a \) -a \( -z $a -o -n $a \) ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且（可读或者是文件夹）并且（可执行或者可写）并且（为空或者不为空），则输出1，否则输出0
if [ -f $a -a \( -r $a -o -d $a \) -a \( -x $a -o -w $a \) -a \( -z $a -o -n $a \) -a \( $a = $b -o $a != $b \) ]; then echo "1"; else echo "0"; fi  #如果$a是文件并且（可读或者是文件夹）并且（可执行或者可写）并且（为空或者不为空）并且（等于或者不等于$b），则输出1，否则输出0
if (( $a == 1 )); then echo "1"; else echo "0"; fi       #如果$a等于1，则输出1，否则输出0
if (( $a != 1 )); then echo "1"; else echo "0"; fi       #如果$a不等于1，则输出1，否则输出0
if (( $a > 1 )); then echo "1"; else echo "0"; fi        #如果$a大于1，则输出1，否则输出0
if (( $a < 1 )); then echo "1"; else echo "0"; fi        #如果$a小于1，则输出1，否则输出0
if (( $a >= 1 )); then echo "1"; else echo "0"; fi       #如果$a大于等于1，则输出1，否则输出0
if (( $a <= 1 )); then echo "1"; else echo "0"; fi       #如果$a小于等于1，则输出1，否则输出0
if (( $a == 1 && $b == 1 )); then echo "1"; else echo "0"; fi  #如果$a等于1并且$b等于1，则输出1，否则输出0
if (( $a == 1 || $b == 1 )); then echo "1"; else echo "0"; fi  #如果$a等于1或者$b等于1，则输出1，否则输出0
if (( $a == 1 && ( $b == 1 || $c == 1 ) )); then echo "1"; else echo "0"; fi  #如果$a等于1并且（$b等于1或者$c等于1），则输出1，否则输出0
if (( $a == 1 && ( $b == 1 || $c == 1 ) && ( $d == 1 || $e == 1 ) )); then echo "1"; else echo "0"; fi  #如果$a等于1并且（$b等于1或者$c等于1）并且（$d等于1或者$e等于1），则输出1，否则输出0
if (( $a == 1 && ( $b == 1 || $c == 1 ) && ( $d == 1 || $e == 1 ) && ( $f == 1 || $g == 1 ) )); then echo "1"; else echo "0"; fi  #如果$a等于1并且（$b等于1或者$c等于1）并且（$d等于1或者$e等于1）并且（$f等于1或者$g等于1），则输出1，否则输出0
