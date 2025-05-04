#!/usr/bin/with-contenv bashio

bashio::log.info "Starting FileBrowser addon (run.sh version for 0.1.6)..."

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

# --- Critical Debugging Information for Ingress ---
RAW_INGRESS_PATH=$(bashio::addon.ingress_entry)
bashio::log.info "--------------------------------------------------------------------"
bashio::log.info "STEP 1: Raw INGRESS_ENTRY_PATH from bashio::addon.ingress_entry:"
bashio::log.info "        '${RAW_INGRESS_PATH}'"
bashio::log.info "--------------------------------------------------------------------"

# Prepare FileBrowser arguments
FB_BASEURL_VALUE="" # This will hold the path like /your/ingress/path

if [[ -n "$RAW_INGRESS_PATH" ]]; then
    TEMP_FB_BASEURL="$RAW_INGRESS_PATH"
    # Ensure it starts with / (bashio should already provide this)
    if [[ "${TEMP_FB_BASEURL:0:1}" != "/" ]];
    then
        bashio::log.warning "RAW_INGRESS_PATH ('${RAW_INGRESS_PATH}') does not start with a slash. Prepending one."
        TEMP_FB_BASEURL="/${TEMP_FB_BASEURL}"
    fi

    # Ensure it doesn't end with a slash unless it's just "/"
    # FileBrowser --baseurl: "must start with / and must not end with /"
    if [[ "$TEMP_FB_BASEURL" != "/" && "${TEMP_FB_BASEURL: -1}" == "/" ]];
    then
        bashio::log.info "Removing trailing slash from '${TEMP_FB_BASEURL}' for --baseurl."
        TEMP_FB_BASEURL="${TEMP_FB_BASEURL%/}"
    fi
    FB_BASEURL_VALUE="$TEMP_FB_BASEURL"
    bashio::log.info "STEP 2: Processed base URL value for FileBrowser:"
    bashio::log.info "        '${FB_BASEURL_VALUE}'"
else
    bashio::log.warning "INGRESS_ENTRY_PATH from bashio is empty. FileBrowser will not receive a --baseurl argument specific to Ingress."
fi
bashio::log.info "--------------------------------------------------------------------"

# Construct exec arguments array
EXEC_ARGS=(
    "/filebrowser"
    "--address=0.0.0.0"
    "--port=${INTERNAL_PORT}"
    "--root=${CONFIG_ROOT_DIRECTORY}"
    "--database=${CONFIG_DATABASE_FILE}"
    "--log=${CONFIG_LOG_LEVEL}"
)

if [[ -n "$FB_BASEURL_VALUE" ]]; then
    EXEC_ARGS+=("--baseurl=${FB_BASEURL_VALUE}")
fi

if bashio::config.true 'no_auth'; then
    EXEC_ARGS+=("--noauth")
    bashio::log.warning "FileBrowser is running with NO AUTHENTICATION. This is insecure."
fi

# Check FileBrowser version for exact flags if issues arise (e.g. --disable-exec vs --no-command)
if bashio::config.false 'allow_commands'; then
    EXEC_ARGS+=("--disable-exec")
else
    if bashio::config.has_value 'commands'; then
        CONFIG_COMMANDS=$(bashio::config 'commands')
        EXEC_ARGS+=("--commands=${CONFIG_COMMANDS}")
    fi
fi

if bashio::config.false 'allow_edit'; then
    EXEC_ARGS+=("--no-edit") # Verify actual flag
fi

if bashio::config.true 'allow_publish'; then
    EXEC_ARGS+=("--allow-publish")
    bashio::log.warning "FileBrowser is allowing file publishing. Ensure you understand the security implications."
fi

bashio::log.info "STEP 3: Final arguments being passed to FileBrowser executable:"
for arg in "${EXEC_ARGS[@]}"; do
    bashio::log.info "  ${arg}"
done
bashio::log.info "--------------------------------------------------------------------"
bashio::log.info "Attempting to execute FileBrowser..."

exec "${EXEC_ARGS[@]}"