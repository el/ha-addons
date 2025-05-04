# filebrowser/CHANGELOG.md

## 0.1.6 - 2025-05-04

- Corrected Dockerfile to explicitly set `ENTRYPOINT ["/run.sh"]` to ensure `run.sh` executes and overrides base image entrypoint.
- Updated `run.sh` with robust argument passing and detailed logging for Ingress path and `--baseurl` setting.
- Refreshed all addon files to ensure consistency.
- Updated README with clearer instructions and troubleshooting notes.

## 0.1.5 (and earlier)

- Previous attempts to fix Ingress, run.sh execution, and build issues.
- (Summarize previous changes if you have them, or start fresh from 0.1.6 if this is a complete reset)
