@rem = '-*- Perl -*-';
@rem = '
@perl -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib "$ENV{MODULES}";
use Utils;
use Batch;

sub Usage {
    print <<EOM;
alias attempts to mimic the Unix ALIAS command 
    usage: alias <newAlias> <commonCommand>

ex: alias lightsoff shutdown /r /m \\\\%COMPUTERNAME\%
EOM
    exit 1;
}

my $new = $ARGV[0];           # get name of new alias
shift @ARGV;                  # grab whatever is left in the prompt
die Usage() if ( !@ARGV );    # die if there is no command to alias

my $dir  = "$ENV{ALIASDIR}";
my $file = "$dir\\$new.bat";
my $text = "\@ECHO OFF\n@ARGV\n";

for (@ARGV) { $text = "\@ECHO OFF\ncall @ARGV\n" if ( $_ =~ m/\.exe/ ) }

if (-e $file) {
    my $contents = `type $file`;
    PrintStd ("Found existing alias for \"$new\"",
              "Alias currently contains: $contents");

    Prompt("Overwrite \"$new\"?")
        ? unlink $file
        : die "Choose a different name from \"$new\" and try again";
}

my $alias = load Batch( $new, $text, $dir );
$alias->genFile();

PrintLine("Saved. Alias => \"$new\"\n\n$text");
__END__
:exit
