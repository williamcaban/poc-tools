# Using thie poc-virtualbmc

## Prerequesites
```
export VIRTUALBMCPATH="/opt/virtualbmc"

# crete path for container volumes
mkdir -pv ${VIRTUALBMCPATH}/keys

# Generate SSH key pair to be used for the libvirt authetnication
ssh-keygen -b 2048 -t rsa -f ${VIRTUALBMCPATH}/keys/id_rsa -q -N ""

# Setup the systemd service
cp poc-virtualbmc.service /etc/systemd/system/poc-virtualbmc.service
```

or execute
```
./install.sh
```

## Using the service

```
systemctl start poc-virtualbmc
systemctl status -l poc-virtualbmc
systemctl enable poc-virtualbmc
```