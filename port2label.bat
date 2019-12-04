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

port2label - Port devmain fix to lab branch and update/sync label

=head1 SYNOPSIS

   port2label -b <buildNumber> -c <changeList>
   
=head1 DESCRIPTION

All options are required. Use sparse direction to do alot of the label
updating and syncing. See usage for more info.

=head1 AUTHOR

Aaron Hauck (v-aahauc)

=cut

my $usage = <<END
Useage: port2label -b <buildNumber> -c <changeList>

    options:
        -b  required    minor high or . delimited fork number
        -c  required    devmain changelist number
        
    ex:
        port2label -b 12113 -c 12345678 (monolith build)
                   -b 11913 -c 12345678 (sporel build)
                   -b 11913.12015 -c 12345678 (sporel fork)
END
;

sub Main {
    my $help;
    my %opts = ();
    
    GetOptions(
        "h|help" => \$help,
        "b=s"    => \$opts{build},
        "c=s"    => \$opts{cl}
    );
    
    die $usage if ($help);
    for (keys %opts) { die "Arguemnts missing!\n$usage" if !$opts{$_}; }
    
    die "$opts{cl} is an invalid changelist!\n\n $usage"
        if ($opts{cl} !~ /^\d+$/);
    
    #==============================================
    # Check for open files, die if open
    #==============================================
    my @opened = SDOpenedN();
    die "Fatal! Cannot continue due to open files on enlistment\n" 
        if (@opened);
        
    #==============================================
    # Ensure label actually exists
    #==============================================
    my $buildNumber = CheckBuildNumber($opts{build});
    my $labelFormat = FormatLabel($buildNumber);
    
    die "Label \"$labelFormat\" looks incorrect for build number \"$buildNumber\"\n$usage"
        if (system ("sd files //depot/devmain/otools/inc/otools/OfficeLabVersion.txt\@$labelFormat > nul 2>&1") != 0);
    
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
    print "\tChangelist : $opts{cl}\n";
    print "#" x 42 . "\n\n";

    if (Prompt("Stage changelist with the above values?")) {       
        system("integrate.bat to $branch c=$opts{cl} -nosubmit")
            or die "Error: Cannot continue due to the preceeding errors\n";
    }
    else {
        die "\nNot staging change - thus exiting early";
    }
    
    #==============================================
    # Get staged changelist number
    #==============================================
    my @open   = SDOpenedN();        ## list open files and
    my $change = $open[0]->{change}; ## store the cl number

    die "Changelist creation failed!\n" . SDError()
        if (!$change);

    #==============================================
    # Submit and retrieve offical change number/files
    #==============================================
    my $ncl = SDSubmit(\"-c $change");
    
    print "Staged changelist $change submitted as $ncl";
    
    my @files;
    my $submission = `sd describe -s $ncl`;
    push @files, $submission =~ /\n\.{3}\s(.+)/g;
    
    die "No files were present in integration!\n$usage"
        if (!@files);
        
    #==============================================
    # Get/Update/Set Label
    #==============================================
    my $label = SDGetLabel($labelFormat);
    $label->{Options}->{locked} = 0;
    
    if (Prompt("Add changelist $opts{cl} to $labelFormat?")) {       
        $label->{Description} =~ s/(.*-s.*-i\s")(.*)("\s-b.*)/$1$2,$opts{cl}$3/;
    }
    else {
        die "Label not updated!\nMust manually take action from here!\n";
    }
    
    SDSetLabel($label);
    
    #==============================================
    # Sync all files from lab branch CL to label
    #==============================================
    print "Will attempt to sync all files from $ncl...\n";
    
    for(@files) {
        if (system("sd labelsync -l $labelFormat $_\n") != 0) {
            print "Unable to sync $_! Try manually syncing\n";
        }
    }
	
    #==============================================
    # Lock the label back up
    #==============================================
    print "Files synced - locking label";
    my $lockedLabel = SDGetLabel($labelFormat);
    $lockedLabel->{Options}->{locked} = 1;
	
	SDSetLabel($lockedLabel);
}

sub CheckBuildNumber {
    my ($build) = shift;

    my $num = "16.0.$build.10000";

    if ( length($build) == 4 )  { $num = "16.0.$build.1000"; }  #dev16
    if ( $build > 19000 )       { $num = "16.0.$build.12000"; } #sporel
    if ( $build =~ /\d+\.\d+/ ) { $num = "16.0.$build"; }       #fork

    return $num;
}

sub FormatLabel {
    my ($num) = shift;
    
    if ($num =~ m/\.12\d+$/) {
        return $num = "ovr_sporel_bld$1\_$2\_$3" 
            if $num =~ m/(\d+)\.\d+\.(\d+)\.(\d+)/g;
    }
        
    return $num = "bld$1\_$2\_$3" 
        if $num =~ m/(\d+)\.\d+\.(\d+)\.(\d+)/g;
}

sub Prompt {
	my $prompt= $_[0];
	my $def = $_[1];
	my $input;

	print ("$prompt" . ($def ? " ($def)" : "") . ": ");

	chop($input = lc(<STDIN>));
	return $input eq 'y' ? 1 : 0;
}

Main();

__END__
:exit