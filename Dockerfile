FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       libsnmp-perl \
    && rm -rf /var/lib/apt/lists/*

COPY mib-file-lookup.pl /usr/local/bin/mib-file-lookup.pl

ENTRYPOINT ["perl", "/usr/local/bin/mib-file-lookup.pl"]
