package Bool;

=head1 NAME

Bool - Boolean replies for perl

=head1 SYNOPSIS
    use Bool
    
=head1 AUTHOR

Aaron Hauck (v-aahauc)

=cut

use strict;
use warnings;
require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(
    Success 
    Failure
);

use constant {
    TRUE  => 0,
    FALSE => 1
};

sub Success { return ( shift == TRUE )  ? 1 : 0; }
sub Failure { return ( shift == FALSE ) ? 1 : 0; }

1;
