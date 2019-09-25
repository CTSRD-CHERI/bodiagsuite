#!/usr/bin/perl -w

##--------------------------------------------------------------
## Copyright
##--------------------------------------------------------------
#Copyright 2005 Massachusetts Institute of Technology
#             All rights reserved. 
#
#Redistribution and use of software in source and binary forms, with or without 
#modification, are permitted provided that the following conditions are met.
#
#    - Redistributions of source code must retain the above copyright notice, 
#      this set of conditions and the disclaimer below.
#    - Redistributions in binary form must reproduce the copyright notice, this 
#      set of conditions, and the disclaimer below in the documentation and/or 
#      other materials provided with the distribution.
#    - Neither the name of the Massachusetts Institute of Technology nor the 
#      names of its contributors may be used to endorse or promote products 
#      derived from this software without specific prior written permission. 
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS".
#
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
#DISCLAIMED. 
#
#IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
#INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
#BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
#DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
#OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
#ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

use strict;
use Getopt::Long;

##--------------------------------------------------------------
## File globals
##--------------------------------------------------------------
# definitions for overflow size variations
my $OK_OVERFLOW = 0;
my $MIN_OVERFLOW = 1;
my $MED_OVERFLOW = 2;
my $LARGE_OVERFLOW = 3;

# buffer and overflow sizes defined
my $BUF_SIZE = 10;
my $ARRAY_SIZE = 5; # for when we have an array of buffers
my $OK_SIZE = 0;
my $MIN_SIZE = 1;
my $MED_SIZE = 8;
my $LARGE_SIZE = 4096;

# comments for the buffer accesses
use constant OK_COMMENT => "  /*  OK  */";
use constant BAD_COMMENT => "  /*  BAD  */";

# associate overflow type with size and comment in a hash
my %OverflowInfo = ($OK_OVERFLOW => [$OK_SIZE, OK_COMMENT],
                    $MIN_OVERFLOW => [$MIN_SIZE, BAD_COMMENT],
                    $MED_OVERFLOW => [$MED_SIZE, BAD_COMMENT],
                    $LARGE_OVERFLOW => [$LARGE_SIZE, BAD_COMMENT]);

# definitions for array indices related to the OverflowInfo hash
use constant SIZE_INDEX => 0;
use constant COMMENT_INDEX => 1;

# pieces of the test case programs
use constant FILE_HEADER =>
"/*
Copyright 2005 Massachusetts Institute of Technology
             All rights reserved. 

Redistribution and use of software in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met.

    - Redistributions of source code must retain the above copyright notice, 
      this set of conditions and the disclaimer below.
    - Redistributions in binary form must reproduce the copyright notice, this 
      set of conditions, and the disclaimer below in the documentation and/or 
      other materials provided with the distribution.
    - Neither the name of the Massachusetts Institute of Technology nor the 
      names of its contributors may be used to endorse or promote products 
      derived from this software without specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\".

ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. 

IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*/\n\n";

use constant TAXONOMY_CLASSIFICATION => "/* Taxonomy Classification: VALUE */\n\n";
use constant MAIN_OPEN => "int main\(int argc, char *argv[]\)\n{\n";
use constant MAIN_CLOSE => "\n  return 0;\n}\n";

my $BUF_DECL = "  TYPE buf[$BUF_SIZE];\n\n";
my $BUF_ACCESS = "COMMENT\n  buf[INDEX] = WRITE_VALUE;\n";

# definitions for the taxonomy characteristics digits
my $WRITEREAD_DIGIT = 0;
my $WHICHBOUND_DIGIT = 1;
my $DATATYPE_DIGIT = 2;
my $MEMLOC_DIGIT = 3;
my $SCOPE_DIGIT = 4;
my $CONTAINER_DIGIT = 5;
my $POINTER_DIGIT = 6;
my $INDEXCOMPLEX_DIGIT = 7;
my $ADDRCOMPLEX_DIGIT = 8;
my $LENCOMPLEX_DIGIT = 9;
my $ALIASADDR_DIGIT = 10;
my $ALIASINDEX_DIGIT = 11;
my $LOCALFLOW_DIGIT = 12;
my $SECONDARYFLOW_DIGIT = 13;
my $LOOPSTRUCTURE_DIGIT = 14;
my $LOOPCOMPLEX_DIGIT = 15;
my $ASYNCHRONY_DIGIT = 16;
my $TAINT_DIGIT = 17;
my $RUNTIMEENVDEP_DIGIT = 18;
my $MAGNITUDE_DIGIT = 19;
my $CONTINUOUSDISCRETE_DIGIT = 20;
my $SIGNEDNESS_DIGIT = 21;

# associate taxonomy characteristics with their values in an array
my @TaxonomyInfo = (
    ['WRITE/READ', {0 => 'write', 1 => 'read'}], 
    ['WHICH BOUND', {0 => 'upper', 1 => 'lower'}], 
    ['DATA TYPE', {0 => 'char', 1 => 'int', 2 => 'float', 
                        3 => 'wchar', 4 => 'pointer', 5 => 'unsigned int',
                        6 => 'unsigned char'}], 
    ['MEMORY LOCATION', {0 => 'stack', 1 => 'heap', 2 => 'data segment',
                      3 => 'bss', 4 => 'shared'}], 
    ['SCOPE', {0 => 'same', 1 => 'inter-procedural', 2 => 'global',
                     3 => 'inter-file/inter-proc', 4 => 'inter-file/global'}], 
    ['CONTAINER', {0 => 'no', 1 => 'array', 2 => 'struct', 3 => 'union',
                         4 => 'array of structs', 5 => 'array of unions'}], 
    ['POINTER', {0 => 'no', 1 => 'yes'}], 
    ['INDEX COMPLEXITY', {0 => 'constant', 1 => 'variable', 2 => 'linear expr',
                            3 => 'non-linear expr', 4 => 'function return value',
                            5 => 'array contents', 6 => 'N/A'}], 
    ['ADDRESS COMPLEXITY', {0 => 'constant', 1 => 'variable', 2 => 'linear expr',
                            3 => 'non-linear expr', 4 => 'function return value',
                            5 => 'array contents'}], 
    ['LENGTH COMPLEXITY', {0 => 'N/A', 1 => 'none', 2 => 'constant', 
                          3 => 'variable', 4 => 'linear expr', 
                          5 => 'non-linear expr', 6 => 'function return value',
                          7 => 'array contents'}], 
    ['ADDRESS ALIAS', {0 => 'none', 1 => 'yes, one level', 
                         2 => 'yes, two levels'}], 
    ['INDEX ALIAS', {0 => 'none', 1 => 'yes, one level', 
                         2 => 'yes, two levels', 3 => 'N/A'}], 
    ['LOCAL CONTROL FLOW', {0 => 'none', 1 => 'if', 2 => 'switch', 3 => 'cond',
                         4 => 'goto/label', 5 => 'longjmp', 
                         6 => 'function pointer', 7 => 'recursion'}], 
    ['SECONDARY CONTROL FLOW', {0 => 'none', 1 => 'if', 2 => 'switch', 3 => 'cond',
                         4 => 'goto/label', 5 => 'longjmp', 
                         6 => 'function pointer', 7 => 'recursion'}], 
    ['LOOP STRUCTURE', {0 => 'no', 1 => 'for', 2 => 'do-while', 3 => 'while',
                             4 => 'non-standard for', 5 => 'non-standard do-while',
                             6 => 'non-standard while'}], 
    ['LOOP COMPLEXITY', {0 => 'N/A', 1 => 'zero', 2 => 'one', 3 => 'two', 4 => 'three'}], 
    ['ASYNCHRONY', {0 => 'no', 1 => 'threads', 2 => 'forked process',
                          3 => 'signal handler'}], 
    ['TAINT', {0 => 'no', 1 => 'argc/argv', 2 => 'environment variable', 
                     3 => 'file read', 4 => 'socket', 5 => 'process environment'}], 
    ['RUNTIME ENV. DEPENDENCE', {0 => 'no', 1 => 'yes'}], 
    ['MAGNITUDE', {0 => 'no overflow', 1 => "$MIN_SIZE byte", 
                         2 => "$MED_SIZE bytes", 3 => "$LARGE_SIZE bytes"}],
    ['CONTINUOUS/DISCRETE', {0 => 'discrete', 1 => 'continuous'}], 
    ['SIGNEDNESS', {0 => 'no', 1 => 'yes'}]);

# definitions for array indices related to the TaxonomyInfo array
use constant NAME_INDEX => 0;
use constant VALUES_INDEX => 1;

# associate taxonomy attributes with functions that handle them
my %AttributeFunctions = 
(
    $WRITEREAD_DIGIT => \&do_writeread,
    $WHICHBOUND_DIGIT => \&do_whichbound,
    $DATATYPE_DIGIT => \&do_datatype,
    $MEMLOC_DIGIT => \&do_memloc,
    $SCOPE_DIGIT => \&do_scope,
    $CONTAINER_DIGIT => \&do_container,
    $POINTER_DIGIT => \&do_pointer,
    $INDEXCOMPLEX_DIGIT => \&do_indexcomplex,
    $ADDRCOMPLEX_DIGIT => \&do_addrcomplex,
    $LENCOMPLEX_DIGIT => \&do_lencomplex,
    $ALIASADDR_DIGIT => \&do_aliasaddr,
    $ALIASINDEX_DIGIT => \&do_aliasindex,
    $LOCALFLOW_DIGIT => \&do_localflow,
    $SECONDARYFLOW_DIGIT => \&do_secondaryflow,
    $LOOPSTRUCTURE_DIGIT => \&do_loopstructure,
    $LOOPCOMPLEX_DIGIT => \&do_loopcomplex,
    $ASYNCHRONY_DIGIT => \&do_asynchrony,
    $TAINT_DIGIT => \&do_taint,
    $CONTINUOUSDISCRETE_DIGIT => \&do_continuousdiscrete,
    $SIGNEDNESS_DIGIT => \&do_signedness,
    $RUNTIMEENVDEP_DIGIT => \&do_runtimeenvdep,
    $MAGNITUDE_DIGIT => \&do_magnitude,
);

##--------------------------------------------------------------
## main program
##--------------------------------------------------------------

#--------------------------------------------------------------
# process options
# (future options: clean dir, starting file num)
#--------------------------------------------------------------
# initialize to default values
#my $Opt_Outdir = ".\\";
my $Opt_Combo = undef;

# get caller-provided values
if(!GetOptions(#"outdir=s" => \$Opt_Outdir,
               "combo" => \$Opt_Combo))
{
    usage("Unable to parse options.\n");
}

# verify that options are valid
#-e $Opt_Outdir or die "Sorry.  Output directory $Opt_Outdir does not exist.\n";
#-d $Opt_Outdir or die "Sorry.  $Opt_Outdir is not a directory.\n";

#--------------------------------------------------------------
# process arguments
#--------------------------------------------------------------
# get remaining command line arguments - they are the attributes to vary
my @vary_these = @ARGV;

#--------------------------------------------------------------
# here's the beef
#--------------------------------------------------------------

# find the file sequence number to start with
my $fseq_num = get_fseq_num();

# if the caller wants a combo, pass all attributes in one call
if ($Opt_Combo) 
{
    $fseq_num = make_files(\@vary_these, $fseq_num);
}
else
{
    # the caller wants singles, not combos, so pass one attribute at a time
    foreach my $attribute (@vary_these) 
    {
        $fseq_num = make_files([$attribute], $fseq_num);
    }
}

exit(0);

##--------------------------------------------------------------
## subroutines  (alphabetized)
##--------------------------------------------------------------
##--------------------------------------------------------------
## do_addrcomplex : produces all the test case variants for the 
##  "address complexity" attribute.
##--------------------------------------------------------------
sub do_addrcomplex
{   # COMBO NOTE: these will be affected by whether or not we're using a 
    # pointer or a function call instead of a buffer index.  For now it 
    # assumes a buffer index.  This needs to be updated for other
    # combos to work.

    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # variable = 1
        my $var_values_ref = get_hash_copy($entry);
        $var_values_ref->{'TAX'}->[$ADDRCOMPLEX_DIGIT] = 1;
        $var_values_ref->{'OTHER_DECL'} = "  int i;\n" . $var_values_ref->{'OTHER_DECL'};
        $var_values_ref->{'PRE_ACCESS'} =  "  i = INDEX;\n" . 
                                            $var_values_ref->{'PRE_ACCESS'};
        $var_values_ref->{'ACCESS'} = "COMMENT\n  (buf + i)[0] = WRITE_VALUE;\n";
        push @$results_ref, $var_values_ref;

        # linear expression = 2
        my $linexp_values_ref = get_hash_copy($entry);
        $linexp_values_ref->{'TAX'}->[$ADDRCOMPLEX_DIGIT] = 2;
        $linexp_values_ref->{'OTHER_DECL'} = "  int i;\n" . $linexp_values_ref->{'OTHER_DECL'};
        # need to calculate the values that will get substituted to fit
        #   the linear expr: 4 * FACTOR2 + REMAIN = previous value for INDEX
        my $factor1 = 4;
        foreach my $index_value (keys %{$linexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $linexp_values_ref->{'MULTIS'}->{'FACTOR2'}->{$index_value} = 
                int $linexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} / $factor1;
            $linexp_values_ref->{'MULTIS'}->{'REMAIN'}->{$index_value} = 
                $linexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} - 
                    ($linexp_values_ref->{'MULTIS'}->{'FACTOR2'}->{$index_value} * $factor1);
        }
        $linexp_values_ref->{'PRE_ACCESS'} =  "  i = FACTOR2;\n" . 
                                            $linexp_values_ref->{'PRE_ACCESS'};
        $linexp_values_ref->{'ACCESS'} = "COMMENT\n  (buf + ($factor1 * i))[REMAIN] = WRITE_VALUE;\n";
        push @$results_ref, $linexp_values_ref;

        # non-linear expression = 3
        my $nonlinexp_values_ref = get_hash_copy($entry);
        $nonlinexp_values_ref->{'TAX'}->[$ADDRCOMPLEX_DIGIT] = 3;
        $nonlinexp_values_ref->{'OTHER_DECL'} = "  int i;\n" . $nonlinexp_values_ref->{'OTHER_DECL'};
        foreach my $index_value (keys %{$nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $nonlinexp_values_ref->{'MULTIS'}->{'MOD'}->{$index_value} = 
                int $nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} + 1;
        }
        $nonlinexp_values_ref->{'PRE_ACCESS'} =  "  i = MOD;\n" . 
                                            $nonlinexp_values_ref->{'PRE_ACCESS'};
        $nonlinexp_values_ref->{'ACCESS'} = "COMMENT\n  (buf + (INDEX % i))[0] = WRITE_VALUE;\n";
        push @$results_ref, $nonlinexp_values_ref;

         # function return value = 4
        my $funcret_values_ref = get_hash_copy($entry);
        $funcret_values_ref->{'TAX'}->[$ADDRCOMPLEX_DIGIT] = 4;
        $funcret_values_ref->{'BEFORE_MAIN'} = "TYPE * function1\(TYPE * arg1)\n{\n" .
                                               "  return arg1;\n}\n\n" .
                                               $funcret_values_ref->{'BEFORE_MAIN'};
        $funcret_values_ref->{'ACCESS'} = "COMMENT\n  (function1(buf))[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $funcret_values_ref;

        #  array contents = 5
        my $arraycontent_values_ref = get_hash_copy($entry);
        $arraycontent_values_ref->{'TAX'}->[$ADDRCOMPLEX_DIGIT] = 5;
        $arraycontent_values_ref->{'OTHER_DECL'} = "  TYPE * addr_array[$ARRAY_SIZE];\n" . 
                                    $arraycontent_values_ref->{'OTHER_DECL'};
        $arraycontent_values_ref->{'PRE_ACCESS'} =  "  addr_array[0] = buf;\n" . 
                                            $arraycontent_values_ref->{'PRE_ACCESS'};
        $arraycontent_values_ref->{'ACCESS'} = "COMMENT\n  (addr_array[0])[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $arraycontent_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_aliasaddr : produces all the test case variants for the 
