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

##--------------------------------------------------------------
## File globals
##--------------------------------------------------------------
# There will be one entry for each test case (minus the suffix
# ok/min/med/large), and the value will be the taxonomy
# classification string.
my %TestCases;

my $OK_SIZE = 0;
my $MIN_SIZE = 1;
my $MED_SIZE = 8;
my $LARGE_SIZE = 4096;

# associate taxonomy characteristics with their values in an array
my @TaxonomyInfo = (
    ['WRITE/READ', {0 => 'write', 1 => 'read'}], 
    ['WHICH BOUND', {0 => 'upper', 1 => 'lower'}], 
    ['DATA TYPE', {0 => 'char', 1 => 'int', 2 => 'float', 
                        3 => 'wchar', 4 => 'pointer', 5 => 'unsigned int',
                        6 => 'unsigned char'}], 
    ['MEMORY LOCATION', {0 => 'stack', 1 => 'heap', 2 => 'data segment',
                      3 => 'bss', 4 => 'shared'}], 
    ['SCOPE', {0 => 'same scope', 1 => 'inter-procedural', 2 => 'global',
                     3 => 'inter-file/inter-proc', 4 => 'inter-file/global'}], 
    ['CONTAINER', {0 => 'no container', 1 => 'array', 2 => 'struct', 3 => 'union',
                         4 => 'array of structs', 5 => 'array of unions'}], 
    ['POINTER', {0 => 'no pointer', 1 => 'pointer'}], 
    ['INDEX COMPLEXITY', {0 => 'index:constant', 1 => 'index:variable', 2 => 'index:linear expr',
                            3 => 'index:non-linear expr', 4 => 'index:func ret val',
                            5 => 'index:array contents', 6 => 'index:N/A'}], 
    ['ADDRESS COMPLEXITY', {0 => 'addr:constant', 1 => 'addr:variable', 2 => 'addr:linear expr',
                            3 => 'addr:non-linear expr', 4 => 'addr:func ret val',
                            5 => 'addr:array contents'}], 
    ['LENGTH COMPLEXITY', {0 => 'length:N/A', 1 => 'length:none', 2 => 'length:constant', 
                          3 => 'length:variable', 4 => 'length:linear expr', 
                          5 => 'length:non-linear expr', 6 => 'length:func ret val',
                          7 => 'length:array contents'}], 
    ['ADDRESS ALIAS', {0 => 'aliasaddr:none', 1 => 'aliasaddr:one', 
                         2 => 'aliasaddr:two'}], 
    ['INDEX ALIAS', {0 => 'aliasindex:none', 1 => 'aliasindex:one', 
                         2 => 'aliasindex:two', 3 => 'aliasindex:N/A'}], 
    ['LOCAL CONTROL FLOW', {0 => 'localflow:none', 1 => 'localflow:if', 2 => 'localflow:switch', 3 => 'localflow:cond',
                         4 => 'localflow:goto', 5 => 'localflow:longjmp', 
                         6 => 'localflow:funcptr', 7 => 'localflow:recursion'}], 
    ['SECONDARY CONTROL FLOW', {0 => '2ndflow:none', 1 => '2ndflow:if', 2 => '2ndflow:switch', 3 => '2ndflow:cond',
                         4 => '2ndflow:goto', 5 => '2ndflow:longjmp', 
                         6 => '2ndflow:funcptr', 7 => '2ndflow:recursion'}], 
    ['LOOP STRUCTURE', {0 => 'no loop', 1 => 'for', 2 => 'do-while', 3 => 'while',
                             4 => 'non-standard for', 5 => 'non-standard do-while',
                             6 => 'non-standard while'}], 
    ['LOOP COMPLEXITY', {0 => 'loopcomplex:N/A', 1 => 'loopcomplex:zero', 
                        2 => 'loopcomplex:one', 3 => 'loopcomplex:two', 4 => 'loopcomplex:three'}], 
    ['ASYNCHRONY', {0 => 'no asynchrony', 1 => 'threads', 2 => 'forked process',
                          3 => 'signal handler'}], 
    ['TAINT', {0 => 'no taint', 1 => 'argc/argv', 2 => 'env var', 
                     3 => 'file read', 4 => 'socket', 5 => 'proc env'}], 
    ['RUNTIME ENV. DEPENDENCE', {0 => 'not runtime env dep', 1 => 'runtime env dep'}], 
    ['MAGNITUDE', {0 => 'no overflow', 1 => "$MIN_SIZE byte", 
                         2 => "$MED_SIZE bytes", 3 => "$LARGE_SIZE bytes"}],
    ['CONTINUOUS/DISCRETE', {0 => 'discrete', 1 => 'continuous'}], 
    ['SIGNEDNESS', {0 => 'no sign', 1 => 'sign'}]);

