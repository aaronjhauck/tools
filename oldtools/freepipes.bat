@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

# -----------------------------------------------
# Tool to collect info about pipes that are in
# use for FFD and Monolith builds and return a
# list of available pipes for scheduling a build
#
# Contact: v-aahauc
# Usage:   freepipes
# -----------------------------------------------

use strict;
use warnings;
use DBI;
use SQLUtil;

my $address  = '10.188.242.254';
my $database = 'buildexecution';
my @pipes    = (01,05,07,
                12,16,18,
                21,31,36);
my @claimed;
my @avail;

# --- SQL queries ---
my $ffds = "
SELECT SDBC.LabBranchDepotPath
FROM SDBranchClaim SDBC
WHERE SDBC.IsActive = 1
ORDER BY SDBC.LabBranchDepotPath DESC";

my $monoliths = "
SELECT P.PipeName
FROM Build B
JOIN BuildState BS ON B.BuildStateId = BS.BuildStateId
JOIN Pipe P ON B.PipeId = P.PipeId
WHERE BS.BuildStateId = 3 AND B.BuildTypeId = 1
ORDER BY P.PipeName DESC";

# --- SQL operations from SQLUtil.pm ---
my $dbh = EstablishConnection($address, $database);

my $sth = ExecuteQuery($ffds, $dbh);
while (my @row = $sth->fetchrow_array)
{
    $row[0] =~ m/(\d+)/;
    push @claimed, $1;
}
$sth->finish();

# -- Second check to ensure nothing slips through
my $vth = ExecuteQuery($monoliths, $dbh);
while (my @row = $vth->fetchrow_array)
{
    $row[0] =~ m/(\d+)/;
    push @claimed, $1 unless grep { $1 eq $_ } @claimed;
}
$vth->finish();

# --- Search for available pipes ---
my $pipeCount = scalar @pipes;

for (my $i = 0; $i < $pipeCount; $i++)
{
    my $current = $pipes[$i];
    my $result  = IsInList($current, @claimed);

    if(!$result)
    {
        push @avail, $current;
    }
}

if(!@avail) { die "There are no pipes available for scheudling!\n"; }

print "The following pipes are available for scheduling:\n";
print "Pipe$_\n" for @avail;

sub IsInList
{
    my($claimed,
       @pipeList) = @_;
    my $count     = scalar @pipeList;
    my $check     = 0;

    for(my $i = 0; $i < $count; $i++)
    {
        my $current = $pipeList[$i];

        if($current == $claimed)
	    {
            $check = 1;
        }
    }
    return $check;
}

__END__
:exit