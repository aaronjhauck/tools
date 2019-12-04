package BuildExeUtils;

=head1 NAME

BuildExeUtils - Common BuildExecution queries to be used in perl

=head1 SYNOPSIS

    use BuildExeUtils
    
=head1 AUTHOR

Aaron Hauck (v-aahauc)

=cut

use strict;
use warnings;
use DBUtils;
require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(
  CheckBuildNumber
  GetPipePoolName
  GetPriorBuildsAndState
  GetBFMsFromPipeName
  GetJobIdFromBuildNumber
  GetMachinesFromBuildNumber
  IsMachineActive
  GetPipeName
);

#
# CheckBuildNumber - Normalizes build numbers for devmain, dev16, forks, etc.
#
# CheckBuildNumber($minorHighBuildNumber)
#
#   $num = "some.qualified.build.number";
#
sub CheckBuildNumber {
    my ($build) = @_;

    my $num = "16.0.$build.10000";

    if ( length($build) == 4 )  { $num = "16.0.$build.1000"; }     #dev16
    if ( $build > 19000 )       { $num = "16.0.$build.12000"; }    #sporel
    if ( $build =~ /\d+\.\d+/ ) { $num = "16.0.$build"; }          #fork

    return $num;
}
#
# GetPipePoolName - Returns ref of pipepool friendly names
#
# GetPipePoolName(@builds)
#
#   %result = (
#       'BuildNumber1' => 'PipePoolName1'
#       'BuildNumber2' => 'PipePoolName2'
#       ...
#   );
#
sub GetPipePoolName {
    my ($build) = @_;
    my %result;

    my $num = CheckBuildNumber($build);

    # --- Query ---
    my $query = "
    SELECT PP.PipePoolName
    FROM Build B
    JOIN PipePool PP ON B.PipePoolId = PP.PipePoolId
    WHERE B.BuildNumber = '$num'";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $result{$num} = $row[0];
    }
    $sth->finish();

    %result ? return \%result : return undef;
}
#
# GetPipeName - Returns unfriendly pipe names
#
# GetPipeName(@builds)
#
#   $pipe = (
#       'Pipe1'
#       'Pipe2'
#       ...
#   );
#
sub GetPipeName {
    my ($build) = @_;
    my $pipe;

    my $num = CheckBuildNumber($build);

    # --- Query ---
    my $query = "
    SELECT P.PipeName, B.BuildNumber
    FROM   Build B
    JOIN   Pipe P 
           ON B.PipeId = P.PipeId
    WHERE  B.BuildNumber = '$num'";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $pipe = $row[0];
    }
    $sth->finish();

    $pipe ? return $pipe : return undef;
}
#
# GetPriorBuildsAndState - Return ref of build number->build state for last two months
#
# GetPriorBuildsAndState($pipeNumber)
#
#     %result = (
#       'Build' => 'State'
#       'Build' => 'State'
#       ...
#     );
#
sub GetPriorBuildsAndState {
    my ($pipe) = @_;
    my %result;
    $pipe = "Pipe$pipe";

    # --- Query ---
    my $query = "
    SELECT B.BuildNumber, BS.BuildStateName, B.BuildId
    FROM   Build B
    JOIN   Pipe P 
           ON B.PipeId = P.PipeId
    JOIN   BuildState BS 
           ON B.BuildStateId = BS.BuildStateId
    WHERE  P.PipeName = '$pipe'
    AND    B.DateStarted >= DATEADD(dd,-60,CONVERT(datetime,CONVERT(nvarchar(11),GETDATE())))
    ORDER  BY B.BuildId ASC";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        if ( $row[0] !~ /\.12\d{2}$/ ) {    # avoid sporel 4.4 builds
            $result{ $row[0] } = $row[1];
        }
    }
    $sth->finish();

    %result ? return \%result : return undef;
}
#
# GetBFMsFromPipeName - Return ref of bfm name => role
#
# GetBFMsFromPipeName($pipeNumber)
#
#     %result = (
#       'BFM1' => 'Role'
#       'BFM2' => 'Role'
#       ...
#     );
#
sub GetBFMsFromPipeName {
    my ($pipe) = @_;
    my %result;
    $pipe = "O16PipePool$pipe";

    # --- Query ---
    my $query = "
    SELECT		DISTINCT M.MachineName,
                MRC.MachineRoleCategoryName
    FROM		Machine M
    INNER JOIN  PipePoolMachine PPM
                ON M.MachineId = PPM.MachineId
    INNER JOIN	MachineRole MR
                ON MR.MachineRoleId = PPM.MachineRoleId
    INNER JOIN	MachineRoleCategory MRC
                ON MRC.MachineRoleCategoryId = MR.MachineRoleCategoryId
    INNER JOIN  PipePool PP
                ON PPM.PipePoolId = PP.PipePoolId
    WHERE		PP.PipePoolName = '$pipe'
                AND PPM.IsActive = 1
                AND M.MachineName NOT LIKE '\%OOM%'
                AND M.MachineName NOT LIKE '\%LOOP%'
                AND MRC.MachineRoleCategoryName NOT IN ('Archive',
                                                        'Shadow', 
                                                        'Retention')
    ORDER BY M.MachineName ASC";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $result{ $row[0] } = $row[1];
    }
    $sth->finish();

    %result ? return \%result : return undef;
}
#
# GetJobIdFromBuildNumber - Returns job id variable from build number
#
# GetJobIdFromBuildNumber($buildNumber)
#
#     $jobID = [int];
#
sub GetJobIdFromBuildNumber {
    my ($num) = @_;
    my $jobid;

    # --- Query ---
    my $query = "
    SELECT     J.JobId
    FROM       Build B
    INNER JOIN BuildJob BJ 
            ON B.BuildId = BJ.BuildId
    INNER JOIN Job J 
            ON BJ.JobId = J.JobId
    WHERE      B.BuildNumber = '$num'";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $jobid = $row[0];
    }
    $sth->finish();

    return $jobid;
}
#
# GetMachinesFromBuildNumber - Return ref of machine name => role
#
# GetMachinesFromBuildNumber($buildNumber)
#
#     %result = (
#       'MAC1' => 'Role'
#       'MAC2' => 'Role'
#       ...
#     );
#
sub GetMachinesFromBuildNumber {
    my ($build) = @_;
    my %result;

    my $num = CheckBuildNumber($build);

    my $jobid = GetJobIdFromBuildNumber($num)
      or return undef;

    # --- Query ---
    my $query = "
    SELECT		M.MachineName,
                MRC.MachineRoleCategoryName
    FROM		Machine M
    INNER JOIN	ActiveBuildMachine ABM
                ON ABM.MachineId = M.MachineId
    INNER JOIN	MachineRole MR
                ON MR.MachineRoleId = ABM.MachineRoleId
    INNER JOIN	MachineRoleCategory MRC
                ON MRC.MachineRoleCategoryId = MR.MachineRoleCategoryId
    WHERE		ABM.JobId = $jobid
                AND ABM.IsActive = 1
    ORDER BY MRC.MachineRoleCategoryId DESC";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $result{ $row[0] } = $row[1];
    }
    $sth->finish();

    %result ? return \%result : return undef;
}
#
# IsMachineActive - Return a build number from machine name if in use
#
# IsMachineActive($machinename)
#
#     $build = (
#       some.qualified.build.number,
#       another.qualified.build.number
#       ...
#     );
#
sub IsMachineActive {
    my ($machine) = @_;
    my $build;

    my $query = "
    SELECT ABM.IsActive, B.BuildNumber
    FROM ActiveBuildMachine ABM
    JOIN BuildJob BJ ON ABM.JobId = BJ.JobId
    JOIN Build B ON BJ.BuildId = B.BuildId
    JOIN Machine M ON ABM.MachineId = M.MachineId
    WHERE M.MachineName = '$machine'
    AND ABM.IsActive = 1";

    my $sth = UseDB($query)
      or return undef;

    while ( my @row = $sth->fetchrow_array ) {
        $build = $row[1] if ( $row[0] );
    }

    $build ? return $build : return undef;
}

1;
