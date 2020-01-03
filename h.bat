@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "C:\\src\\tools";

use Honk;

my $obj = load Honk("Aaron",31);

print $obj->intro();

__END__
:exit