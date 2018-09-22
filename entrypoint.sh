#!/bin/bash

#CHECK INPUTS
echo "${TARGETS}"
if [[ ! "${TARGETS}" =~ ^\[\[[A-Za-z0-9\._\-][A-Za-z0-9\._\-]*\.[[:alpha:]]{2,7}\,(NS|A|CNAME|MX|TXT|SRV|AAAA|CAA)\,(@|\*|www|_domainconnect|[A-Za-z0-9]*)\](\;\[[A-Za-z0-9\._\-][A-Za-z0-9\._\-]*\.[[:alpha:]]{2,7}\,(NS|A|CNAME|MX|TXT|SRV|AAAA|CAA)\,(@|\*|www|_domainconnect|[A-Za-z0-9]*)\])*\]$ ]]; then
    >&2 echo "The environment variable TARGETS is missing or malformed. Exiting...";
    exit 1;
fi
if [[ ! "${KEY}" =~ ^[A-Za-z0-9]{1,12}\_[A-Za-z0-9]{1,22}$ ]]; then
    >&2 echo "The environment variable KEY is missing or malformed. Exiting...";
    exit 1;
fi
if [[ ! "${SECRET}" =~ ^[A-Za-z0-9]{1,22}$ ]]; then
    >&2 echo "The environment variable SECRET is missing or malformed. Exiting...";
    exit 1;
fi
if [[ ! "${DELAY}" =~ ^[0-9][0-9]*$ ]]; then
    echo "DELAY is missing or is malformed: defaults to 3600 seconds / 60 minutes"
fi
if [[ ! "${TTL}" =~ ^[0-9][0-9]*$ ]]; then
    echo "TTL is missing or is malformed: defaults to 1800 seconds / 30 minutes"
fi

targets="${TARGETS:1:${#TARGETS}-2}";
IFS=';' read -a targets <<< "${targets}"
while true;
do
    for target in "${targets[@]}"
    do
        :
        target="${target:1:${#target}-2}";
        IFS=',' read -a target <<< "${target}"
        domain="${target[0]}";
        type="${target[1]}";
        name="${target[2]}";
        echo "Checking for IP address change for $domain/records/$type/$name ...";
        godaddyresult=$(curl -s -X GET -H "Authorization: sso-key $KEY:$SECRET" "https://api.godaddy.com/v1/domains/$domain/records/$type/$name");
        godaddyip=$(echo $godaddyresult | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b");
        ipresult=$(curl -s GET https://ipinfo.io/ip);
        ip=$(echo $ipresult | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b");
        if [ "$ip" != "$godaddyip" ];
         then
            echo "Updating $domain/records/$type/$name to new IP address $ip ..."
            result=$(curl -i -s -X PUT -H "Authorization: sso-key $KEY:$SECRET" -H "Content-Type: application/json" -d '[{"data":"'$ip'","ttl":'$TTL'}]' "https://api.godaddy.com/v1/domains/$domain/records/$type/$name")
            echo "$result"
        fi
    done
    echo "DONE. Waiting for $DELAY seconds.";
    sleep $DELAY;
done


