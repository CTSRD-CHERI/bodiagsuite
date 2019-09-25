mkdir writeread_datatype
cd writeread_datatype
..\..\gen_basic_tests.pl --combo 1 3
cd ..

mkdir whichbound_datatype
cd whichbound_datatype
..\..\gen_basic_tests.pl --combo 2 3
cd ..

mkdir memloc_datatype
cd memloc_datatype
..\..\gen_basic_tests.pl --combo 4 3
cd ..

mkdir scope_datatype
cd scope_datatype
..\..\gen_basic_tests.pl --combo 5 3
cd ..

mkdir container_datatype
cd container_datatype
..\..\gen_basic_tests.pl --combo 6 3
cd ..

mkdir pointer_datatype
cd pointer_datatype
..\..\gen_basic_tests.pl --combo 7 3
cd ..

mkdir indexcomplex_datatype
cd indexcomplex_datatype
..\..\gen_basic_tests.pl --combo 8 3
cd ..

mkdir addrcomplex_datatype
cd addrcomplex_datatype
..\..\gen_basic_tests.pl --combo 9 3
cd ..

mkdir aliasaddr_datatype
cd aliasaddr_datatype
..\..\gen_basic_tests.pl --combo 11 3
cd ..

mkdir aliasindex_datatype
cd aliasindex_datatype
..\..\gen_basic_tests.pl --combo 12 3
cd ..

mkdir localflow_datatype
cd localflow_datatype
..\..\gen_basic_tests.pl --combo 13 3
cd ..

mkdir secondaryflow_datatype
cd secondaryflow_datatype
..\..\gen_basic_tests.pl --combo 14 3
cd ..

mkdir loopstructure_datatype
cd loopstructure_datatype
..\..\gen_basic_tests.pl --combo 15 3
cd ..

mkdir loopcomplex_datatype
cd loopcomplex_datatype
..\..\gen_basic_tests.pl --combo 16 3
cd ..

mkdir asynchrony_datatype
cd asynchrony_datatype
..\..\gen_basic_tests.pl --combo 17 3
cd ..

mkdir taint_datatype
cd taint_datatype
..\..\gen_basic_tests.pl --combo 18 3
cd ..

mkdir continuousdiscrete_datatype
cd continuousdiscrete_datatype
..\..\gen_basic_tests.pl --combo 21 3
cd ..