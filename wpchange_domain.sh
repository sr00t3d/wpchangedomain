#!/bin/bash
################################################################################
#                                                                              #
#   PROJECT: WordPress Domain Changer                                          #
#   VERSION: 1.3.0                                                             #
#                                                                              #
#   AUTHOR:  Percio Andrade                                                    #
#   CONTACT: percio@evolya.com.br | contato@perciocastelo.com.br               #
#   WEB:     https://perciocastelo.com.br                                      #
#                                                                              #
#   INFO:                                                                      #
#   Updates WordPress domain in DB, handles backups and auto-detects creds.    #
#                                                                              #
################################################################################

# --- CONFIGURATION ---
VERSION='1.3.0'
UPDATE_URL='https://raw.githubusercontent.com/percioandrade/wpchangedomain/refs/heads/main/wpchange_domain.sh'
CONFIG_FILE="wp-config.php"
# ---------------------

# Detect System Language
SYSTEM_LANG="${LANG:0:2}"

if [[ "$SYSTEM_LANG" == "pt" ]]; then
    # Portuguese Strings
    MSG_USAGE="Uso: $0 [-s|--skip] [-n|--noversion]"
    MSG_OPT_VER="Pular verificação de versão"
    MSG_OPT_SKIP="Pular backup do banco de dados"
    MSG_SKIP_VER="[!] Pulando verificação de versão."
    MSG_UPDATE_AVAIL="[!] Uma nova atualização está disponível. Versão"
    MSG_UPDATE_LINK="[!] Por favor, atualize em"
    MSG_START="[!] Iniciando..."
    MSG_FILE_FOUND="[+] Arquivo wp-config.php encontrado."
    MSG_ERR_FILE="[!] Arquivo wp-config.php não encontrado, saindo..."
    MSG_ERR_VALUES="[!] Valores vazios no config, saindo..."
    MSG_DB_FOUND="[+] Credenciais do banco encontradas:"
    MSG_CHECK_DOMAIN="[!] Verificando o domínio atual..."
    MSG_CONNECTING="[!] Tentando estabelecer conexão, aguarde..."
    MSG_ERR_DOMAIN="[!] Não foi possível determinar o domínio do banco"
    MSG_CUR_DOMAIN="[+] O domínio atual no banco"
    MSG_ERR_MYSQL="[!] Falha na conexão MySQL. Verifique as credenciais."
    MSG_SKIP_BACKUP="[!] Opção --skip usada. Não geraremos backup."
    MSG_DUMPING="[!] Gerando dump do banco, aguarde..."
    MSG_DUMP_CREATED="[+] Dump criado em:"
    MSG_INPUT_DOMAIN="Digite o NOVO domínio (ex: domain.com.br): "
    MSG_CONFIRM_TXT="[!] Este script vai alterar"
    MSG_TO="para"
    MSG_CONFIRM_ASK="Deseja continuar? (y/n): "
    MSG_INVALID="Resposta inválida."
    MSG_CONTINUING="[!] Continuando..."
    MSG_CHANGING="[+] Alterando domínio no banco de dados..."
    MSG_DONE="[+] Todos os valores foram atualizados com sucesso."
    MSG_NO_CHANGE="[!] Novo domínio vazio. Nenhuma alteração feita."
    MSG_EXIT="Saindo..."
else
    # English Strings (Default)
    MSG_USAGE="Usage: $0 [-s|--skip] [-n|--noversion]"
    MSG_OPT_VER="Skip version check"
    MSG_OPT_SKIP="Skip database dump creation"
    MSG_SKIP_VER="[!] Skipping version check."
    MSG_UPDATE_AVAIL="[!] A new update is available. Version"
    MSG_UPDATE_LINK="[!] Please update at"
    MSG_START="[!] Starting..."
    MSG_FILE_FOUND="[+] File wp-config.php was found."
    MSG_ERR_FILE="[!] File wp-config.php not found, exiting..."
    MSG_ERR_VALUES="[!] Empty values in config, exiting..."
    MSG_DB_FOUND="[+] Database values found:"
    MSG_CHECK_DOMAIN="[!] Checking the current domain..."
    MSG_CONNECTING="[!] Trying to establish a connection, please wait..."
    MSG_ERR_DOMAIN="[!] Unable to determine the database domain for"
    MSG_CUR_DOMAIN="[+] The actual database domain for"
    MSG_ERR_MYSQL="[!] Connection to MySQL failed. Check credentials."
    MSG_SKIP_BACKUP="[!] Skip option used. No backup will be generated."
    MSG_DUMPING="[!] Dumping database, please wait..."
    MSG_DUMP_CREATED="[+] Database dump created at:"
    MSG_INPUT_DOMAIN="Insert the NEW domain (e.g., domain.com.br): "
    MSG_CONFIRM_TXT="[!] This script will change"
    MSG_TO="to"
    MSG_CONFIRM_ASK="Do you want to continue? (y/n): "
    MSG_INVALID="Invalid response."
    MSG_CONTINUING="[!] Continuing..."
    MSG_CHANGING="[+] Changing database domain..."
    MSG_DONE="[+] All values were updated successfully."
    MSG_NO_CHANGE="[!] New domain is empty. No changes made."
    MSG_EXIT="Exiting..."
