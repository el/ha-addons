# filebrowser/Dockerfile (with build-fail diagnostic)
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Initial checks (output will be in the detailed build log if you can find it)
RUN echo "--- DIAGNOSTIC: Initial / listing (immediately after FROM ${BUILD_FROM}) ---" && \
    ls -l / && \
    echo "--- DIAGNOSTIC: Checking for /filebrowser (after FROM) ---" && \
    (ls -l /filebrowser || echo "DIAGNOSTIC: /filebrowser NOT FOUND at this stage") && \
    echo "--- DIAGNOSTIC: Current PATH (after FROM) ---" && \
    echo "$PATH" && \
    echo "--- DIAGNOSTIC: End of initial checks ---"

# Ensure we are root to install packages
USER root
RUN apk add --no-cache jq bash

RUN echo "--- DIAGNOSTIC: / listing (after apk add) ---" && \
    ls -l / && \
    echo "--- DIAGNOSTIC: Checking for /filebrowser (after apk add) ---" && \
    (ls -l /filebrowser || echo "DIAGNOSTIC: /filebrowser NOT FOUND at this stage") && \
    echo "--- DIAGNOSTIC: Current PATH (after apk add) ---" && \
    echo "$PATH" && \
    echo "--- DIAGNOSTIC: End of checks after apk add ---"

# ---- BUILD-FAIL DIAGNOSTIC BLOCK ----
# This command will check for 'filebrowser' in common locations and in the PATH.
# If not found, it prints a critical error and exits with code 1, failing the build.
RUN if ! command -v filebrowser >/dev/null 2>&1 && \
       [ ! -f /filebrowser ] && \
       [ ! -f /usr/bin/filebrowser ] && \
       [ ! -f /usr/local/bin/filebrowser ]; then \
        echo "CRITICAL ERROR FROM DOCKERFILE: 'filebrowser' executable was NOT FOUND in PATH or common locations (/filebrowser, /usr/bin/filebrowser, /usr/local/bin/filebrowser) after initial setup and apk add. Forcing build to fail." >&2; \
        exit 1; \
    else \
        echo "DIAGNOSTIC FROM DOCKERFILE: 'filebrowser' executable WAS FOUND (either in PATH or a common location). Proceeding with build."; \
    fi
# ---- END OF BUILD-FAIL DIAGNOSTIC BLOCK ----

COPY run.sh /run.sh
COPY rootfs/ /

RUN chmod a+x /run.sh

ENTRYPOINT ["/run.sh"]