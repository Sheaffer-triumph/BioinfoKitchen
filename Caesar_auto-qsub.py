#!/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/amita/bin/python
import os
import sys
import argparse

parser = argparse.ArgumentParser(description="Autcreq: Auto create qsub script", formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument("-i", "--input", type=argparse.FileType('r'), required=True, help="Input file, each line of the file should be the realpath of the sh to be qsub.")
parser.add_argument("-n", "--numbers", type=int, required=True, help="Maximum number of sh in running and waiting. It will be automatically qsub to supplement when it detects that the actual number is less than this number")
parser.add_argument("-c", "--cpu", type=int,  required=True, help="Amount of cpu requested when qsub, it should be the same as the amount of proc")
parser.add_argument("-p", "--proc", type=int, required=True, help="Amount of proc requested when qsub, it should be the same as the amount of CPU")
parser.add_argument("-m", "--memory", type=int, required=True, help="Amount of memory requested when qsub (G)")
parser.add_argument("-s", "--sleep", type=int, default=5, help="Time between cycles (min)")

args = parser.parse_args()
inputfile = args.input
num = args.numbers
cpus = args.cpu
proc = args.proc
mem = args.memory
sleep = args.sleep


with open(os.path.join("auto_qsub.sh"), "w") as f:
    f.write("#!/bin/bash\n")
    f.write(f"INITPATH=$(pwd)\n")
    f.write(f"a=`cat ${inputfile} | wc -l`\n")
    f.write("until [ $a == 0 ]\n")
    f.write("    do\n")
    f.write("    b=`qstat | grep st.q | wc -l`\n")
    f.write(f"    if [ $b -lt {num} ]\n")
    f.write("        then\n")
    f.write(f"        d=`expr {num} - $b`\n")
    f.write(f"        cat {inputfile} > tobeqsub.list\n")
    f.write("        head -n $d tobeqsub.list > qsub.list\n")
    f.write("        grep -wvf qsub.list tobeqsub.list > tmp.list\n")
    f.write("        cat tmp.list > tobeqsub.list\n")
    f.write("        rm tmp.list\n")
    f.write("        a=`cat tobeqsub.list | wc -l`\n")
    f.write("        f=`date`\n")
    f.write("        echo $f >> qsub.log\n")
    f.write("        for e in `cat qsub.list`\n")
    f.write("            do\n")
    f.write("            g=`basename $e`\n")
    f.write("            h=`dirname $e`\n")
    f.write("            cd $h\n")
    f.write(f"            qsub -cwd -q st.q -P P17Z10200N0246 -l vf={mem}g,num_proc={proc} -binding linear:{cpus} $g\n")
    f.write("            cd $INITPATH\n")
    f.write("            echo \"$e has been qsub\" >> qsub.log\n")
    f.write("        done\n")
    f.write("    else\n")
    f.write("        f=`date`\n")
    f.write("        echo $f >> qsub.log\n")
    f.write(f"        echo \"There are {num} jobs running, please wait\" >> qsub.log\n")
    f.write("    fi\n")
    f.write(f"    sleep {sleep}m\n")
