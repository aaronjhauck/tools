@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :eof
';

use strict;
use warnings;
use lib '\\\\blacklodge\\tools';
use BLUtils;

=head1 NAME

qtool - Simple wrapper for BuildRequester

=head1 SYNOPSIS

  qtool -b <labBranch>
  qtool -b <labBranch> -c <cl>
  qtool -b <labBranch> -c <cl> -full -devmain -q x64,x86
  qtool -ltsb -b (lab1|lab2) -c <cl> -q chpe -debug

=head1 DESCRIPTION

qtool is a cloudbuild build requester from the command line. It accepts
devmain, retail, debug, full, cl, and several other optionns. Quickly request a
highly customizable queue of builds via batmon

=cut

use Getopt::Long;

use vars 
    qw($devmain $debug $full $ltsb $test %args $legacy $testmode @labBranches);

my $view     = "client";
my $platform = "retail";

sub Usage {
    print <<END;
Usage: qtool.bat -b branch -c changeList [options]

  options (ltsb|devmain):
  
    -b           branch   Branch to kick CloudBuild queues off at
    
                          Lab Branch   :: qtool -b labXX (eg: lab05)
                          Monthly Fork :: qtool -b XXXX  (eg: 1901)
                          
                          LTSB (main)  :: qtool -ltsb -c <change>
                          LTSB (fork)  :: qtool -ltsb -b lab1|lab2 -c <change>

    -c           change   Changelist to kick CloudBuild queues off at (If omitted: highest change is used)
    
    -full                 Request full builds with no cache used
    -q           queues   CSV: Specify specifc flavors in branch (x86,x64,Droid,etc.)
    
  options (devmain only):
  
    -debug                Request debug queue builds
    -devmain              Request devmain builds (client builds are default)
END
    exit 1;
}

sub Main {
    my $fullName;
    
    if ( GetArgs() ) {
        unless ($ltsb) {
            if ( !$args{Branch} ) {
                PrintErr("No branch defined!");
                Usage();
            }
            unless ( $args{Branch} =~ m/(lab\d{2}$|\d{4}$)/ ) {
                PrintErr("Invalid branch name: \"$args{Branch}\"");
                Usage();
            }
        }
        
        #---Get full branch name---
        $fullName = "devmain$1"    if $args{Branch} =~ m/(lab\d{2})$/;
        $fullName = "devmainlab$1" if $args{Branch} =~ m/(\d{4})$/;

        #---For minimal forks---
        $legacy = 1
          if ( $args{Branch}
            && $args{Branch} =~ m/\d{4}$/
            && $args{Branch} <= 1901 );

        #---Defaults---
        $view     = "devmain" if ($devmain);
        $platform = "debug"   if ($debug);

        #---Queue Population----
        if ( $args{Branch} ) {
            @labBranches = (
                "office${view}_${args{Branch}}_${platform}_x64",
                "office${view}_${args{Branch}}_${platform}_x86",
                "office${view}_${args{Branch}}_${platform}_chpe"
            );

            if ($devmain) {
                push @labBranches,
                  (
                    "office${view}_${args{Branch}}_debug_Arm",
                    "office${view}_${args{Branch}}_debug_Chpe",
                    "office${view}_${args{Branch}}_debug_DroidArm",
                    "office${view}_${args{Branch}}_debug_DroidX86",
                    "office${view}_${args{Branch}}_debug_X64",
                    "office${view}_${args{Branch}}_debug_X86",
                    "office${view}_${args{Branch}}_retail_DroidArm",
                    "office${view}_${args{Branch}}_retail_DroidX86",
                    "office${view}_${args{Branch}}_warehouse"
                  );
            }
            elsif ( !$legacy ) {
                push @labBranches,
                  (
                    "office${view}_${args{Branch}}_${platform}_droid",
                    "office${view}_${args{Branch}}_${platform}_arm"
                  );
            }
        }

        #---LTSB---
        if ($ltsb) {
            @labBranches = (
                "officedevltsb_retail_chpe", "officedevltsb_retail_x64",
                "officedevltsb_retail_x86",  "officedevltsb_debug_chpe",
                "officedevltsb_debug_x64",   "officedevltsb_debug_x86",
            );

            if ( $args{Branch} ) {
                if ( $args{Branch} !~ m/(lab1|lab2)/i ) {
                    PrintErr("Invalid ltsb branch name: $args{Branch}");
                    Usage();
                }

                for (@labBranches) {
                    substr( $_, 14, 0 ) = $args{Branch} . "_";
                }
            }
        }

        @labBranches = join( ',', @labBranches );

        #---If Queues Are Defined---
        my @nQueues;
        for ( @{ $args{Queues} } ) {
            if ($ltsb) {
                if ( $args{Branch} ) {
                    push @nQueues,
                      ("officedevltsb_${args{Branch}}_${platform}_$_");
                }
                else {
                    push @nQueues, ("officedevltsb_${platform}_$_");
                }
            }
            else {
                push @nQueues, ("office${view}_${args{Branch}}_${platform}_$_");
            }
        }

        @nQueues = join( ',', @nQueues );

        #---Request Builds---
        my $flags = "";

        @labBranches = @nQueues       if ( @{ $args{Queues} } );
        $flags .= " -c $args{Change}" if ( $args{Change} );
        $flags .= " -fullbuild "      if ($full);

        $testmode
          ? exit print "CB ondemand -b $fullName -bq @labBranches" . $flags 
          : exit system( "CB ondemand -b $fullName -bq @labBranches" . $flags );
    }
}

sub GetArgs {
    my $opts = GetOptions(
        "h|help|?"   => \&Usage,
        "Branch|b:s" => \&HandleScalar,
        "Queues|q:s" => \&HandleArray,
        "Change|c:s" => \&HandleScalar,
        'devmain'    => sub { $devmain++ },
        'debug'      => sub { $debug++ },
        'full'       => sub { $full++ },
        'ltsb'       => sub { $ltsb++ },
        'test'       => sub { $testmode++ }
    );
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
:eof
