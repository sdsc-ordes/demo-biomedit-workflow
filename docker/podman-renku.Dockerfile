FROM podman-in-podman:latest


RUN dnf -y update && \
    dnf -y install git-lfs git python3-pip && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*
RUN pip install renku==1.8.0