##  "alias of buffer address" attribute.
##--------------------------------------------------------------
sub do_aliasaddr
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # one alias = 1 (there are two variations of this)
        # first variation: simple alias to original buffer
        my $onealiasvar1_values_ref = get_hash_copy($entry);
        $onealiasvar1_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1;
        $onealiasvar1_values_ref->{'OTHER_DECL'} = "  TYPE * buf_alias;\n" .
                                        $onealiasvar1_values_ref->{'OTHER_DECL'};
        $onealiasvar1_values_ref->{'PRE_ACCESS'} = "  buf_alias = buf;\n" .
                                        $onealiasvar1_values_ref->{'PRE_ACCESS'};
        $onealiasvar1_values_ref->{'ACCESS'} =~ s/buf/buf_alias/;
        push @$results_ref, $onealiasvar1_values_ref;

        # second variation: buffer passed into one function
        my $onealiasvar2_values_ref = get_hash_copy($entry);
        $onealiasvar2_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1;
        $onealiasvar2_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 1;  #inter-procedural
        $onealiasvar2_values_ref->{'BEFORE_MAIN'} = "void function1\(TYPE * buf\)\n{\n" .
                                               $onealiasvar2_values_ref->{'ACCESS'} .
                                               "}\n\n" .
                                                $onealiasvar2_values_ref->{'BEFORE_MAIN'};
        $onealiasvar2_values_ref->{'ACCESS'} = "  function1\(buf\);\n";
        push @$results_ref, $onealiasvar2_values_ref;

        # two aliases = 2 (there are two variations of this)
        # first variation: simple double alias to original buffer
        my $twoaliasvar1_values_ref = get_hash_copy($entry);
        $twoaliasvar1_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 2;
        $twoaliasvar1_values_ref->{'OTHER_DECL'} = "  TYPE * buf_alias1;\n" .
                                                   "  TYPE * buf_alias2;\n" .
                                        $twoaliasvar1_values_ref->{'OTHER_DECL'};
        $twoaliasvar1_values_ref->{'PRE_ACCESS'} = "  buf_alias1 = buf;\n" .
                                                   "  buf_alias2 = buf_alias1;\n" .
                                        $twoaliasvar1_values_ref->{'PRE_ACCESS'};
        $twoaliasvar1_values_ref->{'ACCESS'} =~ s/buf/buf_alias2/;
        push @$results_ref, $twoaliasvar1_values_ref;

        # second variation: buffer passed into two functions
        my $twoaliasvar2_values_ref = get_hash_copy($entry);
        $twoaliasvar2_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 2;
        $twoaliasvar2_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 1;  #inter-procedural
        $twoaliasvar2_values_ref->{'BEFORE_MAIN'} = "void function2\(TYPE * buf\)\n{\n" .
                                               $twoaliasvar2_values_ref->{'ACCESS'} .
                                               "}\n\n" . "void function1\(TYPE * buf\)\n{\n" .
                                               "  function2\(buf\);\n}\n\n" .
                                                $twoaliasvar2_values_ref->{'BEFORE_MAIN'};
        $twoaliasvar2_values_ref->{'ACCESS'} = "  function1\(buf\);\n";
        push @$results_ref, $twoaliasvar2_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_aliasindex : produces all the test case variants for the 
##  "alias of buffer index" attribute.
##--------------------------------------------------------------
sub do_aliasindex
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # one alias = 1
        my $onealias_values_ref = get_hash_copy($entry);
        $onealias_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 1;
        $onealias_values_ref->{'OTHER_DECL'} = "  int i;\n  int j;\n" .
                                        $onealias_values_ref->{'OTHER_DECL'};
        $onealias_values_ref->{'PRE_ACCESS'} = "  i = INDEX;\n  j = i;\n" .
                                        $onealias_values_ref->{'PRE_ACCESS'};
        $onealias_values_ref->{'ACCESS'} =~ s/INDEX/j/;
        push @$results_ref, $onealias_values_ref;

        # two aliases = 2
        my $twoalias_values_ref = get_hash_copy($entry);
        $twoalias_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 2;
        $twoalias_values_ref->{'OTHER_DECL'} = "  int i;\n  int j;\n  int k;\n" .
                                        $twoalias_values_ref->{'OTHER_DECL'};
        $twoalias_values_ref->{'PRE_ACCESS'} = "  i = INDEX;\n  j = i;\n  k = j;\n" .
                                        $twoalias_values_ref->{'PRE_ACCESS'};
        $twoalias_values_ref->{'ACCESS'} =~ s/INDEX/k/;
        push @$results_ref, $twoalias_values_ref;
    }
    
    return $results_ref;
}

##--------------------------------------------------------------
## do_asynchrony : produces all the test case variants for the 
##  "asynchrony" attribute.
##--------------------------------------------------------------
#  pthread_exit((void *)NULL); /* Doesn't return */
#  return (0); /* Make GCC happy */
sub do_asynchrony
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # threads = 1
        my $thread_values_ref = get_hash_copy($entry);
        $thread_values_ref->{'TAX'}->[$ASYNCHRONY_DIGIT] = 1;
        $thread_values_ref->{'INCL'} = "#include <pthread.h>\n" . $thread_values_ref->{'INCL'};
        $thread_values_ref->{'BEFORE_MAIN'} = "void * thread_function1(void * arg1)\n{\n" .
                                              $thread_values_ref->{'BUF_DECL'} . 
                                              $thread_values_ref->{'OTHER_DECL'} . 
                                              $thread_values_ref->{'PRE_ACCESS'} .
                                              $thread_values_ref->{'ACCESS'} . 
                                              $thread_values_ref->{'POST_ACCESS'} .
                                              "  pthread_exit((void *)NULL);\n\n" .
                                              "  return 0;\n}\n\n" .
                                               $thread_values_ref->{'BEFORE_MAIN'};
        $thread_values_ref->{'BUF_DECL'} = "";
        $thread_values_ref->{'OTHER_DECL'} = "  pthread_t  thread1;\n\n";
        $thread_values_ref->{'PRE_ACCESS'} = "  pthread_create(&thread1, NULL, &thread_function1, (void *)NULL);\n" .
                                             "  pthread_exit((void *)NULL);\n";
        $thread_values_ref->{'ACCESS'} = "";
        $thread_values_ref->{'POST_ACCESS'} = "";
        push @$results_ref, $thread_values_ref;

        # forked process = 2
        my $fork_values_ref = get_hash_copy($entry);
        $fork_values_ref->{'TAX'}->[$ASYNCHRONY_DIGIT] = 2;
        $fork_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 1;      # if
        $fork_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;  # if
        $fork_values_ref->{'INCL'} = "#include <sys/types.h>\n" .
                                     "#include <sys/wait.h>\n" . 
                                     "#include <unistd.h>\n" .
                                     "#include <stdlib.h>\n" . $fork_values_ref->{'INCL'};
        $fork_values_ref->{'OTHER_DECL'} = "  pid_t pid;\n  int child_status;\n\n";
        $fork_values_ref->{'PRE_ACCESS'} = $fork_values_ref->{'PRE_ACCESS'} .
                                           "  pid = fork();\n" .
                                           "  if (pid == 0)\n  {\n    sleep(3);\n    exit(0);\n  }\n" .
                                           "  else if (pid != -1)\n  {\n    wait(&child_status);\n" .
                                           "    if (WIFEXITED(child_status))\n    {\n";
        $fork_values_ref->{'ACCESS'} = indent(6, $fork_values_ref->{'ACCESS'});
        $fork_values_ref->{'POST_ACCESS'} = "    }\n  }\n" . $fork_values_ref->{'POST_ACCESS'};
        push @$results_ref, $fork_values_ref;

        # signal handler = 3
        my $sighand_values_ref = get_hash_copy($entry);
        $sighand_values_ref->{'TAX'}->[$ASYNCHRONY_DIGIT] = 3;
        $sighand_values_ref->{'INCL'} = "#include <signal.h>\n" . "#include <sys/time.h>\n" .
                                      "#include <unistd.h>\n" . $sighand_values_ref->{'INCL'};
        $sighand_values_ref->{'BEFORE_MAIN'} = "void sigalrm_handler(int arg1)\n{\n" .
                                              $sighand_values_ref->{'BUF_DECL'} . 
                                              $sighand_values_ref->{'OTHER_DECL'} . 
                                              $sighand_values_ref->{'PRE_ACCESS'} .
                                              $sighand_values_ref->{'ACCESS'} . 
                                              $sighand_values_ref->{'POST_ACCESS'} .
                                              "  return;\n}\n\n" .
                                               $sighand_values_ref->{'BEFORE_MAIN'};
        $sighand_values_ref->{'BUF_DECL'} = "";
        $sighand_values_ref->{'OTHER_DECL'} = "  struct itimerval new_timeset, old_timeset;\n";
        $sighand_values_ref->{'PRE_ACCESS'} = "  signal(SIGALRM, &sigalrm_handler);\n" .
                                              "  new_timeset.it_interval.tv_sec = 1;\n" .
                                              "  new_timeset.it_interval.tv_usec = 0;\n" .
                                              "  new_timeset.it_value.tv_sec = 1;\n" .
                                              "  new_timeset.it_value.tv_usec = 0;\n" .
                                              "  setitimer(ITIMER_REAL, &new_timeset, &old_timeset );\n" .
                                              "  pause();\n\n";
        $sighand_values_ref->{'ACCESS'} = "";
        $sighand_values_ref->{'POST_ACCESS'} = "";
        push @$results_ref, $sighand_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_container : produces all the test case variants for the 
