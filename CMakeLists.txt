cmake_minimum_required (VERSION 3.0)
project (bodiagsuite)

# These tests were designed for static analuysis so many of these tests contain
# code that is obviously UB (or dead) so the compiler will just delete it when
# compiling with optimizations

# Prevent cmake from setting -O2 (for release, relwithdebinf, minsizerel, etc)
set(CMAKE_C_FLAGS_RELWITHDEBINFO "-g")
set(CMAKE_C_FLAGS_RELEASE "-g")
set(CMAKE_C_FLAGS_MINSIZEREL "-g")
add_compile_options(-O0)  # Hopefully adding -O0 here should turn of optimizations

# Collect all the binaries into one directory and give them suffixes so make
# can handle them in transformation rules.  Ick.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_EXECUTABLE_SUFFIX ".exe")

# copy the run makefile to the build directory every time it changes:
add_custom_target(copy-test-makefile ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/Makefile.bsd-run)
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Makefile.bsd-run
                   COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Makefile.bsd-run
                                                    ${CMAKE_CURRENT_BINARY_DIR}/Makefile.bsd-run
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Makefile.bsd-run
)

option(WITHOUT_STACK_PROTECTOR "disable stack protector" OFF)
option(WITHOUT_FORTIFY_SOURCE "disable _FORTIFY_SOURCE" OFF)
if (WITHOUT_STACK_PROTECTOR)
	message(STATUS "compiling WITHOUT stack protector")
	add_compile_options(-fno-stack-protector)
else()
	message(STATUS "compiling WITH stack protector (default level)")
endif()
if (WITHOUT_FORTIFY_SOURCE)
	add_definitions(-D_FORTIFY_SOURCE=0)
	message(STATUS "compiling WITHOUT _FORTIFY_SOURCE")
	add_compile_options(-fno-stack-protector)
else()
	message(STATUS "compiling WITH _FORTIFY_SOURCE at default level")
endif()

file( GLOB test_cs RELATIVE ${CMAKE_SOURCE_DIR} testcases/*.c )
file( GLOB test_cs_heap RELATIVE ${CMAKE_SOURCE_DIR} testcases-heap/*.c )
# Or test with just a subset:
# file ( GLOB test_cs RELATIVE ${CMAKE_SOURCE_DIR} testcases/basic-00001-*.c  testcases/basic-00232-*.c )

# Ignore missing malloc prototype for now
add_compile_options(-Wno-implicit-function-declaration)
# These are intentionally buggy -> silence the array bounds warning
add_compile_options(-Wno-array-bounds)

if (NOT CMAKE_CROSSCOMPILING)
	enable_testing()
endif()

foreach ( tcf ${test_cs} ${test_cs_heap})
	string ( REGEX REPLACE ".c$" "" tf ${tcf} )
	string ( REGEX REPLACE "^testcases(-heap)?/" "" to ${tf} )
	unset ( tf )
	add_executable ( ${to} ${tcf} )
	target_compile_options( ${to} PUBLIC "-pthread")
	target_link_libraries( ${to} "pthread" )
	add_test(NAME test-${to} COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/check_test.sh $<TARGET_FILE:${to}>)
	if (NOT ${to} MATCHES ".*-ok$")
		# message(STATUS "Expecting ${to} to fail")
		set_tests_properties(test-${to} PROPERTIES WILL_FAIL TRUE)
	endif()
endforeach ( tcf ${TESTC} )
