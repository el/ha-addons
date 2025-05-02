# librespeed/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# The linuxserver/librespeed image is pre-configured and includes s6-overlay.
# Its own /init process will handle starting the LibreSpeed service.
# No additional files or setup steps are required for this simple addon.

# Add labels if not sufficiently covered by build.yaml
LABEL maintainer="Eliz"