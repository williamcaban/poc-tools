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

## Installing the service

- Start the service
```
systemctl start poc-virtualbmc
systemctl status -l poc-virtualbmc
systemctl enable poc-virtualbmc
```

- Copy virtualbmc public key as authorized keys in the libvirt server
```
export VIRTUALBMCPATH="/opt/virtualbmc"
export LIBVIRTSERVER="root@kvm01"

# Copy output from
cat  ${VIRTUALBMCPATH}/keys/id_rsa.pub

ssh root@${LIBVIRTSERVER}
vi /root/.ssh/authorized_keys
# paste content of poc-virtualbmc id_rsa.pub
```

## Using the service

