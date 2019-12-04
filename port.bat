@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use warnings;
use strict;

use lib "$ENV{'SRCROOT'}\\otools\\lib\\perl";
use Office::SD;
use Office::Branch;

use Getopt::Long;

=head1 NAME

port - Port devmain fix to lab branch and create a childbug of parent bug

=head1 SYNOPSIS

   port.bat -b bug -f fork -p projectName -c changelist
   
=head1 DESCRIPTION

All options are required as this script just calls childbugs.exe and gets
a title back, ports the change, and then appends the description to match 
the title of the newly created bug.

=head1 AUTHOR

Aaron Hauck (v-aahauc)

=cut

my $usage = <<END
Usage: port.bat -b bug -f fork -p projectName -c changelist

    options:
        -b  required    BugId for parent ADO bug
        -f  required    Fork number (FFDXXXXX)
        -p  required    Project name (OC, OE, Office)
        -c  required    Changelist to port
        
    example:
        port -b 12345 -f FFD12345 -p OE -c 12345
END
;

sub Main
{
    #==============================================
    # Parse command line options
    #==============================================
    my $help;
    my %opts = ();
    
    GetOptions("h|help" => \$usage,
            "b=s"    => \$opts{bug},
            "f=s"    => \$opts{fork},
            "p=s"    => \$opts{project},
            "c=s"    => \$opts{changelist});

    die $usage if ($help);

    for (keys %opts) { die "Arguments missing!\n$usage" if !$opts{$_}; }

    if ($opts{fork} =~ m/^[A-Za-z]*(\d{5,6})$/) 
    {
        if    (length($1) == 5) { $opts{fork} = "FFD$1"; } ## force user input to 
        elsif (length($1) == 6) { $opts{fork} = "FF$1";  } ## conform to our convention
    }
    else
    {
        die "Malformed fork number!\n\n$usage";
    }

    #==============================================
    # Check for open files, die if open
    #==============================================
    my @opened = SDOpenedN();
    die "Fatal! Cannot continue due to open files on enlistment\n" 
        if (@opened);

    #==============================================
    # Get branch name
    #==============================================
    my $branch = OfficeCurrentBranchName();
    die "Must be run from a lab enlistment!\n$usage"
        if $branch !~ m/devmainlab/i;

    #==============================================
    # Attempt integration
    #==============================================
    chdir("$ENV{'OTOOLS'}\\lab\\bin");

    print "\nWill attempt to stage integration with the following values\n\n";
    print "#" x 42 . "\n";
    print "\tBranch     : $branch\n";
    print "\tChangelist : $opts{changelist}\n";
    print "#" x 42 . "\n\n";

    if (Prompt("Stage changelist with the above values?"))
    {       
        system("integrate.bat to $branch c=$opts{changelist} -nosubmit")  == 0 or
            die "Error: Cannot continue due to the preceeding errors\n";
    }
    else
    {
        die "\nNot staging change - thus exiting without creating childbug";
    }

    #==============================================
    # Get staged changelist number
    #==============================================
    my @open   = SDOpenedN();        ## list open files and
    my $change = $open[0]->{change}; ## store the cl number

    die "Changelist creation failed!\n" . SDError()
        if (!$change);

    PrintSuccess("Staged change $change for submission after childbug creation");
    
    #==============================================
    # Attempt to create childbug
    #==============================================
    print "\nWill attempt to create child bug with the following values\n\n";
    print "#" x 42 . "\n";
    print "\tBug     : $opts{bug}\n";
    print "\tFork    : $opts{fork}\n";
    print "\tProject : $opts{project}\n";
    print "#" x 42 . "\n\n";

    my $desc = "";
    if (Prompt("Create child bug with the above values?"))
    {
        ## --labport is a special flag added to childbugs.exe to
        ## return only the bug title so we can later copy it, trim
        ## it, and use it for the changelist desciption below
        my $flags = "-b $opts{bug} -f $opts{fork} -p $opts{project} --labport";
        $desc = `\\\\obuildlab\\shares\\Published\\ChildBugs\\childbugs.exe $flags`;

        if ($! || $? != 0)
        {
            print "\nFailure! See above childbugs.exe errors\n";
            print "Reverting $change...\n";
            RevertAndExit($change);
        }
        else
        {
            PrintSuccess("Created childbug of $opts{bug}");
        }
    }
    else
    {
        print "\nNot creating childbug - reverting open change and exiting early";
        RevertAndExit($change);
    }

    #==============================================
    # Attempt to change cl description
    #==============================================
    my $cl = SDGetChange($change); ## return hash of cl attributes
    $cl->{Description} = $desc;    ## change desc to tile from childbugs
    SDSetChange($cl);              ## set new cl attributes

    print "\nReview cl description and ensure it matches bug title then run: sd submit -c $change";
}

sub Prompt
{
	my $prompt= $_[0];
	my $def = $_[1];
	my $input;

	print ("$prompt" . ($def ? " ($def)" : "") . ": ");

	chop($input = lc(<STDIN>));
	return $input eq 'y' ? 1 : 0;
}

sub RevertAndExit
{
    my $change = $_[0];
    
    `sd revert -c $change`;
    exit 0;
}

sub PrintSuccess
{
    my $input = $_[0];
    
    print "\n";
    print "Success: $input";
    print "\n";
}

Main();

__END__
:exit