############################################
##########用于vContact2聚类结果的处理##########
############################################

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
        f=1
        until [ $f -gt 1 ]
            do
            e=$(expr $e + 1)
            f=$(awk -F ',' -v var=$e '{print $var}' | sort | uniq | wc -l)
        done
        printf "$f" >> cluster.txt
        for h in $(seq $e 6)
        do
            printf ",Unassigned" >> cluster.txt
        done
        printf "\n" >> cluster.txt
    fi
done
