# GoDaddy Dynamic DNS updater.

Docker image to dynamically update the DNS zone via Godaddy API.

Define TARGETS as bash array of arrays with [domain.tld, record-type, name]
e.g. [[domain.tld,A,@],[domain2.tld,A,api]].
So far only tested with A records.

Define GoDaddy KEY and SECRET.

Optionally define DELAY [default: 3600 seconds] and TTL [default: 3600].

