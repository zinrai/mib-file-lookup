# mib-file-lookup

Resolves an OID or MIB symbol name to the physical MIB file that defines it.
Uses the Net-SNMP Perl bindings (`libsnmp-perl`) for MIB parsing.

## Local

### Installation

```
apt-get install libsnmp-perl
```

Copy `mib-file-lookup.pl` to a directory in your PATH.

### Usage

```
perl mib-file-lookup.pl --oid <OID> --mib-dir <dir> [--mib-dir <dir> ...] [--debug]
```

```
$ perl mib-file-lookup.pl --oid sysDescr --mib-dir ./mibs
./mibs/SNMPv2-MIB.txt
```

```
$ perl mib-file-lookup.pl --oid 1.3.6.1.2.1.2.2.1.2 --mib-dir ./mibs
./mibs/IF-MIB.txt
```

```
$ perl mib-file-lookup.pl --oid ifDescr --mib-dir ./mibs --mib-dir ./base_mibs
./mibs/IF-MIB.txt
```

Show Net-SNMP parse errors for troubleshooting:

```
$ perl mib-file-lookup.pl --oid ifDescr --mib-dir ./mibs --debug
```

## Docker

```
$ docker pull ghcr.io/zinrai/mib-file-lookup:latest
```

```
$ docker run --rm -v $(pwd)/mibs:/mibs ghcr.io/zinrai/mib-file-lookup:latest \
  --oid sysDescr --mib-dir /mibs
/mibs/SNMPv2-MIB.txt
```

## Exit codes

- 0: MIB file found (path printed to stdout)
- 1: OID not resolved or no matching file found (no output)
- 2: invalid arguments

## With SNMP Exporter Generator

When splitting a flat MIB directory into per-vendor directories for the
SNMP Exporter Generator, this tool identifies which MIB file defines each
OID in `generator.yml`.

Extract OIDs from `generator.yml` with `yq` and look up each one:

```
for oid in $(yq '.modules[].walk[]' generator.yml); do
  perl mib-file-lookup.pl --oid "$oid" --mib-dir ./mibs
done
```

Deduplicate to get the list of required MIB files:

```
for oid in $(yq '.modules[].walk[]' generator.yml); do
  perl mib-file-lookup.pl --oid "$oid" --mib-dir ./mibs
done | sort -u
```

## License

This project is licensed under the [MIT License](./LICENSE).
