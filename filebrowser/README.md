# filebrowser/README.md

# Home Assistant Add-on: FileBrowser

![FileBrowser](https://raw.githubusercontent.com/filebrowser/docs/master/static/img/screenshot.png)

FileBrowser is a web-based file manager that allows you to browse, manage, and share files and folders. This add-on integrates FileBrowser into Home Assistant using the official `filebrowser/filebrowser` Docker image and supports access via Home Assistant Ingress.

## About

This add-on runs [FileBrowser](https://filebrowser.org/), providing a convenient way to manage your files directly from your Home Assistant setup. You can access it through the Home Assistant sidebar after installation.

## Installation

1.  Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on Store**.
2.  Click on the triple-dot menu in the top right and select **Repositories**.
3.  Add the following URL: `https://github.com/el/ha-addons` (or your specific repository URL).
4.  Close the dialog. The "FileBrowser" add-on should now appear in the store.
5.  Click on "FileBrowser", then click "Install".
6.  Enable "Show in sidebar" if you want to access FileBrowser directly from the Home Assistant menu.
7.  Configure the add-on options as described below.
8.  Start the add-on.

## Configuration

The add-on can be configured via the "Configuration" tab in the Home Assistant UI.

Available options:

- **`root_directory`**: (string, default: `/share`)
  The main directory that FileBrowser will serve and manage. You can set this to `/config`, `/media`, `/share`, or any other mapped path.
- **`database_file`**: (string, default: `/config/filebrowser/filebrowser.db`)
  The path where FileBrowser will store its database file. This should be in a persistent location, like `/config`.
- **`log_level`**: (string, default: `info`)
  Set the logging level for FileBrowser. Can be `debug`, `info`, `warn`, or `error`.
- **`no_auth`**: (boolean, default: `false`)
  Set to `true` to disable authentication. **Use with extreme caution!**
- **`allow_commands`**: (boolean, default: `true`)
  Allow executing commands.
- **`allow_edit`**: (boolean, default: `true`)
  Allow editing files.
- **`allow_new`**: (boolean, default: `true`)
  Allow creating new files/folders.
- **`allow_publish`**: (boolean, default: `false`)
  Allow creating share links to files. **Be careful as this can expose files publicly.**
- **`commands`**: (string, default: `git,svn,hg`)
  Comma-separated list of commands allowed to be executed.

**Note:** The internal port for FileBrowser is fixed to `80`. If you need direct access (not via Ingress), ensure you configure the host port mapping under the "Network" section of the add-on (e.g., `8080:80`).

## Accessing FileBrowser

- **Via Ingress (Recommended):** If you have enabled "Show in sidebar", you can click the "FileBrowser" item in your Home Assistant sidebar.
- **Via Direct Access:** You can also access FileBrowser directly at `http://<your-home-assistant-ip>:<host-port>` if you have configured a host port in the Network settings (e.g., `http://homeassistant.local:8080`).

## Basic Usage

1.  Once the add-on is started, access it via Ingress (sidebar) or direct URL.
2.  On the first run, or if `no_auth` is `false` and the database is new, the default credentials are:
    - **Username:** `admin`
    - **Password:** `admin`
      It is highly recommended to change the default password immediately after logging in for the first time via the "Settings" menu within FileBrowser.

## Support

- For issues specifically with this Home Assistant add-on, please open an issue on the [GitHub repository](https://github.com/el/ha-addons/issues).
- For issues related to FileBrowser itself, please refer to the [FileBrowser GitHub repository](https://github.com/filebrowser/filebrowser/issues).

## License

This Home Assistant add-on is available under the MIT license. See the [LICENSE](LICENSE) file for details.
FileBrowser and the `filebrowser/filebrowser` Docker image are distributed under their own respective licenses (typically Apache 2.0).
