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

add_compile_options(-Wall)

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

option(WITH_STACK_PROTECTOR "disable stack protector" OFF)
option(WITH_FORTIFY_SOURCE "disable _FORTIFY_SOURCE" OFF)
if (WITH_STACK_PROTECTOR)
	message(STATUS "compiling WITH stack protector")
	add_compile_options(-fstack-protector-all)
else()
	message(STATUS "compiling WITHOUT stack protector")
	add_compile_options(-fno-stack-protector)
endif()
if (WITH_FORTIFY_SOURCE)
	message(STATUS "compiling WITH _FORTIFY_SOURCE=2")
	add_definitions(-D_FORTIFY_SOURCE=2)
	# TODO: should do this once there are no more dead stores...
	# Need to find the generator scripts to fix this.
	if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
		# _FORTIFY_SOURCE requires optimizations with GLIBC
		# Try to disable dead-store-elimination and dead-code-elimination
		# add_compile_options(-O -fno-dse -fno-dce -fno-tree-dse -fno-tree-dce)
		add_compile_definitions(__OPTIMIZE__=2)
	endif()
else()
	add_definitions(-D_FORTIFY_SOURCE=0)
	message(STATUS "compiling WITHOUT _FORTIFY_SOURCE")
endif()

file( GLOB test_cs RELATIVE ${CMAKE_SOURCE_DIR} testcases/*.c )
file( GLOB test_cs_heap RELATIVE ${CMAKE_SOURCE_DIR} testcases-heap/*.c )
# Or test with just a subset:
# file ( GLOB test_cs RELATIVE ${CMAKE_SOURCE_DIR} testcases/basic-00001-*.c  testcases/basic-00232-*.c )

# Ignore missing malloc prototype for now
add_compile_options(-Werror=implicit-function-declaration)
# These are intentionally buggy -> silence the array bounds warning
add_compile_options(-Wno-array-bounds)
# ignore switch on boolean (used in some of the files):
add_compile_options(-Wno-switch-bool)

if (NOT CMAKE_CROSSCOMPILING)
	enable_testing()
endif()

#  Could also add extern "C" int __lsan_is_turned_off() { return 1; }
# to disable LSAN (but for now just set ASAN_OPTIONS=detect_leaks=0 in the test script)
# add_library(disable-lsan OBJECT disable-leak-sanitizer.c)

foreach ( tcf ${test_cs} ${test_cs_heap})
	string ( REGEX REPLACE ".c$" "" tf ${tcf} )
	string ( REGEX REPLACE "^testcases(-heap)?/" "" to ${tf} )
	unset ( tf )
	add_executable ( ${to} ${tcf} )
	target_compile_options( ${to} PUBLIC "-pthread")
	target_compile_options( ${to} PUBLIC "-include" "${CMAKE_SOURCE_DIR}/fix-missing-decls.h")
	target_link_libraries( ${to} "pthread")
	# target_link_libraries( ${to} disable-lsan)
	add_test(NAME test-${to} COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/check_test.sh $<TARGET_FILE:${to}>)
	if (NOT ${to} MATCHES ".*-ok$")
		# message(STATUS "Expecting ${to} to fail")
		set_tests_properties(test-${to} PROPERTIES WILL_FAIL TRUE)
	endif()
endforeach ( tcf ${TESTC} )
