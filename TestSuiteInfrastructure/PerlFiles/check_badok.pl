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
    print "Processing: $file ...";
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
        print "skipped\n";
        next;
    }

    open(THISFILE, "<", $file) or die "Sorry.  Could not open $file.\n";
    my $foundit = 0;
    while (<THISFILE>) 
    {
        if ($_ =~ /\/\*\s*?$comment\s*?\*\//) 
        {
            print "passed\n";
            $foundit = 1;
            last;
        }
    }
    if (!$foundit) 
    {
        print "FAILED\n";
    }
    close(THISFILE);
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

    die "\nUsage:  check_badok.pl <dir>\n";
};
__END__

=cut

=head1 NAME

    # give your program name and a very short description
    check_badok.pl - Checks to see if each given file contains the 
      appropriate BAD/OK label.

=head1 SYNOPSIS

    # show examples of how to use your program
    ./check_badok.pl 

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
