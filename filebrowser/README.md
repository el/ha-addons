# filebrowser/README.md

# Home Assistant Add-on: FileBrowser

![FileBrowser](https://raw.githubusercontent.com/filebrowser/docs/master/static/img/screenshot.png)

FileBrowser is a web-based file manager that allows you to browse, manage, and share files and folders. This add-on integrates FileBrowser into Home Assistant using the official `filebrowser/filebrowser` Docker image and supports access via Home Assistant Ingress.

## About

This add-on runs [FileBrowser](https://filebrowser.org/), providing a convenient way to manage your files directly from your Home Assistant setup. You can access it through the Home Assistant sidebar after installation.

## Installation

1.  Add your add-on repository URL to Home Assistant (Settings -> Add-ons -> Add-on Store -> Repositories). For example: `https://github.com/el/ha-addons` (update this URL if it's different).
2.  Find "FileBrowser" in the Add-on Store and click "Install".
3.  Enable "Show in sidebar" if you want to access FileBrowser directly from the Home Assistant menu.
4.  Review and adjust configuration options under the "Configuration" tab if needed.
5.  Start the add-on.

## Configuration

The add-on can be configured via the "Configuration" tab in the Home Assistant UI.

Available options:

- **`root_directory`**: (string, default: `/share`)
  The main directory that FileBrowser will serve and manage. Mapped paths like `/config`, `/media`, `/share` can be used.
- **`database_file`**: (string, default: `/config/filebrowser/filebrowser.db`)
  The path where FileBrowser will store its database file (e.g., user accounts, settings). This should be in a persistent location like `/config`.
- **`log_level`**: (string, default: `info`)
  Set the logging level for FileBrowser. Can be `debug`, `info`, `warn`, or `error`.
- **`no_auth`**: (boolean, default: `false`)
  Set to `true` to disable authentication. **Use with extreme caution!**
- **`allow_commands`**: (boolean, default: `true`)
  Allow executing commands (if FileBrowser is compiled with this feature).
- **`allow_edit`**: (boolean, default: `true`)
  Allow editing files.
- **`allow_new`**: (boolean, default: `true`)
  Allow creating new files/folders.
- **`allow_publish`**: (boolean, default: `false`)
  Allow creating share links to files. **Be careful as this can expose files publicly.**
- **`commands`**: (string, default: `git,svn,hg`)
  Comma-separated list of commands allowed to be executed if `allow_commands` is true.

**Note on Access:**
The internal port for FileBrowser within the addon is fixed to `80`.

- **Ingress (Recommended):** Access via the Home Assistant sidebar or the "Open Web UI" button on the addon page.
- **Direct Access (Optional):** If you need direct network access, you can map a host port to the addon's internal port 80 in the "Network" section of the addon configuration (e.g., map host port `8080` to container port `80`).

## First Use

1.  Once the add-on is started, access it via Ingress (sidebar or "Open Web UI").
2.  If `no_auth` is `false` (default), the initial credentials are:
    - **Username:** `admin`
    - **Password:** `admin`
      It is **strongly recommended** to change the default password immediately after your first login via the "Settings" menu within FileBrowser.

## Troubleshooting

- Check the addon logs in Home Assistant for messages from `run.sh` (prefixed with "STEP 1", "STEP 2", "STEP 3") and from FileBrowser itself.
- If static assets (CSS, JavaScript) are not loading correctly via Ingress, examine the logged `INGRESS_ENTRY_PATH` and `baseurl` argument. If these seem correct, the issue might be with how FileBrowser handles the `baseurl` for static content.

## Support

- For issues specifically with this Home Assistant add-on, please open an issue on your GitHub repository (e.g., `https://github.com/el/ha-addons/issues`).
- For issues related to FileBrowser itself, please refer to the [FileBrowser GitHub repository](https://github.com/filebrowser/filebrowser/issues).

## License

This Home Assistant add-on is available under the MIT license. See the [LICENSE](LICENSE) file for details.
FileBrowser and the `filebrowser/filebrowser` Docker image are distributed under their own respective licenses.
