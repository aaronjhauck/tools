@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "$ENV{MODULES}";
use Batch;

my $perlText = 
"\@rem = '-*- Perl -*-';
\@rem = '
\@perl -w %~dpnx0 %*
\@goto :exit
';

use strict;
use warnings;
use lib \"\$ENV{MODULES}\";


__END__
:exit";

my $rubyText = 
"\@rem = '-*- Ruby -*-';
\@rem = '
\@ruby -w %~dpnx0 %*
\@goto :endofruby
';


__END__
:endofruby";

my $lang = $perlText;
$lang    = $rubyText if $ARGV[1] =~ "r";

my $obj  = load Batch($ARGV[0], $lang);

$obj->genFile();

__END__
:exit