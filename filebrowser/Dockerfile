# filebrowser/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# This command assumes 'run.sh' is in the same directory as this Dockerfile
# (i.e., the root of the build context, which is typically your 'filebrowser/' addon directory).
COPY run.sh /run.sh
COPY rootfs/ /

# ---- DIAGNOSTIC STEP ----
# List the contents of the root directory to check if run.sh was copied.
# The output of this command will appear in your Docker build log.
RUN echo "--- Listing / contents after COPY ---" && ls -l / && echo "--- End of / listing ---"
# ---- END DIAGNOSTIC STEP ----

RUN chmod a+x /run.sh

# Explicitly set /run.sh as the entrypoint.
ENTRYPOINT ["/run.sh"]