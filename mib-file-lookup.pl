#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use SNMP;

my $debug = 0;
my $oid;
my @mib_dirs;
my $opt_ok = GetOptions(
    "debug"     => \$debug,
    "oid=s"     => \$oid,
    "mib-dir=s" => \@mib_dirs,
);

if ( !$opt_ok ) {
    usage();
}

if ( !$oid || !@mib_dirs ) {
    usage();
}

if ( !$debug ) {
    open STDERR, ">", "/dev/null";
}

$ENV{MIBDIRS} = join( ":", @mib_dirs );
$ENV{MIBS}    = "ALL";
SNMP::initMib();

my $node = $SNMP::MIB{$oid};
if ( !$node || !$node->{moduleID} ) {
    exit 1;
}

my $module = $node->{moduleID};

for my $dir (@mib_dirs) {
    for my $file ( glob("$dir/*") ) {
        my $base = fileparse( $file, qr/\.\w+$/ );
        if ( lc($base) eq lc($module) ) {
            print "$file\n";
            exit 0;
        }
    }
}

exit 1;

sub usage {
    print STDERR
      "Usage: $0 --oid <OID> --mib-dir <dir> [--mib-dir <dir> ...] [--debug]\n";
    exit 2;
}
