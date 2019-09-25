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
# info we collected in database table format
for my $entry (sort keys %TestCases)
{
    # the first column is the test case name
    print "$entry";

    # next we want each digit of the taxonomy classification in its own column
    # except for the size digit - we want to skip that one
    my $tax_string = $TestCases{$entry};
    my $this_char;
    for (my $i = 0; $i < length $tax_string; $i++) 
    {
        # skip the magnitude digit
        if ($i == 19) 
        {
            next;
        }
        # for every other digit, precede it with a tab
        $this_char = substr($tax_string, $i, 1);
        print "\t$this_char";
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
    gen_testcase_db_info.pl - Finds all of the test cases in the given 
        directory, collects their names and taxonomy classification, and
        prints report in database table format (test case name first,
        followed by taxonomy classification digits [except for the size digit]
        all tab-delimited.

=head1 SYNOPSIS

    # show examples of how to use your program
    ./gen_testcase_db_info.pl . 

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
