@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use lib "$ENV{'SRCROOT'}\\otools\\lib\\perl";
use lib '\\\\blacklodge\\tools';
use warnings;
use strict;
use BLUtils;
use Office::SD;

=head1 NAME

minchange - Bump min change for an FFD 

=head1 SYNOPSIS

   minchange -c <clToBumpTo> -f <forkToBump>

=head1 DESCRIPTION

Instead of sd editing bulk core XMLs, just call minchange with a change to
rev to and a fork to rev. You can call this from anywhere in an office 
enlistment and the tool will edit the core XMLs for the specified fork. 
It will then validate the XMLs and ask you if you'd like to submit a 
changelist after it creates one with a description for you.

=cut

use Getopt::Long;

chdir("$ENV{'SRCROOT'}\\collateral\\oloop\\cross\\cross\\x\-none") or die $!;

my $usage = <<END
Usage: minchange.bat -f forkNumber -c changeList
  options:
    -c           number   Required: CL number to update
    -f           number   Specify FFD fork number
END
  ;

#---- Get Arguments -------------

my %opts;
my @files;
my $help;
my $legacy;

GetOptions(
    "f:s" => \$opts{fork},
    "c:s" => \$opts{cl},
    "h"   => \$help
);

#---- Check Sanity -------------

die $usage if ($help);

if ( $opts{fork} =~ m/^[A-Za-z]*(\d{5,6})$/ ) {
    if    ( length($1) == 5 ) { $opts{fork} = "FFD$1"; }
    elsif ( length($1) == 6 ) { $opts{fork} = "FF$1"; }
}
else {
    die "Malformed fork number!\n\n$usage";
}

if ( length( $opts{cl} ) < 8 ) {
    die "$opts{cl} does not appear to be a valid change!\n\n$usage";
}

die $usage if ( $opts{cl} && !$opts{fork} || $opts{fork} && !$opts{cl} );

my $number = $1 if $opts{fork} =~ m/\w{3}(\d+)/;
$legacy++ if ( $number <= 11328 );

@files = (
    "${\$opts{fork}}_CoreX64.xml",  "${\$opts{fork}}_CoreX86.xml",
    "${\$opts{fork}}_CoreChpe.xml", "${\$opts{fork}}_CoreCheckpoint.xml",
);

push @files,
  (
    "${\$opts{fork}}_CoreCBWaypoint.xml",
    "${\$opts{fork}}_CoreDroid.xml",
    "${\$opts{fork}}_CoreArm.xml",
  ) if !$legacy;

#--- Sync XMLS ---

system("sd sync $_") for @files;

#---- Edit XMLs -------------

foreach my $file (@files) {
    open my $in, '<', 
      $file || die "Cannot open $file for reading : $!.\n";
    open my $out, '>',
      "$file.new" || die "Cannot open $file.new for writing : $!.\n";

    print `sd edit $file`;

    while (<$in>) {
        $_ =~ s/(MinimumChangeList=)\"\d+\"/${1}"$opts{cl}"/;
        print $out $_;
    }

    close $in;
    close $out;

    rename( "$file.new", $file );
}

#---- Validate XMLs -------------

print "Updated files, calling validate.bat...\n\n";
my $f = join( ' ', @files );
system("validate.bat $f -noprintvalid");
if ( $? != 0 ) { die "Failed to validate files"; }

#---- Create Changelist ----------

my $opened  = `sd opened ...`;
my @clFiles = $opened =~ /(\/\/[^\s]+)\s/g;

my $description = <<DESC
($ENV{'USERNAME'}) Bumping minimum changelist number to ${\$opts{cl}} for ${\$opts{fork}}
oloop validation passed
code review will be done later

change generated by minchange.bat
DESC
  ;

print `sdvdiff -lo`;

if ( Prompt("Create new changelist?") ) {
    NewLine();
    my $cl = SDNewChange( $description, @clFiles );
    PrintStd( "New changelist created",
        "Please review CL $cl and then run: sd submit -c $cl" );
    NewLine();
}
else {
    NewLine();
    PrintStd("The following files are still open:");
    FormatList(@clFiles);
    PrintStd("Must manually create and submit changelist!");
    exit 0;
}

__END__
:exit