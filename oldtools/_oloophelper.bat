@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib '\\\\blacklodge\\tools';
use BLUtils;
use OloopUtils;

use Getopt::Long;

my $help;
my @forks;
my $build;
my $change;
my @depotpaths;
my $friendlyName;

my $usage = <<EOM;
oloophelper [OPTIONS]

Get random information from the oloop db
*[a] == accepts array*

OPTIONS
     -h     display help
     
    Get Machine State:
     -f     array of fork friendly names for machine state <FFD#> [a]
     
    Is Change in Fork:
     -fn    fork friendly name <FFD#>
     -c     changelist number
    
    Get Depot Path from Friendly Name:
     -fn    fork friendly name <FFD#> [a]
     
    Get Friendly Name from Depot Path
     -dp    depot path short hand (labXX{daily} || XXXX{monthly}) [a]
EOM
;

GetOptions(
    "h|help" => \$help,
    "f:s"    => \@forks,
    "c:s"    => \$change,
    "dp:s"   => \@depotpaths,
    "fn:s"   => \$friendlyName
);

die $usage if ($help);

@forks      = SplitJoin(@forks);
@depotpaths = SplitJoin(@depotpaths);

if ($friendlyName) {
    die "Fork format not recognized!\n$usage" 
        if ($friendlyName !~ /^FFD/i);
    
    $change
        ? ChangePresent( $change, $friendlyName )
        : DepotPaths($friendlyName);
}
else {
    MachineState(@forks)
        if @forks;
    FriendlyNames(@depotpaths)
        if @depotpaths;
}

sub GetBuilds {
    my $name = shift;
    my @builds;

    return @builds if ( @builds = GetBuildsFromFriendlyName($name) );
}

sub MachineState {
    for (@_) {
        PrintStd("FORK: $_");
        if ( my $mac = GetForkGroupMachineState($_) ) {
            PrettyPrint($mac);
        }
        else {
            PrintErr("Unable to get machine state for $_!");
        }
    }
}

sub ChangePresent {
    my ( $change, $friendlyName ) = @_;

    my @builds = GetBuilds($friendlyName);

    for (@builds) {
        if ( IsChangeInBuild( $change, $_ ) ) {
            return PrintStd( "Change found", "$change first seen in $_" );
        }
    }
    PrintStd("Change $change not found in $friendlyName");
}

sub DepotPaths {
    for (@_) {
        if ( my $depotPath = GetDepotPathFromFriendlyName($_) ) {
            $depotPath =~ /\/\/\w+\/(\w+)\/.*/i;
            PrintStd("$_ => $1");
        }
        else {
            PrintErr("Unable to determine depot path for \"$_\"");
        }
    }
}

sub FriendlyNames {
    for (@_) {
        if ( my $bgName = GetFriendlyNameFromDepotPath($_) ) {
            $_ =~ /.*\d{4}/i
              ? PrintStd("$bgName -> Monthly Fork")
              : PrintStd("$bgName -> Daily Fork");
        }
        else {
            PrintErr("Unable to determine BuildGroup Friendly Name for \"$_\"");
        }
    }
}

__END__
:exit
