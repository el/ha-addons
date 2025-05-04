# filebrowser/README.md

# Home Assistant Add-on: File Browser

<p align="center">
  <img src="https://raw.githubusercontent.com/filebrowser/logo/master/banner.png" width="550"/>
</p>

![Preview](https://user-images.githubusercontent.com/5447088/50716739-ebd26700-107a-11e9-9817-14230c53efd2.gif)

A self-hosted filebrowser based on the `filebrowser/filebrowser` Docker image.

## About

This add-on allows you to run [File Browser](https://filebrowser.org/) within your Home Assistant environment. File Browser is a very lightweight and fast filebrowser implemented in JavaScript, using XMLHttpRequest and Web Workers.

This add-on uses the official [filebrowser/filebrowser](https://hub.docker.com/r/filebrowser/filebrowser) Docker image.

## Installation

1.  Navigate in your Home Assistant frontend to **Settings** -> **Add-ons** -> **Add-on Store**.
2.  Click on the triple-dot menu in the top right and select **Repositories**.
3.  Add the following URL: `https://github.com/el/ha-addons` (or your specific repository URL).
4.  Close the dialog. The "File Browser" add-on should now appear in the store.
5.  Click on "File Browser", then click "Install".
6.  Configure the port mapping if necessary. By default, port `80` on your Home Assistant host is mapped to port `80` of the File Browser container.
7.  Start the add-on.

## Configuration

No specific add-on configuration is required beyond the standard Home Assistant add-on options.

### Port Configuration

The default port for accessing the File Browser web interface is `8080`. You can change this in the "Network" section of the add-on configuration page if `8080` is already in use on your host.

## Basic Usage

Once the add-on is installed and started:

1.  Open your web browser.
2.  Navigate to `http://<your-home-assistant-ip>:8080` (replace `<your-home-assistant-ip>` with the actual IP address of your Home Assistant instance, and `8080` with the host port you configured).
3.  The File Browser interface will load, and you can start a speed test.

## Support

- For issues specifically with this Home Assistant add-on, please open an issue on the [GitHub repository](https://github.com/el/ha-addons/issues).

## License

This Home Assistant add-on is available under the MIT license. See the [LICENSE](LICENSE) file for details.
File Browser and the filebrowser/filebrowser Docker image are distributed under their own respective licenses.
