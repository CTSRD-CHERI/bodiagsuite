#!/bin/sh
for file in `ls basic*.c`
do
    bs=`basename $file .c`
    /usr/bin/uno -CPP=/usr/bin/cpp -w $file >& /home/kendra/Thesis/Uno_results/$bs
done
