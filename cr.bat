@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use Cwd;

my $text = 
"\@rem = '-*- Perl -*-';
\@rem = '
\@perl\%OPERLOPT% -w %~dpnx0 %*
\@goto :exit
';

use strict;
use warnings;
use lib \"\\\\\\\\blacklodge\\\\tools\";

# for sd/depot stuff
# use lib \"\$ENV{'SRCROOT'}\\otools\\lib\\perl\";
# use Office::SD;
# use Office::Branch;

use BLUtils;
use Bool;
use BuildExeUtils;
use DBUtils;
use JsonUtils;
use OloopUtils;

__END__
:exit";

# -- Create Perl file as batch file from commandline -- #
my $dir  = getcwd;
my $file = "$dir\\$ARGV[0]";

ToFile( $file, $text );
system("code $file");

sub ToFile {
    my ( $file, $text ) = @_;

    open( my $fh, ">", $file ) or die "Cannot open $file";
    print $fh $text;
    close($fh);
}

__END__
:exit