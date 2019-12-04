package JsonUtils;

use strict;
use warnings;
require Exporter;

use JSON     ();
use JSON::PP ();

our @ISA    = qw(Exporter);
our @EXPORT = qw (
  FromJsonText
  FromJsonFile
  ToJsonText
  ToJsonFile
);

sub FromJsonText {
    return JSON::from_json( shift(@_) );
}

sub FromJsonFile {
    my ($file) = @_;
    local $/ = undef;

    open( my $fh, "<", $file ) or die "Cannot open $file";
    my $contents = <$fh>;
    close($fh);

    $contents =~ s/^\xEF\xBB\xBF//;
    return JSON::from_json($contents);
}

sub ToJsonText {
    my ( $data, $opts ) = @_;

    $opts->{'canonical'} = 1 if !exists( $opts->{'canonical'} );
    $opts->{'pretty'}    = 1 if !exists( $opts->{'pretty'} );

    return JSON::to_json( $data, $opts );
}

sub ToJsonFile {
    my ( $file, $data, $rhJsonOptions ) = @_;

    my $text = ToJsonText( $data, $rhJsonOptions );
    ToFile( $file, $text );
}

sub ToFile {
    my ( $file, $text ) = @_;

    open( my $fh, ">", $file ) or die "Cannot open $file";
    print $fh $text;
    close($fh);
}

1;
