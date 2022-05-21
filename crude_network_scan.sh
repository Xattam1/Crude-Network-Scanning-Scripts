#!/bin/bash
# Crude network CIDR scanner for rather common ports.
# Useful when nmap is not available or if nmap doesn't identify some systems as 'up'.
# If the timeout command is not found in the path, it may be under: /usr/share/doc/bash-3.2/scripts/timeout
# Note: You will need to change the script to reflect this timeout binary since it functions differently.
# This is a good script to run on a system that:
#    Has access to multiple / internal networks:
#        Which are not directly accessible from your personal scanning / attacking system
#    Doesn't have nmap installed
class_c_cidr=$1
ports=(21 22 25 53 80 88 110 111 135 137 139 143 220 389 443 445 464 593 636 1433 3289 3269 3306 3389 5800 5900 5985 8000 8080)
for host in {1..255}; do
    echo "Scanning $class_c_cidr.$host"
    for port in ${ports[@]}; do
        # Depending on the Kernel / OS, you may need to use a different timeout commands / binaries.
        timeout .1 bash -c "echo >/dev/tcp/$class_c_cidr.$host/$port" &&
        #/tmp/timeout 1 bash -c "echo >/dev/tcp/$class_c_cidr.$host/$port" &&
            echo "  Port $port is open"
    done
done
echo "Done"