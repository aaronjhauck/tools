use strict;
use warnings;
use Cwd;

package BatchHatch;

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

sub load {
    my $class = shift;
    my $self  = { 'name' => shift };

    bless $self, $class;
    return $self;
}

sub genFile {
    my $self = shift;
    my $lang = @_;

    my $dir  = Cwd::getcwd;
    my $file = "$dir\\$self->{'name'}.bat";

    $lang
        ? toFile( $file, $rubyText )
        : toFile( $file, $perlText );
    system("code $file");
}

sub toFile {
    my ( $file, $text ) = @_;

    die "Cannot open $file" unless open( FILE, ">", $file );
    print FILE $text;
    close(FILE);
}

1;
