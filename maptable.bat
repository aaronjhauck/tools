@rem = '-*- Perl -*-';
@rem = '
@perl -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "$ENV{MODULES}";
use Utils;

my @untracked = `git ls-files --exclude-standard --others`;
@untracked = map { s/\//\\/g; $_ } @untracked;
@untracked = map { s/(.*)/\<Build Include\=\"$1\" \/\>/; $_ } @untracked;

my $dirname = '.';
my $sqlproj;

die "cannot open $dirname\n$!" unless opendir(DIR, $dirname);
while (my $fn = readdir(DIR)) { $sqlproj = $fn if $fn =~ m/.*\.sqlproj$/; }

# --- edit sqlproj ---
open my $in, '<', $sqlproj || die "cannot open $sqlproj for reading : $!";
open my $out, '>', "$sqlproj.new" || die "cannot open $sqlproj.new for writing : $!";

while (<$in>) {
    if ($_ =~ m/Build\sInclude/g) {
        print $out @untracked;
        last;
    }
    print $out $_;
}

close $in;
close $out;

__END__
:exit