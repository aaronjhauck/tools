@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "$ENV{MODULES}";
use Batch;
use Cwd;
use Getopt::Long;
use vars qw/$ruby/;

GetOptions( 'r' => sub { $ruby++ } );

my %languages;

$languages{'perlText'} = 
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

$languages{'rubyText'} = 
"\@rem = '-*- Ruby -*-';
\@rem = '
\@ruby -w %~dpnx0 %*
\@goto :endofruby
';


__END__
:endofruby";

my $lang;

$ruby
    ? ( $lang = $languages{'rubyText'} )
    : ( $lang = $languages{'perlText'} );

my $obj = load Batch( $ARGV[0], $lang, Cwd::getcwd );

my $file = $obj->genFile();

system("code $file");

__END__
:exit
