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
my %Results;    #holds statistics for each tool/each attribute/each value

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
my $file = $ARGV[0];
-e $file or die "Sorry.  $file does not exist.\n";

#--------------------------------------------------------------
# here's the beef
#--------------------------------------------------------------
# open the given input file
open(THISFILE, "<", $file) or die "Sorry.  Could not open $file.\n";

# process five blocks of results from the five tools
for (my $i=1; $i < 6; ++$i) 
{
    process_tool_block();
}

close(THISFILE);

# now that we've processed all of the tool info, print out the statistics
print "ATTRIBUTE\tVALUE\tDESCRIPTION\tARCHER TOTAL\tBOON TOTAL" . 
       "\tPOLYSPACE TOTAL\tSPLINT TOTAL\tUNO TOTAL" . 
       "\tARCHER RESULT\tBOON RESULT\tPOLYSPACE RESULT" . 
       "\tSPLINT RESULT\tUNO RESULT\n";
for my $attribute (sort keys %Results) 
{
    my $attrib_hash = $Results{$attribute};
    for my $value (sort keys %$attrib_hash) 
    {
        my $value_hash = $attrib_hash->{$value};
        printf "$attribute\t$value\t$value_hash->{'desc'}\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n",
               $value_hash->{'archer'}->{'total'}, 
               $value_hash->{'boon'}->{'total'}, 
               $value_hash->{'polyspace'}->{'total'}, 
               $value_hash->{'splint'}->{'total'}, 
               $value_hash->{'uno'}->{'total'}, 
               $value_hash->{'archer'}->{'result'}, 
               $value_hash->{'boon'}->{'result'}, 
               $value_hash->{'polyspace'}->{'result'},
               $value_hash->{'splint'}->{'result'}, 
               $value_hash->{'uno'}->{'result'};
    }
}

exit(0);

##--------------------------------------------------------------
## subroutines  (alphabetized)
##--------------------------------------------------------------
##--------------------------------------------------------------
## process_addrcomplex : get the addrcomplex attribute/value results
##--------------------------------------------------------------
sub process_addrcomplex
{
    my $tool = shift;

    # 0 = constant
    save_values("addrcomplex", 0, "constant", $tool);

    # 1 = variable
    save_values("addrcomplex", 1, "variable", $tool);

    # 2 = linear exp
    save_values("addrcomplex", 2, "linear exp", $tool);

    # 3 = non-linear exp
    save_values("addrcomplex", 3, "non-linear exp", $tool);

    # 4 = func ret val
    save_values("addrcomplex", 4, "func ret val", $tool);

    # 5 = array contents
    save_values("addrcomplex", 5, "array contents", $tool);
};

##--------------------------------------------------------------
## process_aliasaddr : get the aliasaddr attribute/value results
##--------------------------------------------------------------
sub process_aliasaddr
{
    my $tool = shift;

    # 0 = none
    save_values("aliasaddr", 0, "none", $tool);

    # 1 = one
    save_values("aliasaddr", 1, "one", $tool);

    # 2 = two
    save_values("aliasaddr", 2, "two", $tool);
};

##--------------------------------------------------------------
## process_aliasindex : get the aliasindex attribute/value results
##--------------------------------------------------------------
sub process_aliasindex
{
    my $tool = shift;

    # 0 = none
    save_values("aliasindex", 0, "none", $tool);

    # 1 = one
    save_values("aliasindex", 1, "one", $tool);

    # 2 = two
    save_values("aliasindex", 2, "two", $tool);

    # 3 = N/A
    save_values("aliasindex", 3, "N/A", $tool);

};

##--------------------------------------------------------------
## process_asynchrony : get the asynchrony attribute/value results
##--------------------------------------------------------------
sub process_asynchrony
{
    my $tool = shift;

    # 0 = none
    save_values("asynchrony", 0, "none", $tool);

    # 1 = threads
    save_values("asynchrony", 1, "threads", $tool);

    # 2 = fork
    save_values("asynchrony", 2, "fork", $tool);

    # 3 = sig hand
    save_values("asynchrony", 3, "sig hand", $tool);
};

