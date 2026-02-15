# WP Change Domain 🚀

Readme: [Português](README-ptbr.md)

<img src="https://github.com/user-attachments/assets/2ccc5fbf-c01e-4919-b662-320d87fddf8d" width="700">

![License](https://img.shields.io/github/license/sr00t3d/bindfilter)
![Shell Script](https://img.shields.io/badge/shell-script-green)

This Shell Bash script was developed to automate the process of changing the domain in `WordPress` installations. It performs search and replace directly in the MySQL/MariaDB database, ensuring that all references to the old domain are updated to the new one.

## 📝 Description

When moving a WordPress site to a new domain, it is not enough to just change the files. It is necessary to update several entries in the database, including post URLs, image links, and global settings. This script simplifies this process by executing SQL commands safely and quickly via terminal.

## ✨ Features

- **Options Update**: Changes siteurl and home in the `wp_options` table.
- **Global Search and Replace**: Updates URLs in posts, pages, comments, and metadata.
- **Cache Cleanup (Optional)**: Helps avoid conflicts after migration.
- **Simplicity**: Interactive terminal interface that requests the necessary data.

## 📋 Prerequisites

Before using the script, make sure the environment meets the following requirements:

- Linux/Unix Operating System.
- Terminal access (SSH).
- MySQL/MariaDB client installed.
- **Up-to-date database backup** (mandatory for safety).

## 🚀 Installation and Usage

1. Clone the repository:

```bash
git clone https://github.com/sr00t3d/wpchangedomain
cd wpchangedomain
chmod +x wpchangedomain.sh
```

2. Run the script and follow the on-screen instructions:

```bash
./wpchange_domain.sh
```

## Usage

```bash
./wpchange_domain.sh [-s|--skip] [-n|--noversion]
```
- `--noversion`   Skip version check from the remote source
- `--skip`        Skip database backup creation
- `--help`        Display help message

## ⚠️ Important Warnings

- **Backup**: **Never run scripts that modify the database without having a full backup**. If something goes wrong, you will be able to restore your site.
- **Serialized Data**: Note that direct replacements via SQL can corrupt PHP serialized data (common in some page builder plugins like Elementor). After running the script, it is recommended to review the site.
- **Permissions**: Make sure to run the script with a user that has read/write permissions on the database.

## ⚠️ Legal Notice

> [!WARNING]
> This software is provided "as is". Always make sure to test first in a development environment. The author is not responsible for any misuse, legal consequences, or data impact caused by this tool.

## 📚 Detailed Tutorial

For a complete, step-by-step guide, check out my full article:

👉 [**Change WordPress Domain in Shell**](https://perciocastelo.com.br/blog/change-wordPress-domain-in-shell.html)

## License 📄

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for more details.
