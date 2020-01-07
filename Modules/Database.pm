package Database;

use strict;
use warnings;
use DBI;
require Exporter;

our @ISA    = qw(Exporter);
our @EXPORT = qw(
  EstablishConnection
  ExecuteQuery
  UseDB
  UseDBWithCreds
);

use vars qw ($address $database $uid $passwd);

# --- Database Transactions ---
sub EstablishConnection {
    my ( $address, $database ) = @_;

    my $dsn = "Driver={SQL Server};
               Server=$address;
               Database=$database;";

    $dsn .= "Trusted_Connection=Yes" if ( !$uid );

    my $dbh = DBI->connect( "dbi:ODBC:$dsn", $uid, $passwd )
      or DieWithDBError( "Could not connect to database", $DBI::errstr );

    return $dbh;
}

sub ExecuteQuery {
    my ( $query, $dbh ) = @_;

    my $sth = $dbh->prepare($query)
      or DieWithDBError( "Failed to prepare SQL statement", $DBI::errstr );

    $sth->execute()
      or DieWithDBError( "Failled to execute SQL statement", $DBI::errstr );

    return $sth;
}

sub UseDB {
    my ($query) = @_;

    my $dbh = EstablishConnection( $address, $database );
    my $sth = ExecuteQuery( $query, $dbh );

    return $sth;
}

sub DieWithDBError {
    my ( $input, $error ) = @_;

    die "$input : $error\n";
}

1;