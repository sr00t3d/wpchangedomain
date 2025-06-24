#!/bin/bash
##################################################################
# Shell script to change WordPress domain to another domain
#
# Features:
# - Automatically detects WordPress database credentials from wp-config.php
# - Creates database backup before changes (optional)
# - Updates domain across multiple WordPress tables
# - Handles both HTTP and HTTPS URLs
# - Version checking against remote source
#
# Usage: ./change_domain.sh [-s|--skip] [-n|--noversion]
#
# Options:
#   -n, --noversion   Skip version check against remote source
#   -s, --skip        Skip database backup creation
#   -h, --help        Display help message
#
# Author: Percio Andrade
# Email: percio@zendev.com.br
# Version: 1.2
#
# Requirements:
# - MySQL/MariaDB client
# - WordPress installation with wp-config.php
# - Database credentials with UPDATE privileges
##################################################################

function display_help() {
    cat <<-EOF

    Usage: $0 [-s|--skip] [-n|--noversion]

    Options:
            -n, --noversion   Skip version check      
            -s, --skip        Skip database dump creation
EOF
}

# Check for help option
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    display_help
    exit
fi

V='1.2'
URL='https://raw.githubusercontent.com/percioandrade/wpchangedomain/refs/heads/main/wpchange_domain.sh'

# Skip version check
if [[ " $* " == *" -n "* || " $* " == *" --noversion "* ]]; then
    echo '[!] We will not check this script version'
else
    # Check script version
    V_URL=$(GET ${URL}|grep -m1 "V="|cut -d "'" -f2)
    if [[ ${V} != ${V_URL} ]];then
        echo '[!] A new update for this script was released. Version '${V_URL}''
        echo '[!] Please update on update on '${URL}''
    fi
fi

echo '[!] Starting'

# Check if the wp-config.php file exists
FILE="wp-config.php"

if [[ -f "${FILE}" ]]; then
    echo '[+] File wp-config.php was found'
else
    echo '[!] File wp-config.php not found, exiting...'
    exit 1
fi

# Function to extract values from the config file
get_db_value() {
    local key="$1"
    grep -i "$key" "${FILE}" | grep -v '#' | awk -F "[=']" '{print $4}'
}

# Extract database credentials
DATABASE=$(get_db_value "DB_NAME")
DB_USER=$(get_db_value "DB_USER")
DB_PASS=$(get_db_value "DB_PASSWORD")
DB_HOST=$(get_db_value "DB_HOST")

# Check if any values are empty
if [[ -z "${DATABASE}" || -z "${DB_USER}" || -z "${DB_PASS}" || -z "${DB_HOST}" ]]; then
    echo '[!] - Empty values, exiting...'
    exit 1
fi

echo '[+] Database values founded'

echo $'
------------------------
| Database: '${DATABASE}'
| User: '${DB_USER}'
| Password: '${DB_PASS}'
| Host: '${DB_HOST}'
------------------------
'

echo '[!] Checking the current domain'
echo '[!] Trying to establish a connection, please wait....'

PREFIX=$(mysql -N -s -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" -e "SELECT table_name FROM information_schema.tables WHERE table_schema = '${DATABASE}' AND table_name LIKE '%options' LIMIT 1;")
PREFIX="${PREFIX%"_options"}"_
DOMAIN=$(mysql -N -s -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" -e "use ${DATABASE}; SELECT * FROM ${PREFIX}options WHERE option_name = 'home';" | awk '{print $3}')
MYSQL_EXIT_CODE=$?

if [[ $MYSQL_EXIT_CODE -eq 0 ]]; then
    if [[ -z "${DOMAIN}" ]]; then
        echo '[!] Unable to determine the database '${DATABASE}' domain'
    else
        echo '[+] The actual database '${DATABASE}' domain is: '${DOMAIN}' with prefix '${PREFIX}' '
    fi
else
    echo '[!] Connection to MySQL failed. Please check your database credentials'
    exit 1
fi

# Clean domain https and http
CLEANED_DOMAIN=${DOMAIN#http://}
CLEANED_DOMAIN=${DOMAIN#https://}

# Ask if the user wants to skip the database dump
if [[ " $* " == *" -s "* || " $* " == *" --skip "* ]]; then
    echo '[!] Skip database used, we will not generate a backup'
else
    # Generate a database dump using the determined prefix
    DUMP_FILE="${PREFIX}db_backup_$(date +%Y%m%d%H%M%S).sql"
    mysqldump -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" "${DATABASE}" > "${DUMP_FILE}"
    echo '[!] Dumping database, please wait...'
    echo '[+] Database dump created on: '$(pwd)/${DUMP_FILE}''
fi

echo $'[!] Please insert the new domain. Example: domain.com.br )\n'

read -p 'Insert a domain: ' INPUT_DOMAIN

# Clean input domain https and http
CLEANED_INPUT_DOMAIN=${INPUT_DOMAIN#http://}
CLEANED_INPUT_DOMAIN=${INPUT_DOMAIN#https://}

echo -e "\n[!] This script will change ${CLEANED_DOMAIN} to ${CLEANED_INPUT_DOMAIN}\n"

read -p "Do you want to continue? (y/n): " RESPONSE

# Convert the response to lowercase for comparison
RESPONSE=$(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]')

# Loop until a valid response is given
while [[ "${RESPONSE}" != "y" && "${RESPONSE}" != "n" ]]; do
    echo 'Invalid response. Please enter 'y' or 'n'.'
    read -p 'Do you want to continue? (y/n): ' RESPONSE
    RESPONSE=$(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]')
done

if [[ "${RESPONSE}" == "y" ]]; then

    echo $'\n[!] Continuing...'

    if [[ -n "$CLEANED_INPUT_DOMAIN" ]]; then
        echo $'[+] Changing database domain...\n'

        mysql -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" "${DATABASE}" -e "
        UPDATE ${PREFIX}options SET option_value = replace(option_value, '${CLEANED_DOMAIN}', '${CLEANED_INPUT_DOMAIN}') WHERE option_name = 'home' OR option_name = 'siteurl';
        UPDATE ${PREFIX}posts SET guid = replace(guid, '${CLEANED_DOMAIN}','${CLEANED_INPUT_DOMAIN}');
        UPDATE ${PREFIX}posts SET post_content = replace(post_content, '${CLEANED_DOMAIN}', '${CLEANED_INPUT_DOMAIN}');
        UPDATE ${PREFIX}postmeta SET meta_value = replace(meta_value,'${CLEANED_DOMAIN}','${CLEANED_INPUT_DOMAIN}');"

        echo $'\n[+] All values was updated\n'
    else
        echo $'\n[!] New domain is empty. No changes made\n'
    fi

else
    echo $'\nExiting...\n'
    exit 1
fi