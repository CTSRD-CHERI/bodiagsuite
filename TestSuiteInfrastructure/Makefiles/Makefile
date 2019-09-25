
sources := $(wildcard *.c)
exes := $(patsubst %.c,%.exe,$(sources))

%.exe : %.c
	$(CC) -lpthread -o $@ $<

.PHONY: cred
cred: CC = /home/kendra/gcc-cred-hw/install/bin/gcc -fbounds-checking
cred : $(exes)
	-$(foreach file,$(exes),./$(file) 9 10 17 4105 2>&1 | ../filter_cred.pl;)

.PHONY: gcc
gcc : CC=gcc -W -pedantic
gcc : $(exes)


clean :
	-rm -f $(exes)

