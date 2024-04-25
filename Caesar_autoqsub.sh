#本脚本为自动提交任务脚本，需要在对应的文件夹下运行。脚本分两部分，前半段为自动提交任务脚本，后半段为自动检查报错脚本
#!/bin/bash -e

while getopts :l:n:p:m:t:h opt
do
    case "$opt" in
        l)
            LIST=$OPTARG
            ;;
        n)
            JOBNUM=$OPTARG
            ;;
        p)
            PROCESS=$OPTARG
            ;;
        m)
            MEM=$OPTARG
            ;;
        s)
            SLEEPTIME=$OPTARG
            ;;
        h)
            cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/autoqsub_help.txt
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

if [ -z $LIST ] || [ -z $JOBNUM ] || [ -z $PROCESS ] || [ -z $MEM ] || [ -z $TIME ]
    then
    echo "Usage: autoqsub.sh -l <list> -n <jobnum> -p <process> -m <mem> -s <sleeptime> -h"
    cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/autoqsub_help.txt
    exit 1
fi

WDIR=$(pwd -e)
cp $LIST .tobeqsub.list
a=$(cat .tobeqsub.list | wc -l)                       #a表示还需要提交的任务数
until [ $a == 0 ]                                   #until表示直到a等于0才停止
    do
    b=$(qstat | grep "lizhuoran1" | wc -l)                                   
    if [ $b -lt $JOBNUM ]                                #如果当前正在运行的任务数小于20，则继续提交任务
        then    
        d=$(expr $JOBNUM - $b)
        head -n $d .tobeqsub.list > .qsub.list
        grep -wvf .qsub.list .tobeqsub > .tmp.list    #在tobeqsub.list中去除qsub.list中的内容，-w表示精确匹配，-v表示取反，-f表示从文件中读取内容
        cat .tmp.list > .tobeqsub.list
        f=`date`
        echo $f >> autoqsub.log
        for e in `cat .qsub.list`
            do
            cd $(dirname $e)
            qsub -cwd -q st.q -P P17Z10200N0246 -l vf=${MEM}g,num_proc=$PROCESS -binding linear:$PROCESS $e
            cd $WDIR
            echo "$e has been qsub" >> auotoqsub.log
        done
    else
        f=`date`
        echo $f >> autoqsub.log
        echo "There are $JOBNUM jobs running, please wait" >> autoqsub.log
    fi
    sleep ${SLEEPTIME}m                                        #sleep 2m表示休眠2分钟
	#grep "has been qsub" qsub.log | awk '{print $1}' | sort | uniq > run.list       #在qsub.log中查找含有has been qsub的每一行，并输出第一列，即run.list中的内容为已经提交的任务
    #m=`date`
    #echo $m >> check.log
	#for i in `cat run.list`                         #对于run.list中的每一个任务
    #    do
    #    grep -i "error" ${i}/*sh.e* > ${i}_error.txt    #grep -i "error" ${i}/*sh.e*表示在${i}文件夹中查找含有error的每一行，并输出到${i}_error.txt中
    #    j=`ls -l ${i}_error.txt | awk '{print $5}'`     #j表示${i}_error.txt的大小，即含有error的行数
    #    if [ $j == 0 ]                                  #如果${i}_error.txt的大小为0，则表示该任务没有报错
    #        then
    #        echo "$i has no error" >> check.log
    #        /usr/bin/rm -rf ${i}_error.txt
    #    elif [ -e $i/01_fastp/${i}.fastq.gz ]           #如果fastp-dump运行结果为单端，则将该任务加入到single.list中
    #        then
    #        echo $i >> single.list
    #        cat single.list | sort | uniq > tmp
    #        cat tmp > single.list
    #        /usr/bin/rm -rf ${i}_error.txt
    #    else                                            #排除单端运行错误，剩下就是报错
    #        echo $i >> tobeqsub.list                    #将该任务重新加入到tobeqsub.list中，等待重新投递该任务
    #        echo "$i reported error, the output has been deleted and the job is waiting to be re-qsub" >> check.log
    #        /usr/bin/rm -rf ${i}_error.txt ${i}/*sh.* ${i}/0*                       #删除该任务的报错信息和输出文件
    #    fi
    #done
    #echo "\n" >> check.log
    #a=`cat tobeqsub.list | wc -l`
done
echo "All jobs have been qsub" >> autoqsub.log
/usr/bin/rm -rf .tobeqsub.list .qsub.list .tmp.list
#echo "All jobs have been checked" >> check.log