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

use vars qw(%args);

sub Usage {
    print <<EOM;
oloophelper [task] -OPTIONS

OPTIONS
     -h     display help
     
oloophelper machines -f <forkName>                 returns list of machines for build group
oloophelper inbuild -c <cl> -fn <forkFriendlyName> returns what build change is in, if in fork
oloophelper depotpath -fn <forkFriendlyName>       get depot path from friendly name
oloophelper friendlyname -dp <depotPathShortName>  get friendly name from depot path

some uses:
[MACHINES]
-f 12308    # shorthand of forkname
-f FFD12308 # full fork name

[INBUILD]
-c 12345678 -fn FFD12308

[DEPOTPATH]
-fn FFD12308,FFD12309

[FRIENDLYNAME]
-dp devmainlab07
-dp 1901,lab31,1908
EOM
    exit 1;
}

sub Main {
    if ( GetArgs() ) {
        if ( $args{Task} =~ /^Machines$/i ) {
            GetMachines();
        }
        elsif ( $args{Task} =~ /^InBuild$/i ) {
            ChangePresent();
        }
        elsif ( $args{Task} =~ /^DepotPath$/i ) {
            DepotPaths();
        }
        elsif ( $args{Task} =~ /^FriendlyName$/i ) {
            FriendlyNames();
        }
        else {
            PrintErr("Unrecognized task: \"$args{Task}\"");
            Usage();
        }
    }
}

sub GetMachines {
    for ( @{ $args{Forks} } ) {
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
    my @builds = GetBuilds( $args{FriendlyName}[0] );

    for (@builds) {
        return PrintStd( "Change found", "$args{Change} first seen in $_" )
          if ( IsChangeInBuild( $args{Change}, $_ ) );
    }
    PrintStd("Change $args{Change} not found in $args{FriendlyName}[0]");
}

sub DepotPaths {
    for ( @{ $args{FriendlyName} } ) {
        if ( my $depotPath = GetDepotPathFromFriendlyName($_) ) {
            $depotPath =~ /\/\/\w+\/(\w+)\/.*/i;
            PrintStd("$_ => $1");
        }
        else {
            PrintErr(
                "Unable to determine depot path for \"$args{FriendlyName}\"");
        }
    }
}

sub FriendlyNames {
    for ( @{ $args{DepotPaths} } ) {
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

sub GetBuilds {
    my @builds;

    return @builds if ( @builds = GetBuildsFromFriendlyName(shift) );
}

sub GetArgs {
    my $opts = GetOptions(
        "h|?|help"          => \&Usage,
        "Forks|f:s"         => \&HandleArray,
        "DepotPaths|dp:s"   => \&HandleArray,
        "Change|c:s"        => \&HandleScalar,
        "FriendlyName|fn:s" => \&HandleArray,
    );

    $args{Task} = shift @ARGV;
    Usage() if ( !defined $args{Task} );

    return $opts ? 1 : 0;
}

sub HandleScalar {
    my ( $key, $value ) = @_;

    return $args{$key} = $value;
}

sub HandleArray {
    my ( $key, @value ) = @_;
    @value = SplitCSV(@value);

    return $args{$key} = [@value];
}

Main();

__END__
:exit
