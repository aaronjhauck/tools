@rem = '-*- Perl -*-';
@rem = '
@perl -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "$ENV{MODULES}";
use Utils;

# ################################
# Parse python dependencies ------
# Pass a file name or leave blank 
# to process entire directory. ---
# - aaron.hauck ------------------
# ################################

if ($ARGV[0]) {
    ParseDeps($ARGV[0]);
}
else {
    my $dirname = '.';
    opendir(DIR, $dirname) or die "Could not open $dirname\n$!";

    while ( my $fn = readdir(DIR) ) {
        next if $fn =~ /init/;
        if (-f $fn) {
            ParseDeps($fn);
        }
    }
    closedir(DIR);
}

sub ParseDeps {
    my $fn = shift;
    die "Cannot open $fn for reading : $!" unless open my $in, '<', $fn;
    
    my @imports; # Import array
    my @froms;   # From array
    while (<$in>) {
        if ($_ =~ /import\s(.*)|from\s(.*)\simport/g) {
            push @imports, $1 if $1;
            push @froms, $2 if $2;
        }
    }
    @imports = Uniq(@imports); # Obtain only 
    @froms   = Uniq(@froms);   # unique entries

    return if (!@imports && !@froms);

    PrintStd("\t$fn dependencies:");
    NewLine();
    PrintStd("IMPORT:");
    FormatList(@imports);
    NewLine();
    PrintStd("FROM:");
    FormatList(@froms);
    NewLine();
    close $in;
}
__END__
:exit