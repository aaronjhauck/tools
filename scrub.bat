@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;

use lib '\\\\blacklodge\\tools';
use Getopt::Long;
use BLUtils;

=head1 NAME

scrub - grep RESULTS.LOG for failed projects, exports, and cultures

=head1 SYNOPSIS

   scrub -p <path>

=head1 DESCRIPTION

Paste a path for any non-domnio enabled failed build. Returns failed projects,
exports, cultures, and a formatted preamble for manual rebuilds.

=cut

my $help;
my $path;
my $context;
my @cultures;
my @proj;

my $usage = <<END
usage : scrub.bat -p <path to failed task>

ex    : scrub.bat -p \\\\daddev\\office\\15.0\\5155.1000\\logs\\BFREarlyCoreX86ShipNonBVTCultures\\OhomeBuild.2019-06-19-14-43-39
END
  ;

#---Assemble Details---#
GetOptions(
    "p:s"    => \$path,
    "h|help" => \$help
);

die $usage if ( !$path || $help );

my $log = "$path" . "\\RESULTS.LOG";

my $task    = $1 if $path =~ m/.*(BFR\w+).*/;
my $subTask = $1 if $path =~ m/.*(Ohome\w+).*/;

#---Get failed projects/exports/cultures---#
open my $in, '<', $log or die "Cannot open $log for reading : $!.\n";

while (<$in>) {
    if ( $_ =~ m/export\s(\w+).*/ || m/build\s(\w+).*/ ) {
        if ( $_ !~ m/\score\s/ ) {
            push( @proj, $1 );
        }
    }

    if ( $_ =~ m/export.*(\w{2}-\w{2,3}.?(\w+)?).*/ ) {
        push( @cultures, $1 );
    }
}

close $in;

#---Get only distinct projects/cultures---#
@proj     = Uniq(@proj);
@cultures = Uniq(@cultures);

#---Display list of failures---#
die "No failed projects! Check your -p flag and try again\n\n$usage"
  if ( !@proj );

PrintStd("\n\tFAILED PROJECTS:");
FormatList(@proj);

print "\n\tFAILED CULTURES:\n";
FormatList(@cultures);

my $taskflag;

$task 
  ? ($taskflag = "-task $task:$subTask")
  : ($taskflag = "");

PrintStd("\n\tPREAMBLE:\n");
@cultures
  ? PrintStd(
"\%otools\%\\lab\\bin\\buildprojects -builder $ENV{'USERNAME'} -p @proj -l @cultures " . $taskflag
  )
  : PrintStd(
"\%otools\%\\lab\\bin\\buildprojects -builder $ENV{'USERNAME'} -p @proj " . $taskflag
  );
__END__
:exit
