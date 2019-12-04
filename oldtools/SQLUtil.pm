package SQLUtil;

use strict;
use warnings;
use DBI;

use Exporter qw(import);
our @ISA = qw(Exporter);
our @EXPORT = qw(EstablishConnection ExecuteQuery);

sub EstablishConnection
{
    my ($address, $database) = @_;

    my $DSN      = "Driver={SQL Server};
                    Server=$address;
                    Database=$database;
                    Trusted_Connection=Yes;";

    my $dbh      = DBI->connect("dbi:ODBC:$DSN",
                    {RaiseError => 1})
                    or die "Couldn't connect to database: " . DBI->errstr;

    return $dbh;
}

sub ExecuteQuery
{
    my ($query, $dbh) = @_;
    my @results;

    my $sth = $dbh->prepare($query);
    $sth->execute();

    return $sth;
}