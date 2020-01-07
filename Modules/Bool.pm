package Bool;

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
