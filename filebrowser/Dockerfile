# filebrowser/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Add dependencies: curl to download, tar to extract.
# jq is often in HA base images, but explicit add is safer if needed by bashio or run.sh directly.
# bash is also usually present.
RUN apk add --no-cache curl tar jq bash

ARG BUILD_ARCH
ARG FILEBROWSER_VERSION="v2.32.0" # Specify a recent stable FileBrowser version

# Map Home Assistant BUILD_ARCH to FileBrowser release asset architecture names
# HA_ARCH: amd64, aarch64, armv7, armhf
# FileBrowser assets: linux-amd64, linux-arm64, linux-armv7, linux-arm (for armv6/armhf)
# We need to be careful with armhf. FileBrowser might offer 'linux-arm.tar.gz' for armv6.
# Let's check their release page for armhf/armv6.
# Latest release (v2.32.0) has:
# linux-amd64-filebrowser.tar.gz
# linux-arm64-filebrowser.tar.gz
# linux-armv7-filebrowser.tar.gz
# linux-armv6-filebrowser.tar.gz (This should map to HA's 'armhf')

ENV FILEBROWSER_ARCH=""
RUN case "${BUILD_ARCH}" in \
        "aarch64") FILEBROWSER_ARCH="arm64" ;; \
        "amd64") FILEBROWSER_ARCH="amd64" ;; \
        "armv7") FILEBROWSER_ARCH="armv7" ;; \
        "armhf") FILEBROWSER_ARCH="armv6" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" ; exit 1 ;; \
    esac && \
    echo "Building for HA_ARCH: ${BUILD_ARCH},  FileBrowser ARCH: ${FILEBROWSER_ARCH}" && \
    curl -L "https://github.com/filebrowser/filebrowser/releases/download/${FILEBROWSER_VERSION}/linux-${FILEBROWSER_ARCH}-filebrowser.tar.gz" -o /tmp/filebrowser.tar.gz && \
    tar -xzf /tmp/filebrowser.tar.gz -C /usr/local/bin/ filebrowser && \
    chmod +x /usr/local/bin/filebrowser && \
    rm /tmp/filebrowser.tar.gz

# Verify installation (optional debug)
RUN ls -l /usr/local/bin/filebrowser && /usr/local/bin/filebrowser version

COPY run.sh /run.sh
COPY rootfs/ / # Ensure rootfs exists, can be empty with a .keep file

RUN chmod a+x /run.sh

# ENTRYPOINT is not strictly needed if using HA base image and run.sh is standard.
# HA base images are often S6-based when init=true.
# For init=false, /run.sh is usually executed by Supervisor.
# Let's rely on the Supervisor's default behavior for run.sh with init:false.
# If issues, we can add ENTRYPOINT ["/run.sh"]