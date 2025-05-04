# filebrowser/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install jq for parsing /data/options.json in run.sh, and bash for easier scripting.
# The official filebrowser image is Alpine based.
# Add bash for more complex scripting, though basic run.sh might only need sh.
# Ensure we are root to install packages. The filebrowser image might run as root.
USER root
RUN apk add --no-cache jq bash

COPY run.sh /run.sh
COPY rootfs/ /

# Diagnostic step (optional, can be removed after confirming build)
RUN echo "--- Listing / contents after COPY and jq/bash install ---" && ls -l / && ls -l /usr/bin/jq && ls -l /bin/bash && echo "--- End of / listing ---"

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]
# No USER instruction here, assuming filebrowser itself handles user if needed,
# or runs as root which is common for its official image.