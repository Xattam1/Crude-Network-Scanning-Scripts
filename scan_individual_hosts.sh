#!/bin/bash

# $1 = IP address(es) to scan.
# $2 = Base directory to store output.
# Ex: sudo ./scan_individual_hosts.sh 10.11.1.0/24 results
# Run aggressive nmap system/service/port scan on identified 'up' hosts.
if [ "$#" -ne 2 ]; then
    echo "  Usage: sudo ${0} [IP_CIDR_Range] [output_directory]"
    echo "Example: sudo ${0} 10.11.1.0/24 results"
    exit 1
fi
current_date=`date '+%h-%d-%Y'`
output_hosts_filename="${2}"/nmap_scan_up_hosts_"${current_date}".txt
mkdir -p $2
nmap -sn "${1}" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" > "${output_hosts_filename}"
while read host; do
    output_scan_filename="${2}"/"${host}"/nmap_scans/nmap-scan_"${host}"_"${current_date}".txt
    mkdir -p "${2}"/"${host}"
    nmap -A -T4 -p- "${host}" -oN "${output_scan_filename}"
done < $output_hosts_filename
chown -R "${USER}": "${2}"