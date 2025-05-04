#!/usr/bin/with-contenv bashio

echo "------------------------------------------------------------"
echo "RUN.SH TEST: Plain echo - This script is starting now."
echo "------------------------------------------------------------"

bashio::log.info "============================================================"
bashio::log.info "RUN.SH BASHIO TEST: If you see this, bashio logging works!"
bashio::log.info "Attempting to log a config option (root_directory):"
bashio::log.info "Value: $(bashio::config 'root_directory' 'DEFAULT_IF_MISSING')"
bashio::log.info "============================================================"

# Forcing a very simple FileBrowser execution to see if it even gets this far
# This will ignore Ingress and most settings for this basic test.
INTERNAL_PORT=8088 # Using a different port to avoid conflict if old one is stuck
bashio::log.info "TEST: Forcing FileBrowser to listen on port ${INTERNAL_PORT} with minimal args."
bashio::log.info "TEST: Database will be /tmp/filebrowser_test.db"
bashio::log.info "TEST: Root will be /share"
bashio::log.info "TEST: No authentication will be enabled for this test."

exec /filebrowser \
    --port=${INTERNAL_PORT} \
    --address=0.0.0.0 \
    --noauth \
    --root=/share \
    --database=/tmp/filebrowser_test.db \
    --log=debug