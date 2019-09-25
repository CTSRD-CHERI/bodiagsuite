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
    -ignore-constant-overflows \
    -include /work/tools/PolySpace/2.5/include/include-linux/sys/types.h \
    -sources $file \
    -results-dir /home/kendra/retest-basic-00006/PolySpace_results/$bs
done
