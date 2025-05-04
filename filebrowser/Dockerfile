# filebrowser/Dockerfile (Diagnostic Version)
ARG BUILD_FROM
FROM ${BUILD_FROM}

RUN echo "--- Initial / listing (immediately after FROM ${BUILD_FROM}) ---" && \
    ls -l / && \
    echo "--- Checking for /filebrowser (after FROM) ---" && \
    (ls -l /filebrowser || echo "/filebrowser NOT FOUND at this stage") && \
    echo "--- Checking for filebrowser in common PATH locations (after FROM) ---" && \
    (ls -l /usr/bin/filebrowser || echo "/usr/bin/filebrowser NOT FOUND") && \
    (ls -l /usr/local/bin/filebrowser || echo "/usr/local/bin/filebrowser NOT FOUND") && \
    echo "--- Current PATH (after FROM) ---" && \
    echo "$PATH" && \
    echo "--- End of initial checks ---"

# It's good practice to be root if you need to install packages or modify system files
USER root
RUN apk add --no-cache jq bash

RUN echo "--- / listing (after apk add) ---" && \
    ls -l / && \
    echo "--- Checking for /filebrowser (after apk add) ---" && \
    (ls -l /filebrowser || echo "/filebrowser NOT FOUND at this stage") && \
    echo "--- Current PATH (after apk add) ---" && \
    echo "$PATH" && \
    echo "--- End of checks after apk add ---"

COPY run.sh /run.sh
COPY rootfs/ /

RUN echo "--- / listing (after COPY run.sh) ---" && \
    ls -l / && \
    echo "--- Checking for /filebrowser (after COPY run.sh) ---" && \
    (ls -l /filebrowser || echo "/filebrowser NOT FOUND at this stage") && \
    echo "--- End of checks after COPY ---"

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]