@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "$ENV{MODULES}";
use BatchHatch;

my $obj = load BatchHatch($ARGV[0]);

$ARGV[1] && $ARGV[1] =~ "r"
    ? $obj->genFile(1)
    : $obj->genFile();

__END__
:exit