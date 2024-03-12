################################################################
####用于vContac2聚类后的结果分析处理,需要提供序列ID以及对应的csv内容####
################################################################

set -e



cat cluster.id | while read a
    do
    printf ${a}\\t >> cluster.txt
    b=$(rg "\b$a\b" cluster.csv | cut -d',' -f10)
    printf ${b}\\t >> cluster.txt
    rg $b genome_by_genome_overview.csv | cut -d',' -f2-7 | grep -v "Unassigned,Unassigned,Unassigned,Unassigned,Unassigned,Unassigned" | sort | uniq > temp
    c=$(cat temp | wc -l)
    if (( $c == 0))
    then
        printf "N/A\n" >> cluster.txt
    elif (( $c == 1))
    then
        d=$(cat temp)
        printf ${d}\\n >> cluster.txt
    else
        e=$(cat temp | cut -f1-5 -d',' | sort | uniq)
        printf ${e}\\n >> cluster.txt
    fi
done
rm temp