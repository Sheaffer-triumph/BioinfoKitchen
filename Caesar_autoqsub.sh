#更新时间：2024年7月5日
#更新内容：增加了一个选项-d，用于在每次循环中监测磁盘占用空间，当磁盘占用空间大于设定值时，会暂停正在运行的任务；设定值支持浮点数
#备注：由于增加的模块只有暂停提交任务的功能，没有清理磁盘的功能，因此所提交的任务最好含有一些用于清理中间文件的命令，以免一直暂停
#备注：监测当前磁盘空间的命令会根据不同的服务器而有所不同，需要根据实际情况进行修改

#!/usr/bin/bash -e

JOBNUM=20
PROCESS=8
MEM=50
SLEEPTIME=5

while getopts :l:n:p:m:s:d:hv opt
do
    case $opt in
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
        d)
            DISKLIMIT=$OPTARG
            ;;
        h)
            cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/autoqsub_help.txt
            exit
            ;;
        v)
            echo "Autoqsub v1.1.0"
            exit
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/autoqsub_help.txt
            exit 1
            ;;
    esac
done

if [ -z $LIST ] || [ -z $JOBNUM ] || [ -z $PROCESS ] || [ -z $MEM ] || [ -z $TIME ]
    then
    echo "ERROR! There are options with missing parameters, check the command"
    cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/autoqsub_help.txt
    exit 1
fi

WDIR=$(pwd -P)
cp $LIST .tobeqsub.list
a=$(cat .tobeqsub.list | wc -l)                         #a表示还需要提交的任务数
until [ $a == 0 ]                                       #until表示直到a等于0才停止
do

    b=$(qstat | grep "lizhuoran1" | wc -l)                                   
    if [ $b -lt $JOBNUM ]                               #如果当前正在运行的任务数小于设定值，则继续提交任务
    then    
        d=$(expr $JOBNUM - $b)
        head -n $d .tobeqsub.list > .qsub.list
        grep -wvf .qsub.list .tobeqsub.list > .tmp.list      #在tobeqsub.list中去除qsub.list中的内容，-w表示精确匹配，-v表示取反，-f表示从文件中读取内容
        cat .tmp.list > .tobeqsub.list
        f=`date`
        echo $f >> autoqsub.log
        for e in $(cat .qsub.list)
        do
            cd $(dirname $e)
            qsub -cwd -q st.q -P P17Z10200N0246 -l vf=${MEM}g,num_proc=$PROCESS -binding linear:$PROCESS $e
            cd $WDIR
            echo "$e has been qsub" >> autoqsub.log
        done
    else
        f=`date`
        echo $f >> autoqsub.log
        echo "There are $JOBNUM jobs running, please wait" >> autoqsub.log
    fi

    if [ -n $DISKLIMIT]
    then
        DiskQuota=$(lfs quota -gh st_p17z10200n0246 /ldfssz1/ | sed '1,2d' | head -n 1 | awk '{print $2}' | sed 's/T//g')
        THAN=$(echo "$DiskQuota > $DISKLIMIT" | bc)
        if [ $THAN -eq 1 ]
        then
            echo "Disk space has exceeded the set limit and the sh has been suspended" >> autoqsub.log
            qstat | sed '1,2d' | grep -w r | awk '{print $1}' | while read id
            do
                qhold $id
            done
        else
            qstat | sed '1,2d' | grep -w hr | awk '{print $1}' | while read id
            do
                qrls $id
            done
        fi
    sleep ${SLEEPTIME}m                                        #sleep 2m表示休眠2分钟

done
echo "All jobs have been qsub" >> autoqsub.log
/usr/bin/rm -rf .tobeqsub.list .qsub.list .tmp.list
