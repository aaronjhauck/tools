@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib '\\\\blacklodge\\tools';

use BuildExeUtils;
use BLUtils;
use Getopt::Long;

use vars qw(%args $history);

sub Usage {
    print <<END;
checkpipe [task] -OPTIONS

OPTIONS
    -h     display help
     
checkpipe info -b <builds>         get pool names/machines from array of build numbers   
checkpipe isactive -m <machines>   checks if a machine is currently in use
checkpipe pipes -p <pipes> (-hist) gets bfms for pipepool
     
some uses:

[INFO]
-b 19228.12003      # sporel fork
-b 4907,12028,12029 # return multiple results, mix build types

[ISACTIVE]
-m bfm420           # can leave off "obld" - works with int,bfm,shd,etc
-m bfm420,int301    # return multiple results, mix machine pools

[PIPES]
-p 01               # return list of bfms associated with pipe
-p 15,31,02 -hist   # return last two months of builds per pipe and completion status

END
  exit 1;
}

sub Main {
    if ( GetArgs() ) {
        if ( $args{Task} =~ /^info$/i ) {
            BuildInfo();
        }
        elsif ( $args{Task} =~ /^isactive$/i ) {
            IsActive();
        }
        elsif ( $args{Task} =~ /^pipes$/i ) {
            Pipes();
        }
        else {
            PrintErr("Unrecognized task: \"$args{Task}\"");
            Usage();
        }
    }
    else {
        PrintErr("Failed to parse commandline arguments!")
    }
}

sub BuildInfo {
    for ( @{ $args{Builds} } ) {
        if ( my $pools = GetPipePoolName($_) ) {
            PrintStd("$_ on $$pools{$_}") for ( sort keys %$pools );
        }
        else {
            PrintErr("Failed to retrieve pipe pool name for $_");
        }

        Machines($_);
    }
}

sub Machines {
    for (@_) {
        if ( my $machines = GetMachinesFromBuildNumber($_) ) {
            PrettyPrint($machines);
        }
        else {
            PrintErr(
                "Failed to retrieve machines for $_",
                "It's possible the build is no longer active"
            );
        }
    }
}

sub IsActive {
    for ( @{ $args{Machines} } ) {
        my $build = IsMachineActive("OBLD$_");

        $build
          ? PrintStd("obld$_ is currently in use for $build")
          : PrintStd("obld$_ is currently not in use");
    }
}

sub Pipes {
    for ( @{ $args{Pipes} } ) {
        my $machines = GetBFMsFromPipeName($_);
        my $historic = GetPriorBuildsAndState($_);

        PrintStd("PIPE$_");
        $history
          ? PrettyPrint($historic)
          : PrettyPrint($machines);
    }
}

sub GetArgs {
    my $opts = GetOptions(
    "h|?|help"     => \&Usage,
    "Builds|b:s"   => \&HandleArray,
    "Pipes|p:s"    => \&HandleArray,
    "Machines|m:s" => \&HandleArray,
    "hist"         => sub { $history++ }
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
