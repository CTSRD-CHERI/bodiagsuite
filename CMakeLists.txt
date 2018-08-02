cmake_minimum_required (VERSION 3.0)
project (bodiagsuite)

# Prevent cmake from setting -O2
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-g")

# Collect all the binaries into one directory and give them suffixes so make
# can handle them in transformation rules.  Ick.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_EXECUTABLE_SUFFIX ".exe")

file( GLOB test_cs RELATIVE ${CMAKE_SOURCE_DIR} testcases/*.c )
# Or test with just a subset:
# file ( GLOB test_cs RELATIVE ${CMAKE_SOURCE_DIR} testcases/basic-00001-*.c  testcases/basic-00232-*.c )

foreach ( tcf ${test_cs} )
	string ( REGEX REPLACE ".c$" "" tf ${tcf} )
	string ( REGEX REPLACE "^testcases/" "" to ${tf} )
	unset ( tf )
	add_executable ( ${to} ${tcf} )
	target_compile_options( ${to} PUBLIC "-pthread")
	target_link_libraries( ${to} "pthread" )
endforeach ( tcf ${TESTC} )
