#!/bin/sh
testdir=`pwd`
export PATH="$PATH:/data/ia/tools/boon"
for file in `ls basic*.c`
do
    bs=`basename $file .c`
    cd /data/ia/tools/boon
    ./preproc $testdir/$file
    ./boon $testdir/$bs.i >& /home/kendra/Thesis/Boon_results/$bs
    rm $testdir/$bs.i
done
