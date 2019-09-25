#!/bin/sh
for file in `ls basic*.c`
do
    bs=`basename $file .c`
    /work/tools/PolySpace/2.5/bin/polyspace-c \
    -continue-with-existing-host \
    -target i386 \
    -OS-target linux \
    -I /work/tools/PolySpace/2.5/include/include-linux \
    -permissive \
    -sources $file \
    -results-dir /home/kendra/PolySpace_results/$bs
done
