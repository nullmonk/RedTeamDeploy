#remove duplicate IPs from a host
ip a | grep "inet 192.168" | grep "ark" | awk '{print $2}' > /tmp/ips
while read p; do ip a del $p dev ens33; done</tmp/ips
