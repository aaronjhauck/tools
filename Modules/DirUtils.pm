package DirUtils;

use strict;
use warnings;
require Exporter;

use File::Copy ();
use File::Path ();

our @ISA    = qw(Exporter);
our @EXPORT = qw (
  copyfile
  movefile
  createdirs
  nukedirs
);

sub copyfile {
    my ( $in, $out ) = @_;

    die "Copy failed! $!" unless File::Copy::copy( $in, $out );
}

sub movefile {
    my ( $old, $new ) = @_;

    if ( -d $new ) {
        print "$new is a directory - moving $old there";
        File::Copy::move( $old, $new );
    }
    elsif ( -f $new ) {
        print "Renaming $old to $new";
        File::Copy::move( $old, $new );
    }
    else {
        File::Copy::move( $old, $new );
    }
}

sub createdirs {
    my @created;
    return @created = File::Path::make_path(@_);
}

sub nukedirs {
    my $removed;
    return $removed = File::Path::remove_tree(@_);
}

1;
