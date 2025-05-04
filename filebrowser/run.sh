#!/usr/bin/env bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- RUN.SH EXECUTION STARTED (Addon Version 0.1.6h or later) ---"
echo "--- RUNTIME PATH IS: '$PATH' ---"
echo "--- USER is: '$(id)' ---"
echo "--- Current directory is: '$(pwd)' ---"
echo "--- Listing / : ---"
ls -l / || echo "Could not list /"
echo "--- Listing /usr/bin : ---"
ls -l /usr/bin || echo "Could not list /usr/bin"
echo "--- Listing /usr/local/bin : ---"
ls -l /usr/local/bin || echo "Could not list /usr/local/bin"
echo "--- Checking 'which filebrowser': $(command -v filebrowser || echo 'filebrowser not in PATH via command -v')"
echo "-----------------------------------------------------------------"


# --- Configuration Defaults ---
DEFAULT_ROOT_DIRECTORY="/share"
DEFAULT_DATABASE_FILE="/config/filebrowser/filebrowser.db"
DEFAULT_LOG_LEVEL="info"
# ... (rest of your default and config loading logic from the previous run.sh)
DEFAULT_NO_AUTH="false"
DEFAULT_ALLOW_COMMANDS="true"
DEFAULT_ALLOW_EDIT="true"
DEFAULT_ALLOW_NEW="true"
DEFAULT_ALLOW_PUBLISH="false"
DEFAULT_COMMANDS="git,svn,hg"
INTERNAL_PORT=80

CONFIG_FILE="/data/options.json"

if [ -f "$CONFIG_FILE" ]; then
    echo "Reading configuration from $CONFIG_FILE"
    ROOT_DIRECTORY=$(jq -r '.root_directory // empty' "$CONFIG_FILE")
    DATABASE_FILE=$(jq -r '.database_file // empty' "$CONFIG_FILE")
    LOG_LEVEL=$(jq -r '.log_level // empty' "$CONFIG_FILE")
    NO_AUTH_STR=$(jq -r '.no_auth // "false"' "$CONFIG_FILE")
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

ROOT_DIRECTORY=${ROOT_DIRECTORY:-$DEFAULT_ROOT_DIRECTORY}
DATABASE_FILE=${DATABASE_FILE:-$DEFAULT_DATABASE_FILE}
LOG_LEVEL=${LOG_LEVEL:-$DEFAULT_LOG_LEVEL}
COMMANDS=${COMMANDS:-$DEFAULT_COMMANDS}

echo "[config] Root Directory: $ROOT_DIRECTORY"
echo "[config] Database File: $DATABASE_FILE"
# ... (other echos for config)

DB_DIR=$(dirname "${DATABASE_FILE}")
if [[ ! -d "$DB_DIR" ]]; then
    echo "Database directory ${DB_DIR} does not exist. Creating..."
    if mkdir -p "$DB_DIR"; then echo "Database directory ${DB_DIR} created."; \
    else echo "ERROR: Failed to create database directory ${DB_DIR}." >&2; exit 1; fi
fi

# ---- IMPORTANT ----
# Based on your Docker BUILD log, determine the correct absolute path to 'filebrowser'.
# Example: If build log showed it was at /usr/local/bin/filebrowser, use that.
# For now, we'll try 'filebrowser' (relying on PATH) and the common absolute path '/filebrowser'.
# One of these should work if the build diagnostic was accurate.

EXECUTABLE_TO_TRY="filebrowser" # Default to relying on PATH
# If your build log (from the Dockerfile with many echos and ls commands)
# showed filebrowser was at /app/filebrowser, you would change this to:
# EXECUTABLE_TO_TRY="/app/filebrowser"
# Or if it showed it was at /filebrowser, use that explicitly.
# The diagnostic Dockerfile should have indicated where it was found.
# Let's assume for a moment, based on common practice for this image, it *should* be /filebrowser.
# The diagnostic block in the Dockerfile checked for /filebrowser, /usr/bin/filebrowser, /usr/local/bin/filebrowser, or in PATH.

# First, use the path that the build-time diagnostic check would have confirmed.
# The check was: ! command -v filebrowser && [ ! -f /filebrowser ] && [ ! -f /usr/bin/filebrowser ] && [ ! -f /usr/local/bin/filebrowser ]
# This implies if that block passed, 'filebrowser' is either in PATH or at one of those locations.
# Since 'exec "filebrowser"' failed, it suggests PATH is the issue at runtime.
# Let's try the most common explicit path from the base image.
# If you can confirm from build logs it's elsewhere, update this. For now, we try /filebrowser explicitly.
# If your diagnostic build logs (the ls -l /filebrowser parts) showed /filebrowser exists, this should work.
# If not, you need to find where it is from those build logs.
EXECUTABLE_TO_TRY="/filebrowser" # Trying the most standard absolute path for this image

echo "Attempting to use executable: '${EXECUTABLE_TO_TRY}'"


EXEC_ARGS=(
    "${EXECUTABLE_TO_TRY}"
    "--address=0.0.0.0"
    "--port=${INTERNAL_PORT}"
    "--root=${ROOT_DIRECTORY}"
    "--database=${DATABASE_FILE}"
    "--log=${LOG_LEVEL}"
)

FB_BASEURL_VALUE=""
if [ -n "$INGRESS_ENTRY" ]; then
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

if [[ "$NO_AUTH_STR" == "true" ]]; then EXEC_ARGS+=("--noauth"); echo "WARNING: No Auth."; fi
if [[ "$ALLOW_COMMANDS_STR" == "false" ]]; then EXEC_ARGS+=("--disable-exec"); else
    if [[ -n "$COMMANDS" ]]; then EXEC_ARGS+=("--commands=${COMMANDS}"); fi
fi
if [[ "$ALLOW_EDIT_STR" == "false" ]]; then EXEC_ARGS+=("--no-edit"); fi
if [[ "$ALLOW_PUBLISH_STR" == "true" ]]; then EXEC_ARGS+=("--allow-publish"); echo "WARNING: Allow Publish."; fi

echo "--- Starting FileBrowser ---"
echo "Final arguments for FileBrowser:"
for arg in "${EXEC_ARGS[@]}"; do printf "  %s\n" "${arg}"; done
echo "----------------------------------------------------"

exec "${EXEC_ARGS[@]}"