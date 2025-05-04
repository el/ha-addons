# filebrowser/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

COPY run.sh /run.sh
COPY rootfs/ /

RUN chmod a+x /run.sh

# Explicitly set /run.sh as the entrypoint.
# This overrides the base image's ENTRYPOINT (e.g., ["/filebrowser"]).
ENTRYPOINT ["/run.sh"]