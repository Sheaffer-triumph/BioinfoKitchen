#已实装
#使用路径：/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/amita/bin/nana

#!/usr/bin/bash

PIGZ=/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/amita/bin/pigz

THREAD=8
level=9

while getopts :i:t:z: opt
do
    case $opt in
        i)
            INPUTFILE=$OPTARG
            ;;
        t)
            THREAD=$OPTARG
            ;;
        z)
            level=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG"

            cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/nana_help.txt
            exit 1
            ;;
    esac
done

if [ -z $2 ]
    then
    INPUTFILE=$1
fi

if [ -z $INPUTFILE ]
    then
    echo "Error: No file input"
    cat /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/.store/nana_help.txt
    exit 1
fi

if [ $THREAD -ge 24 ] || [ $THREAD -lt 1 ]
    then
    THREAD=8
    echo "Warning: Nana detected that the number of threads was set incorrectly (>=24 or <1). To ensure stable operation, the default number of threads has been used."
fi

if [ $level -gt 9 ] || [ $THREAD -lt 0 ]
    then
    level=9
    echo "Warning: Nana detected that the compression level was set incorrectly (>9 or <0). To ensure stable operation, the default compression level has been used."
fi

FILENAME=$(echo $INPUTFILE)

case $FILENAME in 
    *.tar.gz)
        tar xf $INPUTFILE || { echo "Error: Failed to unpack $INPUTFILE"; exit 1; }
        ;;
    *.gz)
        NEWFILE=$(echo $INPUTFILE | sed 's/\.gz//g')
        gzip -d -f -c $INPUTFILE > $NEWFILE || { echo "Error: Failed to unpack $INPUTFILE"; exit 1; }
        ;;
    *.zip)
        unzip -o $INPUTFILE || { echo "Error: Failed to unpack $INPUTFILE"; exit 1; }
        ;;
    *.tar)
        $PIGZ -p $THREAD -k -$level $INPUTFILE || { echo "Error: Failed to compress $INPUTFILE"; exit 1; }
        ;;
    *)
        tar cf - $INPUTFILE | $PIGZ -p $THREAD -k -$level > ${INPUTFILE}.tar.gz || { echo "Error: Failed to compress $INPUTFILE"; exit 1; }
        ;;
esac
