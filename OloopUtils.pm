package OloopUtils;

=head1 NAME

OloopUtils - Common Oloop queries to be used in perl

=head1 SYNOPSIS

    use OloopUtils
    
=head1 AUTHOR

Aaron Hauck (v-aahauc)

=cut

use strict;
use warnings;
use DBUtils;
require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(
  GetForkGroupMachineState
  IsChangeInBuild
  GetFriendlyNameFromDepotPath
  GetDepotPathFromFriendlyName
  GetBuildsFromFriendlyName
);

BEGIN {
    $DBUtils::address  = "pi-sqlhost-01";
    $DBUtils::database = "oloop";
    $DBUtils::uid      = "oloop_ro";
    $DBUtils::passwd   = "oloop_ro";
}

#
# GetForkGroupMachineState - Returns ref of loop machine states
#
# GetForkGroupMachineState(@buildGroups)
#
#   %result = (
#       'LoopName1' => 'StateName1'
#       'LoopName2' => 'StateName2'
#       ...
#   );
#
sub GetForkGroupMachineState {
    my $fork = shift;
    my %result;

    my $query = "
    SELECT L.LoopName, LM.State
    FROM BuildGroups BG
    JOIN Loops L ON BG.BuildGroupID = L.BuildGroupID
    JOIN Loop_Machines LM ON L.LoopID = LM.LoopID
    WHERE BG.BuildGroupName = '$fork'
    AND LM.State != 'Removed'";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $result{ $row[0] } = $row[1];
    }
    $sth->finish();

    %result ? return \%result : return undef;
}
#
# IsChangeInBuild - Returns true or false if change is in specific build number
#
# IsChangeInBuild($change,$buildNumber)
#
#   $result = Y|N;
#
sub IsChangeInBuild {
    my ( $change, $buildNumber ) = @_;
    my $result;

    my $query = "
    SELECT DISTINCT LI.BuildNumber
    FROM LoopIterations LI
    WHERE LI.IncludedChanges LIKE '\%$change\%' 
    AND LI.BuildNumber LIKE '$buildNumber'";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $result = $row[0] if $row[0];
    }
    $sth->finish();

    $result ? 1 : 0;
}
#
# GetFriendlyNameFromDepotPath - Returns oloop build group friendly name from depot shorthand
#
# GetFriendlyNameFromDepotPath(@depotpaths)
#
#   @result = (
#       FFD123456
#       FFD789101
#       ...
#   );
#
sub GetFriendlyNameFromDepotPath {
  my $depotpath = shift;
  my $result;
  
  my $query = "
  SELECT TOP 1 BG.BuildGroupName
  FROM BuildGroups BG
  JOIN BuildGroupDepotPaths BGDP ON BGDP.BuildGroupID = BG.BuildGroupID
  WHERE BGDP.DepotPath LIKE '\%$depotpath\%' 
  AND BG.OwnerEmail LIKE '\%oloop\%' 
  ORDER BY BG.BuildGroupID DESC";
  
  my $sth = UseDB($query)
    or return undef;

  while ( my @row = $sth->fetchrow_array ) {
      $result = $row[0] if $row[0];
  }
  $sth->finish();

  $result ? return $result : return undef;
}
#
# GetDepotPathFromFriendlyName - Returns depot path from oloop friendly name
#
# GetDepotPathFromFriendlyName(@friendlyNames)
#
#   @result = (
#       devmainlabxxxx
#       devmainlabxxxx
#       ...
#   );
#
sub GetDepotPathFromFriendlyName {
  my $friendlyName = shift;
  my $result;
  
  my $query = "
  SELECT TOP 1 BGDP.DepotPath
  FROM BuildGroups BG
  JOIN BuildGroupDepotPaths BGDP ON BGDP.BuildGroupID = BG.BuildGroupID
  WHERE BG.BuildGroupName LIKE '\%$friendlyName\%'
  ORDER BY BG.BuildGroupID DESC";
  
  my $sth = UseDB($query)
    or return undef;

  while ( my @row = $sth->fetchrow_array ) {
      $result = $row[0] if $row[0];
  }
  $sth->finish();

  $result ? return $result : return undef;
}
#
# GetBuildsFromFriendlyName - Returns all builds associated with friendly name
#
# GetBuildsFromFriendlyName(@depotpaths)
#
#   @result = (
#       16.0.12201.20000
#       16.0.12201.20002
#       ...
#   );
#
sub GetBuildsFromFriendlyName {
  my $friendlyName = shift;
  my @builds;
  
  my $query = "
  SELECT DISTINCT LI.BuildNumber
  FROM BuildGroups BG
  JOIN Loops L ON BG.BuildGroupID = L.BuildGroupID
  JOIN LoopIterations LI ON L.LoopID = LI.LoopID
  WHERE BG.BuildGroupName = '$friendlyName'
  AND LI.BuildNumber IS NOT NULL
  ORDER BY LI.BuildNumber ASC";
  
  my $sth = UseDB($query)
    or return undef;

  while ( my @row = $sth->fetchrow_array ) {
      push @builds, $row[0];
  }
  $sth->finish();

  @builds ? return @builds : return undef;
}
1;
