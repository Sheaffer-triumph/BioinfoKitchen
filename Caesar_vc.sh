################################################################
####用于vContac2聚类后的结果分析处理,需要提供序列ID以及对应的csv内容####
################################################################

set -e

grep "clustered" genome_by_genome_overview.csv | cut -d',' -f1 | grep id > cluster.id   ##此处没有通用代码，根据自己需要，在genome_by_genome_overview.csv中提取形成clustered的样本序列ID，输入至cluster.id

rm cluster.txt
cat cluster.id | while read a
    do
    printf "${a}\t" >> cluster.txt
    b=$(grep "\b$a\b" genome_by_genome_overview.csv | cut -d',' -f10)
    printf "${b}\t" >> cluster.txt
    c=$(grep $b genome_by_genome_overview.csv | cut -d',' -f2-7 | grep -v "Unassigned,Unassigned,Unassigned,Unassigned,Unassigned,Unassigned" | sort | uniq)
    d=$(echo $c | wc -l)
    if [ -z "$c" ]
    then
        printf "Unassigned,Unassigned,Unassigned,Unassigned,Unassigned,Unassigned\n" >> cluster.txt
    elif (( $d == 1 ))
    then
        printf "$c\n" >> cluster.txt
    else
        e=0
        g=1
        until [ $g -gt 1 ]
        do
            e=$(expr $e + 1)
            f=$(awk -F ',' -v var=$e '{print $var}' | sort | uniq)
            g=$(echo $f | wc -l)
        done
        printf "$f" >> cluster.txt
        g=$(expr 6 - $e)
        for h in $(seq 1 $g)
        do
            printf ",Unassigned" >> cluster.txt
        done
        printf "\n" >> cluster.txt
    fi
done