##--------------------------------------------------------------
## process_container : get the container attribute/value results
##--------------------------------------------------------------
sub process_container
{
    my $tool = shift;

    # 0 = none
    save_values("container", 0, "none", $tool);

    # 1 = array
    save_values("container", 1, "array", $tool);

    # 2 = struct
    save_values("container", 2, "struct", $tool);

    # 3 = union
    save_values("container", 3, "union", $tool);

    # 4 = array of structs
    save_values("container", 4, "array of structs", $tool);

    # 5 = array of unions
    save_values("container", 5, "array of unions", $tool);
};

##--------------------------------------------------------------
## process_continuousdiscrete : get the continuousdiscrete attribute/value results
##--------------------------------------------------------------
sub process_continuousdiscrete
{
    my $tool = shift;

    # 0 = discrete
    save_values("continuousdiscrete", 0, "discrete", $tool);

    # 1 = continuous
    save_values("continuousdiscrete", 1, "continuous", $tool);
};

##--------------------------------------------------------------
## process_datatype : get the datatype attribute/value results
##--------------------------------------------------------------
sub process_datatype
{
    my $tool = shift;

    # 0 = char
    save_values("datatype", 0, "char", $tool);

    # 1 = int
    save_values("datatype", 1, "int", $tool);

    # 2 = float
    save_values("datatype", 2, "float", $tool);

    # 3 = wchar
    save_values("datatype", 3, "wchar", $tool);

    # 4 = pointer
    save_values("datatype", 4, "pointer", $tool);

    # 5 = unsigned int
    save_values("datatype", 5, "unsigned int", $tool);

    # 6 = unsigned char
    save_values("datatype", 6, "unsigned char", $tool);
};

##--------------------------------------------------------------
## process_indexcomplex : get the indexcomplex attribute/value results
##--------------------------------------------------------------
sub process_indexcomplex
{
    my $tool = shift;

    # 0 = constant
    save_values("indexcomplex", 0, "constant", $tool);

    # 1 = variable
    save_values("indexcomplex", 1, "variable", $tool);

    # 2 = linear exp
    save_values("indexcomplex", 2, "linear exp", $tool);

    # 3 = non-linear exp
    save_values("indexcomplex", 3, "non-linear exp", $tool);

    # 4 = func ret val
    save_values("indexcomplex", 4, "func ret val", $tool);

    # 5 = array contents
    save_values("indexcomplex", 5, "array contents", $tool);

    # 6 = N/A
    save_values("indexcomplex", 6, "N/A", $tool);
};

##--------------------------------------------------------------
## process_lencomplex : get the lencomplex attribute/value results
##--------------------------------------------------------------
sub process_lencomplex
{
    my $tool = shift;

    # 0 = N/A
    save_values("lencomplex", 0, "N/A", $tool);

    # 1 = none
    save_values("lencomplex", 1, "none", $tool);

    # 2 = constant
    save_values("lencomplex", 2, "constant", $tool);

    # 3 = variable
    save_values("lencomplex", 3, "variable", $tool);

    # 4 = linear exp
    save_values("lencomplex", 4, "linear exp", $tool);

    # 5 = non-linear exp
    save_values("lencomplex", 5, "non-linear exp", $tool);

    # 6 = func ret val
    save_values("lencomplex", 6, "func ret val", $tool);

    # 7 = array contents
    save_values("lencomplex", 7, "array contents", $tool);
};

##--------------------------------------------------------------
## process_localflow : get the localflow attribute/value results
##--------------------------------------------------------------
sub process_localflow
{
    my $tool = shift;

    # 0 = none
    save_values("localflow", 0, "none", $tool);

    # 1 = if
    save_values("localflow", 1, "if", $tool);

    # 2 = switch
    save_values("localflow", 2, "switch", $tool);

    # 3 = cond
    save_values("localflow", 3, "cond", $tool);

    # 4 = goto
    save_values("localflow", 4, "goto", $tool);

    # 5 = longjmp
    save_values("localflow", 5, "longjmp", $tool);

    # 6 = func ptr
    save_values("localflow", 6, "func ptr", $tool);

    # 7 = recursion
    save_values("localflow", 7, "recursion", $tool);
};

