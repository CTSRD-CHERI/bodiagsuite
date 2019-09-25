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
    ['LOOP COMPLEXITY', {0 => 'N/A', 1 => 'none', 2 => 'one', 3 => 'two', 4 => 'three'}], 
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

my @CoverageStats = ({0 => 0, 1 => 0},  # write/read
                     {0 => 0, 1 => 0},  # which bound
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0}, # data type
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0}, # memory location
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0},  # scope
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0},  # container
                     {0 => 0, 1 => 0},  # pointer
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0},  # index complexity
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0},  # addr complexity
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0},  # length complexity
                     {0 => 0, 1 => 0, 2 => 0},  # address alias
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0},  # index alias
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0},  # local control flow
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 0},  # secondary control flow
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0},  # loop structure
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0},  # loop complexity
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0},  # asynchrony
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0},  # taint
                     {0 => 0, 1 => 0},  # runtime env dep
                     {0 => 0, 1 => 0, 2 => 0, 3 => 0},  # magnitude
                     {0 => 0, 1 => 0},  # continuous/discrete
                     {0 => 0, 1 => 0}); # signedness

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

my $comment = undef;
foreach my $file (@allfiles) 
{
    if ($file =~ /(min.c|med.c|large.c|ok.c)/) 
    {
        #print "Processing: $file ...\n";
    }
    else
    {
        #print "Skipped $file\n";
        next;
    }

    open(THISFILE, "<", "$dir/$file") or die "Sorry.  Could not open $dir/$file.\n";
    my $foundit = 0;
    my $class_value = undef;
    while (<THISFILE>) 
    {
        if ($_ =~ /Taxonomy Classification: (\d*) /) 
        {
            $foundit = 1;
            $class_value = $1;
            last;
        }
    }

    if (!$foundit) 
    {
        print "FAILED to find taxonomy info in $file\n";
    }
    else
    {
        # for each digit in the string, increment a counter associated with its value
        my $this_char;
        for (my $i = 0; $i < length $class_value; $i++) 
        {
            $this_char = substr($class_value, $i, 1);
            $CoverageStats[$i]->{$this_char}++;
        }
    }
}

# now that we've processed all the files in the directory, print out the statistics
print "\nCoverage Statistics:\n\n";
for (my $i = 0; $i < scalar @CoverageStats; $i++) 
{
    printf "%-25s\n", $TaxonomyInfo[$i]->[NAME_INDEX];
    foreach my $value (sort keys %{$CoverageStats[$i]}) 
    {
        printf "\t%2u\t", $CoverageStats[$i]->{$value};
        print "$TaxonomyInfo[$i]->[VALUES_INDEX]->{$value}\n";
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

    die "\nUsage:  analyze_coverage.pl <dir>\n";
};
__END__

=cut

=head1 NAME

    # give your program name and a very short description
    analyze_coverage.pl - Calculates how many examples of each taxonomy
      attribute/value exist in the given directory, and prints report.

=head1 SYNOPSIS

    # show examples of how to use your program
    ./analyze_coverage.pl . 

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
