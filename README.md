# PostgreSQL & pgAdmin Auto-Launcher

## The Problem

By default, the PostgreSQL Windows background service runs continuously on "Automatic" startup, consuming system resources even when you are not actively working with databases. Manually starting and stopping the service each time you want to use pgAdmin is a tedious, multi-step process.

## The Solution

This setup provides a seamless, single-click solution that treats pgAdmin and the underlying PostgreSQL server as a single application.

When you launch the custom Start Menu shortcut, it:
1. Silently requests administrator privileges via a VBScript wrapper.
2. Starts the PostgreSQL background service.
3. Displays native Windows toast notifications for server status.
4. Opens the pgAdmin 4 interface.
5. Monitors the pgAdmin process in the background without displaying a command prompt.
6. Automatically shuts down the PostgreSQL service the moment you close pgAdmin.

## Included Files

* **install.bat**: A simple double-click launcher that bypasses default Windows execution policies to run the installer.
* **setup.ps1**: The core PowerShell script that configures your system and generates the background payload files.

## Installation Instructions

1. Extract both `install.bat` and `setup.ps1` into the same directory.
2. Double-click **install.bat**.
3. Click **Yes** when prompted by User Account Control (UAC) for administrator privileges.
4. Wait for the terminal window to display "Setup complete."
5. Press **Enter** to reboot your machine and apply the new Start Menu shortcut.

## The Final Result

Once the installation and reboot are complete, you will find a new app named **PostgreSQL** (or pgAdmin Custom) integrated directly into your Windows Start Menu. 

This operates exactly like a standard desktop application. To keep your workspace clean, **no desktop shortcut is created**. Simply open your Start Menu, search for the app, and launch it from there to start your database and UI simultaneously. 

## Under the Hood

When you run the installer, the script automatically performs the following actions:

* **Version Detection**: Scans `C:\Program Files\PostgreSQL` to dynamically find the highest installed version number.
* **Service Configuration**: Permanently changes your `postgresql-x64-[version]` Windows service from "Automatic" to "Manual" so it only runs when explicitly launched by the shortcut.
* **Payload Generation**: Creates a `start` folder inside your PostgreSQL directory containing a `.bat` file (for process management and notifications) and a `.vbs` wrapper (to hide the command prompt window).
* **Start Menu Integration**: Generates a custom `.lnk` shortcut in your global Windows Start Menu equipped with the official pgAdmin executable icon.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)

Copyright (c) Giovanni Orlotti 2026