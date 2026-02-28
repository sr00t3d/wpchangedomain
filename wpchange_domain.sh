#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                                                                           ║
# ║   WordPress Change Domain v1.3.1                                          ║
# ║                                                                           ║
# ╠═══════════════════════════════════════════════════════════════════════════╣
# ║   Autor:   Percio Castelo                                                 ║
# ║   Contato: percio@evolya.com.br | contato@perciocastelo.com.br            ║
# ║   Web:     https://perciocastelo.com.br                                   ║
# ║                                                                           ║
# ║   Função:  Updates WP domains in the database,handles backups and         ║
# ║            detects prefixes.                                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# --- CONFIGURATION ---
VERSION='1.3.1'
UPDATE_URL='https://raw.githubusercontent.com/sr00t3d/wpchangedomain/refs/heads/main/wpchange_domain.sh'
CONFIG_FILE="wp-config.php"

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
    MSG_ERR_DOMAIN="[!] Não foi possível determinar o domínio no banco"
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

display_help() {
    cat <<-EOF
$MSG_USAGE

Options:
-n, --noversion   $MSG_OPT_VER
-s, --skip        $MSG_OPT_SKIP
EOF
}

# --- ARGUMENT CHECK ---
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    display_help
    exit 0
fi

# --- VERSION CHECK ---
if [[ " $* " == *" -n "* || " $* " == *" --noversion "* ]]; then
    echo "$MSG_SKIP_VER"
else
    if command -v curl &> /dev/null; then
        V_REMOTE=$(curl -s "$UPDATE_URL" | grep -m1 "VERSION=" | cut -d "'" -f2 | tr -d '\r')
    elif command -v wget &> /dev/null; then
        V_REMOTE=$(wget -qO- "$UPDATE_URL" | grep -m1 "VERSION=" | cut -d "'" -f2 | tr -d '\r')
    fi
    if [[ "$VERSION" != "$V_REMOTE" && -n "$V_REMOTE" ]]; then
        echo "$MSG_UPDATE_AVAIL $V_REMOTE"
        echo "$MSG_UPDATE_LINK $UPDATE_URL"
    fi
fi

echo "$MSG_START"

# --- CONFIG VALIDATION ---
if [[ -f "${CONFIG_FILE}" ]]; then
    echo "$MSG_FILE_FOUND"
else
    echo "$MSG_ERR_FILE"
    exit 1
fi

get_db_value() {
    local key="$1"
    grep -E "define\s*\(\s*['\"]$key['\"]\s*," "$CONFIG_FILE" | awk -F "['\"]" '{print $4}'
}

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

# --- MYSQL CONNECTION & DOMAIN DETECTION ---
echo "$MSG_CHECK_DOMAIN"
echo "$MSG_CONNECTING"

# Detect Table Prefix
RAW_TABLE=$(mysql -N -s -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" "${DB_NAME}" -e "SHOW TABLES LIKE '%options';" 2>/dev/null | head -n 1)
MYSQL_EXIT_CODE=$?

if [[ $MYSQL_EXIT_CODE -ne 0 ]]; then
    echo "$MSG_ERR_MYSQL"
    exit 1
fi

PREFIX="${RAW_TABLE%options}"

# Get Current Domain
CURRENT_URL=$(mysql -N -s -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" "${DB_NAME}" -e "SELECT option_value FROM ${PREFIX}options WHERE option_name = 'siteurl' LIMIT 1;" 2>/dev/null)

if [[ -z "${CURRENT_URL}" ]]; then
    echo "$MSG_ERR_DOMAIN"
    exit 1
fi

# Clean protocols for replacement logic
CLEAN_DOMAIN=$(echo "${CURRENT_URL}" | sed -e 's|^[^/]*//||' -e 's|/$||')
echo "$MSG_CUR_DOMAIN: ${CURRENT_URL} (Prefix: ${PREFIX})"

# --- BACKUP LOGIC ---
if [[ " $* " == *" -s "* || " $* " == *" --skip "* ]]; then
    echo "$MSG_SKIP_BACKUP"
else
    DUMP_FILE="backup_${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"
    echo "$MSG_DUMPING"
    mysqldump -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" "${DB_NAME}" > "${DUMP_FILE}"
    echo "$MSG_DUMP_CREATED $(pwd)/${DUMP_FILE}"
fi

# --- INPUT & CONFIRMATION ---
echo ""
read -p "$MSG_INPUT_DOMAIN" INPUT_DOMAIN
CLEAN_INPUT=$(echo "${INPUT_DOMAIN}" | sed -e 's|^[^/]*//||' -e 's|/$||')

if [[ -z "$CLEAN_INPUT" ]]; then
    echo "$MSG_NO_CHANGE"
    exit 1
fi

echo -e "\n$MSG_CONFIRM_TXT $CLEAN_DOMAIN $MSG_TO $CLEAN_INPUT"
read -p "$MSG_CONFIRM_ASK" RESPONSE
RESPONSE=$(echo "${RESPONSE}" | tr '[:upper:]' '[:lower:]')

if [[ "${RESPONSE}" != "y" ]]; then
    echo "$MSG_EXIT"
    exit 1
fi

# --- EXECUTION ---
echo -e "\n$MSG_CONTINUING"
echo -e "$MSG_CHANGING\n"

# Performs updates to the database using the detected prefix
mysql -u "${DB_USER}" -p"${DB_PASS}" -h "${DB_HOST}" "${DB_NAME}" <<EOF
UPDATE ${PREFIX}options SET option_value = REPLACE(option_value, '${CLEAN_DOMAIN}', '${CLEAN_INPUT}') WHERE option_name IN ('home', 'siteurl');
UPDATE ${PREFIX}posts SET guid = REPLACE(guid, '${CLEAN_DOMAIN}', '${CLEAN_INPUT}');
UPDATE ${PREFIX}posts SET post_content = REPLACE(post_content, '${CLEAN_DOMAIN}', '${CLEAN_INPUT}');
UPDATE ${PREFIX}postmeta SET meta_value = REPLACE(meta_value, '${CLEAN_DOMAIN}', '${CLEAN_INPUT}');
EOF

echo -e "\n$MSG_DONE\n"