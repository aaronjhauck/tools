package BLUtils;

use strict;
use warnings;
use Data::Dumper;
require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(
  PrintStd
  PrintWrn
  PrintErr
  FormatList
  NewLine
  SplitCSV
  PrintKV
  PrettyPrint
  Uniq
  Prompt
  GetDate
);

# --- Formatting ---
sub PrintStd   { print map { ( $_, "\n" ) } @_; }
sub PrintWrn   { print "Warning: ", map { ( $_, "\n" ) } @_; }
sub PrintErr   { print "Error: ", map { ( $_, "\n" ) } @_; }
sub FormatList { print "$_\n" for @_; }
sub NewLine    { $_[0] ? print "\n" x $_[0] : print "\n"; }
sub SplitCSV   { split( /,/, join( ',', @_ ) ); }

sub PrintKV { 
    my %hash = @_;
    
    PrintStd("\"$_\" => \"$hash{$_}\"") for (keys %hash);
}

sub PrettyPrint {
    $Data::Dumper::Terse      = 1;
    $Data::Dumper::Useqq      = 1;
    $Data::Dumper::Indent     = 1;
    $Data::Dumper::Deparse    = 1;
    $Data::Dumper::Sortkeys   = 1;
    $Data::Dumper::Quotekeys  = 0;
    $Data::Dumper::Sparseseen = 1;

    print Dumper(shift);
}

sub Uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}

# --- Misc ---
sub Prompt {
    print shift . ": ";

    chop( my $input = lc(<STDIN>) );
    return $input eq 'y' ? 1 : 0;
}

# --- Date/Time Function ---
sub GetDate {
    my ($sel) = shift;
    
    my ( $sec, $min, $hour, 
        $mday, $mon, $year, 
        $wday, $yday, $isdst ) = localtime(time);
    $year += 1900;

    my @mos  = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    my @days = qw(Sun Mon Tues Weds Thurs Fri Sat);

    my @list = ( $days[$wday], $mos[$mon], $mday, $year );
    if ($sel) {
        if    ( $sel =~ m/day/i )  { return $list[0]; }
        elsif ( $sel =~ m/mon/i )  { return $list[1]; }
        elsif ( $sel =~ m/date/i ) { return $list[2]; }
        elsif ( $sel =~ m/year/i ) { return $list[3]; }
    }
    @list = join( " ", @list );
    return @list;
}

1;