##--------------------------------------------------------------
## process_loopcomplex : get the loopcomplex attribute/value results
##--------------------------------------------------------------
sub process_loopcomplex
{
    my $tool = shift;

    # 0 = N/A
    save_values("loopcomplex", 0, "N/A", $tool);

    # 1 = none
    save_values("loopcomplex", 1, "none", $tool);

    # 2 = one
    save_values("loopcomplex", 2, "one", $tool);

    # 3 = two
    save_values("loopcomplex", 3, "two", $tool);

    # 4 = N/A
    save_values("loopcomplex", 4, "N/A", $tool);
};

##--------------------------------------------------------------
## process_loopstructure : get the loopstructure attribute/value results
##--------------------------------------------------------------
sub process_loopstructure
{
    my $tool = shift;

    # 0 = none
    save_values("loopstructure", 0, "none", $tool);

    # 1 = standard for
    save_values("loopstructure", 1, "standard for", $tool);

    # 2 = standard do-while
    save_values("loopstructure", 2, "standard do-while", $tool);

    # 3 = standard while
    save_values("loopstructure", 3, "standard while", $tool);

    # 4 = non-standard for
    save_values("loopstructure", 4, "non-standard for", $tool);

    # 5 = non-standard do-while
    save_values("loopstructure", 5, "non-standard do-while", $tool);

    # 6 = non-standard while
    save_values("loopstructure", 6, "non-standard while", $tool);
};

##--------------------------------------------------------------
## process_memloc : get the memloc attribute/value results
##--------------------------------------------------------------
sub process_memloc
{
    my $tool = shift;

    # 0 = stack
    save_values("memloc", 0, "stack", $tool);

    # 1 = heap
    save_values("memloc", 1, "heap", $tool);

    # 2 = data
    save_values("memloc", 2, "data", $tool);

    # 3 = bss
    save_values("memloc", 3, "bss", $tool);

    # 4 = shared
    save_values("memloc", 4, "shared", $tool);
};

##--------------------------------------------------------------
## process_pointer : get the pointer attribute/value results
##--------------------------------------------------------------
sub process_pointer
{
    my $tool = shift;

    # 0 = no
    save_values("pointer", 0, "no", $tool);

    # 1 = yes
    save_values("pointer", 1, "yes", $tool);
};

##--------------------------------------------------------------
## process_runtimeenvdep : get the runtimeenvdep attribute/value results
##--------------------------------------------------------------
sub process_runtimeenvdep
{
    my $tool = shift;

    # 0 = no
    save_values("runtimeenvdep", 0, "no", $tool);

    # 1 = yes
    save_values("runtimeenvdep", 1, "yes", $tool);
};

##--------------------------------------------------------------
## process_scope : get the scope attribute/value results
##--------------------------------------------------------------
sub process_scope
{
    my $tool = shift;

    # 0 = same
    save_values("scope", 0, "same", $tool);

    # 1 = inter-proc
    save_values("scope", 1, "inter-proc", $tool);

    # 2 = global
    save_values("scope", 2, "global", $tool);

    # 3 = inter-file/inter-proc
    save_values("scope", 3, "inter-file/inter-proc", $tool);
};

##--------------------------------------------------------------
## process_secondaryflow : get the secondaryflow attribute/value results
##--------------------------------------------------------------
sub process_secondaryflow
{
    my $tool = shift;

    # 0 = none
    save_values("secondaryflow", 0, "none", $tool);

    # 1 = if
    save_values("secondaryflow", 1, "if", $tool);

    # 2 = switch
    save_values("secondaryflow", 2, "switch", $tool);

    # 3 = cond
    save_values("secondaryflow", 3, "cond", $tool);

    # 4 = goto
    save_values("secondaryflow", 4, "goto", $tool);

    # 5 = longjmp
    save_values("secondaryflow", 5, "longjmp", $tool);

    # 6 = func ptr
    save_values("secondaryflow", 6, "func ptr", $tool);

    # 7 = recursion
    save_values("secondaryflow", 7, "recursion", $tool);
};

