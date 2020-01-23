use strict;
use warnings;

package Batch;

sub load {
    my $class = shift;
    my $self  = { 
        'name' => shift,
        'text' => shift,
        'dir'  => shift,
        };

    bless $self, $class;
    return $self;
}

sub genFile {
    my $self = shift;

    my $dir  = $self->{'dir'};
    my $file = "$dir\\$self->{'name'}.bat";

    toFile( $file, $self->{'text'} );
    return $file;
}

sub toFile {
    my ( $file, $text ) = @_;

    die "Cannot open $file" unless open( FILE, ">", $file );
    print FILE $text;
    close(FILE);
}

1;
