#!/bin/sh

export DNSMASQPATH=/opt/dnsmasq

# crete path for container volumes
mkdir -pv ${DNSMASQPATH}/{leases,dnsmasq.d,pxelinux.cfg,rhcos}

# Copy configuration files
cp ocp-dhcp.hostfiles.txt   ${DNSMASQPATH}/ocp-dhcp.hostfiles
cp ocp.hosts.txt            ${DNSMASQPATH}/ocp.hosts
cp lab.hosts.txt            ${DNSMASQPATH}/lab.hosts
cp ocp-lab-dnsmasq.conf     ${DNSMASQPATH}/dnsmasq.d/lab.conf
cp default.pxe              ${DNSMASQPATH}/pxelinux.cfg/default

echo "NOTE: To download the RHCOS PXE images execute:
    curl -o ${DNSMASQPATH}/rhcos/rhcos-installer-initramfs.img https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-4.3.8-x86_64-installer-initramfs.x86_64.img
    curl -o ${DNSMASQPATH}/rhcos/rhcos-installer-kernel https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-4.3.8-x86_64-installer-kernel-x86_64
"
# Setup the systemd service
cp poc-dns.service /etc/systemd/system/poc-dns.service
systemctl daemon-reload

#systemctl start poc-dns
#systemctl status -l poc-dns
#systemctl enable poc-dns