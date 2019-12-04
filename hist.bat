@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :eof
';

use strict;
use warnings;

=head1 NAME

hist - Shortcut SDV tool for Source Depot

=head1 SYNOPSIS

   lookup devmain    - hist otools deps
   lookup lab branch - hist devmainlabxx otools deps
   lookup sporel     - hist sporel otools deps
   lookup ltsb       - hist devltsb(lab1|lab2) otools deps
   lookup filename   - hist otools deps some.file

=head1 DESCRIPTION

A shortcut around typing full depot paths when wanting to browse Source Depot
paths or files. Devmain is default - first argument in command line will
also accept devmainlabxx, sporel, or ltsb

=cut

my @projs   = @ARGV;
my $sBranch = $ARGV[0];
my $branch  = "devmain";

if ( $sBranch && $sBranch =~ /(dev*|sporel)/i ) {
    shift @projs;
    $branch = $sBranch;

    $branch = "devmainoverride/sporel"
      if ( $sBranch =~ /sporel/i );
}

if ( $projs[-1] && $projs[-1] =~ /\w+\.\.*/i ) {
    my $file = pop(@projs);
    my $path = join( '/', @projs );

    exit system("start sdv //depot/$branch/$path/$file");
}

my $path = join( '/', @projs );

$path
  ? exit system("sdv.cmd //depot/$branch/$path/...")
  : exit system("sdv.cmd //depot/$branch/...");

__END__
:eof
