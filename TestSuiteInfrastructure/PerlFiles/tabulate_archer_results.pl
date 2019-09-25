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
my %Errors;  # a hash that holds file names/line numbers of bounds errors
my %Results; # a hash that holds all of the detection results
my $TotalErrors = 0; # total number of bounds errors detected

##--------------------------------------------------------------
## main program
##--------------------------------------------------------------

#--------------------------------------------------------------
# process arguments
#--------------------------------------------------------------
# check to see if we have the right number of arguments
if (@ARGV < 2) 
{
    usage();
}

# check arguments for validity
my $src_dir = $ARGV[0];
-e $src_dir or die "Sorry.  Directory $src_dir does not exist.\n";
-d $src_dir or die "Sorry.  $src_dir is not a directory.\n";

my $results_dir = $ARGV[1];
-e $results_dir or die "Sorry.  Directory $results_dir does not exist.\n";
-d $results_dir or die "Sorry.  $results_dir is not a directory.\n";

#--------------------------------------------------------------
# here's the beef
#--------------------------------------------------------------
# process the results directory to find reported errors
opendir(OUTDIR, $results_dir) or die "Sorry.  Could not open $results_dir.\n";
my @resfiles = readdir OUTDIR;
closedir OUTDIR;

foreach my $resfile (@resfiles) 
{
    if (!($resfile =~ /\w*-\d*-(ok|min|med|large)/))
    {
	    #print "Skipping: $resfile\n";
	    next;
    }
    #print "Processing results file: $resfile\n";
    find_errors("$results_dir/$resfile", $resfile);
}

# process the source directory against the errors we found
opendir(SRCDIR, $src_dir) or die "Sorry.  Could not open $src_dir.\n";
my @srcfiles = readdir SRCDIR;
closedir SRCDIR;

foreach my $srcfile (@srcfiles) 
{
    if (!($srcfile =~ /(\w*-\d*)-(ok|min|med|large).c/))
    {
	    #print "Skipping: $srcfile\n";
	    next;
    }
    else
    {
        #print "Processing source file: $srcfile\n";
        process_src_file("$src_dir/$srcfile", $1, $2);
    }
}

# report all of the results recorded in our Results hash
# first print a header line
print "Test case\tOK\tMIN\tMED\tLARGE\n";
foreach my $testcase (sort keys %Results) 
{
    my $ok_result = "-";
    if (exists($Results{$testcase}{"ok"}))
    {
        $ok_result = $Results{$testcase}{"ok"};
    }
    my $min_result = "-";
    if (exists($Results{$testcase}{"min"}))
    {
        $min_result = $Results{$testcase}{"min"};
    }
    my $med_result = "-";
    if (exists($Results{$testcase}{"med"}))
    {
        $med_result = $Results{$testcase}{"med"};
    }
    my $large_result = "-";
    if (exists($Results{$testcase}{"large"}))
    {
        $large_result = $Results{$testcase}{"large"};
    }
    printf ("$testcase\t%d\t%d\t%d\t%d\n", $ok_result, $min_result, $med_result, $large_result);
}
#print "\nTotal Errors Detected = $TotalErrors\n";

exit(0);

##--------------------------------------------------------------
## subroutines  (alphabetized)
##--------------------------------------------------------------
##--------------------------------------------------------------
## find_errors : tabulate (by file name and line number) all the
##  errors found in the given results file.
##--------------------------------------------------------------
sub find_errors
{
    my ($filepath, $file) = @_;

	open(THISFILE, "<", $filepath) or die "Sorry.  Could not open $filepath.\n";
	while (<THISFILE>) 
	{
        # example error line:
        #/home/kendra/ThesisTestSuite/basic-00001-large.c:56:main: ERROR:BUFFER:56:56:Array bounds error (len < off+1) (buf[4105], len = 10, off = 4105, max(len-off) = -4095) 
	    if ($_ =~ /([Aa]rray bounds error|out-of-bound array or string access)/) 
	    {
            ++$TotalErrors;
            if ($_ =~ /$file.*\:([0-9]+)\:([0-9]+)\:/) 
            {
        		$Errors{$file}{$1} = 1;
            }
	    }
	}
	close(THISFILE);
}

##--------------------------------------------------------------
## get_badok_line : return the line number of the BAD/OK line (the line
##    after the BAD/OK comment).  Returns -1 if no such line found.
##--------------------------------------------------------------
sub get_badok_line
{
    my $file = shift;

	open(THISFILE, "<", $file) or die "Sorry.  Could not open $file.\n";
	my $foundit = 0;
	my $linenum = 1;
	while (<THISFILE>) 
	{
	    ++$linenum;
	    if ($_ =~ /\/\*\s*?(BAD|OK)\s*?\*\//) 
	    {
    		$foundit = 1;
	    	last;
	    }
	}
	close(THISFILE);

    if (!$foundit) 
	{
	    return -1;
	}
    else
    {
        return $linenum;
    }
}

##--------------------------------------------------------------
## process_src_file : process the given source file to determine if an error
##      was reported for the annotated (BAD/OK) line
##--------------------------------------------------------------
sub process_src_file
{
    my ($src_file, $root, $suffix) = @_;

    my $badok_line = get_badok_line($src_file);
    #print "BAD/OK line number: $badok_line\n";

    # record in the Results hash whether or not an error was reported on
    #  the bad/ok line for this file
    $Results{$root}{$suffix} = exists($Errors{"$root-$suffix"}{$badok_line});
}

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

    die "\nUsage:  tabulate_archer_results.pl <testcase src dir> <archer results dir>\n";
};
__END__

=cut

=head1 NAME

    # give your program name and a very short description
    tabulate_archer_results.pl - parses Archer results to see if it reported errors
        when it should have and didn't when it shouldn't have.

=head1 SYNOPSIS

    # show examples of how to use your program
    ./tabulate_archer_results.pl testcase_src_dir archer_results_dir

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
