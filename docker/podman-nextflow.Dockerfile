FROM podman-in-podman:latest
ARG NXF_VERSION=22.10.4

RUN dnf -y update && \
    dnf install -y \
        java-17-openjdk.x86_64 \
        zip && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*


# Getting the nextflow-all binary to avoid runtime download of dependencies
RUN curl -L https://github.com/nextflow-io/nextflow/releases/download/v${NXF_VERSION}/nextflow-${NXF_VERSION}-all \
         --output nextflow && \
    chmod +rx nextflow && \
    mv nextflow /usr/local/bin
