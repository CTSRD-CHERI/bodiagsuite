mkdir writeread
cd writeread
..\..\gen_basic_tests.pl 1
cd ..

mkdir whichbound
cd whichbound
..\..\gen_basic_tests.pl 2
cd ..

mkdir datatype
cd datatype
..\..\gen_basic_tests.pl 3
cd ..

mkdir memloc
cd memloc
..\..\gen_basic_tests.pl 4
cd ..

mkdir scope
cd scope
..\..\gen_basic_tests.pl 5
cd ..

mkdir container
cd container
..\..\gen_basic_tests.pl 6
cd ..

mkdir pointer
cd pointer
..\..\gen_basic_tests.pl 7
cd ..

mkdir indexcomplex
cd indexcomplex
..\..\gen_basic_tests.pl 8
cd ..

mkdir addrcomplex
cd addrcomplex
..\..\gen_basic_tests.pl 9
cd ..

mkdir lencomplex
cd lencomplex
..\..\gen_basic_tests.pl 10
cd ..

mkdir aliasaddr
cd aliasaddr
..\..\gen_basic_tests.pl 11
cd ..

mkdir aliasindex
cd aliasindex
..\..\gen_basic_tests.pl 12
cd ..

mkdir localflow
cd localflow
..\..\gen_basic_tests.pl 13
cd ..

mkdir secondaryflow
cd secondaryflow
..\..\gen_basic_tests.pl 14
cd ..

mkdir loopstructure
cd loopstructure
..\..\gen_basic_tests.pl 15
cd ..

mkdir loopcomplex
cd loopcomplex
..\..\gen_basic_tests.pl 16
cd ..

mkdir asynchrony
cd asynchrony
..\..\gen_basic_tests.pl 17
cd ..

mkdir taint
cd taint
..\..\gen_basic_tests.pl 18
cd ..

mkdir continuousdiscrete
cd continuousdiscrete
..\..\gen_basic_tests.pl 21
cd ..

mkdir signedness
cd signedness
..\..\gen_basic_tests.pl 22
cd ..
