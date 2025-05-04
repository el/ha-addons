#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

set -e

bashio::log.info "--- FileBrowser Addon run.sh (bashio version) ---"
bashio::log.info "Date: $(date)"
bashio::log.info "User: $(id)"
bashio::log.info "Runtime PATH: '${PATH}'"
bashio::log.info "---------------------------------"

# --- Read Configuration using bashio ---
ROOT_DIRECTORY=$(bashio::config 'root_directory')
DATABASE_FILE=$(bashio::config 'database_file')
LOG_LEVEL=$(bashio::config 'log_level')
NO_AUTH=$(bashio::config 'no_auth')
ALLOW_COMMANDS=$(bashio::config 'allow_commands')
ALLOW_EDIT=$(bashio::config 'allow_edit')
ALLOW_NEW=$(bashio::config 'allow_new')
ALLOW_PUBLISH=$(bashio::config 'allow_publish')
# 'commands' option was removed from config schema as it's not a direct FileBrowser flag.

INTERNAL_PORT=80 # FileBrowser will listen on this port

bashio::log.info "[Config] Root Directory: ${ROOT_DIRECTORY}"
bashio::log.info "[Config] Database File: ${DATABASE_FILE}"
bashio::log.info "[Config] Log Level for FileBrowser: ${LOG_LEVEL}"
bashio::log.info "[Config] No Auth: ${NO_AUTH}"
bashio::log.info "[Config] Allow Commands: ${ALLOW_COMMANDS}"
# Add other config echoes if needed

# --- Ensure database directory exists ---
DB_DIR=$(dirname "${DATABASE_FILE}")
if [[ ! -d "$DB_DIR" ]]; then
    bashio::log.info "Database directory ${DB_DIR} does not exist. Creating..."
    if mkdir -p "$DB_DIR"; then
        bashio::log.info "Database directory ${DB_DIR} created."
    else
        bashio::log.error "Failed to create database directory ${DB_DIR}."
        bashio::exit.nok "Cannot create database directory."
    fi
fi

# --- Prepare FileBrowser Arguments ---
# FileBrowser executable should be in PATH now, or we can use /usr/local/bin/filebrowser
EXECUTABLE_PATH="/usr/local/bin/filebrowser" # Path where we installed it

EXEC_ARGS=(
    "${EXECUTABLE_PATH}"
    "--address=0.0.0.0"
    "--port=${INTERNAL_PORT}"
    "--root=${ROOT_DIRECTORY}"
    "--database=${DATABASE_FILE}"
    "--log=${LOG_LEVEL}"
)

# --- Ingress Base URL using bashio ---
INGRESS_ENTRY_PATH=$(bashio::addon.ingress_entry)
if [[ -n "$INGRESS_ENTRY_PATH" ]]; then
    bashio::log.info "Found Ingress Entry Path via bashio: '${INGRESS_ENTRY_PATH}'"
    # FileBrowser's --baseurl must start with / and not end with / (unless it's just /)
    # bashio::addon.ingress_entry should provide it correctly formatted.
    # Let's ensure no trailing slash if not root, as per FileBrowser docs.
    if [[ "$INGRESS_ENTRY_PATH" != "/" && "${INGRESS_ENTRY_PATH: -1}" == "/" ]]; then
        INGRESS_ENTRY_PATH="${INGRESS_ENTRY_PATH%/}"
    fi
    EXEC_ARGS+=("--baseurl=${INGRESS_ENTRY_PATH}")
    bashio::log.info "[Config] Using Ingress base URL for FileBrowser: '${INGRESS_ENTRY_PATH}'"
else
    bashio::log.warning "bashio::addon.ingress_entry did not return a path. FileBrowser will use root base URL (/). This may cause issues with Ingress asset paths."
fi

# --- Boolean Flags & Other Options ---
if bashio::config.true 'no_auth'; then
    EXEC_ARGS+=("--noauth")
    bashio::log.warning "FileBrowser configured with NO AUTHENTICATION."
fi

if ! bashio::config.true 'allow_commands'; then # If allow_commands is false
    EXEC_ARGS+=("--disable-exec")
    bashio::log.info "[Config] Command execution will be disabled (--disable-exec)."
else
    bashio::log.info "[Config] Command execution is enabled (no --disable-exec flag)."
fi

if ! bashio::config.true 'allow_edit'; then
    EXEC_ARGS+=("--no-edit")
fi

if bashio::config.true 'allow_publish'; then
    EXEC_ARGS+=("--allow-publish")
    bashio::log.warning "FileBrowser configured to allow file publishing. Use with caution."
fi

bashio::log.info "--- Starting FileBrowser ---"
bashio::log.info "Final arguments for FileBrowser:"
for arg in "${EXEC_ARGS[@]}"; do
    bashio::log.info "  ${arg}"
done
bashio::log.info "----------------------------------------------------"

exec "${EXEC_ARGS[@]}"