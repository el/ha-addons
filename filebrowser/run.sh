#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- FileBrowser Addon run.sh ---"
echo "Date: $(date)"
echo "User: $(id)"
echo "Current Directory: $(pwd)"
echo "Runtime PATH: '$PATH'" # For debugging, good to keep for now
echo "---------------------------------"

# --- Configuration Defaults ---
DEFAULT_ROOT_DIRECTORY="/share"
DEFAULT_DATABASE_FILE="/config/filebrowser/filebrowser.db"
DEFAULT_LOG_LEVEL="info"
DEFAULT_NO_AUTH="false"
DEFAULT_ALLOW_COMMANDS="true" # Default to true, as per your config schema
DEFAULT_ALLOW_EDIT="true"
DEFAULT_ALLOW_NEW="true"
DEFAULT_ALLOW_PUBLISH="false"
# DEFAULT_COMMANDS is not used as a direct flag anymore
INTERNAL_PORT=80

CONFIG_FILE="/data/options.json"

# --- Read Configuration from /data/options.json ---
if [ -f "$CONFIG_FILE" ]; then
    echo "Reading configuration from $CONFIG_FILE"
    ROOT_DIRECTORY=$(jq -r '.root_directory // empty' "$CONFIG_FILE")
    DATABASE_FILE=$(jq -r '.database_file // empty' "$CONFIG_FILE")
    LOG_LEVEL=$(jq -r '.log_level // empty' "$CONFIG_FILE")
    NO_AUTH_STR=$(jq -r '.no_auth // "false"' "$CONFIG_FILE")
    ALLOW_COMMANDS_STR=$(jq -r '.allow_commands // "true"' "$CONFIG_FILE") # Read from config
    ALLOW_EDIT_STR=$(jq -r '.allow_edit // "true"' "$CONFIG_FILE")
    ALLOW_NEW_STR=$(jq -r '.allow_new // "true"' "$CONFIG_FILE")
    ALLOW_PUBLISH_STR=$(jq -r '.allow_publish // "false"' "$CONFIG_FILE")
    # 'commands' field from config is not passed as a CLI flag to FileBrowser
else
    echo "WARNING: Configuration file $CONFIG_FILE not found. Using default values."
    NO_AUTH_STR="$DEFAULT_NO_AUTH"
    ALLOW_COMMANDS_STR="$DEFAULT_ALLOW_COMMANDS"
    # ... set other defaults if needed ...
fi

# Use defaults if values are empty or not set
ROOT_DIRECTORY=${ROOT_DIRECTORY:-$DEFAULT_ROOT_DIRECTORY}
DATABASE_FILE=${DATABASE_FILE:-$DEFAULT_DATABASE_FILE}
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}

echo "[Config] Root Directory: $ROOT_DIRECTORY"
echo "[Config] Database File: $DATABASE_FILE"
echo "[Config] Log Level for FileBrowser: $LOG_LEVEL"
echo "[Config] No Auth: $NO_AUTH_STR"
echo "[Config] Allow Commands (feature toggle): $ALLOW_COMMANDS_STR"
# Add other config echoes if needed

# --- Ensure database directory exists ---
DB_DIR=$(dirname "${DATABASE_FILE}")
if [[ ! -d "$DB_DIR" ]]; then
    echo "Database directory ${DB_DIR} does not exist. Creating..."
    if mkdir -p "$DB_DIR"; then
        echo "Database directory ${DB_DIR} created."
    else
        echo "ERROR: Failed to create database directory ${DB_DIR}." >&2
        exit 1
    fi
fi

# --- Prepare FileBrowser Arguments ---
EXECUTABLE_PATH="/filebrowser" # We confirmed this exists at the root

EXEC_ARGS=(
    "${EXECUTABLE_PATH}"
    "--address=0.0.0.0"
    "--port=${INTERNAL_PORT}"
    "--root=${ROOT_DIRECTORY}"
    "--database=${DATABASE_FILE}"
    "--log=${LOG_LEVEL}"
    # "--tempdir=/tmp"
)

# --- Ingress Base URL ---
FB_BASEURL_VALUE=""
# SUPERVISOR_INGRESS_ENTRY is set by Home Assistant Supervisor for Ingress-enabled addons
if [ -n "$SUPERVISOR_INGRESS_ENTRY" ]; then
    echo "Found SUPERVISOR_INGRESS_ENTRY: '$SUPERVISOR_INGRESS_ENTRY'"
    TEMP_FB_BASEURL="$SUPERVISOR_INGRESS_ENTRY"
    if [[ "$TEMP_FB_BASEURL" != "/" && "${TEMP_FB_BASEURL: -1}" == "/" ]]; then
        TEMP_FB_BASEURL="${TEMP_FB_BASEURL%/}"
    fi
    FB_BASEURL_VALUE="$TEMP_FB_BASEURL"
    EXEC_ARGS+=("--baseurl=${FB_BASEURL_VALUE}")
    echo "[Config] Using Ingress base URL for FileBrowser: '$FB_BASEURL_VALUE'"
else
    echo "SUPERVISOR_INGRESS_ENTRY env var not found. FileBrowser will use root base URL (/). This is expected if not accessing via Ingress panel or if direct access is used."
fi

# --- Boolean Flags & Other Options ---
if [[ "$NO_AUTH_STR" == "true" ]]; then
    EXEC_ARGS+=("--noauth")
    echo "WARNING: FileBrowser configured with NO AUTHENTICATION."
fi

# Handle command execution toggle; --commands flag is removed
if [[ "$ALLOW_COMMANDS_STR" == "false" ]]; then
    EXEC_ARGS+=("--disable-exec")
    echo "[Config] Command execution will be disabled (--disable-exec)."
else
    echo "[Config] Command execution is enabled (no --disable-exec flag)."
    # Note: Which specific commands are allowed is typically managed within FileBrowser's
    # internal settings or user permissions, not by a startup flag like --commands=git,svn
fi

if [[ "$ALLOW_EDIT_STR" == "false" ]]; then
    EXEC_ARGS+=("--no-edit")
fi

if [[ "$ALLOW_PUBLISH_STR" == "true" ]]; then
    EXEC_ARGS+=("--allow-publish")
    echo "WARNING: FileBrowser configured to allow file publishing. Use with caution."
fi

echo "--- Starting FileBrowser ---"
echo "Final arguments for FileBrowser:"
for arg in "${EXEC_ARGS[@]}"; do
    printf "  %s\n" "${arg}"
done
echo "----------------------------------------------------"

exec "${EXEC_ARGS[@]}"