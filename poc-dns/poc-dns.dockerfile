# podman build -t quay.io/wcaban/poc-dns:latest -f Dockerfile
FROM registry.access.redhat.com/ubi8/ubi

RUN dnf install --nodocs -y dnsmasq syslinux-tftpboot && \
    dnf clean all && \
    rm -rf /var/cache/dnf 

LABEL maintainer="William Caban" \
    io.k8s.display-name="dnsmasq" \
    io.k8s.description="Containerized dnsmasq - DNS caching server"

# DNS (53), DHCP (67,68), TFTP (69), DHCPv6 (547)
EXPOSE 53 67 68 69 547

#EXPOSE 24580
#EXPOSE 30581

# Using shell mode for env vars substitution
ENTRYPOINT /usr/sbin/dnsmasq -k -d --log-facility=-