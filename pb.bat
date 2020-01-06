@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "C:\\src\\tools";
use PBatch;

my $obj = load PBatch($ARGV[0]);
$obj->genFile();

__END__
:exit