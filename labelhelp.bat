@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "\\\\blacklodge\\tools";

use BLUtils;
use BuildExeUtils;
use Getopt::Long;
use vars qw($usage);

$usage = <<END

useage: labelhelp.bat -b <buildNumber(s)> [other options]

    for sporel label help:
        labelhelp -b five.five -sporel
        ex:       -b 19304.12016 -sporel
        
    for updating/syncing checkpoints help:
        labelhelp -b XXXXXX,XXXXX -c <cl>
        ex:       -b 12113,12112,11929 -c 123456

END
  ;

sub Main {
    my $help;
    my @builds;
    my $sporel;
    my $changelist;

    GetOptions(
        "h|help" => \$help,
        "b:s"    => \@builds,
        "c:s"    => \$changelist,
        "sporel" => sub { $sporel++ }
    );

    @builds = split( /,/, join( ',', @builds ) );

    die $usage if ($help);
    unless ($sporel) { die "Missing Changelist!\n$usage" if ( !$changelist ); }

    if ($sporel) {
        foreach my $build (@builds) {
            my @errs;

            ## Check specifically for DB errors
            my $pool = GetPipeName($build);
            push @errs, "GetPipeName" if !$pool;
            my $num = CheckBuildNumber($build);
            push @errs, "CheckBuildNumber" if !$num;

            my $dig = GetDigit($pool) if ($pool);            
            $dig
                ? my $priors = GetPriorBuildsAndState($dig)
                : push @errs, "GetPriorBuildsAndState";

            my $lastbuild = LastCompletedBuild($priors);

            my $current  = GetLabel($num);
            my $previous = GetLabel($lastbuild);
            
            if ($current =~ /(.*)(\d{1})$/) {
                my $inc = $2-1;
                $current = "$1$inc";
            }

            MoveOn( $build, @errs ) && next if (@errs);

            NewLine();
            PrintStd("For build: $num");
            PrintStd(
                "Copy Contents : sd label ovr_sporel_$previous",
                "Paste Contents: sd label ovr_sporel_$current"
            );
        }
    }
    else {
        foreach my $build (@builds) {
            my @errs;

            ## Check specifically for DB errors
            my $pool = GetPipePoolName($build);
            push @errs, "GetPipePoolName" if !$pool;
            my $num = CheckBuildNumber($build);
            push @errs, "CheckBuildNumber" if !$num;

            MoveOn( $build, @errs ) && next if (@errs);

            NewLine();
            PrintStd("$num :: $pool->{$num}");

            my $dig   = GetDigit( $pool->{$num} );
            my $label = GetLabel($num);

            PrintStd(
                "\t\%otools%\\lab\\bin\\integrate.bat to devmainlab$dig c=$changelist u=$ENV{USERNAME}",
                "\tsd label $label ## add devmain change ( $changelist ) to -i flag, unlock label",
                "\tsd labelsync -l $label <filesToUpdate>",
                "\tsd label $label ## lock label"
            );
        }
    }
}

sub LastCompletedBuild {
    my $priors = shift;
    my @builds = sort keys %$priors;

    for ( my $i = scalar @builds - 1 ; $i >= 0 ; $i-- ) {
        next unless ( $builds[$i] =~ m/\d{5}$/ );    # Avoid 4.4 sporel builds
        return $builds[$i] if ( $$priors{ $builds[$i] } =~ m/Complete/g );
    }
}

sub MoveOn {
    my ( $build, @errs ) = @_;

    NewLine();
    PrintErr(
        "Error preparing or executing SQL statement for build: \"$build\"");
    return PrintStd("\t--> Failed to call: @errs");
}

sub GetDigit { return $1 if shift =~ m/.*(\d{2})$/g; }

sub GetLabel { return "bld$1\_$2\_$3" if shift =~ m/(\d+)\.\d+\.(\d+)\.(\d+)/g; }

Main();

__END__
:exit