##  "container" attribute.
##--------------------------------------------------------------
sub do_container
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # array = 1
        my $array_values_ref = get_hash_copy($entry);
        $array_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 1;
        $array_values_ref->{'BUF_DECL'} = "  TYPE buf[$ARRAY_SIZE][$BUF_SIZE];\n\n";
        # COMBO NOTE: if it's an underflow, the array_index would be affected.
        # Needs to be updated for underflow combos to work.
        my $array_index1 = $ARRAY_SIZE - 1;
        $array_values_ref->{'ACCESS'} = "COMMENT\n  buf[$array_index1][INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $array_values_ref;

        # struct = 2
        # variation 1: the buffer is the only thing in the struct
        my $struct1_values_ref = get_hash_copy($entry);
        $struct1_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 2;
        $struct1_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $struct1_values_ref->{'BEFORE_MAIN'};
        $struct1_values_ref->{'BUF_DECL'} = "  my_struct s;\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $struct1_values_ref->{'ACCESS'} = "COMMENT\n  s.buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $struct1_values_ref;

        # struct = 2
        # variation 2: 2 buffers, 1st overflows
        my $struct2_values_ref = get_hash_copy($entry);
        $struct2_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 2;
        $struct2_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf1[$BUF_SIZE];\n" .
                                       "  TYPE buf2[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $struct2_values_ref->{'BEFORE_MAIN'};
        $struct2_values_ref->{'BUF_DECL'} = "  my_struct s;\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $struct2_values_ref->{'ACCESS'} = "COMMENT\n  s.buf1[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $struct2_values_ref;

        # struct = 2
        # variation 3: 2 buffers, 2nd overflows
        my $struct3_values_ref = get_hash_copy($entry);
        $struct3_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 2;
        $struct3_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf1[$BUF_SIZE];\n" .
                                       "  TYPE buf2[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $struct3_values_ref->{'BEFORE_MAIN'};
        $struct3_values_ref->{'BUF_DECL'} = "  my_struct s;\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $struct3_values_ref->{'ACCESS'} = "COMMENT\n  s.buf2[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $struct3_values_ref;

        # struct = 2
        # variation 4: buffer then integer
        my $struct4_values_ref = get_hash_copy($entry);
        $struct4_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 2;
        $struct4_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "  int int_field;\n" .
                                       "} my_struct;\n\n" .
                                       $struct4_values_ref->{'BEFORE_MAIN'};
        $struct4_values_ref->{'BUF_DECL'} = "  my_struct s;\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $struct4_values_ref->{'ACCESS'} = "COMMENT\n  s.buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $struct4_values_ref;

        # struct = 2
        # variation 5: integer then buffer
        my $struct5_values_ref = get_hash_copy($entry);
        $struct5_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 2;
        $struct5_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  int int_field;\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $struct5_values_ref->{'BEFORE_MAIN'};
        $struct5_values_ref->{'BUF_DECL'} = "  my_struct s;\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $struct5_values_ref->{'ACCESS'} = "COMMENT\n  s.buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $struct5_values_ref;

        # struct = 2
        # variation 6: buffer then integer, use integer as index
        my $struct6_values_ref = get_hash_copy($entry);
        $struct6_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 2;
        $struct6_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1; # variable
        $struct6_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "  int int_field;\n" .
                                       "} my_struct;\n\n" .
                                       $struct6_values_ref->{'BEFORE_MAIN'};
        $struct6_values_ref->{'BUF_DECL'} = "  my_struct s;\n\n";
        $struct6_values_ref->{'PRE_ACCESS'} = "  s.int_field = INDEX;\n" . 
                                                $struct6_values_ref->{'PRE_ACCESS'};
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $struct6_values_ref->{'ACCESS'} = "COMMENT\n  s.buf[s.int_field] = WRITE_VALUE;\n";
        push @$results_ref, $struct6_values_ref;

        # struct = 2
        # variation 7: integer then buffer, use integer as index
        my $struct7_values_ref = get_hash_copy($entry);
        $struct7_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 2;
        $struct7_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1; # variable
        $struct7_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  int int_field;\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $struct7_values_ref->{'BEFORE_MAIN'};
        $struct7_values_ref->{'BUF_DECL'} = "  my_struct s;\n\n";
        $struct7_values_ref->{'PRE_ACCESS'} = "  s.int_field = INDEX;\n" . 
                                                $struct7_values_ref->{'PRE_ACCESS'};
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $struct7_values_ref->{'ACCESS'} = "COMMENT\n  s.buf[s.int_field] = WRITE_VALUE;\n";
        push @$results_ref, $struct7_values_ref;

        # union = 3
        # variation 1: buffer first
        my $union1_values_ref = get_hash_copy($entry);
        $union1_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 3;
        $union1_values_ref->{'BEFORE_MAIN'} = "typedef union\n{\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "  int intval;\n" .
                                       "} my_union;\n\n" .
                                       $union1_values_ref->{'BEFORE_MAIN'};
        $union1_values_ref->{'BUF_DECL'} = "  my_union u;\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $union1_values_ref->{'ACCESS'} = "COMMENT\n  u.buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $union1_values_ref;

        # union = 3
        # variation 2: buffer second
        my $union2_values_ref = get_hash_copy($entry);
        $union2_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 3;
        $union2_values_ref->{'BEFORE_MAIN'} = "typedef union\n{\n" .
                                       "  int intval;\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "} my_union;\n\n" .
                                       $union2_values_ref->{'BEFORE_MAIN'};
        $union2_values_ref->{'BUF_DECL'} = "  my_union u;\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        $union2_values_ref->{'ACCESS'} = "COMMENT\n  u.buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $union2_values_ref;

        # array of structs = 4
        # variation 1: the buffer is the only thing in the struct
        my $structarray1_values_ref = get_hash_copy($entry);
        $structarray1_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 4;
        $structarray1_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $structarray1_values_ref->{'BEFORE_MAIN'};
        $structarray1_values_ref->{'BUF_DECL'} = "  my_struct array_buf[$ARRAY_SIZE];\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        # COMBO NOTE: if it's an underflow, the array_index would be different.
        # Needs to be updated for underflow combos to work.
        my $array_index2 = $ARRAY_SIZE - 1;
        $structarray1_values_ref->{'ACCESS'} = "COMMENT\n  array_buf[$array_index2].buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $structarray1_values_ref;

        # array of structs = 4
        # variation 2: 2 buffers, 1st overflows
        my $structarray2_values_ref = get_hash_copy($entry);
        $structarray2_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 4;
        $structarray2_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf1[$BUF_SIZE];\n" .
                                       "  TYPE buf2[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $structarray2_values_ref->{'BEFORE_MAIN'};
        $structarray2_values_ref->{'BUF_DECL'} = "  my_struct array_buf[$ARRAY_SIZE];\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        # COMBO NOTE: if it's an underflow, the array_index would be different.
        # Needs to be updated for underflow combos to work.
        my $array_index3 = $ARRAY_SIZE - 1;
        $structarray2_values_ref->{'ACCESS'} = "COMMENT\n  array_buf[$array_index3].buf1[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $structarray2_values_ref;

        # array of structs = 4
        # variation 3: 2 buffers, 2nd overflows
        my $structarray3_values_ref = get_hash_copy($entry);
        $structarray3_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 4;
        $structarray3_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf1[$BUF_SIZE];\n" .
                                       "  TYPE buf2[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $structarray3_values_ref->{'BEFORE_MAIN'};
        $structarray3_values_ref->{'BUF_DECL'} = "  my_struct array_buf[$ARRAY_SIZE];\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        # COMBO NOTE: if it's an underflow, the array_index would be different.
        # Needs to be updated for underflow combos to work.
        my $array_index4 = $ARRAY_SIZE - 1;
        $structarray3_values_ref->{'ACCESS'} = "COMMENT\n  array_buf[$array_index4].buf2[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $structarray3_values_ref;

        # array of structs = 4
        # variation 4: buffer then integer
        my $structarray4_values_ref = get_hash_copy($entry);
        $structarray4_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 4;
        $structarray4_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "  int int_field;\n" .
                                       "} my_struct;\n\n" .
                                       $structarray4_values_ref->{'BEFORE_MAIN'};
        $structarray4_values_ref->{'BUF_DECL'} = "  my_struct array_buf[$ARRAY_SIZE];\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        # COMBO NOTE: if it's an underflow, the array_index would be different.
        # Needs to be updated for underflow combos to work.
        my $array_index5 = $ARRAY_SIZE - 1;
        $structarray4_values_ref->{'ACCESS'} = "COMMENT\n  array_buf[$array_index5].buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $structarray4_values_ref;

        # array of structs = 4
        # variation 5: integer then buffer
        my $structarray5_values_ref = get_hash_copy($entry);
        $structarray5_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 4;
        $structarray5_values_ref->{'BEFORE_MAIN'} = "typedef struct\n{\n" .
                                       "  int int_field;\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "} my_struct;\n\n" .
                                       $structarray5_values_ref->{'BEFORE_MAIN'};
        $structarray5_values_ref->{'BUF_DECL'} = "  my_struct array_buf[$ARRAY_SIZE];\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        # COMBO NOTE: if it's an underflow, the array_index would be different.
        # Needs to be updated for underflow combos to work.
        my $array_index6 = $ARRAY_SIZE - 1;
        $structarray5_values_ref->{'ACCESS'} = "COMMENT\n  array_buf[$array_index6].buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $structarray5_values_ref;

        # array of unions = 5
        # variation 1: buffer first
        my $unionarray1_values_ref = get_hash_copy($entry);
        $unionarray1_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 5;
        $unionarray1_values_ref->{'BEFORE_MAIN'} = "typedef union\n{\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "  int intval;\n" .
                                       "} my_union;\n\n" .
                                       $unionarray1_values_ref->{'BEFORE_MAIN'};
        $unionarray1_values_ref->{'BUF_DECL'} = "  my_union array_buf[$ARRAY_SIZE];\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        # COMBO NOTE: if it's an underflow, the array_index would be different.
        # Needs to be updated for underflow combos to work.
        my $array_index7 = $ARRAY_SIZE - 1;
        $unionarray1_values_ref->{'ACCESS'} = "COMMENT\n  array_buf[$array_index7].buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $unionarray1_values_ref;

        # array of unions = 5
        # variation 2: buffer second
        my $unionarray2_values_ref = get_hash_copy($entry);
        $unionarray2_values_ref->{'TAX'}->[$CONTAINER_DIGIT] = 5;
        $unionarray2_values_ref->{'BEFORE_MAIN'} = "typedef union\n{\n" .
                                       "  int intval;\n" .
                                       "  TYPE buf[$BUF_SIZE];\n" .
                                       "} my_union;\n\n" .
                                       $unionarray2_values_ref->{'BEFORE_MAIN'};
        $unionarray2_values_ref->{'BUF_DECL'} = "  my_union array_buf[$ARRAY_SIZE];\n\n";
        # COMBO NOTE: if it's a read or a pointer, the access would be different.
        # Needs to be updated for read and pointer combos to work.
        # COMBO NOTE: if it's an underflow, the array_index would be different.
        # Needs to be updated for underflow combos to work.
        my $array_index8 = $ARRAY_SIZE - 1;
        $unionarray2_values_ref->{'ACCESS'} = "COMMENT\n  array_buf[$array_index8].buf[INDEX] = WRITE_VALUE;\n";
        push @$results_ref, $unionarray2_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_continuousdiscrete : produces all the test case variants for the
##  "continuous/discrete" attribute.
##--------------------------------------------------------------
sub do_continuousdiscrete
{   
    # NOTE: these are all continuous versions of what's produced by do_loopstructure
    #       and do_loopcomplex
    my $results_ref = [];
    
    # first, the variations on do_loopstructure
    my $loopstruct_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$loopstruct_array) 
    {
        $variant_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1;
        $variant_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1;   # variable
        $variant_ref->{'ACCESS'} =~ s/INDEX/loop_counter/;
        push @$results_ref, $variant_ref;
    }

    # next, the variations on do_loopcomplex
    my $loopcomplex_array = do_loopcomplex($_[0]);
    foreach my $variant_ref (@$loopcomplex_array) 
    {
        $variant_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1;
        $variant_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1;   # variable
        $variant_ref->{'ACCESS'} =~ s/INDEX/loop_counter/;
        push @$results_ref, $variant_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_datatype : produces all the test case variants for the "data type"
##  attribute.
##--------------------------------------------------------------
sub do_datatype
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # integer = 1
        my $int_values_ref = get_hash_copy($entry);
        $int_values_ref->{'TAX'}->[$DATATYPE_DIGIT] = 1;
        $int_values_ref->{'SINGLES'}->{'TYPE'} = "int";
        $int_values_ref->{'SINGLES'}->{'WRITE_VALUE'} = "55";
        push @$results_ref, $int_values_ref;

        # float = 2
        my $float_values_ref = get_hash_copy($entry);
        $float_values_ref->{'TAX'}->[$DATATYPE_DIGIT] = 2;
        $float_values_ref->{'SINGLES'}->{'TYPE'} = "float";
        $float_values_ref->{'SINGLES'}->{'WRITE_VALUE'} = "55.55";
        push @$results_ref, $float_values_ref;

        # wchar = 3
        my $wchar_values_ref = get_hash_copy($entry);
        $wchar_values_ref->{'TAX'}->[$DATATYPE_DIGIT] = 3;
        $wchar_values_ref->{'SINGLES'}->{'TYPE'} = "wchar_t";
        $wchar_values_ref->{'SINGLES'}->{'WRITE_VALUE'} = "L\'A\'";
        $wchar_values_ref->{'INCL'} = "#include <wchar.h>\n" . $wchar_values_ref->{'INCL'};
        push @$results_ref, $wchar_values_ref;

        # pointer = 4
        my $ptr_values_ref = get_hash_copy($entry);
        $ptr_values_ref->{'TAX'}->[$DATATYPE_DIGIT] = 4;
        $ptr_values_ref->{'SINGLES'}->{'TYPE'} = "char *";
        $ptr_values_ref->{'SINGLES'}->{'WRITE_VALUE'} = "\"A\"";
        push @$results_ref, $ptr_values_ref;

        # unsigned integer = 5
        my $uint_values_ref = get_hash_copy($entry);
        $uint_values_ref->{'TAX'}->[$DATATYPE_DIGIT] = 5;
        $uint_values_ref->{'SINGLES'}->{'TYPE'} = "unsigned int";
        $uint_values_ref->{'SINGLES'}->{'WRITE_VALUE'} = "55";
        push @$results_ref, $uint_values_ref;

        # unsigned char = 6
        my $uchar_values_ref = get_hash_copy($entry);
        $uchar_values_ref->{'TAX'}->[$DATATYPE_DIGIT] = 6;
        $uchar_values_ref->{'SINGLES'}->{'TYPE'} = "unsigned char";
        push @$results_ref, $uchar_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_indexcomplex : produces all the test case variants for the 
##  "index complexity" attribute.
##--------------------------------------------------------------
sub do_indexcomplex
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # variable = 1
        my $var_values_ref = get_hash_copy($entry);
        $var_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1;
        $var_values_ref->{'OTHER_DECL'} = "  int i;\n" . $var_values_ref->{'OTHER_DECL'};
        $var_values_ref->{'PRE_ACCESS'} =  "  i = INDEX;\n" . 
                                            $var_values_ref->{'PRE_ACCESS'};
        $var_values_ref->{'ACCESS'} = "COMMENT\n  buf[i] = WRITE_VALUE;\n";
        push @$results_ref, $var_values_ref;

        # linear expression = 2
        my $linexp_values_ref = get_hash_copy($entry);
        $linexp_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 2;
        $linexp_values_ref->{'OTHER_DECL'} = "  int i;\n" . $linexp_values_ref->{'OTHER_DECL'};
        # need to calculate the values that will get substituted to fit
        #   the linear expr: 4 * FACTOR2 + REMAIN = previous value for INDEX
        my $factor1 = 4;
        foreach my $index_value (keys %{$linexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $linexp_values_ref->{'MULTIS'}->{'FACTOR2'}->{$index_value} = 
                int $linexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} / $factor1;
            $linexp_values_ref->{'MULTIS'}->{'REMAIN'}->{$index_value} = 
                $linexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} - 
                    ($linexp_values_ref->{'MULTIS'}->{'FACTOR2'}->{$index_value} * $factor1);
        }
        $linexp_values_ref->{'PRE_ACCESS'} =  "  i = FACTOR2;\n" . 
                                            $linexp_values_ref->{'PRE_ACCESS'};
        $linexp_values_ref->{'ACCESS'} = "COMMENT\n  buf[($factor1 * i) + REMAIN] = WRITE_VALUE;\n";
        push @$results_ref, $linexp_values_ref;

        # non-linear expression = 3
        my $nonlinexp_values_ref = get_hash_copy($entry);
        $nonlinexp_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 3;
        $nonlinexp_values_ref->{'OTHER_DECL'} = "  int i;\n" . $nonlinexp_values_ref->{'OTHER_DECL'};
        foreach my $index_value (keys %{$nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $nonlinexp_values_ref->{'MULTIS'}->{'MOD'}->{$index_value} = 
                $nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} + 1;
        }
        $nonlinexp_values_ref->{'PRE_ACCESS'} =  "  i = MOD;\n" . 
                                            $nonlinexp_values_ref->{'PRE_ACCESS'};
        $nonlinexp_values_ref->{'ACCESS'} = "COMMENT\n  buf[INDEX % i] = WRITE_VALUE;\n";
        push @$results_ref, $nonlinexp_values_ref;

         # function return value = 4
        my $funcret_values_ref = get_hash_copy($entry);
        $funcret_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 4;
        $funcret_values_ref->{'BEFORE_MAIN'} = "int function1\(int arg1)\n{\n" .
                                               "  return arg1;\n}\n\n" .
                                               $funcret_values_ref->{'BEFORE_MAIN'};
        $funcret_values_ref->{'ACCESS'} = "COMMENT\n  buf[function1(INDEX)] = WRITE_VALUE;\n";
        push @$results_ref, $funcret_values_ref;

        #  array contents = 5
        my $arraycontent_values_ref = get_hash_copy($entry);
        $arraycontent_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 5;
        $arraycontent_values_ref->{'OTHER_DECL'} = "  int index_array[$ARRAY_SIZE];\n" . 
                                    $arraycontent_values_ref->{'OTHER_DECL'};
        $arraycontent_values_ref->{'PRE_ACCESS'} =  "  index_array[0] = INDEX;\n" . 
                                            $arraycontent_values_ref->{'PRE_ACCESS'};
        $arraycontent_values_ref->{'ACCESS'} = "COMMENT\n  buf[index_array[0]] = WRITE_VALUE;\n";
        push @$results_ref, $arraycontent_values_ref;

        # not applicable = 6 
        # this is covered by the pointer case - don't need another one here
    }

   return $results_ref;
}

