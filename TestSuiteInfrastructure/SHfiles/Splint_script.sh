#!/bin/sh
testdir=`pwd`
for file in `ls basic*.c`
do
    bs=`basename $file .c`
    /usr/bin/splint +bounds +orconstraint -paramuse $file >& /home/kendra/Thesis/Splint_results/$bs
done
