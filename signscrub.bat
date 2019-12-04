@rem = '-*- Perl -*-';
@rem = '
@perl%OPERLOPT% -w %~dpnx0 %*
@goto :exit
';

use strict;
use warnings;

##########################
# NOT A WORKING TOOL YET
# DO NOT USE (8/2/19)
##########################

use lib '\\\\blacklodge\\tools';
use BLUtils;
use JSON::Parse ':all';
use File::Find;
use Cwd;

my $base_dir = getcwd;
my $start_dir = shift || '.';

my @dirs;

find( sub{
    -d $_ and push @dirs,  $File::Find::name;
}, $start_dir );

ScanDirectory($_) for @dirs;

sub ScanDirectory
{
    my ($workdir) = shift;
    return if ($workdir !~ m/ESRP/);
    chdir($workdir) or die "Unable to enter dir $workdir:$!\n";
    opendir(DIR, ".") or die "Unable to open $workdir:$!\n";
    my @names = readdir(DIR) or die "Unable to read $workdir:$!\n";
    closedir(DIR);

    foreach my $name (@names)
    {
        next if ($name eq "."); 
        next if ($name eq "..");

        next unless ($name =~ m/\.json$/);
        
        my $glob = json_file_to_perl($name);

        foreach my $deal($glob->{submissionResponses})
        {
            print $deal;
            CheckIfErrorInfo($deal);
        }
        

    }
    chdir($base_dir);
}

sub CheckIfErrorInfo
{
    my (@input) = @_;
    my @failedFiles;
    
    for (@input)
    {
        push @failedFiles, $_ if($_->{errorInfo});
    }
    return @failedFiles;
}

sub GetFileInfo
{
    my (@input) = @_;
    my @filenames;
    
    foreach my $ref(@input)
    {
        foreach my $value(@{$ref})
        {
            print $value->{fileStatusDetail}[0]->{hashType};
        }
    }
    
    return @filenames;
}

#my $filename = $_->{destinationLocation};
#$filename = $1 if $filename =~ m/.*\\(\w+\.\w+.?\w+)/;                        
#push @filenames, $filename;
__END__
:exit