##--------------------------------------------------------------
## do_lencomplex : produces all the test case variants for the 
##  "length/limit complexity" attribute.
##--------------------------------------------------------------
sub do_lencomplex
{   # COMBO NOTE: these would be affected by data type.  Needs to be updated
    # for data type combos to work.
    # FUTURE: add an option for generating a whole set of string functions.
    # Note that we set the index complexity to N/A when passing the buffer
    #  address to a library function.  We don't know what the library
    #  function does, but our own code is not using an index.
    # However, we do set the continuous attribute if the library function
    #  would be copying a string past the end of a buffer.
    # Also note that we set scope to inter-file/inter-procedural, and alias
    #  addr to one alias.
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # COMBO NOTE: what function would we use for other data types?
        # none = 1
    	# variation 1: copy directly from a string
        my $none1_values_ref = get_hash_copy($entry);
        $none1_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 1;
        $none1_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $none1_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $none1_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $none1_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $none1_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $none1_values_ref->{'INCL'} = "#include <string.h>\n" . $none1_values_ref->{'INCL'};
        my $source_str;
        foreach my $index_value (keys %{$none1_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $source_str = "\"" . ('A' x $none1_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value}) . "\"";
            $none1_values_ref->{'MULTIS'}->{'SOURCE'}->{$index_value} = $source_str;
        }
        $none1_values_ref->{'ACCESS'} = "COMMENT\n  strcpy(buf, SOURCE);\n";
        push @$results_ref, $none1_values_ref;

        # none = 1
    	# variation 2: copy from another buffer
        my $none2_values_ref = get_hash_copy($entry);
        $none2_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 1;
        $none2_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $none2_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $none2_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $none2_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $none2_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $none2_values_ref->{'INCL'} = "#include <string.h>\n" . $none2_values_ref->{'INCL'};
        foreach my $index_value (keys %{$none2_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $none2_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $none2_values_ref->{'OTHER_DECL'} = "  char src[INDEX];\n" . 
                                            $none2_values_ref->{'OTHER_DECL'};
	$none2_values_ref->{'PRE_ACCESS'} = "  memset(src, 'A', INDEX);\n" . 
                                            "  src[INDEX - 1] = '\\0';\n" .
                                            $none2_values_ref->{'PRE_ACCESS'};
        $none2_values_ref->{'ACCESS'} = "COMMENT\n  strcpy(buf, src);\n";
        push @$results_ref, $none2_values_ref;

        # constant = 2
        my $const_values_ref = get_hash_copy($entry);
        $const_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 2;
        $const_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $const_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $const_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $const_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $const_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $const_values_ref->{'INCL'} = "#include <string.h>\n" . $const_values_ref->{'INCL'};
        foreach my $index_value (keys %{$const_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $const_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $const_values_ref->{'OTHER_DECL'} = "  char src[INDEX];\n" . 
                                            $const_values_ref->{'OTHER_DECL'};
	$const_values_ref->{'PRE_ACCESS'} = "  memset(src, 'A', INDEX);\n" . 
                                            "  src[INDEX - 1] = '\\0';\n" .
                                            $const_values_ref->{'PRE_ACCESS'};
        $const_values_ref->{'ACCESS'} = "COMMENT\n  strncpy(buf, src, INDEX);\n";
        push @$results_ref, $const_values_ref;

        # variable = 3
        my $var_values_ref = get_hash_copy($entry);
        $var_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 3;
        $var_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $var_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $var_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $var_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $var_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $var_values_ref->{'INCL'} = "#include <string.h>\n" . $var_values_ref->{'INCL'};
        foreach my $index_value (keys %{$var_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $var_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $var_values_ref->{'OTHER_DECL'} = "  size_t len;\n  char src[INDEX];\n" . 
                                            $var_values_ref->{'OTHER_DECL'};
        $var_values_ref->{'PRE_ACCESS'} = "  memset(src, 'A', INDEX);\n" . 
                                          "  src[INDEX - 1] = '\\0';\n" .
                                          "  len = INDEX;\n" . 
                                          $var_values_ref->{'PRE_ACCESS'};
        $var_values_ref->{'ACCESS'} = "COMMENT\n  strncpy(buf, src, len);\n";
        push @$results_ref, $var_values_ref;

        # linear expression = 4
        my $linexp_values_ref = get_hash_copy($entry);
        $linexp_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 4;
        $linexp_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $linexp_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $linexp_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $linexp_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $linexp_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $linexp_values_ref->{'INCL'} = "#include <string.h>\n" . $linexp_values_ref->{'INCL'};
        foreach my $index_value (keys %{$linexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $linexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $linexp_values_ref->{'OTHER_DECL'} = "  int i;\n  char src[INDEX];\n" . 
                                            $linexp_values_ref->{'OTHER_DECL'};
        # need to calculate the values that will get substituted to fit
        #   the linear expr: 4 * FACTOR2 + REMAIN = previous value for INDEX
        my $factor1 = 4;
        foreach my $index_value (keys %{$linexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $linexp_values_ref->{'MULTIS'}->{'FACTOR2'}->{$index_value} = 
                int $linexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} / $factor1;
            $linexp_values_ref->{'MULTIS'}->{'REMAIN'}->{$index_value} = 
                $linexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} - 
                    ($linexp_values_ref->{'MULTIS'}->{'FACTOR2'}->{$index_value} * $factor1);
        }
        $linexp_values_ref->{'PRE_ACCESS'} =  "  memset(src, 'A', INDEX);\n" . 
                                              "  src[INDEX - 1] = '\\0';\n" . 
                                              "  i = FACTOR2;\n" . 
                                              $linexp_values_ref->{'PRE_ACCESS'};
        $linexp_values_ref->{'ACCESS'} = "COMMENT\n  strncpy(buf, src, ($factor1 * i) + REMAIN);\n";
        push @$results_ref, $linexp_values_ref;

        # non-linear expression = 5
        my $nonlinexp_values_ref = get_hash_copy($entry);
        $nonlinexp_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 5;
        $nonlinexp_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $nonlinexp_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $nonlinexp_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $nonlinexp_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $nonlinexp_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $nonlinexp_values_ref->{'INCL'} = "#include <string.h>\n" . $nonlinexp_values_ref->{'INCL'};
        foreach my $index_value (keys %{$nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $nonlinexp_values_ref->{'OTHER_DECL'} = "  int i;\n  char src[INDEX];\n" . 
                                            $nonlinexp_values_ref->{'OTHER_DECL'};
        foreach my $index_value (keys %{$nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $nonlinexp_values_ref->{'MULTIS'}->{'MOD'}->{$index_value} = 
                int $nonlinexp_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} + 1;
        }
        $nonlinexp_values_ref->{'PRE_ACCESS'} =  "  memset(src, 'A', INDEX);\n" . 
                                              "  src[INDEX - 1] = '\\0';\n" . 
                                              "  i = MOD;\n" . 
                                            $nonlinexp_values_ref->{'PRE_ACCESS'};
        $nonlinexp_values_ref->{'ACCESS'} = "COMMENT\n  strncpy(buf, src, INDEX % i);\n";
        push @$results_ref, $nonlinexp_values_ref;

        # function return value = 6
        my $funcret_values_ref = get_hash_copy($entry);
        $funcret_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 6;
        $funcret_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $funcret_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $funcret_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $funcret_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $funcret_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $funcret_values_ref->{'INCL'} = "#include <string.h>\n" . $funcret_values_ref->{'INCL'};
        foreach my $index_value (keys %{$funcret_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $funcret_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $funcret_values_ref->{'OTHER_DECL'} = "  char src[INDEX];\n" . 
                                            $funcret_values_ref->{'OTHER_DECL'};
        $funcret_values_ref->{'BEFORE_MAIN'} = "int function1\(int arg1)\n{\n" .
                                               "  return arg1;\n}\n\n" .
                                               $funcret_values_ref->{'BEFORE_MAIN'};
        $funcret_values_ref->{'PRE_ACCESS'} =  "  memset(src, 'A', INDEX);\n" . 
                                              "  src[INDEX - 1] = '\\0';\n" . 
                                            $funcret_values_ref->{'PRE_ACCESS'};
        $funcret_values_ref->{'ACCESS'} = "COMMENT\n  strncpy(buf, src, function1(INDEX));\n";
        push @$results_ref, $funcret_values_ref;

        #  array contents = 7
        my $arraycontent_values_ref = get_hash_copy($entry);
        $arraycontent_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 7;
        $arraycontent_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $arraycontent_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $arraycontent_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $arraycontent_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $arraycontent_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $arraycontent_values_ref->{'INCL'} = "#include <string.h>\n" . $arraycontent_values_ref->{'INCL'};
        foreach my $index_value (keys %{$arraycontent_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $arraycontent_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $arraycontent_values_ref->{'OTHER_DECL'} = "  int index_array[$ARRAY_SIZE];\n  char src[INDEX];\n" . 
                                            $arraycontent_values_ref->{'OTHER_DECL'};
        $arraycontent_values_ref->{'PRE_ACCESS'} =  "  memset(src, 'A', INDEX);\n" . 
                                              "  src[INDEX - 1] = '\\0';\n" . 
                                              "  index_array[0] = INDEX;\n" . 
                                            $arraycontent_values_ref->{'PRE_ACCESS'};
        $arraycontent_values_ref->{'ACCESS'} = "COMMENT\n  strncpy(buf, src, index_array[0]);\n";
        push @$results_ref, $arraycontent_values_ref;
    }

   return $results_ref;
}

##--------------------------------------------------------------
## do_localflow : produces all the test case variants for the
##  "local control flow" attribute.
##--------------------------------------------------------------
sub do_localflow
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # if = 1
        my $if_values_ref = get_hash_copy($entry);
        $if_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 1;
        $if_values_ref->{'OTHER_DECL'} = "  int flag;\n" . $if_values_ref->{'OTHER_DECL'};
        $if_values_ref->{'PRE_ACCESS'} = "  flag = 1;\n" . 
                                         $if_values_ref->{'PRE_ACCESS'} .
                                         "  if (flag)\n  {\n";
        $if_values_ref->{'ACCESS'} = indent(2, $if_values_ref->{'ACCESS'});
        $if_values_ref->{'POST_ACCESS'} = "  }\n" . $if_values_ref->{'POST_ACCESS'};
        push @$results_ref, $if_values_ref;

        # switch = 2
        my $switch_values_ref = get_hash_copy($entry);
        $switch_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 2;
        $switch_values_ref->{'OTHER_DECL'} = "  int flag;\n" . $switch_values_ref->{'OTHER_DECL'};
        $switch_values_ref->{'PRE_ACCESS'} = "  flag = 1;\n" . 
                                         $switch_values_ref->{'PRE_ACCESS'} .
                                         "  switch (flag)\n  {\n    case 1:\n";
        $switch_values_ref->{'ACCESS'} = indent(4, $switch_values_ref->{'ACCESS'});
        $switch_values_ref->{'POST_ACCESS'} = "      break;\n    default:\n      break;\n  }\n" . 
                                                $switch_values_ref->{'POST_ACCESS'};
        push @$results_ref, $switch_values_ref;

        # cond = 3
        my $cond_values_ref = get_hash_copy($entry);
        $cond_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 3;
        $cond_values_ref->{'OTHER_DECL'} = "  int flag;\n" . $cond_values_ref->{'OTHER_DECL'};
        $cond_values_ref->{'PRE_ACCESS'} = "  flag = 1;\n" . 
                                         $cond_values_ref->{'PRE_ACCESS'};
        # strip off the leading comment and the trailing ;\n
        $cond_values_ref->{'ACCESS'} =~ s/COMMENT\n//;
        substr($cond_values_ref->{'ACCESS'}, -2) =~ s/;\n//;
        $cond_values_ref->{'ACCESS'} = "COMMENT\n" .
                                       "  flag ? $cond_values_ref->{'ACCESS'} : 0;\n";
        push @$results_ref, $cond_values_ref;

        # goto = 4
        my $goto_values_ref = get_hash_copy($entry);
        $goto_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 4;
        $goto_values_ref->{'PRE_ACCESS'} = "  goto label1;\n  return 0;\n" . 
                                         $goto_values_ref->{'PRE_ACCESS'} .
                                         "label1:\n";
        push @$results_ref, $goto_values_ref;

        # longjmp = 5;
        my $lj_values_ref = get_hash_copy($entry);
        $lj_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 5;
        $lj_values_ref->{'INCL'} = "#include <setjmp.h>\n" . $lj_values_ref->{'INCL'};
        $lj_values_ref->{'OTHER_DECL'} = "  jmp_buf env;\n" . 
                                         $lj_values_ref->{'OTHER_DECL'};
        $lj_values_ref->{'PRE_ACCESS'} = "  if (setjmp(env) != 0)\n  {\n    return 0;\n  }\n" . 
                                         $lj_values_ref->{'PRE_ACCESS'};
        $lj_values_ref->{'POST_ACCESS'} = $lj_values_ref->{'POST_ACCESS'} .
                                            "  longjmp(env, 1);\n";
        push @$results_ref, $lj_values_ref;

        # function pointer = 6
        my $funcptr_values_ref = get_hash_copy($entry);
        $funcptr_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 6;
        $funcptr_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 1;   #inter-procedural
        $funcptr_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1;   #1 alias of addr
        $funcptr_values_ref->{'BEFORE_MAIN'} = "void function1\(TYPE * buf\)\n{\n" .
                                               $funcptr_values_ref->{'ACCESS'} .
                                               "}\n\n" .
                                                $funcptr_values_ref->{'BEFORE_MAIN'};
        $funcptr_values_ref->{'OTHER_DECL'} = "  void (*fptr)(TYPE *);\n" . 
                                                $funcptr_values_ref->{'OTHER_DECL'};
        $funcptr_values_ref->{'PRE_ACCESS'} = "  fptr = function1;\n" . 
                                                $funcptr_values_ref->{'PRE_ACCESS'};
        $funcptr_values_ref->{'ACCESS'} = "  fptr\(buf\);\n";
        push @$results_ref, $funcptr_values_ref;

        # recursion = 7
        my $recur_values_ref = get_hash_copy($entry);
        $recur_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 7;
        $recur_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 1;   #inter-procedural
        $recur_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1;   #1 alias of addr
        $recur_values_ref->{'BEFORE_MAIN'} = "void function1\(TYPE * buf, int counter\)\n{\n" .
                                             "  if \(counter > 0\)\n  {\n" .
                                             "    function1\(buf, counter - 1\);\n  }\n" . 
                                               $recur_values_ref->{'ACCESS'} .
                                               "}\n\n" .
                                                $recur_values_ref->{'BEFORE_MAIN'};
        $recur_values_ref->{'ACCESS'} = "  function1\(buf, 3\);\n";
        push @$results_ref, $recur_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_loopcomplex : produces all the test case variants for the
##  "loop complexity" attribute.
##--------------------------------------------------------------
sub do_loopcomplex
{   
    my $results_ref = [];

    # NOTE: these are all variations on what's produced by do_loopstructure

    # 0 is baseline - no loop
    # 1 is standard complexity, which is already produced by loopstructure

    #  2 one - one of the three is more complex than the baseline
    #  first we'll change the initialization
    my $complex1_init_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$complex1_init_array) 
    {
        $variant_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 2;
        $variant_ref->{'OTHER_DECL'} = "  int init_value;\n" . 
                                        $variant_ref->{'OTHER_DECL'};
        $variant_ref->{'PRE_ACCESS'} = "  init_value = 0;\n" . 
                                        $variant_ref->{'PRE_ACCESS'};
        $variant_ref->{'SINGLES'}->{'LOOP_INIT'} =~ s/=\s*?0/= init_value/;
        push @$results_ref, $variant_ref;
    }

    #  2 one - one of the three is more complex than the baseline
    #  next we'll change the test
    my $complex1_test_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$complex1_test_array) 
    {
        $variant_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 2;
        $variant_ref->{'OTHER_DECL'} = "  int test_value;\n" . 
                                        $variant_ref->{'OTHER_DECL'};
        $variant_ref->{'PRE_ACCESS'} = "  test_value = INDEX;\n" . 
                                        $variant_ref->{'PRE_ACCESS'};
        $variant_ref->{'SINGLES'}->{'LOOP_TEST'} =~ s/INDEX/test_value/;
        push @$results_ref, $variant_ref;
    }

    #  2 one - one of the three is more complex than the baseline
    #  last we'll change the inc
    my $complex1_inc_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$complex1_inc_array) 
    {
        $variant_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 2;
        $variant_ref->{'OTHER_DECL'} = "  int inc_value;\n" . 
                                        $variant_ref->{'OTHER_DECL'};
        $variant_ref->{'PRE_ACCESS'} = "  inc_value = INDEX - (INDEX - 1);\n" . 
                                        $variant_ref->{'PRE_ACCESS'};
        $variant_ref->{'SINGLES'}->{'LOOP_INC'} = "loop_counter += inc_value";
        push @$results_ref, $variant_ref;
    }

    #  3 two - two of the three are more complex than the baseline
    #  first we'll change the initialization and test
    my $complex2_inittest_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$complex2_inittest_array) 
    {
        $variant_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 3;
        $variant_ref->{'OTHER_DECL'} = "  int init_value;\n  int test_value;\n" . 
                                       $variant_ref->{'OTHER_DECL'};
        $variant_ref->{'PRE_ACCESS'} = "  init_value = 0;\n  test_value = INDEX;\n" . 
                                        $variant_ref->{'PRE_ACCESS'};
        $variant_ref->{'SINGLES'}->{'LOOP_INIT'} =~ s/=\s*?0/= init_value/;
        $variant_ref->{'SINGLES'}->{'LOOP_TEST'} =~ s/INDEX/test_value/;
        push @$results_ref, $variant_ref;
    }

    #  3 two - two of the three are more complex than the baseline
    #  next we'll change the initialization and increment
    my $complex2_initinc_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$complex2_initinc_array) 
    {
        $variant_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 3;
        $variant_ref->{'OTHER_DECL'} = "  int init_value;\n  int inc_value;\n" . 
                                       $variant_ref->{'OTHER_DECL'};
        $variant_ref->{'PRE_ACCESS'} = "  init_value = 0;\n" . 
                                       "  inc_value = INDEX - (INDEX - 1);\n" . 
                                        $variant_ref->{'PRE_ACCESS'};
        $variant_ref->{'SINGLES'}->{'LOOP_INIT'} =~ s/=\s*?0/= init_value/;
        $variant_ref->{'SINGLES'}->{'LOOP_INC'} = "loop_counter += inc_value";
        push @$results_ref, $variant_ref;
    }

    #  3 two - two of the three are more complex than the baseline
    #  last we'll change the test and increment
    my $complex2_testinc_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$complex2_testinc_array) 
    {
        $variant_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 3;
        $variant_ref->{'OTHER_DECL'} = "  int test_value;\n  int inc_value;\n" . 
                                       $variant_ref->{'OTHER_DECL'};
        $variant_ref->{'PRE_ACCESS'} = "  test_value = INDEX;\n" . 
                                       "  inc_value = INDEX - (INDEX - 1);\n" . 
                                        $variant_ref->{'PRE_ACCESS'};
        $variant_ref->{'SINGLES'}->{'LOOP_TEST'} =~ s/INDEX/test_value/;
        $variant_ref->{'SINGLES'}->{'LOOP_INC'} = "loop_counter += inc_value";
        push @$results_ref, $variant_ref;
    }

    #  4 three - all three are more complex than the baseline
    #  change the init, test, and increment
    my $complex3_inittestinc_array = do_loopstructure($_[0]);
    foreach my $variant_ref (@$complex3_inittestinc_array) 
    {
        $variant_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 4;
        $variant_ref->{'OTHER_DECL'} = "  int init_value;\n  int test_value;\n" .
                                       "  int inc_value;\n" . 
                                       $variant_ref->{'OTHER_DECL'};
        $variant_ref->{'PRE_ACCESS'} = "  init_value = 0;\n" . 
                                       "  test_value = INDEX;\n" . 
                                       "  inc_value = INDEX - (INDEX - 1);\n" . 
                                        $variant_ref->{'PRE_ACCESS'};
        $variant_ref->{'SINGLES'}->{'LOOP_INIT'} =~ s/=\s*?0/= init_value/;
        $variant_ref->{'SINGLES'}->{'LOOP_TEST'} =~ s/INDEX/test_value/;
        $variant_ref->{'SINGLES'}->{'LOOP_INC'} = "loop_counter += inc_value";
        push @$results_ref, $variant_ref;
    }
    
    return $results_ref;
}

##--------------------------------------------------------------
## do_loopstructure : produces all the test case variants for the
##  "loop structure" attribute.
##--------------------------------------------------------------
sub do_loopstructure
{   
    my $standard_loop_init = "loop_counter = 0";
    my $standard_loop_test = "loop_counter <= INDEX";
    my $standard_loop_postinc = "loop_counter++";
    my $standard_loop_preinc = "++loop_counter";

    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # standard for = 1
        my $for_values_ref = get_hash_copy($entry);
        $for_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 1;
        $for_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $for_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $for_values_ref->{'SINGLES'}->{'LOOP_TEST'} = $standard_loop_test;
        $for_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $for_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $for_values_ref->{'OTHER_DECL'};
        $for_values_ref->{'PRE_ACCESS'} = $for_values_ref->{'PRE_ACCESS'} .
                                         "  for(LOOP_INIT; LOOP_TEST; LOOP_INC)\n  {\n";
        $for_values_ref->{'ACCESS'} = indent(2, $for_values_ref->{'ACCESS'});
        $for_values_ref->{'POST_ACCESS'} = "  }\n" . $for_values_ref->{'POST_ACCESS'};
        push @$results_ref, $for_values_ref;

        # standard do-while = 2
        my $dowhile_values_ref = get_hash_copy($entry);
        $dowhile_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 2;
        $dowhile_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $dowhile_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $dowhile_values_ref->{'SINGLES'}->{'LOOP_TEST'} = $standard_loop_test;
        $dowhile_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $dowhile_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $dowhile_values_ref->{'OTHER_DECL'};
        $dowhile_values_ref->{'PRE_ACCESS'} = $dowhile_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  do\n  {\n";
        $dowhile_values_ref->{'ACCESS'} = indent(2, $dowhile_values_ref->{'ACCESS'});
        $dowhile_values_ref->{'POST_ACCESS'} = "    LOOP_INC;\n  }\n  while(LOOP_TEST);\n" . 
                                                $dowhile_values_ref->{'POST_ACCESS'};
        push @$results_ref, $dowhile_values_ref;

        # standard while = 3
        my $while_values_ref = get_hash_copy($entry);
        $while_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 3;
        $while_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $while_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $while_values_ref->{'SINGLES'}->{'LOOP_TEST'} = $standard_loop_test;
        $while_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $while_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $while_values_ref->{'OTHER_DECL'};
        $while_values_ref->{'PRE_ACCESS'} = $while_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  while(LOOP_TEST)\n  {\n";
        $while_values_ref->{'ACCESS'} = indent(2, $while_values_ref->{'ACCESS'});
        $while_values_ref->{'POST_ACCESS'} = "    LOOP_INC;\n  }\n" . $while_values_ref->{'POST_ACCESS'};
        push @$results_ref, $while_values_ref;

        # non-standard for = 4
        # first variation: move the init clause
        my $nsfor1_values_ref = get_hash_copy($entry);
        $nsfor1_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 4;
        $nsfor1_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nsfor1_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nsfor1_values_ref->{'SINGLES'}->{'LOOP_TEST'} = $standard_loop_test;
        $nsfor1_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $nsfor1_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nsfor1_values_ref->{'OTHER_DECL'};
        $nsfor1_values_ref->{'PRE_ACCESS'} = $nsfor1_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n" .
                                         "  for( ; LOOP_TEST; LOOP_INC)\n  {\n";
        $nsfor1_values_ref->{'ACCESS'} = indent(2, $nsfor1_values_ref->{'ACCESS'});
        $nsfor1_values_ref->{'POST_ACCESS'} = "  }\n" . $nsfor1_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nsfor1_values_ref;

        # non-standard for = 4
        # second variation: move the test clause
        # Note that the explicit "if" counts as secondary flow control
        my $nsfor2_values_ref = get_hash_copy($entry);
        $nsfor2_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 4;
        $nsfor2_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nsfor2_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;  # if
        $nsfor2_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nsfor2_values_ref->{'SINGLES'}->{'LOOP_TEST'} = "loop_counter > INDEX";
        $nsfor2_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $nsfor2_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nsfor2_values_ref->{'OTHER_DECL'};
        $nsfor2_values_ref->{'PRE_ACCESS'} = $nsfor2_values_ref->{'PRE_ACCESS'} .
                                         "  for(LOOP_INIT; ; LOOP_INC)\n  {\n" .
                                         "    if (LOOP_TEST) break;\n";
        $nsfor2_values_ref->{'ACCESS'} = indent(2, $nsfor2_values_ref->{'ACCESS'});
        $nsfor2_values_ref->{'POST_ACCESS'} = "  }\n" . $nsfor2_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nsfor2_values_ref;

        # non-standard for = 4
        # third variation: move the increment clause
        my $nsfor3_values_ref = get_hash_copy($entry);
        $nsfor3_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 4;
        $nsfor3_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nsfor3_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nsfor3_values_ref->{'SINGLES'}->{'LOOP_TEST'} = $standard_loop_test;
        $nsfor3_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $nsfor3_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nsfor3_values_ref->{'OTHER_DECL'};
        $nsfor3_values_ref->{'PRE_ACCESS'} = $nsfor3_values_ref->{'PRE_ACCESS'} .
                                         "  for(LOOP_INIT; LOOP_TEST; )\n  {\n";
        $nsfor3_values_ref->{'ACCESS'} = indent(2, $nsfor3_values_ref->{'ACCESS'});
        $nsfor3_values_ref->{'POST_ACCESS'} = "    LOOP_INC;\n  }\n" . $nsfor3_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nsfor3_values_ref;

        # non-standard for = 4
        # fourth variation: move all three clauses
        # Note that the explicit "if" counts as secondary flow control
        my $nsfor4_values_ref = get_hash_copy($entry);
        $nsfor4_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 4;
        $nsfor4_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nsfor4_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;    # if
        $nsfor4_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nsfor4_values_ref->{'SINGLES'}->{'LOOP_TEST'} = "loop_counter > INDEX";
        $nsfor4_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $nsfor4_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nsfor4_values_ref->{'OTHER_DECL'};
        $nsfor4_values_ref->{'PRE_ACCESS'} = $nsfor4_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n" .
                                         "  for( ; ; )\n  {\n" .
                                         "    if (LOOP_TEST) break;\n";
        $nsfor4_values_ref->{'ACCESS'} = indent(2, $nsfor4_values_ref->{'ACCESS'});
        $nsfor4_values_ref->{'POST_ACCESS'} = "    LOOP_INC;\n  }\n" . $nsfor4_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nsfor4_values_ref;

        # non-standard do-while = 5
        # first variation: move the increment (combine with test)
        my $nsdowhile1_values_ref = get_hash_copy($entry);
        $nsdowhile1_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 5;
        $nsdowhile1_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nsdowhile1_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nsdowhile1_values_ref->{'SINGLES'}->{'LOOP_TEST'} = $standard_loop_test;
        $nsdowhile1_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_preinc;
        $nsdowhile1_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nsdowhile1_values_ref->{'OTHER_DECL'};
        $nsdowhile1_values_ref->{'PRE_ACCESS'} = $nsdowhile1_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  do\n  {\n";
        $nsdowhile1_values_ref->{'ACCESS'} = indent(2, $nsdowhile1_values_ref->{'ACCESS'});
        $nsdowhile1_values_ref->{'POST_ACCESS'} = "  }\n  while((LOOP_INC) && (LOOP_TEST));\n" . 
                                                $nsdowhile1_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nsdowhile1_values_ref;

        # non-standard do-while = 5
        # second variation: move the test
        # Note that the explicit "if" counts as secondary flow control
        my $nsdowhile2_values_ref = get_hash_copy($entry);
        $nsdowhile2_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 5;
        $nsdowhile2_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nsdowhile2_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;    # if
        $nsdowhile2_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nsdowhile2_values_ref->{'SINGLES'}->{'LOOP_TEST'} = "loop_counter > INDEX";
        $nsdowhile2_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $nsdowhile2_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nsdowhile2_values_ref->{'OTHER_DECL'};
        $nsdowhile2_values_ref->{'PRE_ACCESS'} = $nsdowhile2_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  do\n  {\n";
        $nsdowhile2_values_ref->{'ACCESS'} = indent(2, $nsdowhile2_values_ref->{'ACCESS'});
        $nsdowhile2_values_ref->{'POST_ACCESS'} = "    LOOP_INC;\n" . 
                                                  "    if (LOOP_TEST) break;\n" .
                                                  "  }\n  while(1);\n" . 
                                                $nsdowhile2_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nsdowhile2_values_ref;

        # non-standard do-while = 5
        # third variation: move both test and increment
        # Note that the explicit "if" counts as secondary flow control
        my $nsdowhile3_values_ref = get_hash_copy($entry);
        $nsdowhile3_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 5;
        $nsdowhile3_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nsdowhile3_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;    # if
        $nsdowhile3_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nsdowhile3_values_ref->{'SINGLES'}->{'LOOP_TEST'} = "loop_counter >= INDEX";
        $nsdowhile3_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_preinc;
        $nsdowhile3_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nsdowhile3_values_ref->{'OTHER_DECL'};
        $nsdowhile3_values_ref->{'PRE_ACCESS'} = $nsdowhile3_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  do\n  {\n";
        $nsdowhile3_values_ref->{'ACCESS'} = indent(2, $nsdowhile3_values_ref->{'ACCESS'});
        $nsdowhile3_values_ref->{'POST_ACCESS'} = "    if (LOOP_TEST) break;\n" .
                                                  "  }\n  while(LOOP_INC);\n" . 
                                                $nsdowhile3_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nsdowhile3_values_ref;

        # non-standard while = 6
        # first variation: move test
        # Note that the explicit "if" counts as secondary flow control
        my $nswhile1_values_ref = get_hash_copy($entry);
        $nswhile1_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 6;
        $nswhile1_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nswhile1_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;    # if
        $nswhile1_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nswhile1_values_ref->{'SINGLES'}->{'LOOP_TEST'} = "loop_counter > INDEX";
        $nswhile1_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_postinc;
        $nswhile1_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nswhile1_values_ref->{'OTHER_DECL'};
        $nswhile1_values_ref->{'PRE_ACCESS'} = $nswhile1_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  while(1)\n  {\n";
        $nswhile1_values_ref->{'ACCESS'} = indent(2, $nswhile1_values_ref->{'ACCESS'});
        $nswhile1_values_ref->{'POST_ACCESS'} = "    LOOP_INC;\n" . 
                                                "    if (LOOP_TEST) break;\n  }\n" . 
                                                $nswhile1_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nswhile1_values_ref;

        # non-standard while = 6
        # second variation: move increment
        my $nswhile2_values_ref = get_hash_copy($entry);
        $nswhile2_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 6;
        $nswhile2_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nswhile2_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nswhile2_values_ref->{'SINGLES'}->{'LOOP_TEST'} = $standard_loop_test;
        $nswhile2_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_preinc;
        $nswhile2_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nswhile2_values_ref->{'OTHER_DECL'};
        $nswhile2_values_ref->{'PRE_ACCESS'} = $nswhile2_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  while((LOOP_INC) && (LOOP_TEST))\n  {\n";
        $nswhile2_values_ref->{'ACCESS'} = indent(2, $nswhile2_values_ref->{'ACCESS'});
        $nswhile2_values_ref->{'POST_ACCESS'} = "  }\n" . 
                                                $nswhile2_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nswhile2_values_ref;

        # non-standard while = 6
        # third variation: move both test and increment
        # Note that the explicit "if" counts as secondary flow control
        my $nswhile3_values_ref = get_hash_copy($entry);
        $nswhile3_values_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] = 6;
        $nswhile3_values_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] = 1; #standard
        $nswhile3_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;    # if
        $nswhile3_values_ref->{'SINGLES'}->{'LOOP_INIT'} = $standard_loop_init;
        $nswhile3_values_ref->{'SINGLES'}->{'LOOP_TEST'} = "loop_counter >= INDEX";
        $nswhile3_values_ref->{'SINGLES'}->{'LOOP_INC'} = $standard_loop_preinc;
        $nswhile3_values_ref->{'OTHER_DECL'} = "  int loop_counter;\n" . $nswhile3_values_ref->{'OTHER_DECL'};
        $nswhile3_values_ref->{'PRE_ACCESS'} = $nswhile3_values_ref->{'PRE_ACCESS'} .
                                         "  LOOP_INIT;\n  while(LOOP_INC)\n  {\n";
        $nswhile3_values_ref->{'ACCESS'} = indent(2, $nswhile3_values_ref->{'ACCESS'});
        $nswhile3_values_ref->{'POST_ACCESS'} = "    if (LOOP_TEST) break;\n  }\n" . 
                                                $nswhile3_values_ref->{'POST_ACCESS'};
        push @$results_ref, $nswhile3_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_magnitude : produces all the test case variants for the
##  "magnitude" attribute.
##--------------------------------------------------------------
sub do_magnitude
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    # we don't need to produce anything here, because we automatically vary
    # the magnitude across all the other test cases we produce

    return $results_ref;
}

##--------------------------------------------------------------
## do_memloc : produces all the test case variants for the "memory
##  location" attribute.
##--------------------------------------------------------------
sub do_memloc
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # heap = 1
        my $heap_values_ref = get_hash_copy($entry);
        $heap_values_ref->{'TAX'}->[$MEMLOC_DIGIT] = 1;
        $heap_values_ref->{'INCL'} = "#include <stdlib.h>\n#include <assert.h>\n" . 
            $heap_values_ref->{'INCL'};
        $heap_values_ref->{'BUF_DECL'} = "  TYPE * buf;\n\n";
        $heap_values_ref->{'PRE_ACCESS'} = 
            "  buf = \(TYPE *\) malloc\($BUF_SIZE\ * sizeof\(TYPE\)\);\n" .
            "  assert \(buf != NULL\);\n" .
            $heap_values_ref->{'PRE_ACCESS'};
        push @$results_ref, $heap_values_ref;

        # data region = 2
        my $data_values_ref = get_hash_copy($entry);
        $data_values_ref->{'TAX'}->[$MEMLOC_DIGIT] = 2;
        # COMBO NOTE: need to make this init value more generic and dependent on TYPE.
        # Needs to be updated in order for data type combos to work.
        $data_values_ref->{'BUF_DECL'} = "  static " . $data_values_ref->{'BUF_DECL'};
        $data_values_ref->{'BUF_DECL'} =~ s/\;/ = \"\"\;/;
        push @$results_ref, $data_values_ref;

        # bss = 3
        my $bss_values_ref = get_hash_copy($entry);
        $bss_values_ref->{'TAX'}->[$MEMLOC_DIGIT] = 3;
        $bss_values_ref->{'BUF_DECL'} = "  static " . $bss_values_ref->{'BUF_DECL'};
        push @$results_ref, $bss_values_ref;

        # shared = 4
        my $shared_values_ref = get_hash_copy($entry);
        $shared_values_ref->{'TAX'}->[$MEMLOC_DIGIT] = 4;
        $shared_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 1; # inter-procedural
        $shared_values_ref->{'INCL'} = "#include <sys/types.h>\n#include <sys/ipc.h>\n" .
                                       "#include <sys/shm.h>\n#include <assert.h>\n" .
                                       "#include <stdlib.h>\n" . $shared_values_ref->{'INCL'};
        $shared_values_ref->{'BEFORE_MAIN'} = "int getSharedMem()\n{\n" .
                                              "  return (shmget(IPC_PRIVATE, $BUF_SIZE, 0xffffffff));\n}\n\n" .
                                              "void relSharedMem(int memID)\n{\n  struct shmid_ds temp;\n" .
                                              "  shmctl(memID, IPC_RMID, &temp);\n}\n\n" .
                                              $shared_values_ref->{'BEFORE_MAIN'};
        $shared_values_ref->{'OTHER_DECL'} = "  int memIdent;\n" . $shared_values_ref->{'OTHER_DECL'};
        $shared_values_ref->{'BUF_DECL'} = "  TYPE * buf;\n\n";
        $shared_values_ref->{'PRE_ACCESS'} = "  memIdent = getSharedMem();\n  assert(memIdent != -1);\n" .
                                             "  buf = ((TYPE *) shmat(memIdent, NULL, 0));\n  assert(((int)buf) != -1);\n" .
                                             $shared_values_ref->{'PRE_ACCESS'};
        $shared_values_ref->{'POST_ACCESS'} = $shared_values_ref->{'POST_ACCESS'} .
                                              "  shmdt((void *)buf);\n  relSharedMem(memIdent);\n";
                                              ;
        push @$results_ref, $shared_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_pointer : produces all the test case variants for the "pointer"
##  attribute.
##--------------------------------------------------------------
sub do_pointer
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # yes = 1
        my $pointer_values_ref = get_hash_copy($entry);
        $pointer_values_ref->{'TAX'}->[$POINTER_DIGIT] = 1;
        $pointer_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $pointer_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $pointer_values_ref->{'ACCESS'} = "COMMENT\n  *(buf + INDEX) = WRITE_VALUE;\n";
        push @$results_ref, $pointer_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_runtimeenvdep : produces all the test case variants for the
##  "runtime environment dependent" attribute.
##--------------------------------------------------------------
sub do_runtimeenvdep
{
    my $start_with_array_ref = shift;
    my $results_ref = [];

    # we don't need to produce anything here, because cover both possibilities
    # in the other test cases we produce

    return $results_ref;
}

##--------------------------------------------------------------
## do_scope : produces all the test case variants for the "scope"
##  attribute.
##--------------------------------------------------------------
sub do_scope
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # inter-procedural = 1
        my $interproc_values_ref = get_hash_copy($entry);
        $interproc_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 1;
        $interproc_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1;   # 1 function arg alias
        $interproc_values_ref->{'BEFORE_MAIN'} = "void function1\(TYPE * buf\)\n{\n" .
                                               $interproc_values_ref->{'ACCESS'} .
                                               "}\n\n" .
                                                $interproc_values_ref->{'BEFORE_MAIN'};
        $interproc_values_ref->{'ACCESS'} = "  function1\(buf\);\n";
        push @$results_ref, $interproc_values_ref;

        # global = 2 
        # generate 2 variations here, because the global declaration has to be 
        #   either bss (uninitialized) or data segment (initialized)
        my $global1_values_ref = get_hash_copy($entry);
        $global1_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 2;
        $global1_values_ref->{'TAX'}->[$MEMLOC_DIGIT] = 3; # bss
        $global1_values_ref->{'FILE_GLOBAL'} = "static " . $global1_values_ref->{'BUF_DECL'};
        $global1_values_ref->{'BUF_DECL'} = "";
        push @$results_ref, $global1_values_ref;

        my $global2_values_ref = get_hash_copy($entry);
        $global2_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 2;
        $global2_values_ref->{'TAX'}->[$MEMLOC_DIGIT] = 2; # data segment
        $global2_values_ref->{'FILE_GLOBAL'} = "static " . $global2_values_ref->{'BUF_DECL'};
        $global2_values_ref->{'FILE_GLOBAL'} =~ s/\;/ = \"\"\;/;
        $global2_values_ref->{'BUF_DECL'} = "";
        push @$results_ref, $global2_values_ref;

        # Note: there are some examples of inter-file/inter-proc in test cases
        #  that call library functions.
        # FUTURE: add some examples of these two variations where the
        #  overwriting function is user-defined, not a library function.
        # inter-file/inter-proc = 3
        # inter-file/global = 4
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_secondaryflow : produces all the test case variants for the
##  "secondary control flow" attribute.
##--------------------------------------------------------------
sub do_secondaryflow
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # if = 1
        my $if_values_ref = get_hash_copy($entry);
        $if_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;
        $if_values_ref->{'PRE_ACCESS'} = "  if (sizeof buf > INDEX + 1)\n  {\n    " . 
                                         "return 0;\n  }\n" .
                                         $if_values_ref->{'PRE_ACCESS'};
        push @$results_ref, $if_values_ref;

        # switch = 2
        my $switch_values_ref = get_hash_copy($entry);
        $switch_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 2;
        $switch_values_ref->{'PRE_ACCESS'} = "  switch (sizeof buf > INDEX + 1)\n  {\n    case 1:\n" . 
                                         "      return 0;\n    default:\n      break;\n  }\n" .
                                             $switch_values_ref->{'PRE_ACCESS'};
        push @$results_ref, $switch_values_ref;

        # cond = 3
        my $cond_values_ref = get_hash_copy($entry);
        $cond_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 3;
        $cond_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1; # variable
        $cond_values_ref->{'OTHER_DECL'} = "  int i;\n" . $cond_values_ref->{'OTHER_DECL'};
        $cond_values_ref->{'PRE_ACCESS'} = "  i = (sizeof buf > INDEX + 1) ? 0 : INDEX;\n" . 
                                         $cond_values_ref->{'PRE_ACCESS'};
        $cond_values_ref->{'ACCESS'} =~ s/INDEX/i/;
        push @$results_ref, $cond_values_ref;

        # goto = 4
        my $goto_values_ref = get_hash_copy($entry);
        $goto_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 4;
        $goto_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 1;  # local if
        $goto_values_ref->{'OTHER_DECL'} = "  int flag;\n" . $goto_values_ref->{'OTHER_DECL'};
        $goto_values_ref->{'PRE_ACCESS'} = "  goto label1;\n  return 0;\n" . 
                                         $goto_values_ref->{'PRE_ACCESS'} .
                                         "label1:\n  flag = 1;\n" . 
                                         "  if (flag)\n  {\n";
        $goto_values_ref->{'ACCESS'} = indent(2, $goto_values_ref->{'ACCESS'});
        $goto_values_ref->{'POST_ACCESS'} = "  }\n" . $goto_values_ref->{'POST_ACCESS'};
        push @$results_ref, $goto_values_ref;

        # longjmp = 5;
        my $lj_values_ref = get_hash_copy($entry);
        $lj_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 5;
        $lj_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 1;  # local if
        $lj_values_ref->{'INCL'} = "#include <setjmp.h>\n" . $lj_values_ref->{'INCL'};
        $lj_values_ref->{'OTHER_DECL'} = "  jmp_buf env;\n  int flag;\n" . 
                                         $lj_values_ref->{'OTHER_DECL'};
        $lj_values_ref->{'PRE_ACCESS'} = "  if (setjmp(env) != 0)\n  {\n    return 0;\n  }\n" . 
                                         $lj_values_ref->{'PRE_ACCESS'} .
                                         "  flag = 1;\n  if (flag)\n  {\n";
        $lj_values_ref->{'ACCESS'} = indent(2, $lj_values_ref->{'ACCESS'});
        $lj_values_ref->{'POST_ACCESS'} = "  }\n" . $lj_values_ref->{'POST_ACCESS'} .
                                            "  longjmp(env, 1);\n";
        push @$results_ref, $lj_values_ref;

        # function pointer = 6
        my $funcptr_values_ref = get_hash_copy($entry);
        $funcptr_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 6;
        $funcptr_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1;    # variable
        $funcptr_values_ref->{'BEFORE_MAIN'} = "int function1\(\)\n{\n" .
                                               "  return INDEX;\n}\n\n" .
                                                $funcptr_values_ref->{'BEFORE_MAIN'};
        $funcptr_values_ref->{'OTHER_DECL'} = "  int i;\n  int (*fptr)();\n" . 
                                                $funcptr_values_ref->{'OTHER_DECL'};
        $funcptr_values_ref->{'PRE_ACCESS'} = "  fptr = function1;\n  i = fptr\(\);\n" . 
                                                $funcptr_values_ref->{'PRE_ACCESS'};
        $funcptr_values_ref->{'ACCESS'} = "COMMENT\n  buf[i] = WRITE_VALUE;\n";
        push @$results_ref, $funcptr_values_ref;


        # recursion = 7
        my $recur_values_ref = get_hash_copy($entry);
        $recur_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 7;
        $recur_values_ref->{'BEFORE_MAIN'} = "int function1\(int counter\)\n{\n" .
                                             "  if \(counter > 0\)\n  {\n" .
                                             "    return function1\(counter - 1\);\n  }\n" . 
                                             "  else\n  {\n    return INDEX;\n  }\n}\n\n" .
                                                $recur_values_ref->{'BEFORE_MAIN'};
        $recur_values_ref->{'OTHER_DECL'} = "  int i;\n  int (*fptr)(int);\n" . 
                                                $recur_values_ref->{'OTHER_DECL'};
        $recur_values_ref->{'PRE_ACCESS'} = "  fptr = function1;\n  i = fptr\(3\);\n" . 
                                                $recur_values_ref->{'PRE_ACCESS'};
        $recur_values_ref->{'ACCESS'} = "COMMENT\n  buf[i] = WRITE_VALUE;\n";
        push @$results_ref, $recur_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_signedness : produces all the test case variants for the
##  "signedness" attribute.
##--------------------------------------------------------------
sub do_signedness
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # yes = 1
        # variation 1: directly use a negative constant for an unsigned length
        my $sign1_values_ref = get_hash_copy($entry);
        $sign1_values_ref->{'TAX'}->[$SIGNEDNESS_DIGIT] = 1;
        $sign1_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 2;  # constant
        $sign1_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $sign1_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $sign1_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $sign1_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $sign1_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $sign1_values_ref->{'INCL'} = "#include <string.h>\n" . $sign1_values_ref->{'INCL'};
        foreach my $index_value (keys %{$sign1_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $sign1_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $sign1_values_ref->{'MULTIS'}->{'SIGNED_LEN'} = {$OK_OVERFLOW => $BUF_SIZE, 
                                 $MIN_OVERFLOW => "-1",
                                 $MED_OVERFLOW => "-1", 
				 $LARGE_OVERFLOW => "-1"};
        $sign1_values_ref->{'OTHER_DECL'} = "  char src[INDEX];\n" . 
                                            $sign1_values_ref->{'OTHER_DECL'};
	$sign1_values_ref->{'PRE_ACCESS'} = "  memset(src, 'A', INDEX);\n" . 
                                            "  src[INDEX - 1] = '\\0';\n" .
                                            $sign1_values_ref->{'PRE_ACCESS'};
        $sign1_values_ref->{'ACCESS'} = "COMMENT\n  memcpy(buf, src, SIGNED_LEN);\n\n";
        push @$results_ref, $sign1_values_ref;

        # yes = 1
        # variation 2: use a negative variable
        my $sign2_values_ref = get_hash_copy($entry);
        $sign2_values_ref->{'TAX'}->[$SIGNEDNESS_DIGIT] = 1;
        $sign2_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 3;  # variable
        $sign2_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $sign2_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $sign2_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $sign2_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $sign2_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $sign2_values_ref->{'INCL'} = "#include <string.h>\n" . $sign2_values_ref->{'INCL'};
        foreach my $index_value (keys %{$sign2_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $sign2_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $sign2_values_ref->{'MULTIS'}->{'SIGNED_LEN'} = {$OK_OVERFLOW => $BUF_SIZE, 
                                 $MIN_OVERFLOW => "-1",
                                 $MED_OVERFLOW => "-1", 
				 $LARGE_OVERFLOW => "-1"};
        $sign2_values_ref->{'OTHER_DECL'} = "  int size;\n  char src[INDEX];\n" . 
                                            $sign2_values_ref->{'OTHER_DECL'};
        $sign2_values_ref->{'PRE_ACCESS'} = "  memset(src, 'A', INDEX);\n" . 
                                            "  src[INDEX - 1] = '\\0';\n" .
                                           "  size = SIGNED_LEN;\n" . 
                                           $sign2_values_ref->{'PRE_ACCESS'};
        $sign2_values_ref->{'ACCESS'} = "COMMENT\n  memcpy(buf, src, size);\n\n";
        push @$results_ref, $sign2_values_ref;

        # yes = 1
        # variation 3: use a negative variable, plus test 
        my $sign3_values_ref = get_hash_copy($entry);
        $sign3_values_ref->{'TAX'}->[$SIGNEDNESS_DIGIT] = 1;
        $sign3_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 3;  # variable
        $sign3_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $sign3_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $sign3_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $sign3_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $sign3_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 1;   # if
        $sign3_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $sign3_values_ref->{'INCL'} = "#include <string.h>\n" . $sign3_values_ref->{'INCL'};
        foreach my $index_value (keys %{$sign3_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $sign3_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $sign3_values_ref->{'MULTIS'}->{'SIGNED_LEN'} = {$OK_OVERFLOW => $BUF_SIZE, 
                                 $MIN_OVERFLOW => "-1",
                                 $MED_OVERFLOW => "-1", 
				 $LARGE_OVERFLOW => "-1"};
        $sign3_values_ref->{'OTHER_DECL'} = "  int copy_size;\n  int buf_size;\n" .
                                            "  char src[INDEX];\n" . 
                                            $sign3_values_ref->{'OTHER_DECL'};
        $sign3_values_ref->{'PRE_ACCESS'} = $sign3_values_ref->{'PRE_ACCESS'} . 
                                            "  memset(src, 'A', INDEX);\n" . 
                                            "  src[INDEX - 1] = '\\0';\n" .
                                            "  copy_size = SIGNED_LEN;\n" .  
                                            "  buf_size = sizeof buf;\n" . 
                                            "  if (copy_size <= buf_size)\n  {\n"; 
        $sign3_values_ref->{'ACCESS'} = indent(2, "COMMENT\n  memcpy(buf, src, copy_size);\n\n");
        $sign3_values_ref->{'POST_ACCESS'} = "  }\n" . $sign3_values_ref->{'POST_ACCESS'};
        push @$results_ref, $sign3_values_ref;

        # yes = 1
        # variation 4: use a negative variable, plus test with a cast 
        my $sign4_values_ref = get_hash_copy($entry);
        $sign4_values_ref->{'TAX'}->[$SIGNEDNESS_DIGIT] = 1;
        $sign4_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 3;  # variable
        $sign4_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $sign4_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $sign4_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; # inter-file/inter-proc
        $sign4_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $sign4_values_ref->{'TAX'}->[$LOCALFLOW_DIGIT] = 1;   # if
        $sign4_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $sign4_values_ref->{'INCL'} = "#include <string.h>\n" . $sign4_values_ref->{'INCL'};
        foreach my $index_value (keys %{$sign4_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $sign4_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        $sign4_values_ref->{'MULTIS'}->{'SIGNED_LEN'} = {$OK_OVERFLOW => $BUF_SIZE, 
                                 $MIN_OVERFLOW => "-1",
                                 $MED_OVERFLOW => "-1", 
				 $LARGE_OVERFLOW => "-1"};
        $sign4_values_ref->{'OTHER_DECL'} = "  int copy_size;\n  char src[INDEX];\n" . 
                                            $sign4_values_ref->{'OTHER_DECL'};
        $sign4_values_ref->{'PRE_ACCESS'} = $sign4_values_ref->{'PRE_ACCESS'} . 
                                            "  memset(src, 'A', INDEX);\n" . 
                                            "  src[INDEX - 1] = '\\0';\n" .
                                            "  copy_size = SIGNED_LEN;\n" . 
                                            "  if (copy_size <= (int)(sizeof buf))\n  {\n"; 
        $sign4_values_ref->{'ACCESS'} = indent(2, "COMMENT\n  memcpy(buf, src, copy_size);\n\n");
        $sign4_values_ref->{'POST_ACCESS'} = "  }\n" . $sign4_values_ref->{'POST_ACCESS'};
        push @$results_ref, $sign4_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_taint : produces all the test case variants for the 
##  "taint" attribute.
##--------------------------------------------------------------
sub do_taint
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # argc/argv = 1
        my $argcargv_values_ref = get_hash_copy($entry);
        $argcargv_values_ref->{'TAX'}->[$TAINT_DIGIT] = 1;
        # depends on command line argument
        $argcargv_values_ref->{'TAX'}->[$RUNTIMEENVDEP_DIGIT] = 1;
        # if statement before overflow
        $argcargv_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;
        # index complexity = return value of a function
        $argcargv_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 4;
        $argcargv_values_ref->{'INCL'} = "#include <stdlib.h>\n" . $argcargv_values_ref->{'INCL'};
       
        # setup the argv index to depend on the size of the overflow
        $argcargv_values_ref->{'MULTIS'}->{'WHICH_ARGV'} = 
                                     {$OK_OVERFLOW => 1,
                                      $MIN_OVERFLOW => 2,
                                      $MED_OVERFLOW => 3,
                                      $LARGE_OVERFLOW => 4};
        $argcargv_values_ref->{'PRE_ACCESS'} = "  if ((argc < 5) || (atoi(argv[WHICH_ARGV]) > INDEX))\n" .
                                               "  {\n    return 0;\n  }\n" .
                                        $argcargv_values_ref->{'PRE_ACCESS'};
        $argcargv_values_ref->{'ACCESS'} =~ s/INDEX/atoi(argv\[WHICH_ARGV\])/;
        push @$results_ref, $argcargv_values_ref;

        # env var = 2
        my $envvar_values_ref = get_hash_copy($entry);
        $envvar_values_ref->{'TAX'}->[$TAINT_DIGIT] = 2;
        # depends on length of PATH
        $envvar_values_ref->{'TAX'}->[$RUNTIMEENVDEP_DIGIT] = 1;
        # if statement before overflow
        $envvar_values_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] = 1;
        # index complexity = variable
        $envvar_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 1;
        $envvar_values_ref->{'INCL'} = "#include <string.h>\n#include <stdlib.h>\n" . 
                                        $envvar_values_ref->{'INCL'};
        $envvar_values_ref->{'OTHER_DECL'} = "  int i;\n  char * envvar;\n" .
                                        $envvar_values_ref->{'OTHER_DECL'};
        $envvar_values_ref->{'MULTIS'}->{'ENVVAR'} = {$OK_OVERFLOW => "STRINGLEN_OK", 
                                 $MIN_OVERFLOW => "STRINGLEN_MIN",
                                 $MED_OVERFLOW => "STRINGLEN_MED", 
				 $LARGE_OVERFLOW => "STRINGLEN_LARGE"};
        $envvar_values_ref->{'PRE_ACCESS'} = "  envvar = getenv(\"ENVVAR\");\n" .
                                             "  if (envvar != NULL)\n  {\n" .
                                             "    i = strlen(envvar);\n  }\n" .
                                             "  else\n  {\n    i = 0;\n  }\n\n" .
                                             "  if (i > INDEX)\n" .
                                             "  {\n    return 0;\n  }\n" .
                                             $envvar_values_ref->{'PRE_ACCESS'};
        $envvar_values_ref->{'ACCESS'} =~ s/INDEX/i/;
        push @$results_ref, $envvar_values_ref;

        # reading from file or stdin = 3
        my $fileread_values_ref = get_hash_copy($entry);
        $fileread_values_ref->{'TAX'}->[$TAINT_DIGIT] = 3;
        # depends on contents of file
        $fileread_values_ref->{'TAX'}->[$RUNTIMEENVDEP_DIGIT] = 1;
        # length/limit complexity = constant
        $fileread_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 2;
        # library functions are inter-file/inter-proc, 1 alias of addr, no index
        $fileread_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; #inter-file/inter-proc
        $fileread_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $fileread_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $fileread_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $fileread_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $fileread_values_ref->{'INCL'} = "#include <assert.h>\n#include <stdio.h>\n" . 
                                        $fileread_values_ref->{'INCL'};
        $fileread_values_ref->{'OTHER_DECL'} = "  FILE * f;\n" .
                                        $fileread_values_ref->{'OTHER_DECL'};
        $fileread_values_ref->{'PRE_ACCESS'} = "  f = fopen(\"TestInputFile1\", \"r\");\n" .
                                             "  assert(f != NULL);\n" .
                                        $fileread_values_ref->{'PRE_ACCESS'};
        $fileread_values_ref->{'ACCESS'} = "COMMENT\n  fgets(buf, INDEX, f);\n\n";
        $fileread_values_ref->{'POST_ACCESS'} = "  fclose(f);\n" .
                                        $fileread_values_ref->{'POST_ACCESS'};
        foreach my $index_value (keys %{$fileread_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $fileread_values_ref->{'MULTIS'}->{'INDEX'}->{$index_value} += 1;
        }
        # we need to generate the input file as well
        $fileread_values_ref->{'EXTRA_FILES'}->{'TestInputFile1'} = 'A' x 5000;
        push @$results_ref, $fileread_values_ref;

        # FUTURE: fill in a sockets example here
        # reading from a socket = 4

        # process environment = 5
        my $processenv_values_ref = get_hash_copy($entry);
        $processenv_values_ref->{'TAX'}->[$TAINT_DIGIT] = 5;
        # depends on current working directory
        $processenv_values_ref->{'TAX'}->[$RUNTIMEENVDEP_DIGIT] = 1;
        # length/limit complexity = constant
        $processenv_values_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] = 2;
        # library functions are inter-file/inter-proc, and 1 alias of addr
        $processenv_values_ref->{'TAX'}->[$SCOPE_DIGIT] = 3; #inter-file/inter-proc
        $processenv_values_ref->{'TAX'}->[$ALIASADDR_DIGIT] = 1; #1 alias of addr
        $processenv_values_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] = 6; # N/A - no index 
        $processenv_values_ref->{'TAX'}->[$ALIASINDEX_DIGIT] = 3; # N/A - no index 
        $processenv_values_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] = 1; #continuous
        $processenv_values_ref->{'INCL'} = "#include <unistd.h>\n" . 
                                        $processenv_values_ref->{'INCL'};
        # TODO: verify getcwd length/limit operation
        $processenv_values_ref->{'ACCESS'} = "COMMENT\n  getcwd(buf, INDEX);\n\n";
        foreach my $index1_value (keys %{$processenv_values_ref->{'MULTIS'}->{'INDEX'}}) 
        {
            $processenv_values_ref->{'MULTIS'}->{'INDEX'}->{$index1_value} += 1;
        }
        push @$results_ref, $processenv_values_ref;
    }
    
    return $results_ref;
}

##--------------------------------------------------------------
## do_whichbound : produces all the test case variants for the "which bound"
##  attribute.
##--------------------------------------------------------------
# COMBO NOTE:  lower bound will also affect the first index of a 2D array.
# Needs to be updated for underflow combos to work.
sub do_whichbound
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # lower = 1
        my $lower_values_ref = get_hash_copy($entry);
        $lower_values_ref->{'TAX'}->[$WHICHBOUND_DIGIT] = 1;
        $lower_values_ref->{'MULTIS'}->{'INDEX'} = 
                                     {$OK_OVERFLOW => 0,
                                      $MIN_OVERFLOW => 0 - $MIN_SIZE,
                                      $MED_OVERFLOW => 0 - $MED_SIZE,
                                      $LARGE_OVERFLOW => 0 - $LARGE_SIZE};
        push @$results_ref, $lower_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## do_writeread : produces all the test case variants for the "write/read"
##  attribute.
##--------------------------------------------------------------
sub do_writeread
{   
    my $start_with_array_ref = shift;
    my $results_ref = [];

    foreach my $entry (@{$start_with_array_ref}) 
    {
        # write = 0
        push @$results_ref, get_hash_copy($entry);

        # read = 1
        my $read_values_ref = get_hash_copy($entry);
        $read_values_ref->{'TAX'}->[$WRITEREAD_DIGIT] = 1;
        $read_values_ref->{'OTHER_DECL'} = "  TYPE read_value;\n" . $read_values_ref->{'OTHER_DECL'};
        $read_values_ref->{'ACCESS'} = "COMMENT\n  read_value = buf[INDEX];\n";
        push @$results_ref, $read_values_ref;
    }

    return $results_ref;
}

##--------------------------------------------------------------
## expand_tax_class : Write out expanded taxonomy classification 
##  to the given open file using values in the given array ref.
##--------------------------------------------------------------
sub expand_tax_class
{
    my ($fh, $tax_values) = @_;

    print $fh "/*\n";

    for (my $i=0; $i < scalar @$tax_values; ++$i)
    {
        printf $fh " *  %-25s\t", $TaxonomyInfo[$i]->[NAME_INDEX];
        printf $fh "%2u\t", $tax_values->[$i];
        print $fh "$TaxonomyInfo[$i]->[VALUES_INDEX]->{$tax_values->[$i]}\n";
    }

    print $fh " */\n\n";
}

##--------------------------------------------------------------
## get_array_copy : given a reference to an array, returns a reference to a new
##   copy of the array itself (deep copy of all entries)
##--------------------------------------------------------------
sub get_array_copy
{   
    my $orig_array_ref = shift;
    my @new_array;

    foreach my $entry (@$orig_array_ref) 
    {
        if (ref($entry) eq "HASH") 
        {
            push @new_array, get_hash_copy($entry);
        }
        elsif (ref($entry) eq "ARRAY") 
        {
            push @new_array, get_array_copy($entry);
        }
        else
        {
            push @new_array, $entry;
        }
    }
    return \@new_array;
}

##--------------------------------------------------------------
## get_default_values : returns a reference to a hash of default values
##  for various pieces of test case code
##--------------------------------------------------------------
sub get_default_values
{   
    return {'INCL' => "\n", 'BUF_DECL' => $BUF_DECL, 'OTHER_DECL' => "",
        'ACCESS' => $BUF_ACCESS, 
        'SINGLES' => {'TYPE' => "char", 'WRITE_VALUE' => "\'A\'"},
        'MULTIS' => { 'INDEX' => {$OK_OVERFLOW => $BUF_SIZE + $OK_SIZE - 1, 
                                 $MIN_OVERFLOW => $BUF_SIZE + $MIN_SIZE - 1,
                                 $MED_OVERFLOW => $BUF_SIZE + $MED_SIZE - 1, 
                                 $LARGE_OVERFLOW => $BUF_SIZE + $LARGE_SIZE - 1}
                   },
        'TAX' => get_init_tax_class_values(),
        'PRE_ACCESS' => "\n",
        'POST_ACCESS' => "\n",
        'FILE_GLOBAL' => "",
        'BEFORE_MAIN' => "",
        'EXTRA_FILES' => {}};
}

##--------------------------------------------------------------
## get_fseq_num : Figures out and returns the next unused
##   file sequence number. Returns 0 if they're all used up.
##--------------------------------------------------------------
sub get_fseq_num
{
    my $num = 1;
    my $fname;
    my $found_it = 0;

    # loop until we've exhausted all seq nums or we found an unused one
    while ($num <= 99999 && !$found_it) 
    {   # get a file name for this seq num
        $fname = get_ok_filename($num);
        if (-e $fname) 
        {   # if it exists already, increment to next seq num
            $num++;
        } 
        else
        {   # otherwise, set the found flag
            $found_it = 1;
        }
    }

    # return the next unused seq num if we found one, else return 0
    if ($found_it) 
    {
        return $num;
    }
    else
    {
        return 0;
    }
};

##--------------------------------------------------------------
## get_filenames : given a file sequence number, generates a 
##  set of file names
##--------------------------------------------------------------
sub get_filenames
{   # get the seq num that was passed in
    my $num = shift;

    my $fname_ok = get_ok_filename($num);
    my $fname_min = get_min_filename($num);
    my $fname_med = get_med_filename($num);
    my $fname_large = get_large_filename($num);

    return ($fname_ok, $fname_min, $fname_med, $fname_large);
};

##--------------------------------------------------------------
## get_hash_copy : given a reference to a hash, returns a reference to a new
##   copy of the hash itself (deep copy of all entries)
##--------------------------------------------------------------
sub get_hash_copy
{   
    my $orig_hash_ref = shift;
    my %new_hash;

    foreach my $key (sort keys %{$orig_hash_ref}) 
    {
        if (ref($orig_hash_ref->{$key}) eq "HASH") 
        {
            $new_hash{$key} = get_hash_copy($orig_hash_ref->{$key});
        }
        elsif (ref($orig_hash_ref->{$key}) eq "ARRAY") 
        {
            $new_hash{$key} = get_array_copy($orig_hash_ref->{$key});
        }
        else
        {
            $new_hash{$key} = $orig_hash_ref->{$key};
        }
    }
    return \%new_hash;
}

##--------------------------------------------------------------
## get_init_tax_class_values : returns a reference to an array of 
##  initialized taxonomy classification values
##--------------------------------------------------------------
sub get_init_tax_class_values
{   
    return [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
};

##--------------------------------------------------------------
## get_ok_filename : given a file sequence number, generates a file name
##  for an ok (no overflow) file
##--------------------------------------------------------------
sub get_ok_filename
{   # get the seq num that was passed in
    my $num = shift;

    return sprintf("basic-%05u-ok.c", $num);
};

##--------------------------------------------------------------
## get_min_filename : given a file sequence number, generates a file name
##  for a minimum overflow file
##--------------------------------------------------------------
sub get_min_filename
{   # get the seq num that was passed in
    my $num = shift;

    return sprintf("basic-%05u-min.c", $num);
};

##--------------------------------------------------------------
## get_med_filename : given a file sequence number, generates a file name
##  for a medium overflow file
##--------------------------------------------------------------
sub get_med_filename
{   # get the seq num that was passed in
    my $num = shift;

    return sprintf("basic-%05u-med.c", $num);
};

##--------------------------------------------------------------
## get_large_filename : given a file sequence number, generates a file name
##  for a large overflow file
##--------------------------------------------------------------
sub get_large_filename
{   # get the seq num that was passed in
    my $num = shift;

    return sprintf("basic-%05u-large.c", $num);
};

##--------------------------------------------------------------
## handle_attributes : given a reference to an array of attributes to vary, produces
##  all the test case variants for those attributes.  Returns the variants
##  as an array of hashes.  Array element 0, for instance, would hold
##  a hash that contains pieces of a test case program appropriate for 
##  when the given attribute's value is 0.
##--------------------------------------------------------------
sub handle_attributes
{   # get the attribute numbers that were passed in
    my $attributes = shift;

    # check that each attribute is valid (and subtract 1 from each so that
    #   they're zero-relative)
    for (my $i = 0; $i < scalar @$attributes; ++$i) 
    {
        $attributes->[$i]--;
        if (!defined($AttributeFunctions{$attributes->[$i]})) 
        {
            die "Error: unknown attribute\n";
        }
    }
    
    # start with default values and vary from there
    my $start_with_values_ref = [get_default_values()];
    foreach my $attr (@$attributes) 
    {
        $start_with_values_ref = $AttributeFunctions{$attr}->($start_with_values_ref);
    }

    return $start_with_values_ref;
}

##--------------------------------------------------------------
## indent : indents every line in the given string by the given number of 
##      spaces and returns the result in new string
##--------------------------------------------------------------
sub indent
{   
    my ($num_spaces, $oldstr) = @_;
    my $append_str = ' ' x $num_spaces;
    my $newstr = join("\n", map {join("",$append_str,$_)} split("\n", $oldstr));
    if (substr($oldstr, -1) eq "\n") 
    {
        $newstr = join("",$newstr,"\n");
    }
    return $newstr;
}

##--------------------------------------------------------------
## make_files : Generates the test case files for variations on the
##  given attribute, starting with the given file sequence number.
##  Returns the next ununused file sequence number.
##--------------------------------------------------------------
sub make_files
{   # get the parameters that were passed in
    my ($attributes, $fseq_num) = @_;

    my $fh;
    my $this_tax_class;
    my $tax_class_value;
    my $this_buf_access;

    my $values_array_ref = handle_attributes($attributes);

    foreach my $values_hash_ref (@$values_array_ref) 
    {
        # generate a set of output file names
        my ($filename_ok, $filename_min, $filename_med, $filename_large) = 
            get_filenames($fseq_num);

        # generate the set of files
        my %file_info = ($filename_ok => $OK_OVERFLOW, 
                                $filename_min => $MIN_OVERFLOW,
                                $filename_med => $MED_OVERFLOW,
                                $filename_large => $LARGE_OVERFLOW);

        foreach my $file (keys %file_info) 
        {
            print "Processing file: $file...\n";

            # set the value of Magnitude to match the size of this overflow
            $values_hash_ref->{'TAX'}->[$MAGNITUDE_DIGIT] = $file_info{$file};

            # make the taxonomy classification, replacing VALUE with the real value
            $tax_class_value = 
                $values_hash_ref->{'TAX'}->[$WRITEREAD_DIGIT] .
                $values_hash_ref->{'TAX'}->[$WHICHBOUND_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$DATATYPE_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$MEMLOC_DIGIT] .
                $values_hash_ref->{'TAX'}->[$SCOPE_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$CONTAINER_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$POINTER_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$INDEXCOMPLEX_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$ADDRCOMPLEX_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$LENCOMPLEX_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$ALIASADDR_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$ALIASINDEX_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$LOCALFLOW_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$SECONDARYFLOW_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$LOOPSTRUCTURE_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$LOOPCOMPLEX_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$ASYNCHRONY_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$TAINT_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$RUNTIMEENVDEP_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$MAGNITUDE_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$CONTINUOUSDISCRETE_DIGIT] . 
                $values_hash_ref->{'TAX'}->[$SIGNEDNESS_DIGIT];
            $this_tax_class = TAXONOMY_CLASSIFICATION;
            $this_tax_class =~ s/VALUE/$tax_class_value/;

            # perform all necessary substitutions for INDEX, WRITE_VALUE, TYPE,
            #   and COMMENT 
            my %copy_values = %$values_hash_ref;
            substitute_values(\%copy_values, $file_info{$file});

            # open the file for writing
            open($fh, ">", $file);

            # write out the contents
            print $fh $this_tax_class;
            # write out the expanded taxonomy classification
            expand_tax_class($fh, $copy_values{'TAX'});
            print $fh FILE_HEADER;
            print $fh $copy_values{'INCL'};
            print $fh $copy_values{'FILE_GLOBAL'};
            print $fh $copy_values{'BEFORE_MAIN'};
            print $fh MAIN_OPEN;
            print $fh $copy_values{'OTHER_DECL'};
            print $fh $copy_values{'BUF_DECL'};
            print $fh $copy_values{'PRE_ACCESS'};
            print $fh $copy_values{'ACCESS'};
            print $fh $copy_values{'POST_ACCESS'};
            print $fh MAIN_CLOSE;

            # close the file
            close($fh);
        }

        # generate extra files if needed
        foreach my $extra_file (keys %{$values_hash_ref->{'EXTRA_FILES'}}) 
        {
            open ($fh, ">", $extra_file);
            print $fh $values_hash_ref->{'EXTRA_FILES'}->{$extra_file};
            close($fh);
        }
        
        # increment the file sequence number
        ++$fseq_num;
    }

    return $fseq_num;
};

##--------------------------------------------------------------
## substitute_values: given a hash of program strings and which size overflow
##  we're working with, substitute for all of our placeholders such as
##  INDEX, WRITE_VALUE, TYPE, and COMMENT
##--------------------------------------------------------------
sub substitute_values
{
    my ($hash_ref, $which_overflow) = @_;
    
    foreach my $item ('FILE_GLOBAL', 'BEFORE_MAIN', 'OTHER_DECL', 'BUF_DECL', 
        'PRE_ACCESS', 'ACCESS', 'POST_ACCESS') 
    {
        $hash_ref->{$item} =~ s/COMMENT/$OverflowInfo{$which_overflow}->[COMMENT_INDEX]/g;

        # iterate through all of the single substitutions
        foreach my $single (keys %{$hash_ref->{'SINGLES'}}) 
        {
            $hash_ref->{$item} =~ 
                s/$single/$hash_ref->{'SINGLES'}->{$single}/g;
        }

        # iterate through all of the multi (size-related) substitutions
        foreach my $multi (keys %{$hash_ref->{'MULTIS'}}) 
        {
            $hash_ref->{$item} =~ 
                s/$multi/$hash_ref->{'MULTIS'}->{$multi}->{$which_overflow}/g;
        }
    }
};

##--------------------------------------------------------------
## usage : print out an optional error message, followed by usage 
## information, and then die
##--------------------------------------------------------------
sub usage
{
    if (scalar(@_) > 0) 
    {
        print shift;
    }

    die "\nUsage:  gentests \n";
};
__END__

=cut

=head1 NAME

    # give your program name and a very short description
    gen_basic_tests.pl - Generates test cases for static analysis tool test suite 

=head1 SYNOPSIS

    # show examples of how to use your program
    ./gen_basic_tests.pl 

=head1 DESCRIPTION

    # describe in more detail what your_program does

=head1 OPTIONS
    
    # document your_program's options in sub-sections here
=head2 --option1

    # describe what option does

=head1 AUTHOR

    # provide your name and contact information
    Kendra Kratkiewicz, kendra@ll.mit.edu

=cut
