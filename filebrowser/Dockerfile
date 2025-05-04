# filebrowser/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM} # This is filebrowser/filebrowser:latest

# Copy our run script to the expected location and make it executable
COPY run.sh /run.sh
COPY rootfs/ /

RUN chmod a+x /run.sh

# Explicitly set our /run.sh as the entrypoint for the addon.
# This will override the base image's ENTRYPOINT (which is ["/filebrowser"]).
ENTRYPOINT ["/run.sh"]