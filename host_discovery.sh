#!/bin/bash
# If the timeout command is not found in the path, it may be under: /usr/share/doc/bash-3.2/scripts/timeout
# Note: You will need to change the script to reflect this timeout binary since it functions differently.
# Run various quick nmap scans to find as many 'up' hosts as possible on the network CIDR range.

sudo nmap -sn -PE 10.11.1.0/24 >> output.txt
sudo nmap -sn -PS 10.11.1.0/24 >> output.txt
sudo nmap -sn -PA 10.11.1.0/24 >> output.txt
sudo nmap -sn -PU 10.11.1.0/24 >> output.txt
sudo nmap -sn -PR 10.11.1.0/24 >> output.txt
sudo nmap -sS 10.11.1.0/24 >> output.txt

# Crude network CIDR scanner for rather common ports.
# Useful when nmap is not available or if nmap doesn't identify some systems as 'up'.
class_c_cidr=$1
ports=(21 22 25 53 80 88 110 111 135 137 139 143 220 389 443 445 464 593 636 1433 3289 3269 3306 3389 5800 5900 5985 8000 8080)
for host in {1..255}; do
    #echo "Scanning $class_c_cidr.$host"
    for port in ${ports[@]}; do
        # Depending on the Kernel / OS, you may need to use a different timeout commands / binaries.
        timeout .1 bash -c "echo >/dev/tcp/$class_c_cidr.$host/$port" &&
        #/tmp/timeout 1 bash -c "echo >/dev/tcp/$class_c_cidr.$host/$port" &&
            echo "  Host is up: $class_c_cidr.$host" >> output.txt && break
    done
done

# Filter for hosts that are 'up'.
grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" output.txt | sort -t . -k3,3n -k 4,4n | uniq >> output2.txt