use strict;
use warnings;

package Honk;

sub load{

    my $class = shift;

    my $self = {
        'name' => shift,
        'age' => shift
    };

    bless $self, $class;

    return $self;
}

sub intro {
    my $self = shift;
    
    my $string = "$self->{'name'} is $self->{'age'} years old\n";

    return $string;
}

1;