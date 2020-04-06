@rem = '-*- Perl -*-';
@rem = '
@perl -w %~dpnx0 %*
@goto :exit
';

##---Prune.bat------------------------------##
##       Crawl git branches and offer       ##
##     to delete any that are not master    ##
##                                          ##
## Dependencies: g.bat / Bool.pm / Utils.pm ##
## Usage: prune                             ##
##------------------------------------------##

use strict;
use warnings;
use lib "$ENV{MODULES}";
use Utils;
use Bool;

#--- Switch to master ---#
system("g cm > nul 2>&1");

#--- Get list of branches ---#
my @branches = `g ab`;

#--- Loop branches, offer to remove ---#
foreach my $b (@branches) {

    # Skip master branch
    next if ( $b =~ m/\*\smaster/ );

    # Strip leading whitespace
    $b =~ s/^\s+//g;

    # Strip trailing whitespace
    $b =~ s/\s+$//g;

    if ( Prompt("Found branch: \"$b\"\nRemove? ") ) {
        unless ( Success( system("g db $b") ) ) {
            PrintErr("Unable to delete git branch: $b");
            NewLine();
        }
    }
}
system("g pl > nul 2>&1");

__END__
:exit
