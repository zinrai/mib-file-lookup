#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
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
my @files  = map { glob("$_/*") } @mib_dirs;

for my $file (@files) {
    if ( file_defines_module( $file, $module ) ) {
        print "$file\n";
        exit 0;
    }
}

exit 1;

sub file_defines_module {
    my ( $file, $module ) = @_;
    open my $fh, '<', $file or return 0;
    while ( my $line = <$fh> ) {
        if ( $line =~ /^\s*\Q$module\E\s+DEFINITIONS\s*::=\s*BEGIN/i ) {
            close $fh;
            return 1;
        }
    }
    close $fh;
    return 0;
}

sub usage {
    print STDERR
      "Usage: $0 --oid <OID> --mib-dir <dir> [--mib-dir <dir> ...] [--debug]\n";
    exit 2;
}
