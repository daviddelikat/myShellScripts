#!/usr/bin/perl
use warnings;
use strict;

use Getopt::Long;

my ($search, $sfilename);

GetOptions(
    'search=s'  => \$search,
    'servers=s' => \$sfilename,
);

$sfilename ||= ( $ENV{HOME} . '/bin/servers' );
$search    ||= $ARGV[0] or die 'You need to search for something.';

my $regex = eval { qr{$search} } or die "invalid regex: $search";

my $found = 0;
open my $sfile, '<', $sfilename or die "$sfilename: $!";
while (my $host = <$sfile>) {
    chomp $host;
    $host =~ s/#.*//;
    $host =~ s/\s*//;
    next unless $host;
    my $wgVersion = qx{ ssh $host grep VERSION /data/WebGUI/lib/WebGUI.pm };
    chomp $wgVersion;
    $wgVersion =~ s/.*'(.*)'.*/$1/; # version string is in quotes
    print "Searching $host($wgVersion)...\n";

    open my $search, '-|', "ssh $host ls /data/WebGUI/etc/*.conf"
        or die "problem connecting to $host";

    while (my $line = <$search>) {
        my ($site) = $line =~ qr{^/data/WebGUI/etc/(.*).conf};
        if ($site =~ $regex) {
            print "...$site is on $host.\n";
            $found = 1;
            #print "...$site is on $host.  Keep looking? (y/n) ";
            #my $answer = <STDIN>;
            #chomp $answer;
            #if ($answer !~ /^[Yy]/) {
            #    close $search;
            #    close $sfile;
            #    exit 0;
            #}
        }
    }
    close $search;
}
close $sfile;

print "Not found.\n" unless $found;
exit 1;

