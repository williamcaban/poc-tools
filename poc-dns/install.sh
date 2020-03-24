#!/bin/sh

export DNSMASQPATH=/opt/dnsmasq

# crete path for container volumes
mkdir -pv ${DNSMASQPATH}/{leases,dnsmasq.d}

# Copy configuration files
cp ocp-dhcp.hostfiles.txt   ${DNSMASQPATH}/ocp-dhcp.hostfiles
cp ocp.hosts.txt            ${DNSMASQPATH}/ocp.hosts
cp ocp-lab-dnsmasq.conf     ${DNSMASQPATH}/dnsmasq.d/lab.conf

# Setup the systemd service
cp poc-dns.service /etc/systemd/system/poc-dns.service
systemctl daemon-reload

#systemctl start poc-dns
#systemctl status -l poc-dns
#systemctl enable poc-dns