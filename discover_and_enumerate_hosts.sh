#!/bin/bash
# If the timeout command is not found in the path, it may be under: /usr/share/doc/bash-3.2/scripts/timeout
# Note: You will need to change the script to reflect this timeout binary since it functions differently.

# $1 = IP address(es) to scan.
# $2 = Base directory to store output.
# Ex: sudo ./scan_individual_hosts.sh 10.11.1.0/24 results
if [ "$#" -ne 2 ]; then
    echo "  Usage: sudo ${0} [IP_CIDR_Range] [output_directory]"
    echo "Example: sudo ${0} 10.11.1 results"
    exit 1
fi

current_date=`date '+%h-%d-%Y'`
class_c_cidr=$1
mkdir -p $2
output_hosts_filename="${2}"/nmap_scan_up_hosts_"${current_date}".txt
output_hosts_filename_v2="${2}"/nmap_scan_up_hosts_"${current_date}"_v2.txt

# Run various quick nmap scans to find as many 'up' hosts as possible on the network CIDR range.
echo "Conducting nmap scans."
nmap -sn -PE $class_c_cidr.0/24 >> $output_hosts_filename
nmap -sn -PS $class_c_cidr.0/24 >> $output_hosts_filename
nmap -sn -PA $class_c_cidr.0/24 >> $output_hosts_filename
nmap -sn -PU $class_c_cidr.0/24 >> $output_hosts_filename
nmap -sn -PR $class_c_cidr.0/24 >> $output_hosts_filename
nmap -sn -PY $class_c_cidr.0/24 >> $output_hosts_filename
nmap -sn -PP $class_c_cidr.0/24 >> $output_hosts_filename
nmap -sn -PM $class_c_cidr.0/24 >> $output_hosts_filename
#nmap -sn -PA -PE -PM -PO[icmp,igmp,tcp,udp,sctp] -PP -PR -PS -PU -PY 10.11.1.0/24
nmap -sS $class_c_cidr.0/24 >> $output_hosts_filename

# Crude network CIDR scanner for rather common ports.
# Useful when nmap is not available or if nmap doesn't identify some systems as 'up'.
echo "Conducting forced 'limited' port scan on all $class_c_cidr.0/24 ips to discover additional hosts."
ports=(21 22 25 53 80 88 110 111 135 137 139 143 220 389 443 445 464 593 636 1433 3289 3269 3306 3389 5800 5900 5985 8000 8080)
for host in {1..255}; do
    for port in ${ports[@]}; do
        # Depending on the Kernel / OS, you may need to use a different timeout commands / binaries.
        timeout .1 bash -c "echo >/dev/tcp/$class_c_cidr.$host/$port" 2> /dev/null &&
        #/tmp/timeout 1 bash -c "echo >/dev/tcp/$class_c_cidr.$host/$port" &&
            echo "  Host is up: $class_c_cidr.$host" >> $output_hosts_filename && break
    done
done

# Filter for hosts that are 'up'.
grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" $output_hosts_filename | sort -t . -k3,3n -k 4,4n | uniq > $output_hosts_filename_v2
echo "The following hosts are up:"
cat $output_hosts_filename_v2
chown -R "${USER}": "${2}"

# Run aggressive nmap system/service/port scan on identified 'up' hosts.
echo "Scanning services on discovered hosts."
while read host; do
    echo "Scanning services on $host."
    output_scan_filename="${2}"/"${host}"/nmap-scan_"${host}"_"${current_date}".txt
    mkdir -p "${2}"/"${host}"
    nmap -A -T4 -Pn -n -p- "${host}" -oN "${output_scan_filename}"
    echo "nmap scan results for $host."
    cat $output_scan_filename
done < $output_hosts_filename_v2
chown -R "${USER}": "${2}"


