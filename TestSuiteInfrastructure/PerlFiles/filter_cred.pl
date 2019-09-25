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
use Pod::Usage;
# MAIN
{
    my %errors;  # a hash that holds file names/line numbers of bounds errors

    # check to see if we have the right number of arguments
    if (@ARGV < 1) 
    {
	usage();
    }

    # check arguments for validity
    my $dir = $ARGV[0];
    -e $dir or die "Sorry.  Directory $dir does not exist.\n";
    -d $dir or die "Sorry.  $dir is not a directory.\n";

    # initialize options to default values
    my $opt_outfile = "CRED_test_output.log";

    # get caller-provided values
    if(!GetOptions("outfile=s" => \$opt_outfile))
    {
	usage("Unable to parse options.\n");
    }

    # as long as we're getting input...
    while (<>)
    {
	# look for lines that have a file name, line number, and then
	# the phrase 'Bounds error'
	if (/(basic-\d*?-\w*?.c):(\d*?):Bounds error/)
	{
	    # We'll use the file name as a hash key, and the line number
	    # will be its value.  If this key already exists, then we have 
	    # a problem, because there should only be one bounds error per file.
	    if (exists($errors{$1}))
	    {
		print "*** WARNING: more than one bounds error reported in $1 ***\n";
	    }
	    else
	    {
		$errors{$1} = $2;
	    }
	}
    }

    # read the list of files in the directory
    opendir(THEDIR, $dir) or die "Sorry.  Could not open $dir.\n";
    my @allfiles = readdir THEDIR;
    closedir THEDIR;

    # for each test file, find the line number of the overflow (labeled with
    # with the OK/BAD comment)and figure out if a bounds error was correctly or
    # incorrectly reported or not reported
    my $comment;
    foreach my $file (@allfiles) 
    {
	trim($file);  # get rid of leading/trailing whitespace

	if ($file =~ /ok.c/) 
	{
	    $comment = "OK";
	}
	elsif ($file =~ /(min.c|med.c|large.c)/)
	{
	    $comment = "BAD";
	}
	else
	{
	    next;
	}

	# find the line number of the buffer access
	print "Processing: $file ...";
	open(THISFILE, "<", $file) or die "Sorry.  Could not open $file.\n";
	my $foundit = 0;
	my $linenum = 1;
	while (<THISFILE>) 
	{
	    ++$linenum;
	    if ($_ =~ /\/\*\s*?$comment\s*?\*\//) 
	    {
		$foundit = 1;
		last;
	    }
	}
	if (!$foundit) 
	{
	    print "*** ERROR: no $comment comment ***\n";
	}
	close(THISFILE);

	# look up the file name in the errors hash
	# if this is a BAD comment file, it should be there; if it's an
	# OK comment file, it should not be there.
	my $overflowed = exists($errors{$file});
	if (($comment eq "OK") && $overflowed)
	{
	    print "*** ERROR: OK overflowed ***\n";
	}
	elsif (($comment eq "BAD") && (!$overflowed))
	{
	    print "*** ERROR: BAD did not overflow***\n";
	}
	elsif (($comment eq "BAD") && ($errors{$file} != $linenum))
	{
	    print "*** ERROR: overflow on wrong line ***\n";
	}
	else
	{
	    print "PASSED\n";
	}
    }
}

##--------------------------------------------------------------
## trim : trim leading and trailing whitespace off the given
## string - modifies in place
##--------------------------------------------------------------
sub trim
{
    $_[0] =~ s/^\s+//;
    $_[0] =~ s/\s+$//;
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

    die "\nUsage:  ./filter_cred.pl [--outfile=<outfile>]\n";
};


__END__

=head1 NAME
    cred_filter - filters CRED output and gathers statistics

=head1  SYNOPSIS
    cred_filter < /tmp/temppipe

=head1 OPTIONS

=head2 --outfile=<outfile>
    Specifies output file name.

=head2 --unprocfile=<unprocfile>
    Specifies name of file to collect unprocessed cred output.

=head2 --nodisplay
    Don't print anything to stdout; all output goes to file only instead of both.

=head2 --focus=<bufname,file,line,size> or <filename>
    Specifies one buffer to focus on, or a file from which to read buffer info.  
    Generates specially timestamped lines for all accesses to the specified buffers, 
    and no statistics table.

=head1 DESCRIPTION

=head1 EXAMPLE USAGE

=head1 AUTHOR

Kendra Kratkiewicz - 04/08/04 - MIT Lincoln Laboratory
