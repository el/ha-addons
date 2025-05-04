# filebrowser/CHANGELOG.md

## 0.1.1 - Unreleased

- Added Home Assistant Ingress support.
- FileBrowser can now be accessed from the Home Assistant sidebar.
- Internal port fixed to 80. `port` option removed from user configuration.
- `base_url` option removed; Ingress path is now handled automatically.
- Updated documentation for Ingress access.
- Adjusted FileBrowser CLI flags in `run.sh` for better compatibility (e.g., `--disable-exec`).

## 0.1.0 - Unreleased

- Initial release of the FileBrowser add-on.
- Uses `filebrowser/filebrowser` Docker image.
- Configurable root directory, database path, port, and other common FileBrowser settings.
- Default credentials for first login: `admin` / `admin`.
