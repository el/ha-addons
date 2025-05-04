#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "[cont-init.d] Starting run.sh for FileBrowser (bashio-free version)..."

# --- Configuration Defaults ---
DEFAULT_ROOT_DIRECTORY="/share"
DEFAULT_DATABASE_FILE="/config/filebrowser/filebrowser.db"
DEFAULT_LOG_LEVEL="info"
DEFAULT_NO_AUTH="false"
DEFAULT_ALLOW_COMMANDS="true"
DEFAULT_ALLOW_EDIT="true"
DEFAULT_ALLOW_NEW="true"
DEFAULT_ALLOW_PUBLISH="false"
DEFAULT_COMMANDS="git,svn,hg"
INTERNAL_PORT=80

CONFIG_FILE="/data/options.json"

# --- Read Configuration from /data/options.json ---
if [ -f "$CONFIG_FILE" ]; then
    echo "Reading configuration from $CONFIG_FILE"
    ROOT_DIRECTORY=$(jq -r '.root_directory // empty' "$CONFIG_FILE")
    DATABASE_FILE=$(jq -r '.database_file // empty' "$CONFIG_FILE")
    LOG_LEVEL=$(jq -r '.log_level // empty' "$CONFIG_FILE")
    NO_AUTH_STR=$(jq -r '.no_auth // "false"' "$CONFIG_FILE") # Ensure string output for boolean

    ALLOW_COMMANDS_STR=$(jq -r '.allow_commands // "true"' "$CONFIG_FILE")
    ALLOW_EDIT_STR=$(jq -r '.allow_edit // "true"' "$CONFIG_FILE")
    ALLOW_NEW_STR=$(jq -r '.allow_new // "true"' "$CONFIG_FILE")
    ALLOW_PUBLISH_STR=$(jq -r '.allow_publish // "false"' "$CONFIG_FILE")
    COMMANDS=$(jq -r '.commands // empty' "$CONFIG_FILE")
else
    echo "WARNING: Configuration file $CONFIG_FILE not found. Using default values."
    NO_AUTH_STR="$DEFAULT_NO_AUTH"
    ALLOW_COMMANDS_STR="$DEFAULT_ALLOW_COMMANDS"
    ALLOW_EDIT_STR="$DEFAULT_ALLOW_EDIT"
    ALLOW_NEW_STR="$DEFAULT_ALLOW_NEW"
    ALLOW_PUBLISH_STR="$DEFAULT_ALLOW_PUBLISH"
fi

# Use defaults if values are empty or not set
ROOT_DIRECTORY=${ROOT_DIRECTORY:-$DEFAULT_ROOT_DIRECTORY}
DATABASE_FILE=${DATABASE_FILE:-$DEFAULT_DATABASE_FILE}
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}
COMMANDS=${COMMANDS:-$DEFAULT_COMMANDS}

echo "[config] Root Directory: $ROOT_DIRECTORY"
echo "[config] Database File: $DATABASE_FILE"
echo "[config] Log Level: $LOG_LEVEL"
echo "[config] No Auth: $NO_AUTH_STR"
echo "[config] Allow Commands: $ALLOW_COMMANDS_STR"
echo "[config] Allow Edit: $ALLOW_EDIT_STR"
echo "[config] Allow New: $ALLOW_NEW_STR"
echo "[config] Allow Publish: $ALLOW_PUBLISH_STR"
echo "[config] Commands: $COMMANDS"
echo "[config] Internal Port: $INTERNAL_PORT"

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
# Note: The first argument is now "filebrowser" without the leading slash.
EXEC_ARGS=(
    "filebrowser" # <--- Executable name, relying on PATH
    "--address=0.0.0.0"
    "--port=${INTERNAL_PORT}"
    "--root=${ROOT_DIRECTORY}"
    "--database=${DATABASE_FILE}"
    "--log=${LOG_LEVEL}"
)

# --- Ingress Base URL ---
FB_BASEURL_VALUE=""
if [ -n "$INGRESS_ENTRY" ]; then # INGRESS_ENTRY is set by Supervisor for Ingress-enabled addons
    echo "Found INGRESS_ENTRY environment variable: '$INGRESS_ENTRY'"
    TEMP_FB_BASEURL="$INGRESS_ENTRY"
    if [[ "$TEMP_FB_BASEURL" != "/" && "${TEMP_FB_BASEURL: -1}" == "/" ]]; then
        TEMP_FB_BASEURL="${TEMP_FB_BASEURL%/}"
    fi
    FB_BASEURL_VALUE="$TEMP_FB_BASEURL"
    EXEC_ARGS+=("--baseurl=${FB_BASEURL_VALUE}")
    echo "[config] Using Ingress base URL for FileBrowser: '$FB_BASEURL_VALUE'"
else
    echo "INGRESS_ENTRY environment variable not found. FileBrowser will use root base URL (/). This is normal if not accessing via Ingress or if Ingress is not fully set up for this non-bashio script yet."
fi

# --- Boolean Flags & Other Options ---
if [[ "$NO_AUTH_STR" == "true" ]]; then
    EXEC_ARGS+=("--noauth")
    echo "WARNING: FileBrowser configured with NO AUTHENTICATION."
fi

if [[ "$ALLOW_COMMANDS_STR" == "false" ]]; then
    EXEC_ARGS+=("--disable-exec")
else
    if [[ -n "$COMMANDS" ]]; then
        EXEC_ARGS+=("--commands=${COMMANDS}")
    fi
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