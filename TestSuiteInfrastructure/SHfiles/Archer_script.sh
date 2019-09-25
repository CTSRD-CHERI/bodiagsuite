#!/bin/sh
testdir=`pwd`
for file in `ls basic*.c`
do
    bs=`basename $file .c`
    rm -rf /home/kendra/temptree
    mkdir /home/kendra/temptree
    export LD_LIBRARY_PATH=/data/ia/tools/archer/global/global1.0/tree-emit
    export MC_GLOBAL=/data/ia/tools/archer/global/global1.0
    export MCGCC=/data/ia/tools/archer/global/gcc-bin/bin/gcc
    /data/ia/tools/archer/global/gcc-bin/bin/gcc -fmc-emit=/home/kendra/temptree \
        -c $file -lpthread
    cd /data/ia/tools/archer/archer
    /data/ia/tools/archer/archer/archer /home/kendra/temptree > /home/kendra/Thesis/Archer_results/$bs
    cd $testdir
done
