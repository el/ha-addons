#!/usr/bin/with-contenv bashio
# filebrowser/run.sh

bashio::log.info "Starting FileBrowser addon..."

CONFIG_ROOT_DIRECTORY=$(bashio::config 'root_directory')
CONFIG_DATABASE_FILE=$(bashio::config 'database_file')
CONFIG_LOG_LEVEL=$(bashio::config 'log_level')
INTERNAL_PORT=80 # Fixed internal port for FileBrowser

# Ensure database directory exists
DB_DIR=$(dirname "${CONFIG_DATABASE_FILE}")
if [[ ! -d "$DB_DIR" ]]; then
    bashio::log.info "Database directory ${DB_DIR} does not exist. Creating..."
    if mkdir -p "$DB_DIR"; then
        bashio::log.info "Database directory ${DB_DIR} created."
    else
        bashio::log.error "Failed to create database directory ${DB_DIR}."
        bashio::exit.nok "Cannot create database directory."
    fi
fi

ARGS=""
ARGS="${ARGS} --address 0.0.0.0"
ARGS="${ARGS} --port ${INTERNAL_PORT}"
ARGS="${ARGS} --root \"${CONFIG_ROOT_DIRECTORY}\""
ARGS="${ARGS} --database \"${CONFIG_DATABASE_FILE}\""
ARGS="${ARGS} --log \"${CONFIG_LOG_LEVEL}\""

# Handle Ingress base URL
INGRESS_ENTRY_PATH=$(bashio::addon.ingress_entry)
# Ensure INGRESS_ENTRY_PATH starts with a slash if not empty, and handle if it's already set
if [[ -n "$INGRESS_ENTRY_PATH" ]]; then
    # Ensure leading slash if not present, though bashio::addon.ingress_entry usually provides it
    # Filebrowser expects baseurl to start with /
    if [[ "${INGRESS_ENTRY_PATH:0:1}" != "/" ]]; then
        INGRESS_ENTRY_PATH="/${INGRESS_ENTRY_PATH}"
    fi
    # Remove trailing slash if any, as FileBrowser might be sensitive
    if [[ "${INGRESS_ENTRY_PATH}" != "/" ]] && [[ "${INGRESS_ENTRY_PATH: -1}" == "/" ]]; then
        INGRESS_ENTRY_PATH="${INGRESS_ENTRY_PATH%/}"
    fi
    ARGS="${ARGS} --baseurl \"${INGRESS_ENTRY_PATH}\""
    bashio::log.info "Configuring FileBrowser with Ingress base URL: ${INGRESS_ENTRY_PATH}"
else
    bashio::log.info "No Ingress path found by bashio::addon.ingress_entry. FileBrowser will use root base URL (/). This might be an issue if Ingress is expected."
    # Filebrowser defaults to "/" if --baseurl is not provided, which is fine for non-ingress or if INGRESS_ENTRY_PATH is somehow empty.
fi


if bashio::config.true 'no_auth'; then
    ARGS="${ARGS} --noauth"
    bashio::log.warning "FileBrowser is running with NO AUTHENTICATION. This is insecure."
fi

if bashio::config.false 'allow_commands'; then
    ARGS="${ARGS} --disable-exec" # FileBrowser v2.24.0+ uses --disable-exec
else
    if bashio::config.has_value 'commands'; then
        CONFIG_COMMANDS=$(bashio::config 'commands')
        ARGS="${ARGS} --commands \"${CONFIG_COMMANDS}\""
    fi
fi

if bashio::config.false 'allow_edit'; then
    ARGS="${ARGS} --no-edit" # Assuming this flag still exists or equivalent
fi

# FileBrowser v2.x flags might differ slightly.
# For 'allow_new', it seems to be covered by permissions rather than a global flag.
# Default permissions usually allow creation.
# Let's assume 'allow_new' is controlled by user permissions within FileBrowser itself unless a specific global flag exists.
# The `perm` flags during user creation or global config for new users are more relevant.
# This addon doesn't manage users directly, relies on FileBrowser defaults.

if bashio::config.true 'allow_publish'; then
    ARGS="${ARGS} --allow-publish" # This flag might enable the feature globally
    bashio::log.warning "FileBrowser is allowing file publishing. Ensure you understand the security implications."
fi


bashio::log.info "FileBrowser resolved arguments: ${ARGS}"
bashio::log.info "Starting FileBrowser..."

# The /filebrowser executable is in the PATH or at root in the base image.
# shellcheck disable=SC2086
exec /filebrowser ${ARGS}