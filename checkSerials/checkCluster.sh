#!/bin/bash

# Quick and dirty script to check a domain's serial in the ns-cluster

DOMAIN=fido.net
TIMEOUT=2

function showHelp() {
echo "Simple script to check a domain's SOA against the Fido AnyCast cluster"
echo "Written by Jon Morby - April 2023"
echo ""
echo "Options:
     -d DOMAIN - domain name to check (defaults to ${DOMAIN})
     -t TIMEOUT - in seconds (defaults to ${TIMEOUT})
     -h HELP - this page"
echo ""
echo ""
exit
}

while getopts d:t:h flag
do
case "${flag}" in
    d) DOMAIN=${OPTARG};;
    t) TIMEOUT=${OPTARG};;
    h) showHelp;;
esac
done

DIG=$(dig -t txt ns.fido.net +short)

# SERVERS=`echo $DIG | sort | sed s/\"//g`

SERVERS=$(echo "$DIG" | tr -d '"' | tr ' ' '\n' | sort)

echo Checking serials for domain: ${DOMAIN}


for i in $SERVERS
do
printf "%16s\t" ${i}
# host -t soa ${DOMAIN} ${i}.ns.fido.net | grep SOA | cut -f7 -d" "
dig -t soa ${DOMAIN} @${i}.ns.fido.net +short +timeout=${TIMEOUT} | grep -v \; | cut -f3 -d" " 
if [ $? -ne 0 ]; then 
echo ... failed
fi 

done


