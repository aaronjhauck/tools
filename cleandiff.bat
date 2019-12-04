@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;
use lib '\\\\blacklodge\\tools';
use BLUtils;
use Bool;

my $file = $ARGV[0];
my $o_file;

if ( Success( system("perltidy $file") ) ) {
    $o_file = "$file.tdy";
}
else {
    die PrintErr("Unable to prettify $file!");
}

if ( Success( system("code --diff $file $o_file") ) ) {
    if ( Prompt("Keep new tidy version of $file?") ) {
        NewLine();
        PrintStd("Rewritting $file with new diffs...");

        open my $ifh, '<', $o_file or die PrintErr("$o_file : $!");
        open my $ofh, '>', $file   or die PrintErr("$file : $!");

        while (<$ifh>) {
            print $ofh $_;
        }

        close $ifh;
        close $ofh;

        unlink($o_file);
    }
    else {
        NewLine();
        PrintStd( "Not overwritting $file.", "Removing $o_file" );
        unlink($o_file);
    }
}
else {
    PrintErr("Unable to fetch diff of $file and $o_file!");
}

__END__
:exit
