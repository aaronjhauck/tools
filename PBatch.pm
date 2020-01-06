use strict;
use warnings;
use Cwd;

package PBatch;

my $text = 
"\@rem = '-*- Perl -*-';
\@rem = '
\@perl\%OPERLOPT% -w %~dpnx0 %*
\@goto :exit
';

use strict;
use warnings;


__END__
:exit";

sub load {
    my $class = shift;
    my $self = { 'name' => shift };

    bless $self, $class;
    return $self;
}

sub genFile {
    my $self = shift;

    my $dir  = Cwd::getcwd;
    my $file = "$dir\\$self->{'name'}";

    toFile( $file, $text );
    system("code $file");
}

sub toFile {
    my ( $file, $text ) = @_;

    open( my $fh, ">", $file ) or die "Cannot open $file";
    print $fh $text;
    close($fh);
}

1;