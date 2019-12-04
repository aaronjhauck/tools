use strict;
use warnings;

my $dir = "\\\\daddev\\office\\16.0\\11806.10000\\logs\\Iter2\\BFREarlyDevX64ShipAllCultures\\OhomeBuild.2019-06-06-16-19-53";
my @cultures;
my @files;
my @missing;
my @final;

opendir (DIR, $dir) or die $!;

while (my $file = readdir(DIR))
{
    next unless (-f "$dir/$file");
    next unless ($file =~ m/\.err$/);
    
    if ($file =~ m/^devwac/){
        push (@files, $file);
        $file =~ s/^\w+\.(.*).b\w+.*/$1/g;
        push (@cultures, $file);
    }
}

chdir("\\\\daddev\\office\\16.0\\11806.10000\\logs\\Iter2\\BFREarlyDevX64ShipAllCultures\\OhomeBuild.2019-06-06-16-19-53") or die $!;

foreach my $file(@files)
{
    open my $in,  '<',  $file or die "Cannot open $file for reading : $!.\n";
    
    while(<$in>)
    {
        next unless ($_ =~ m/\'.$/);
        
        if ($_ =~ m/.*\\(\w+\-\w+)\\.*/)
        {
            push (@cultures, $1)
        }
        
        $_ =~ s/.*'(.*)'./$1/g;
        $_ =~ s/(ship|debug)/\*/g;
        push (@missing, $_);
    }   
    close $in;
}

closedir(DIR);

my @filtered = uniq(sort @missing);
my @ofilter  = uniq(sort @cultures);
my $addition = join " ", @ofilter;

for(@filtered)
{
    chomp $_;
    push(@final, "$_ { $addition }\n");
}

####################
#---Work in Depot---
####################

chdir("$ENV{'OTOOLS'}\\inc\\devphase\\devwac") or die $!;
my $nfile = "test.txt";

open my $in,  '<',  $nfile      or die "Can't read old file: $!";
open my $out, '>', "$nfile.new" or die "Can't write new file: $!";

#print `sd edit $nfile`;

for(@final)
{   
    print $out $_;

    while(<$in>)
    {
        print $out $_;
    }
}

close $in;
close $out;

rename("$nfile.new", $nfile);

open $in,  '<',  $nfile      or die "Can't read old file: $!";
open $out, '>', "$nfile.new" or die "Can't write new file: $!";

my @lines;

while(<$in>)
{
    push (@lines,$_);
}

@lines = sort @lines;

for(@lines)
{   
    print $out $_;

    while(<$in>)
    {
        print $out $_;
    }
}

close $in;
close $out;

rename("$nfile.new", $nfile);

###########################
#---Subs for ease of use---
###########################
# sub printSortedArray
# {
#     sort @_;
#     print "$_\n" for @_;
# }

sub uniq
{
    my %seen;
    grep !$seen{$_}++, @_;
}