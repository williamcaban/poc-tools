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
export LIBVIRTSERVER="kvm01"

# Setup known_hosts to learn the ssh fingerprint of your libvirt host
ssh-keyscan -H ${LIBVIRTSERVER} >> ${VIRTUALBMCPATH}/keys/known_hosts

# Copy public key from
cat  ${VIRTUALBMCPATH}/keys/id_rsa.pub

# Login to the libvirt server and copy the public key
ssh root@${LIBVIRTSERVER}
vi /root/.ssh/authorized_keys
# paste content of poc-virtualbmc id_rsa.pub

```

## Using the service

Reference doc for VirtualBMC: https://docs.openstack.org/virtualbmc/latest/user/index.html

- Using the service for the first time requires initializing the ssh key
```
# Connect to the running contaiiner
podman exec -ti poc-virtualbmc /bin/bash

# Add initial VMs (increase the port by one with each VM)

vbmc add ocp4-bootstrap --port 7000 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system

vbmc add ocp4-master-0 --port 7001 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system
vbmc add ocp4-master-1 --port 7002 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system
vbmc add ocp4-master-2 --port 7003 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system

vbmc add ocp4-worker-0 --port 7004 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system
vbmc add ocp4-worker-1 --port 7005 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system
vbmc add ocp4-worker-2 --port 7006 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system
```

- Adding VMs after initialization
```
podman exec -ti poc-virtualbmc vbmc add node1 --port 7000 --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system
```

- Adding multiple VMs 
```
for i in {1..5};do
  vbmc add vm-name-$i --port 702$i --username admin --password password --libvirt-uri qemu+ssh://root@kvm01/system
  vbmc start vm-name-$i
done

```