##--------------------------------------------------------------
## process_signedness : get the signedness attribute/value results
##--------------------------------------------------------------
sub process_signedness
{
    my $tool = shift;

    # 0 = no
    save_values("signedness", 0, "no", $tool);

    # 1 = yes
    save_values("signedness", 1, "yes", $tool);
};

##--------------------------------------------------------------
## process_taint : get the taint attribute/value results
##--------------------------------------------------------------
sub process_taint
{
    my $tool = shift;

    # 0 = none
    save_values("taint", 0, "none", $tool);

    # 1 = argc/argv
    save_values("taint", 1, "argc/argv", $tool);

    # 2 = env var
    save_values("taint", 2, "env var", $tool);

    # 3 = file read
    save_values("taint", 3, "file read", $tool);

    # 5 = process env
    save_values("taint", 5, "process env", $tool);
};

##--------------------------------------------------------------
## process_tool_block : process a block of data from one tool
##--------------------------------------------------------------
sub process_tool_block
{
    # the first line is the name of the tool
    my $tool = <THISFILE>;
    chomp $tool;
    trim($tool);
    #print "Found tool $tool\n";

    # get the attribute data
    process_writeread($tool);
    process_whichbound($tool);
    process_datatype($tool);
    process_memloc($tool);
    process_scope($tool);
    process_container($tool);
    process_pointer($tool);
    process_indexcomplex($tool);
    process_addrcomplex($tool);
    process_lencomplex($tool);
    process_aliasaddr($tool);
    process_aliasindex($tool);
    process_localflow($tool);
    process_secondaryflow($tool);
    process_loopstructure($tool);
    process_loopcomplex($tool);
    process_asynchrony($tool);
    process_taint($tool);
    process_runtimeenvdep($tool);
    process_continuousdiscrete($tool);
    process_signedness($tool);
};

##--------------------------------------------------------------
## process_whichbound : get the whichbound attribute/value results
##--------------------------------------------------------------
sub process_whichbound
{
    my $tool = shift;

    # 0 = upper
    save_values("whichbound", 0, "upper", $tool);

    # 1 = lower
    save_values("whichbound", 1, "lower", $tool);
};

##--------------------------------------------------------------
## process_writeread : get the writeread attribute/value results
##--------------------------------------------------------------
sub process_writeread
{
    my $tool = shift;

    # 0 = write
    save_values("writeread", 0, "write", $tool);

    # 1 = read
    save_values("writeread", 1, "read", $tool);
};

##--------------------------------------------------------------
## save_values : get and save values under given attribute/value/desc/tool
##--------------------------------------------------------------
sub save_values
{
    my ($attrib, $value, $desc, $tool) = @_;
    
    # skip "count" line and grab total number from next line
    <THISFILE>;
    my $total = <THISFILE>;
    chomp $total;
    trim($total);

    # skip "count" line and grab this tool's performance number from next line
    <THISFILE>;
    my $result = <THISFILE>;
    chomp $result;
    trim($result);

    # save all this info in our Results hash
    $Results{$attrib}{$value}{'desc'} = $desc;
    $Results{$attrib}{$value}{$tool}{'total'} = $total;
    $Results{$attrib}{$value}{$tool}{'result'} = $result;
};

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

    die "\nUsage:  gen_table_each_value.pl <input file>\n";
};
__END__

=cut

=head1 NAME

    # give your program name and a very short description
    gen_table_each_value.pl - Processes the input file, tabulates how each
        tool performed on each value of each attribute, and prints report.

=head1 SYNOPSIS

    # show examples of how to use your program
    ./gen_table_each_value.pl raw_detection_results.txt > detection_table.txt

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
