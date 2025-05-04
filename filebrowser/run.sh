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
# bashio::addon.ingress_entry provides the base path for Ingress.
# FileBrowser's --baseurl must start with / and not end with / (unless it's just /).
RAW_INGRESS_PATH=$(bashio::addon.ingress_entry)
bashio::log.info "Raw INGRESS_ENTRY_PATH from bashio: '${RAW_INGRESS_PATH}'"

FB_BASEURL=""

if [[ -n "$RAW_INGRESS_PATH" ]]; then
    # Ensure it starts with / (bashio should already provide this, but double-check)
    if [[ "${RAW_INGRESS_PATH:0:1}" != "/" ]]; then
        bashio::log.warning "RAW_INGRESS_PATH does not start with a slash. Prepending one."
        FB_BASEURL="/${RAW_INGRESS_PATH}"
    else
        FB_BASEURL="$RAW_INGRESS_PATH"
    fi

    # Ensure it doesn't end with a slash unless it's just "/"
    if [[ "$FB_BASEURL" != "/" && "${FB_BASEURL: -1}" == "/" ]]; then
        FB_BASEURL="${FB_BASEURL%/}"
    fi

    ARGS="${ARGS} --baseurl \"${FB_BASEURL}\""
    bashio::log.info "Configuring FileBrowser with effective Ingress base URL: '${FB_BASEURL}'"
else
    # This case should ideally not happen if Ingress is enabled in config.yaml
    bashio::log.warning "INGRESS_ENTRY_PATH from bashio is empty. FileBrowser will use root base URL (/). This may cause issues if Ingress is the intended access method."
    # FileBrowser defaults to "/" if --baseurl is not explicitly set, which is fine for non-Ingress.
fi


if bashio::config.true 'no_auth'; then
    ARGS="${ARGS} --noauth"
    bashio::log.warning "FileBrowser is running with NO AUTHENTICATION. This is insecure."
fi

# FileBrowser v2.24.0+ uses --disable-exec. Check FileBrowser version for exact flags.
if bashio::config.false 'allow_commands'; then
    ARGS="${ARGS} --disable-exec"
else
    if bashio::config.has_value 'commands'; then
        CONFIG_COMMANDS=$(bashio::config 'commands')
        ARGS="${ARGS} --commands \"${CONFIG_COMMANDS}\""
    fi
fi

if bashio::config.false 'allow_edit'; then
    # Assuming --disable-edit or similar flag exists if 'no-edit' is not current
    # Check FileBrowser documentation for the correct flag for your version
    ARGS="${ARGS} --no-edit" # Placeholder, verify actual flag
fi

if bashio::config.true 'allow_publish'; then
    ARGS="${ARGS} --allow-publish"
    bashio::log.warning "FileBrowser is allowing file publishing. Ensure you understand the security implications."
fi


bashio::log.info "FileBrowser resolved arguments: ${ARGS}"