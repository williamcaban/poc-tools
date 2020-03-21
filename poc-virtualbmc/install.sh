#!/bin/sh

export VIRTUALBMCPATH="/opt/virtualbmc"



# crete path for container volumes
mkdir -pv ${VIRTUALBMCPATH}/keys

# Generate SSH key pair to be used for the libvirt authetnication
if [[! -f "${VIRTUALBMCPATH}/keys/id_rsa" ]]; then
    echo "Generating ssh keys for libvirt authentication"
    ssh-keygen -b 2048 -t rsa -f ${VIRTUALBMCPATH}/keys/id_rsa -q -N ""
fi

# Setup the systemd service
cp poc-virtualbmc.service /etc/systemd/system/poc-virtualbmc.service
systemctl daemon-reload

#systemctl start poc-virtualbmc
#systemctl status -l poc-virtualbmc
#systemctl enable poc-virtualbmc