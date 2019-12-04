@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib '\\\\blacklodge\\tools';

=head1 NAME

pd - Parse Diffs for devmain changes

=head1 SYNOPSIS

  pd <searchTerm>
  pd <searchTerm> -old (looks beyond current build)
  pd <searchTerm> -or  (checks tenant submissions as well)

=head1 DESCRIPTION

pd.bat greps the ChangeDiffs file share and filters for bot submissions, non-devmain
changelists, and changes older than what would be in the current build

=cut

use BLUtils;
use JsonUtils;
use Data::Dumper;
use Getopt::Long;

use constant SKIP => 1;

my $override;
my $older;
my $pattern = $ARGV[0];

GetOptions(
    "or"  => sub { $override++ },
    "old" => sub { $older++ },
);

if ( !$pattern ) {
    NewLine();
    PrintStd(
        "Usage   : pd <searchExpression>",
        "options : -or (include tenant files) -old (look back beyond one day)"
    );
    exit 0;
}

PrintStd("Searching ChangeDiffs for pattern: $pattern...");
NewLine();

my $dir = "\\\\officefile\\public\\ChangeDiffs";

chdir($dir);
opendir( DIR, $dir ) or die "Could not open $dir\n";

while ( my $filename = readdir(DIR) ) {

    #--- Only look for files that meet our criteria
    next unless ( -f "$dir/$filename" );
    next unless ( $filename =~ m/\.json$/ );

    #--- Convert json to readable perl
    my $glob = FromJsonFile($filename);
    next if ( $glob->{Bot} );    ##Skip bot changes

    #--- Locals
    my $match;
    my $change     = $glob->{Change};
    my $backout    = $glob->{Backout};
    my $submitter  = $glob->{Submitter};
    my $changedate = $glob->{ChangeDate};

    #--- Bail early if we only want latest build changes
    my $compare = $1 if $changedate =~ m/\d+\-\d+-0?(\d+).*/;
    my $latest  = OnlyInLastBuld($compare);
    unless ($older) { next if ($latest); }

    #--- Bail early if we only want devmain changes
    my $check = CheckForTenantFiles($glob);
    unless ($override) { next if ($check); }

    #--- Search for expression
    open my $in, '<', $filename or die;
    while (<$in>) {
        if ( $_ =~ m/$pattern/i ) { $match++; last; }
    }
    close $in;

    #--- Print important details if we find a match
    if ($match) {
        my @projs = GetProjectNames($glob);

        PrintStd(
            "\nChange: $change",
            "$submitter \@ $changedate",
            "Projects touched: @projs"
        );
        PrintStd("\tTHIS IS A BACKOUT") if ($backout);
        next;
    }
}

sub CheckForTenantFiles {
    my ($input) = @_;

    for my $files ( @{ $input->{ChangeFiles} } ) {
        my $filename = $files->{Filename};

        if ( $filename =~ m/devmainoverride/ ) {
            return SKIP unless ( $filename =~ m/\.meta$/ );
        }
    }
}

sub GetProjectNames {
    my ($input) = @_;
    my @projs;

    for my $files ( @{ $input->{ChangeFiles} } ) {
        my $proj = $files->{Project};

        push @projs, $proj;
    }
    return Uniq(@projs);
}

sub OnlyInLastBuld {
    my ($changedate) = @_;
    my $last = ( GetDate(q{DATE}) - 1 );

    return SKIP if ( $changedate < $last || $changedate > $last );
}

__END__
:exit