# definitions for array indices related to the TaxonomyInfo array
use constant NAME_INDEX => 0;
use constant VALUES_INDEX => 1;


##--------------------------------------------------------------
## main program
##--------------------------------------------------------------

#--------------------------------------------------------------
# process arguments
#--------------------------------------------------------------
# check to see if we have the right number of arguments
if (@ARGV < 1) 
{
    usage();
}

# check arguments for validity
my $dir = $ARGV[0];
-e $dir or die "Sorry.  Directory $dir does not exist.\n";
-d $dir or die "Sorry.  $dir is not a directory.\n";

#--------------------------------------------------------------
# here's the beef
#--------------------------------------------------------------
opendir(THEDIR, $dir) or die "Sorry.  Could not open $dir.\n";
my @allfiles = readdir THEDIR;
closedir THEDIR;

my $testcase = undef;
foreach my $file (@allfiles) 
{
    if ($file =~ /(\w*-\d*)-(min.c|med.c|large.c|ok.c)/) 
    {
        #print "Processing: $file ...\n";
        $testcase = $1;
        if (exists($TestCases{$testcase})) 
        {
            #print "\tAlready processed $testcase\n";
            next;
        }
    }
    else
    {
        #print "Skipped $file\n";
        next;
    }

    open(THISFILE, "<", "$dir/$file") or die "Sorry.  Could not open $dir/$file.\n";
    my $class_value = undef;
    while (<THISFILE>) 
    {
        if ($_ =~ /Taxonomy Classification: (\d*) /) 
        {
            $class_value = $1;
            last;
        }
    }

    if (!defined($class_value)) 
    {
        print "FAILED to find taxonomy info in $dir/$file\n";
    }
    else
    {
        # save the taxonomy classification string in the hash
        $TestCases{$testcase} = $class_value;
    }
}

# now that we've processed all the files in the directory, print out the 
# info we collected (one row for each test case in the format:
#  test case name <TAB> desc1,desc2,desc3 etc.
# where the descX's are English descriptions of the non-zero attribute
# values (non-base case)
for my $entry (sort keys %TestCases)
{
    # the first column is the test case name
    print "$entry\t";

    # next, for each non-zero digit of the taxonomy classification, we want to
    # loop up and print out its English description (except for the size digit
    # - we want to skip that one)
    my $tax_string = $TestCases{$entry};
    my $this_char;
    for (my $i = 0; $i < length $tax_string; $i++) 
    {
        # skip the magnitude digit
        if ($i == 19) 
        {
            next;
        }
        # for every other digit, if it's not zero, print out its description
        # (comma separate them)
        $this_char = substr($tax_string, $i, 1);
        if ($this_char != 0) 
        {
            print "$TaxonomyInfo[$i]->[VALUES_INDEX]->{$this_char},";
        }
    }
    print "\n";
}

exit(0);

##--------------------------------------------------------------
## subroutines  (alphabetized)
##--------------------------------------------------------------
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

    die "\nUsage:  gen_testcase_db_info.pl <dir>\n";
};
__END__

=cut

=head1 NAME

    # give your program name and a very short description
    gen_testcase_desc.pl - Finds all of the test cases in the given 
        directory, collects their names and taxonomy classification, and
        prints a report that lists each test case and an English description
        of its non-zero attributes (those that differ from the base case).

=head1 SYNOPSIS

    # show examples of how to use your program
    ./gen_testcase_desc.pl . 

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
