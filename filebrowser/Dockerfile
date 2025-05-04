# filebrowser/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Ensure we are root to install packages.
USER root
RUN apk add --no-cache jq bash

COPY run.sh /run.sh
COPY rootfs/ / # Assuming rootfs is empty or contains non-colliding files

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]