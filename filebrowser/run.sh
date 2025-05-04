#!/usr/bin/with-contenv bashio

echo "------------------------------------------------------------"
echo "RUN.SH DOCKERFILE ENTRYPOINT TEST: Plain echo - This script is starting now."
echo "If you see this line, the Dockerfile ENTRYPOINT to /run.sh is working!"
echo "------------------------------------------------------------"

bashio::log.info "============================================================"
bashio::log.info "RUN.SH DOCKERFILE ENTRYPOINT BASHIO TEST: SUCCESS!"
bashio::log.info "This means /run.sh is now correctly executing."
bashio::log.info "Attempting to log a config option (root_directory):"
bashio::log.info "Value from bashio::config 'root_directory': $(bashio::config 'root_directory' 'NOT_SET_OR_DEFAULT_USED')"
bashio::log.info "============================================================"

# Forcing a very simple FileBrowser execution with specific test parameters
# Using a distinct port and database file for this test.
INTERNAL_TEST_PORT=8089
TEST_DB_PATH="/tmp/fb_test_via_run_sh.db"

bashio::log.info "TEST: FileBrowser will be started with the following arguments by this test run.sh:"
bashio::log.info "  --port=${INTERNAL_TEST_PORT}"
bashio::log.info "  --address=0.0.0.0"
bashio::log.info "  --noauth"
bashio::log.info "  --root=/share"
bashio::log.info "  --database=${TEST_DB_PATH}"
bashio::log.info "  --log=debug"
bashio::log.info "------------------------------------------------------------"

exec /filebrowser \
    --port=${INTERNAL_TEST_PORT} \
    --address=0.0.0.0 \
    --noauth \
    --root=/share \
    --database=${TEST_DB_PATH} \
    --log=debug