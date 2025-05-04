#!/usr/bin/env bash
# librespeed/run.sh

# The linuxserver/librespeed base image uses its own init system (s6-overlay).
# This script will execute the base image's init system.
# Since 'init: false' is set in config.yaml, this script is PID 1.

echo "[INFO] Starting LibreSpeed service using linuxserver/librespeed init..."
# exec /init