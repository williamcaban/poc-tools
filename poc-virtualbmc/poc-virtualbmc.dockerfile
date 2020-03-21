# podman build -t quay.io/wcaban/poc-virtualbmc:latest -f poc-virtualbmc.dockerfile
FROM registry.access.redhat.com/ubi8/ubi
LABEL maintainer="William Caban" \
    io.k8s.display-name="VirtualBMC" \
    io.k8s.description="Containerized Virtual BMC server"

# Update image
RUN dnf update  --disablerepo=* --enablerepo=ubi-8-appstream --enablerepo=ubi-8-baseos -y

# Install specific rpm packages (for troubleshooting: procps-ng, iproute)
# NOTE: These packages require RHEL node
RUN dnf install -y procps-ng iproute python3-virtualenv python3-libvirt openssh-clients \
    && rm -rf /var/cache/yum

VOLUME ["/root/.ssh/id_rsa","/vbmc/config"]

ENV VIRTUALBMC_CONFIG /vbmc/virtualbmc.conf
COPY virtualbmc.conf /vmbc
WORKDIR /vbmc

# User unprivileged user
#USER 10000
RUN pip-3 install virtualbmc
EXPOSE 7000-7020

# Start the service in the foreground
CMD ["--foreground"]
ENTRYPOINT ["/usr/local/bin/vbmcd"]
