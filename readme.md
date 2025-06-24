WordPress Change Domain Script 🔄

# About 📝
A bash script to change WordPress domain names safely and efficiently across your database.

- Author 👨‍💻
- Percio Andrade
- Email: percio@zendev.com.br
- Website: Zendev : https://zendev.com.br

# Features ⭐
- Automatic WordPress database credential detection 🔍
- Optional database backup creation 💾
- Multi-table domain updates 🔄
- HTTP/HTTPS URL handling 🔒
- Remote version checking 🔄

# Requirements 📋
- MySQL/MariaDB client 🗄️
- WordPress installation with wp-config.php ⚙️
- Database credentials with UPDATE privileges 🔑

```bash
./change_domain.sh [-s|--skip] [-n|--noversion]
```

# Options 🛠️
- `-n`, `--noversion`   Skip version check against remote source
- `-s`, `--skip`        Skip database backup creation
- `-h`, `--help`        Display help message

# Example Usage 💡

# Basic usage
```bash
./change_domain.sh

# Skip database backup
./change_domain.sh --skip

# Skip version check
./change_domain.sh --noversion

# Show help
./change_domain.sh --help
````

# Tables Updated 📊
- wp_options (siteurl and home)
- wp_posts (guid and post_content)
- wp_postmeta (meta_value)

# Safety Features 🛡️
- Creates database backup before changes
- Confirms domain changes with user
- Validates database credentials
- Handles both HTTP and HTTPS URLs

# Notes 📌
- Ensure you have the necessary permissions to run the script as root.
- Make sure all required commands are installed on your system.
- Always backup your database before running
- Ensure proper database permissions
- Run from WordPress root directory

# License 📄
This project is licensed under the GNU General Public License v2.0
