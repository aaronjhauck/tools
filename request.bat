@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;

=head1 NAME

request - Request new oloop machines

=head1 SYNOPSIS

   request -f <forkNumber> -l <loopNames>

=head1 DESCRIPTION

Mildly useful shortcut to request new machines for multiple loops at one. Not
a great tool, very little output if something is wrong. Probably not worth using 
even once. -a to print a list of loops you can pass via CSV to the -l flag.

=cut

use Getopt::Long;

my $forkNumber;
my @machines;
my @loops;
my $help;
my $available;

GetOptions("f:s"    => \$forkNumber,
           "l:s"    => \@loops,
           "help|h" => \$help,
           "a"      => \$available);

my $usage = <<END
Usage: request.bat -f ForkNumber -l Loops
    -f  number  Specify FFD fork number to request agaisnt
    -l  name    CSV of loop names

Example: request.bat -f 11501 -l C2RX64,C2RX86,C2RAutomation

    Use "request.bat -a" to see full list of machines for request
END
;

my $list = <<DESC
Loop machines available to be requested for monthly/daily forks:

Android
AndroidAutomation
BBCheckpoint
C2RAutomation
C2RX64
C2RX86
CentennialAutomation
CoreArm
CoreCheckpoint
CoreChpe
CoreDroidArm
CoreDroidX86
CoreX64
CoreX86
ReleaseAutomation
Universal
UniversalAutomation
DESC
;

#--- Check arguments are sane ---
if ($available) { die $list; }
if ($help || !$forkNumber) { die $usage; }
if ($forkNumber && !@loops){ die "-f requires -l\n\n $usage"; }
if (!$forkNumber && @loops){ die "-l requires -f\n\n $usage"; }

if ($forkNumber =~ m/^[A-Za-z]*(\d{5,6})$/)
{
    if    (length($1) == 5) { $forkNumber = "FFD$1"; }
    elsif (length($1) == 6) { $forkNumber = "FF$1";  }
}

#--- Assemble the list ---
@loops = split(/,/,join(',', @loops));

for (@loops)
{
    push @machines,
    (
        "${forkNumber}_${_}"
    );
}

#--- Request the machines ---
foreach my $mac (@machines)
{
    my $ps  = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe';
    my $uri = "http://oloop/api/BuildGroupAPI/NewMachine/$mac";
    my $cmd = "Invoke-RestMethod -Uri $uri -Method Get -UseDefaultCredentials";

    print "Requesting a new machine for $mac ...\n";
    print `$ps -command $cmd`;
}

__END__
:exit