fi

# Function to display help
display_help() {
    cat <<-EOF
    $MSG_USAGE

    Options:
        -n, --noversion    $MSG_OPT_VER
        -s, --skip         $MSG_OPT_SKIP
EOF
}

# Check for help
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    display_help
    exit 0
fi

# Version Check
# Checks for flags -n or --noversion in all arguments ($*)
if [[ " $* " == *" -n "* || " $* " == *" --noversion "* ]]; then
    echo "$MSG_SKIP_VER"
else
    # Use curl or wget (more robust than GET)
    if command -v curl &> /dev/null; then
        V_REMOTE=$(curl -s "$UPDATE_URL" | grep -m1 "VERSION=" | cut -d "'" -f2)
    elif command -v wget &> /dev/null; then
        V_REMOTE=$(wget -qO- "$UPDATE_URL" | grep -m1 "VERSION=" | cut -d "'" -f2)
    else
        V_REMOTE="$VERSION" # Skip check if no tools
    fi

    # Clean version string (remove possible extra chars)
    V_REMOTE=$(echo "$V_REMOTE" | tr -d '\r')

    if [[ "$VERSION" != "$V_REMOTE" && -n "$V_REMOTE" ]]; then
        echo "$MSG_UPDATE_AVAIL $V_REMOTE"
        echo "$MSG_UPDATE_LINK $UPDATE_URL"
    fi
fi

echo "$MSG_START"

# Check wp-config
if [[ -f "${CONFIG_FILE}" ]]; then
    echo "$MSG_FILE_FOUND"
else
    echo "$MSG_ERR_FILE"
    exit 1
fi

# Function to extract values from config
get_db_value() {
    local key="$1"
    # Improved grep to avoid comments and handle spacing
    grep -E "define\s*\(\s*['\"]$key['\"]\s*," "$CONFIG_FILE" | awk -F "['\"]" '{print $4}'
}

# Extract credentials
DB_NAME=$(get_db_value "DB_NAME")
DB_USER=$(get_db_value "DB_USER")
DB_PASS=$(get_db_value "DB_PASSWORD")
DB_HOST=$(get_db_value "DB_HOST")

if [[ -z "${DB_NAME}" || -z "${DB_USER}" || -z "${DB_PASS}" || -z "${DB_HOST}" ]]; then
    echo "$MSG_ERR_VALUES"
    exit 1
fi

echo "$MSG_DB_FOUND"
echo "------------------------"
echo "| Database: ${DB_NAME}"
echo "| User:     ${DB_USER}"
echo "| Host:     ${DB_HOST}"
echo "------------------------"

echo "$MSG_CHECK_DOMAIN"
echo "$MSG_CONNECTING"

# Detect Table Prefix
# Logic: Find a table ending in _options to guess the prefix
PREFIX=$(mysql -N -s -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" "${DB_NAME}" -e "SELECT table_name FROM information_schema.tables WHERE table_schema = '${DB_NAME}' AND table_name LIKE '%options' LIMIT 1;" 2>/dev/null)
MYSQL_EXIT_CODE=$?

if [[ $MYSQL_EXIT_CODE -ne 0 ]]; then
    echo "$MSG_ERR_MYSQL"
    exit 1
fi

# Isolate prefix (remove 'options' from the end)
PREFIX="${PREFIX%options}" 

# Get Current Domain
CURRENT_DOMAIN=$(mysql -N -s -u "${DB_USER}" -p"${DB_PASS}" -h
