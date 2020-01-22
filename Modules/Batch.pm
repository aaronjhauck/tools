use strict;
use warnings;
use Cwd;

package Batch;

sub load {
    my $class = shift;
    my $self  = { 
        'name' => shift,
        'text' => shift,
        };

    bless $self, $class;
    return $self;
}

sub genFile {
    my $self = shift;

    my $dir  = Cwd::getcwd;
    my $file = "$dir\\$self->{'name'}.bat";

    toFile( $file, $self->{'text'} );
    system("code $file");
}

sub toFile {
    my ( $file, $text ) = @_;

    die "Cannot open $file" unless open( FILE, ">", $file );
    print FILE $text;
    close(FILE);
}

1;
